local addonName, GreatVaultOddsNS = ...

local classSpecIDs = GreatVaultOddsNS.ClassSpecIDs
local Utils = GreatVaultOddsNS.Utils
local Tooltip = GreatVaultOddsNS.Tooltip

-- https://wago.tools/db2/MythicPlusSeason?sort%5BMilestoneSeason%5D=desc
local manualMilestoneSeasonIDOverride = false -- 105

local debugLogging = false

local defaultAddonOptions = {
    devMode = false,
}

local function addMissingDefaults(userOptions, defaultOptions) -- Validates that all empty user options are populated with default values
    for option, defaultValue in pairs(defaultOptions) do
        local userValue = userOptions[option]

        if type(defaultValue) == "table" then
            if type(userValue) ~= "table" then
                userOptions[option] = CopyTable(defaultValue) -- Prevents accidental editing of the default addon options table
            else
                addMissingDefaults(userValue, defaultValue)
            end
        elseif userValue == nil then
            userOptions[option] = defaultValue
        end
    end
end

local lootDBInitializationFailed = false
local lootDBValidationFailed = false
local function validateLootDB(lootDB, activeMilestoneSeasonID)
    local hasValidLootDB = lootDB and lootDB.eligibleItems and lootDB.eligibleItemCount

    if not hasValidLootDB and not lootDBValidationFailed then
        -- prints error on the first failure only
        -- redundant because function only gets called once
        lootDBValidationFailed = true
        print("GreatVaultOdds has no valid loot DB for milestone season ID:", activeMilestoneSeasonID)
    end

    return hasValidLootDB
end

local function trySetActiveLootDB(self)
    local _, milestoneSeasonID = C_MythicPlus.GetCurrentSeasonValues()
    milestoneSeasonID = manualMilestoneSeasonIDOverride or milestoneSeasonID
    if not milestoneSeasonID or milestoneSeasonID == -1 then
        C_MythicPlus.RequestMapInfo()
        return
    end

    self:UnregisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
    local activeMilestoneSeasonID = milestoneSeasonID
    local activeLootDB = GreatVaultOddsNS.LootDBByMilestoneSeasonID and GreatVaultOddsNS.LootDBByMilestoneSeasonID[activeMilestoneSeasonID]

    if not activeLootDB and not lootDBInitializationFailed then
        -- prints error on the first failure only
        -- redundant because function only gets this far once
        lootDBInitializationFailed = true
        print("GreatVaultOdds has no loot DB for milestone season ID:", activeMilestoneSeasonID)
        return
    end

    if validateLootDB(activeLootDB, activeMilestoneSeasonID) then -- inverse? But why?
        Tooltip.SetActiveLootDB(activeLootDB)
        Tooltip.RegisterTooltipHandler()
    end
end

local function OnEvent(self, event, loadedAddonName)
    if event == "ADDON_LOADED" and loadedAddonName == addonName then
        GreatVaultOddsAddonOptions = GreatVaultOddsAddonOptions or {}
        GreatVaultOddsDB = GreatVaultOddsDB or {}
        GreatVaultOddsDB.eligibleItems = GreatVaultOddsDB.eligibleItems or {}
        GreatVaultOddsDB.eligibleItemCount = GreatVaultOddsDB.eligibleItemCount or {}
        addMissingDefaults(GreatVaultOddsAddonOptions, defaultAddonOptions)
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGIN" then
        trySetActiveLootDB(self)

        if GreatVaultOddsAddonOptions.devMode or debugLogging then
            C_Timer.After(5, function()
                print("GreatVaultOdds devMode:", GreatVaultOddsAddonOptions.devMode, "debugLogging:", debugLogging)
            end)
        end
        self:UnregisterEvent("PLAYER_LOGIN")
    elseif event == "CHALLENGE_MODE_MAPS_UPDATE" then
        trySetActiveLootDB(self)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
frame:SetScript("OnEvent", OnEvent)

local function activeSeasonIterator()
    local index = 0
    return function()
        local instanceID, instanceName, dungeonAreaMapID, isWorldBoss
        repeat
            index = index + 1
            instanceID = EJ_GetInstanceByIndex(index, false) -- Dungeons only
            if not instanceID then return end

            EJ_SelectInstance(instanceID)
            instanceName, _, _, _, _, _, dungeonAreaMapID = EJ_GetInstanceInfo(instanceID) -- Will return 0 for dungeonAreaMapID if SelectInstance() is not called for an arbitrary instanceID, see: https://warcraft.wiki.gg/wiki/API_EJ_GetEncounterInfo#Example
            -- Despite what https://warcraft.wiki.gg/wiki/API_EJ_GetInstanceInfo says, dungeons **do** return a dungeonAreaMapID.
            isWorldBoss = dungeonAreaMapID == 0 -- Not used when iterating through only dungeons. Will prevent iterator returning a World Boss ID when iterating through raids, it will continue running until a Raid ID is provided or there are no more valid instance IDs.
        until not isWorldBoss

        return instanceID, instanceName
    end
end

local function specificSeasonIterator(milestoneSeasonID)
    local instanceIDs = GreatVaultOddsNS.InstanceIDsByMilestoneSeasonID[milestoneSeasonID]
    local index = 0

    return function()
        index = index + 1
        local instanceID = instanceIDs and instanceIDs[index]
        if not instanceID then return end

        EJ_SelectInstance(instanceID)
        local instanceName = EJ_GetInstanceInfo(instanceID)

        return instanceID, instanceName
    end
end

-- milestoneSeasonID is only used for non-active seasons, a nil value defaults to the current tier EJ dungeon iteration.
local function instanceIterator(milestoneSeasonID)
    if milestoneSeasonID then return specificSeasonIterator(milestoneSeasonID) end

    return activeSeasonIterator()
end

local function disableEJ()
    if EncounterJournal then
        EncounterJournal:UnregisterEvent("EJ_LOOT_DATA_RECIEVED")
        EncounterJournal:UnregisterEvent("EJ_DIFFICULTY_UPDATE")
        EncounterJournal:UnregisterEvent("UNIT_PORTRAIT_UPDATE")
        EncounterJournal:UnregisterEvent("PORTRAITS_UPDATED")
        EncounterJournal:UnregisterEvent("SEARCH_DB_LOADED")
        EncounterJournal:UnregisterEvent("UI_MODEL_SCENE_INFO_UPDATED")
    end
end

local function enableEJ()
    if EncounterJournal then
        EncounterJournal:RegisterEvent("EJ_LOOT_DATA_RECIEVED")
        EncounterJournal:RegisterEvent("EJ_DIFFICULTY_UPDATE")
        EncounterJournal:RegisterEvent("UNIT_PORTRAIT_UPDATE")
        EncounterJournal:RegisterEvent("PORTRAITS_UPDATED")
        EncounterJournal:RegisterEvent("SEARCH_DB_LOADED")
        EncounterJournal:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED")
    end
end

local equippableCache = {}
local function generateDBForAllSpecs(milestoneSeasonID, alreadyRan)
    EJ_SelectTier(EJ_GetNumTiers())
    disableEJ()

    local eligibleItemsByID = GreatVaultOddsDB.eligibleItems
    local eligibleItemCountsByClass = GreatVaultOddsDB.eligibleItemCount

    for className, classData in pairs(classSpecIDs) do -- classData = table of specTable and classID
        eligibleItemCountsByClass[className] = eligibleItemCountsByClass[className] or {}
        local classCounts = eligibleItemCountsByClass[className]

        for specName, specTable in pairs(classData.specData) do -- specTable = table of specID and iconID
            EJ_SetLootFilter(classData.classID, specTable.specID)

            classCounts[specName] = classCounts[specName] or {}
            local specCounts = classCounts[specName]
            specCounts.seasonTotalItems = specCounts.seasonTotalItems or 0

            specCounts.dungeonTotals = specCounts.dungeonTotals or {}
            local dungeonTotalsByInstance = specCounts.dungeonTotals

            for instanceID, instanceName in instanceIterator(milestoneSeasonID) do
                EJ_SelectInstance(instanceID) -- Probably don't need this since I already SelectInstance inside the instanceIterator,should generate a DB without it and compare to known good DB.
                EJ_SetDifficulty(DifficultyUtil.ID.DungeonMythic) -- https://github.com/Gethe/wow-ui-source/blob/0b949009d9558869da5c53ac61c23f2d711b1f6f/Interface/AddOns/Blizzard_FrameXMLUtil/DifficultyUtil.lua#L1 -- Probably only need to call once at the start of func, do the same as above and compare to known good DB.
                -- EJ_SetDifficulty(DifficultyUtil.ID.DungeonChallenge)

                dungeonTotalsByInstance[instanceID] = dungeonTotalsByInstance[instanceID] or {}
                local dungeonCounts = dungeonTotalsByInstance[instanceID]
                dungeonCounts.totalItems = dungeonCounts.totalItems or 0

                dungeonCounts.bossTotals = dungeonCounts.bossTotals or {}
                local bossTotalsByEncounter = dungeonCounts.bossTotals

                C_EncounterJournal.SetSlotFilter(Enum.ItemSlotFilterType.NoFilter) -- Maybe only need to call once at the start of func. Do the same test as above with SelectInstance, I surely do not need this.
                for lootIndex = 1, EJ_GetNumLoot() do
                    local itemInfo = C_EncounterJournal.GetLootInfoByIndex(lootIndex)
                    local itemID = itemInfo and itemInfo.itemID
                    local sourceEncounterID = itemInfo and itemInfo.encounterID or "Unknown Source" -- EncounterID for which the item drops. We'll need to add the itemID to dev tool if unknown source because table just tracks count.
                    local lootDataCached = itemID and C_Item.IsItemDataCachedByID(itemID) -- itemInfo.name ~= nil produces similar results, the name field is nil when the item is not cached.
                    if lootDataCached then -- rename variable, was more accurate when testing cached loot but now care about if loot data is available. Cached by us as equippable vs data cached by the game.
                        -- TODO: distinguish between "cache" types
                        local known = equippableCache[itemID]
                        if known == nil then -- itemID equip status not yet cached. If it's false, we know the item is not equippable so don't need to cache it, but also won't use it.
                            known = C_Item.IsEquippableItem(itemID) -- This only works because loot data is cached. Use a ContinueOnItemLoad implementation if not cached is what we care about.
                            equippableCache[itemID] = known
                        end

                        if known then -- item equippable
                            eligibleItemsByID[itemID] = eligibleItemsByID[itemID] or {}
                            local itemEntry = eligibleItemsByID[itemID]

                            itemEntry[className] = itemEntry[className] or {}
                            local eligibleSpecs = itemEntry[className]

                            if not eligibleSpecs[specName] then
                                eligibleSpecs[specName] = true  -- TODO: For item slot implementation, get corresponding item slot and increment that item slot if the item did not previously exist for this spec, and increment the total slots too
                                itemEntry.sources = itemEntry.sources or {}
                                itemEntry.sources.instanceID = instanceID
                                itemEntry.sources.encounterID = sourceEncounterID

                                specCounts.seasonTotalItems = specCounts.seasonTotalItems + 1
                                dungeonCounts.totalItems = dungeonCounts.totalItems + 1

                                bossTotalsByEncounter[sourceEncounterID] = bossTotalsByEncounter[sourceEncounterID] or 0
                                bossTotalsByEncounter[sourceEncounterID] = bossTotalsByEncounter[sourceEncounterID] + 1
                            end
                        end
                    end
                end
            end
        end
    end
    enableEJ()
    if not alreadyRan then
        C_Timer.After(0.5, function() generateDBForAllSpecs(milestoneSeasonID, true) end) -- Run again after a delay to capture any loot that became cached after initial query
    end
end

local function showHelp() -- TODO: Make show help have option to display help for specific function too, so can /gvodds help db and get info for db specifically with more detail
    print("|cFFE6CC99Great Vault Odds|r will display the chance of each spec receiving an item in the Great Vault on the corresponding item's tooltip.")
    print("|cFFE6CC99Great Vault Odds|r |cFF66BBFFHelp Menu:|r") -- TODO: Make a prefix print and colour function
    print("|cFFE6CC99/gvodds|r", "|cFF66BBFFreset|r", "- Resets all options to their defaults")
    print("|cFFE6CC99/gvodds|r", "|cFF66BBFFdev|r", "- Toggles dev mode")
    print("|cFFE6CC99/gvodds|r", "|cFF66BBFFhelp|r", "- Displays this menu")
    if GreatVaultOddsAddonOptions.devMode then
        print("|cFFE6CC99/gvodds|r", "|cFF66BBFFdb|r", "|cFF66BBFFgen|r", "- Generates a DB in your saved variables")
        print("|cFFE6CC99/gvodds|r", "|cFF66BBFFdb|r", "|cFF66BBFFreset|r", "- Deletes the DB in your saved variables")
    end
    print("----------------------------------------")
end

local validCommands = { -- slashCommandMap or commandConfig?
    help = {},
    dev = {},
    reset = {},
    db = {
        devModeRequired = true,
        hasSubCommand = {
            gen = {},
            reset = {}
        },
    },
}

SLASH_GREATVAULTODDS1 = "/gvodds" -- add /greatvaultodds alias
function SlashCmdList.GREATVAULTODDS(msg, editBox)
    msg = msg and msg:lower():gsub("^%s*(.-)%s*$", "%1") or "" -- Trims leading and trailing whitespace, unnecessary

    local args = {}
    for word in msg:gmatch("%S+") do -- non whitespace ("args")
        table.insert(args, word)
    end

    local cmd, subCmd = args[1], args[2]
    local subCmdArgs = {select(3, unpack(args))}

    if cmd == "dev" then -- Allows "dev" commands to be chained in one command as opposed to requiring devMode toggled on and then the intended command to be inputted again.
        GreatVaultOddsAddonOptions.devMode = not GreatVaultOddsAddonOptions.devMode -- toggle
        print("Devmode active:", GreatVaultOddsAddonOptions.devMode)
        if not subCmd then return end -- Quit handler if no further command is chained

        cmd, subCmd = subCmd, subCmdArgs[1] -- Shift args for chained command
        subCmdArgs = {select(2, unpack(subCmdArgs))}
    end

    local validCommand = validCommands[cmd]
    local hasSubCmd = validCommand and validCommand.hasSubCommand
    local validSubCmd = hasSubCmd and hasSubCmd[subCmd]
    -- local expectsArgs = validSubCmd and validSubCmd.args
    -- local validArgs = expectsArgs and expectsArgs[arg1]

    local devModeActive = GreatVaultOddsAddonOptions.devMode
    local devModeRequired = validCommand and validCommand.devModeRequired
    local missingSubCmd = hasSubCmd and not subCmd
    local invalidSubCmd = hasSubCmd and subCmd and not validSubCmd
    -- local missingArgs = expectsArgs and not arg1
    -- local invalidArgs = expectsArgs and arg1 and not validArgs OR why not invalidArgs = not validArgs?

    if not cmd then
        print("No command provided - displaying /gvodds help")
        showHelp()
    elseif not validCommand then
        print("Unrecognised command \""..cmd.."\" - displaying /gvodds help")
        showHelp()
    elseif devModeRequired and not devModeActive then -- Command entered requires devMode but user is not in devMode, irregardless of subcommand validity
        print("The command \""..cmd.."\" requires dev mode to use. Use /gvodds dev to toggle")
    elseif missingSubCmd and not validCommand.hasSubCommand.default then -- Subcommand required but not provided
        print("Missing args for command \""..cmd.."\" - displaying /gvodds help")
        showHelp()
    elseif invalidSubCmd then -- Subcommand provided is not valid for given command
        print("Invalid arg \""..subCmd.."\" for command \""..cmd.."\" - displaying /gvodds help")
        showHelp()
    else -- Command is valid and can proceed
        if cmd == "help" then
            showHelp()
        elseif cmd == "reset" then
            print("Resetting |cFFE6CC99Great Vault Odds|r options to defaults!")
            GreatVaultOddsAddonOptions = CopyTable(defaultAddonOptions)
        elseif devModeActive then -- Dev mode required for these commands, unnecessary line though because of prior verification/guarding
            if cmd == "db" then
                if subCmd == "gen" then
                    -- Optionally generate a DB for a specific season rather than the current tier, based on if milestoneSeasonID is passed as an arg.
                    local inputMilestoneSeasonID = subCmdArgs[1]

                    if not inputMilestoneSeasonID then generateDBForAllSpecs() return end

                    local requestedMilestoneSeasonID = tonumber(inputMilestoneSeasonID)
                    if not requestedMilestoneSeasonID then print("Invalid arg\""..inputMilestoneSeasonID.."\"") return end

                    C_MythicPlus.RequestMapInfo() -- Required to be called once per session to load functions
                    -- https://warcraft.wiki.gg/wiki/API_C_MythicPlus.RequestMapInfo
                    local _, currentMilestoneSeasonID = C_MythicPlus.GetCurrentSeasonValues()

                    if requestedMilestoneSeasonID == currentMilestoneSeasonID then generateDBForAllSpecs() return end

                    if not GreatVaultOddsNS.InstanceIDsByMilestoneSeasonID[requestedMilestoneSeasonID] then
                        print("Milestone Season ID:", inputMilestoneSeasonID, "not configured!")
                        return
                    end

                    generateDBForAllSpecs(requestedMilestoneSeasonID)
                elseif subCmd == "reset" then
                    print("Deleting |cFFE6CC99Great Vault Odds|r SV DB!")
                    GreatVaultOddsDB = {}
                    GreatVaultOddsDB.eligibleItems = {} -- have to re-init the sub-tables
                    GreatVaultOddsDB.eligibleItemCount = {}
                end
            end
        end
    end
end

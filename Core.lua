local addonName, GreatVaultOddsNS = ...
local seasonLootDB = GreatVaultOddsNS.DB
local classSpecIDs = GreatVaultOddsNS.ClassSpecIDs
local classNameByID = GreatVaultOddsNS.ClassNameByID

local classColors = RAID_CLASS_COLORS
local fallbackColor = CreateColor(1.000, 0.824, 0.000) or {r = 1, g = 0.824, b = 0}
local normalFontColor = NORMAL_FONT_COLOR or fallbackColor

local debugLogging = false

local defaultAddonOptions = {
    devMode = false,
}

local function addToDevTool(data, name)
    if not DevTool then return end -- or (not devMode and not debugLogging), can make a separate loggingEnabled function if wanna handle both

    if data ~= nil then -- Data could potentially be a meaningful false, I assume that there is no such thing as a meaningful nil here?
        DevTool:AddData(data, name)
    else
        DevTool:AddData(tostring(data), name)
    end
end

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

local function getClassColorTable(className) -- Accepts classID or classFile and returns respective Class Color object
    if type(className) == "number" then -- className is ID, not classFile
        className = classNameByID[className]
    end

    return classColors[className]
end

local function getTooltipColorForClass(className) -- Accepts classID or classFile and returns respective Class Color object or fallbackColor object/table if missing
    return getClassColorTable(className) or normalFontColor
end

local hasValidLootDB = false
local function isLootDBValid()
    return seasonLootDB and seasonLootDB.eligibleItems and seasonLootDB.eligibleItemCount
end

local function OnEvent(self, event, loadedAddonName)
    if event == "ADDON_LOADED" and loadedAddonName == addonName then
        GreatVaultOddsAddonOptions = GreatVaultOddsAddonOptions or {}
        GreatVaultOddsDB = GreatVaultOddsDB or {}
        GreatVaultOddsDB.eligibleItems = GreatVaultOddsDB.eligibleItems or {}
        GreatVaultOddsDB.eligibleItemCount = GreatVaultOddsDB.eligibleItemCount or {}
        addMissingDefaults(GreatVaultOddsAddonOptions, defaultAddonOptions)
        self:UnregisterEvent("ADDON_LOADED")

        hasValidLootDB = isLootDBValid()
        if not hasValidLootDB then
            C_Timer.After(5, function()
                print("GreatVaultOdds loot database in Interface/AddOns/GreatVaultOdds/Data/SeasonLootDB.lua is missing or corrupted")
            end)
        end
    elseif event == "PLAYER_LOGIN" then
        if GreatVaultOddsAddonOptions.devMode or debugLogging then
            C_Timer.After(5, function()
                print("GreatVaultOdds devMode:", GreatVaultOddsAddonOptions.devMode, "debugLogging:", debugLogging)
            end)
        end
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", OnEvent)

local function instanceIterator()
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
local function generateDBForAllSpecs(alreadyRan)
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

            for instanceID, instanceName in instanceIterator() do
                EJ_SelectInstance(instanceID) -- Probably don't need this since I already SelectInstance inside the instanceIterator,should generate a DB without it and compare to known good DB.
                EJ_SetDifficulty(DifficultyUtil.ID.DungeonChallenge) -- https://github.com/Gethe/wow-ui-source/blob/0b949009d9558869da5c53ac61c23f2d711b1f6f/Interface/AddOns/Blizzard_FrameXMLUtil/DifficultyUtil.lua#L1 -- Probably only need to call once at the start of func, do the same as above and compare to known good DB.

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
        C_Timer.After(0.5, function() generateDBForAllSpecs(true) end) -- Run again after a delay to capture any loot that became cached after initial query
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

    local cmd, subCmd, arg1 = args[1], args[2], args[3]

    if cmd == "dev" then -- Allows "dev" commands to be chained in one command as opposed to requiring devMode toggled on and then the intended command to be inputted again.
        GreatVaultOddsAddonOptions.devMode = not GreatVaultOddsAddonOptions.devMode -- toggle
        print("Devmode active:", GreatVaultOddsAddonOptions.devMode)
        if not subCmd then return end -- Quit handler if no further command is chained
        cmd, subCmd = subCmd, arg1 -- Shift args for chained command
    end

    local validCommand = validCommands[cmd]
    local hasSubCmd = validCommand and validCommand.hasSubCommand
    local validSubCmd = hasSubCmd and validCommand.hasSubCommand[subCmd]

    local devModeActive = GreatVaultOddsAddonOptions.devMode
    local devModeRequired = validCommand and validCommand.devModeRequired
    local missingSubCmd = hasSubCmd and not subCmd
    local invalidSubCmd = hasSubCmd and subCmd and not validSubCmd

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
                    generateDBForAllSpecs()
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

local playerSpecNames
local playerClassName
local hasSortedPlayerSpecs = false

local tooltipStyle = { -- Includes future tooltip format styles
    dropRateSeparator = {"||", " || ", "  || ", " / ", "  / ", ", "},
    lootSourceSeparator = {"||", " || ", "  || ", " / ", "  / ", ", "},
    specLabel = ": "
}
local ADDON_TOOLTIP_HEADER = "GreatVaultOdds"
local LOOT_SOURCE_TOOLTIP_HEADER = "Vault"..tooltipStyle.lootSourceSeparator[2].."M+"..tooltipStyle.lootSourceSeparator[2].."Boss"

local function ensurePlayerSpecsSorted()
    if hasSortedPlayerSpecs then return end

    playerSpecNames = {}
    playerClassName, _ = UnitClassBase("player")
    for specName in pairs(classSpecIDs[playerClassName].specData) do
        table.insert(playerSpecNames, specName)
    end
    table.sort(playerSpecNames)
    hasSortedPlayerSpecs = true
end

local function buildSpecOddsLine(className, specName, instanceID, encounterID)
    local specCounts = seasonLootDB.eligibleItemCount[className] and seasonLootDB.eligibleItemCount[className][specName]
    local seasonTotal = specCounts and specCounts.seasonTotalItems

    local dungeonCounts = specCounts and specCounts.dungeonTotals and specCounts.dungeonTotals[instanceID]
    local dungeonTotal = dungeonCounts and dungeonCounts.totalItems

    local bossTotalsByEncounter = dungeonCounts and dungeonCounts.bossTotals
    local bossTotal = bossTotalsByEncounter and bossTotalsByEncounter[encounterID]

    local missingLootData = not (seasonTotal and dungeonTotal and bossTotal)
    if missingLootData then return end

    local iconID = classSpecIDs[className].specData[specName].iconID
    local iconText = "|T"..iconID..":0|t"
    return iconText.." "..specName..tooltipStyle.specLabel.."1/"..seasonTotal..tooltipStyle.dropRateSeparator[2].."1/"..dungeonTotal..tooltipStyle.dropRateSeparator[2].."1/"..bossTotal
end

local function appendPlayerClassTooltipLines(tooltip, itemID, instanceID, encounterID)
    ensurePlayerSpecsSorted()

    local tooltipColor = getTooltipColorForClass(playerClassName)
    local playerEligibleSpecs = seasonLootDB.eligibleItems[itemID][playerClassName]
    if not playerEligibleSpecs then
        tooltip:AddLine("Item is not loot eligible for your class!", tooltipColor.r, tooltipColor.g, tooltipColor.b)
        return
    end

    for _, specName in ipairs(playerSpecNames) do
        if playerEligibleSpecs[specName] then
            local specTooltipLine = buildSpecOddsLine(playerClassName, specName, instanceID, encounterID)
            if specTooltipLine then
                tooltip:AddLine(specTooltipLine, tooltipColor.r, tooltipColor.g, tooltipColor.b)
            end
        end
    end
end

local function tooltipHandler(tooltip, data) -- surely I don't have to nilcheck tooltip and data?
    if not data then
        print("Error, data does not exist - GreatVaultOdds")
        addToDevTool(data, "GreatVaultOdds - plain data for "..tooltip:GetName()) -- Might get a nil error here if tooltip also doesn't exist? Wanted to use CopyTable(data) but if data is nil will error.
    else
        if not hasValidLootDB then return end
        local itemID = data.id -- https://warcraft.wiki.gg/wiki/Struct_TooltipData
        if seasonLootDB.eligibleItems[itemID] then -- itemID exists in current season dungeons
            local itemEntry = seasonLootDB.eligibleItems[itemID]
            local sourceInfo = itemEntry.sources
            if not sourceInfo then return end
            local instanceID = sourceInfo.instanceID
            local encounterID = sourceInfo.encounterID
            if not instanceID  or not encounterID then return end -- Maybe we still want to display the tooltip anyway, for the totals? If not, maybe don't need separate early returns?
            local devModeActive = GreatVaultOddsAddonOptions.devMode
            tooltip:AddLine(" ") -- Add a gap between the last tooltip line and our tooltip
            tooltip:AddLine(ADDON_TOOLTIP_HEADER..": "..LOOT_SOURCE_TOOLTIP_HEADER)

            if devModeActive then -- Dirty hack to see all specs in devMode
                local classTooltipsByID = {}
                for className, classData in pairs(classSpecIDs) do
                    if seasonLootDB.eligibleItems[itemID][className] then
                        local eligibleSpecs = {}
                        for specName in pairs(classData.specData) do
                            if seasonLootDB.eligibleItems[itemID][className][specName] then
                                table.insert(eligibleSpecs, specName)
                            end
                        end
                        table.sort(eligibleSpecs)
                        local finalTooltip = ""
                        for _, sortedSpecName in ipairs(eligibleSpecs) do
                            local specTooltipLine = buildSpecOddsLine(className, sortedSpecName, instanceID, encounterID)
                            if specTooltipLine then
                                finalTooltip = finalTooltip..specTooltipLine.." "
                            end
                        end
                        classTooltipsByID[classData.classID] = finalTooltip -- Could check if ~="", can store an empty tooltip if finalTooltip is still the empty string, though this should never occur unless a class isn't valid. But if it isn't valid it won't be here, and if it is valid then it will have a corresponding spec and tooltip unless db is malformed/corrupted, but I notice that before shipping.
                    end
                end
                local eligibleClasses = {}
                for classID in pairs(classTooltipsByID) do
                    table.insert(eligibleClasses, classID)
                end
                table.sort(eligibleClasses)
                for _, classID in ipairs(eligibleClasses) do
                    local tooltipColor = getTooltipColorForClass(classID)
                    tooltip:AddLine(classTooltipsByID[classID], tooltipColor.r, tooltipColor.g, tooltipColor.b) -- will add custom text wrapping as a config option
                end
            else -- The normal path for the end-user tooltip, sorry it's here at the bottom. I will invert the if block I promise.
                appendPlayerClassTooltipLines(tooltip, itemID, instanceID, encounterID)
            end
        end
    end
end

if TooltipDataProcessor then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, tooltipHandler)
end

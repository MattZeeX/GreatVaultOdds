local addonName, GreatVaultOddsNS = ...
local seasonLootDB = GreatVaultOddsNS.DB -- consider using the namespace table instead of a local var (no)
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

    if data ~= nil then -- I assume that there is no such thing as a meaningful nil here? Remember, false is meaningful (look up terminology)
        DevTool:AddData(data, name)
    else
        DevTool:AddData(tostring(data), name) -- I assume there's no nil value that can't be coerced/cast as a string
    end
end

local function addMissingDefaults(userOptions, defaultOptions) -- Validates that all empty user options are populated with default values
    for option, defaultValue in pairs(defaultOptions) do
        local userValue = userOptions[option]

        if type(defaultValue) == "table" then
            if type(userValue) ~= "table" then
                userOptions[option] = CopyTable(defaultValue) -- Prevents accidental editing of the default addon options table, unlikely to matter
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

local function getTooltipColorForClass(className) -- Accepts classID or classFile and returns respective Class Color or fallbackColor if missing
    return getClassColorTable(className) or normalFontColor
end

local function OnEvent(self, event, loadedAddonName) --EventHandler? camelCase?
    if event == "ADDON_LOADED" and loadedAddonName == addonName then
        GreatVaultOddsAddonOptions = GreatVaultOddsAddonOptions or {}
        GreatVaultOddsDB = GreatVaultOddsDB or {} -- do I need to add a flag here and ensure my addon is loaded before I use this saved variable later? could add a helper function that is run any time we want to access an SV, or xpcall?
        GreatVaultOddsDB.eligibleItems = GreatVaultOddsDB.eligibleItems or {}
        GreatVaultOddsDB.eligibleItemCount = GreatVaultOddsDB.eligibleItemCount or {}
        addMissingDefaults(GreatVaultOddsAddonOptions, defaultAddonOptions)
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGIN" then
        if GreatVaultOddsAddonOptions.devMode or debugLogging then
            C_Timer.After(5, function()
                print("devMode:", GreatVaultOddsAddonOptions.devMode, "debugLogging:", debugLogging, "dingus!")
            end)
        end
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("EJ_LOOT_DATA_RECIEVED")
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
local function generateDBForAllSpecs(alreadyRan, profiling, doneCallback) -- profiling and doneCallback are remnants from DB profiling
    EJ_SelectTier(EJ_GetNumTiers())
    disableEJ()

    for className, classData in pairs(classSpecIDs) do -- className = className, classData = table of specTable and classID 13
        for specName, specTable in pairs(classData.specData) do -- specName = specName, specTable = table of specID and iconID 3
            EJ_SetLootFilter(classData.classID, specTable.specID)
            -- DB already init in ADDON_LOADED -- GreatVaultOddsDB = GreatVaultOddsDB or {}
            -- Eligible Items init in ADDON_LOADED -- GreatVaultOddsDB.eligibleItems = GreatVaultOddsDB.eligibleItems or {}
            -- Num Eligible Items init in ADDON_LOADED -- GreatVaultOddsDB.eligibleItemCount = GreatVaultOddsDB.eligibleItemCount or {}
            GreatVaultOddsDB.eligibleItemCount[className] = GreatVaultOddsDB.eligibleItemCount[className] or {}
            GreatVaultOddsDB.eligibleItemCount[className][specName] = GreatVaultOddsDB.eligibleItemCount[className][specName] or {}
            GreatVaultOddsDB.eligibleItemCount[className][specName].allSlots = GreatVaultOddsDB.eligibleItemCount[className][specName].allSlots or 0
            for instanceID, instanceName in instanceIterator() do
                EJ_SelectInstance(instanceID) -- Do I need this since I already SelectInstance inside the instanceIterator? Should generate a DB without it and compare to known good DB.
                EJ_SetDifficulty(DifficultyUtil.ID.DungeonChallenge) -- https://github.com/Gethe/wow-ui-source/blob/0b949009d9558869da5c53ac61c23f2d711b1f6f/Interface/AddOns/Blizzard_FrameXMLUtil/DifficultyUtil.lua#L1 -- Maybe only need to call once at the start of func
                C_EncounterJournal.SetSlotFilter(Enum.ItemSlotFilterType.NoFilter) -- Maybe only need to call once at the start of func. Do the same test as above with SelectInstance, I surely do not need this.
                for lootIndex = 1, EJ_GetNumLoot() do
                    local itemInfo = C_EncounterJournal.GetLootInfoByIndex(lootIndex)
                    local itemID = itemInfo and itemInfo.itemID
                    local lootDataCached = itemID and C_Item.IsItemDataCachedByID(itemID) -- (itemInfo.name ~= nil)
                    if lootDataCached then -- rename variable, was more accurate when testing cached loot but now care about if loot data is available
                        local known = equippableCache[itemID]
                        if known == nil then -- itemID equip status not yet cached
                            known = C_Item.IsEquippableItem(itemID) -- This only works because loot data is cached, use ContinueOnItemLoad if not cached
                            equippableCache[itemID] = known
                        end

                        if known then -- item equippable
                            GreatVaultOddsDB.eligibleItems[itemID] = GreatVaultOddsDB.eligibleItems[itemID] or {}
                            GreatVaultOddsDB.eligibleItems[itemID][className] = GreatVaultOddsDB.eligibleItems[itemID][className] or {}

                            if not GreatVaultOddsDB.eligibleItems[itemID][className][specName] then
                                GreatVaultOddsDB.eligibleItems[itemID][className][specName] = true  -- Get corresponding item slot and increment that item slot if the item did not previously exist for this spec, and increment the total slots too
                                GreatVaultOddsDB.eligibleItemCount[className][specName].allSlots = GreatVaultOddsDB.eligibleItemCount[className][specName].allSlots + 1
                            end
                        end
                    end
                end
            end
        end
    end
    enableEJ()
    if not alreadyRan then
        C_Timer.After(0.5, function() generateDBForAllSpecs(true, profiling, doneCallback) end) -- Run again after a delay to capture any loot that became cached after initial query
    end
end

local function showHelp() -- make show help have option to display help for specific function too, so can /gvodds help db and get info for db specifically, maybe more detail?
    print("|cFFE6CC99Great Vault Odds|r will display the chance of each spec receiving an item in the Great Vault on the corresponding item's tooltip.")
    print("|cFFE6CC99Great Vault Odds|r |cFF66BBFFHelp Menu:|r") -- Make a prefix print and colour function
    print("|cFFE6CC99/gvodds|r", "|cFF66BBFFreset|r", "- Resets all options to their defaults") -- test colour
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

SLASH_GREATVAULTODDS1 = "/gvodds" -- add /greatvaultodds
function SlashCmdList.GREATVAULTODDS(msg, editBox)
    msg = msg and msg:lower():gsub("^%s*(.-)%s*$", "%1") or "" -- Trims leading and trailing whitespace, unnecessary

    local args = {}
    for word in msg:gmatch("%S+") do -- non whitespace ("args")
        table.insert(args, word)
    end

    local cmd, subCmd, arg1 = args[1], args[2], args[3]

    if cmd == "dev" then
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
    elseif missingSubCmd and not validCommand.hasSubCommand.default then -- subcommand required but not provided
        print("Missing args for command \""..cmd.."\" - displaying /gvodds help")
        showHelp()
    elseif invalidSubCmd then -- Subcommand provided is not valid for given command
        print("Invalid arg \""..subCmd.."\" for command \""..cmd.."\" - displaying /gvodds help")
        showHelp()
    else -- Command is valid and can proceed to act on it
        if cmd == "help" then
            showHelp()
        elseif cmd == "reset" then
            print("Resetting |cFFE6CC99Great Vault Odds|r options to defaults!")
            GreatVaultOddsAddonOptions = CopyTable(defaultAddonOptions)
        elseif devModeActive then -- dev mode required for these commands, unnecessary line though because of prior verification/guarding
            if cmd == "db" then
                if subCmd == "gen" then
                    generateDBForAllSpecs()
                elseif subCmd == "reset" then
                    print("Deleting |cFFE6CC99Great Vault Odds|r SV DB!")
                    GreatVaultOddsDB = {}
                    GreatVaultOddsDB.eligibleItems = {} -- have to reinit the subtables
                    GreatVaultOddsDB.eligibleItemCount = {}
                end
            end
        end
    end
end

local playerSpecNames
local playerClassName
local hasSortedPlayerSpecs = false
local function tooltipHandler(tooltip, data) -- surely I don't have to nilcheck tooltip and data?
    if not data then
        print("Error, data does not exist - GreatVaultOdds")
        addToDevTool(CopyTable(data), "GreatVaultOdds - plain data for "..tooltip:GetName()) -- might get a nil error here if tooltip also doesn't exist?
    else
        local itemID = data.id -- https://warcraft.wiki.gg/wiki/Struct_TooltipData
        if seasonLootDB.eligibleItems[itemID] then -- itemID exists in current season dungeons
            -- Do we need to nilCheck seasonLootDB and then eligible items AND eligible item count, and then we can check for item id, and then class, and then spec if necessary, and then slot if count
            local tooltipText = "GreatVaultOdds: "
            local devModeActive = GreatVaultOddsAddonOptions.devMode
            tooltip:AddLine(tooltipText)

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
                            local iconID = classData.specData[sortedSpecName].iconID
                            local iconText = "|T"..iconID..":0|t"
                            finalTooltip = finalTooltip..iconText.." "..sortedSpecName..": 1/"..seasonLootDB.eligibleItemCount[className][sortedSpecName].allSlots.." "
                        end
                        classTooltipsByID[classData.classID] = finalTooltip
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
            else
                tooltipText = "" -- temporary
                if not hasSortedPlayerSpecs then
                    playerSpecNames = {}
                    -- define tooltipText after className and append the className (need to use localised version, so UnitClass)
                    playerClassName, _ = UnitClassBase("player") -- in the future, might wanna call this outside of the handler to reduce function calls, do once player login and then watch event player loot spec changed or spec changed(is that an event?)
                    for specName in pairs(classSpecIDs[playerClassName].specData) do -- specName, specTable
                        table.insert(playerSpecNames, specName)
                    end
                    table.sort(playerSpecNames) -- Figure out a way to cache this beforehand so don't have to do a loop once per session?
                    hasSortedPlayerSpecs = true
                end

                for _, specName in ipairs(playerSpecNames) do -- Probably can first check if the item has a tooltip cached for this *class* first before recomputing the tooltip
                    if not seasonLootDB.eligibleItems[itemID][playerClassName] then -- why is this in loop?
                    -- TODO: Move out of loop
                        tooltipText = tooltipText.." item is not loot eligible for your class!" -- this will appear for all items that are in the database but not eligible for to be looted by this class. Do we want it to say anything? Or better to be blank?
                        break
                    else -- item is loot eligible for the class, can combine this with the next line.
                        if seasonLootDB.eligibleItems[itemID][playerClassName][specName] then -- item is loot eligible for the spec
                            local iconID = classSpecIDs[playerClassName].specData[specName].iconID
                            local iconText = "|T"..iconID..":0|t"
                            tooltipText = tooltipText..iconText.." "..specName..": 1/"..seasonLootDB.eligibleItemCount[playerClassName][specName].allSlots.." " -- want to sort this to go in order of index or table, rn is random -- NIL CHECK NUMVALID ITEMS AAAAAAAAAAAAAAAAAAAAA
                        else
                            -- not loot eligible, do nothing for now
                        end
                    end
                end
                -- consider caching the tooltip for the item/class combo
                tooltip:AddLine(tooltipText)--, red, green, blue, wrapText)
                -- Do I have to handle this: The tooltip resizes in its OnShow handler,[1] so calling this function on an already-visible tooltip will cause the new line to appear outside of the tooltip's backdrop.
            end
        end
    end
end

if TooltipDataProcessor then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, tooltipHandler)
end

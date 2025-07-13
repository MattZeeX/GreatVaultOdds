local addonName, GreatVaultOddsNS = ...
local devMode = true -- temporary
local debugLogging = false
local seasonLootEligibility = GreatVaultOddsNS.DB

if devMode or debugLogging then
    print("devMode:", devMode, "debugLogging:", debugLogging, "dingus!") -- print on login
end

local cachedIDs = { -- cached specID, is there a way to get non localised version of spec name? will this be a problem? -- potentially worth separating into two tables like in dsune's addon with classes and specs as separate tables indexed by numbers equal to classID
    WARRIOR = { -- classData table
        specData = {
            Arms = { -- specTable
                specID = 71,
                iconID = 132355
            },
            Fury = {
                specID = 72,
                iconID = 132347
            },
            Protection = {
                specID = 73,
                iconID = 132341
            }
        },
        classID = 1
    },
    PALADIN = {specData = {Holy = {specID = 65, iconID = 135920}, Protection = {specID = 66, iconID = 236264}, Retribution = {specID = 70, iconID = 135873}}, classID = 2},
    HUNTER = {specData = {["Beast Mastery"] = {specID = 253, iconID = 461112}, Marksmanship = {specID = 254, iconID = 236179}, Survival = {specID = 255, iconID = 461113}}, classID = 3},
    ROGUE = {specData = {Assassination = {specID = 259, iconID = 132292}, Outlaw = {specID = 260, iconID = 135340}, Subtlety = {specID = 261, iconID = 132320}}, classID = 4},
    PRIEST = {specData = {Discipline = {specID = 256, iconID = 135940}, Holy = {specID = 257, iconID = 237542}, Shadow = {specID = 258, iconID = 136207}}, classID = 5},
    DEATHKNIGHT = {specData = {Blood = {specID = 250, iconID = 135770}, Frost = {specID = 251, iconID = 135773}, Unholy = {specID = 252, iconID = 135775}}, classID = 6},
    SHAMAN = {specData = {Elemental = {specID = 262, iconID = 136048}, Enhancement = {specID = 263, iconID = 237581}, Restoration = {specID = 264, iconID = 136052}}, classID = 7},
    MAGE = {specData = {Arcane = {specID = 62, iconID = 135932}, Fire = {specID = 63, iconID = 135810}, Frost = {specID = 64, iconID = 135846}}, classID = 8},
    WARLOCK = {specData = {Affliction = {specID = 265, iconID = 136145}, Demonology = {specID = 266, iconID = 136172}, Destruction = {specID = 267, iconID = 136186}}, classID = 9},
    MONK = {specData = {Brewmaster = {specID = 268, iconID = 608951}, Mistweaver = {specID = 270, iconID = 608952}, Windwalker = {specID = 269, iconID = 608953}}, classID = 10},
    DRUID = {specData = {Balance = {specID = 102, iconID = 136096}, Feral = {specID = 103, iconID = 132115}, Guardian = {specID = 104, iconID = 132276}, Restoration = {specID = 105, iconID = 136041}}, classID = 11},
    DEMONHUNTER = {specData = {Havoc = {specID = 577, iconID = 1247264}, Vengeance = {specID = 581, iconID = 1247265}}, classID = 12},
    EVOKER = {specData = {Devastation = {specID = 1467, iconID = 4511811}, Preservation = {specID = 1468, iconID = 4511812}, Augmentation = {specID = 1473, iconID = 5198700}}, classID = 13},
}

local function addToDevTool(data, name)
    if not DevTool then return end -- or (not devMode and not debugLogging), can make a separate loggingEnabled function if wanna handle both

    if data ~= nil then -- I assume that there is no such thing as a meaningful nil here? Remember, false is meaningful (look up terminology)
        DevTool:AddData(data, name)
    else
        DevTool:AddData(tostring(data), name) -- I assume there's no nil value that can't be coerced/cast as a string
    end
end

local function OnEvent(self, event, loadedAddonName)
    if event == "ADDON_LOADED" and loadedAddonName == addonName then
        GreatVaultOddsAddonOptions = GreatVaultOddsAddonOptions or {}
        GreatVaultOddsDB = GreatVaultOddsDB or {} -- do I need to add a flag here and ensure my addon is loaded before I use this saved variable later? could add a helper function that is run any time we want to access an SV, or xpcall?
        GreatVaultOddsDB.eligibleItems = GreatVaultOddsDB.eligibleItems or {}
        GreatVaultOddsDB.eligibleItemCount = GreatVaultOddsDB.eligibleItemCount or {}
        GreatVaultOddsOutput = GreatVaultOddsOutput or {}
        GreatVaultOddsDumpDB = GreatVaultOddsDumpDB or {}
        GetTimePreciseSec()
        self:UnregisterEvent("ADDON_LOADED")
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("EJ_LOOT_DATA_RECIEVED")
frame:SetScript("OnEvent", OnEvent)

local function instanceIterator()
   local index = 0
   return function()
      local instanceID, instanceName, dungeonAreaMapID, isWorldBoss
      repeat
         index = index + 1
         instanceID = EJ_GetInstanceByIndex(index, false) -- dungeons only
         if not instanceID then return end
         EJ_SelectInstance(instanceID)  -- GET INSTANCE INFO RETURNS 0 FOR MAP ID UNTIL INSTANCE IS SELECTED!?@!?? AAAAAAAAAAAAAAAAAAAAAAAAAAAA
         instanceName, _, _, _, _, _, dungeonAreaMapID = EJ_GetInstanceInfo(instanceID)
         isWorldBoss = dungeonAreaMapID == 0
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
local profileTable = {}
local runCount
local function generateDBForAllSpecs(alreadyRan, profiling, doneCallback)
    local currentTime = debugprofilestop() -- do this at start of command because wanna only return the number once after both function calls happen
    local firstDebug = true
    if profiling then
        GreatVaultOddsDB = {}
        runCount = runCount + 1
    end
    local funcCount = 0 -- should be declared outside of function cause normally at least one item is pre-cached
    local cachedStatus = true
    local totalUncachedItems = 0
    local seenItems = {}
    EJ_SelectTier(EJ_GetNumTiers())
    disableEJ()

    for className, classData in pairs(cachedIDs) do -- className = className, classData = table of specTable and classID 13
        for specName, specTable in pairs(classData.specData) do -- specName = specName, specTable = table of specID and iconID 3
            EJ_SetLootFilter(classData.classID, specTable.specID)
            -- DB already init in ADDON_LOADED -- GreatVaultOddsDB = GreatVaultOddsDB or {}
            -- Eligible Items init in ADDON_LOADED -- GreatVaultOddsDB.eligibleItems = GreatVaultOddsDB.eligibleItems or {}
            -- Num Eligible Items init in ADDON_LOADED -- GreatVaultOddsDB.eligibleItemCount = GreatVaultOddsDB.eligibleItemCount or {}
            GreatVaultOddsDB.eligibleItemCount[className] = GreatVaultOddsDB.eligibleItemCount[className] or {}
            GreatVaultOddsDB.eligibleItemCount[className][specName] = GreatVaultOddsDB.eligibleItemCount[className][specName] or {}
            GreatVaultOddsDB.eligibleItemCount[className][specName].allSlots = GreatVaultOddsDB.eligibleItemCount[className][specName].allSlots or 0
            for instanceID, instanceName in instanceIterator() do
                EJ_SelectInstance(instanceID)
                EJ_SetDifficulty(DifficultyUtil.ID.DungeonChallenge) -- https://github.com/Gethe/wow-ui-source/blob/0b949009d9558869da5c53ac61c23f2d711b1f6f/Interface/AddOns/Blizzard_FrameXMLUtil/DifficultyUtil.lua#L1 -- Maybe only need to call once at the start of func
                C_EncounterJournal.SetSlotFilter(Enum.ItemSlotFilterType.NoFilter) -- Maybe only need to call once at the start of func
                for lootIndex = 1, EJ_GetNumLoot() do
                    local itemInfo = C_EncounterJournal.GetLootInfoByIndex(lootIndex)
                    local itemID = itemInfo and itemInfo.itemID
                    local lootDataCached = itemID and C_Item.IsItemDataCachedByID(itemID) -- (itemInfo.name ~= nil)
                    if not lootDataCached then
                        cachedStatus = false
                        if not seenItems[itemID] then
                            totalUncachedItems = totalUncachedItems + 1
                            seenItems[itemID] = true
                        end
                    end
                    if lootDataCached then -- rename variable, was more accurate when testing cached loot but now care about if loot data is available
                        local known = equippableCache[itemID]
                        if known == nil then -- itemID equip status not yet cached
                        known = C_Item.IsEquippableItem(itemID) -- This only works because loot data is cached, use ContinueOnItemLoad if not cached
                        funcCount = funcCount + 1
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
    local finalTime = debugprofilestop() - currentTime
    if totalUncachedItems > 0 then
        cachedStatus = false
    end
    if funcCount > 219 then
        print("total funcs exceed 219", funcCount)
    end
    if profiling then
        if cachedStatus == true then
            profileTable.cached[runCount] = finalTime
        elseif cachedStatus == false then
            profileTable.notCached[runCount] = finalTime
        end
    end
    enableEJ()
    if not alreadyRan then
        C_Timer.After(0.5, function() generateDBForAllSpecs(true, profiling, doneCallback) end) -- Run again after a delay to capture any loot that became cached after initial query
    else
        if doneCallback then
            doneCallback()
        end
    end
end

SLASH_GREATVAULTODDS1 = "/gvodds" -- add great vault odds
function SlashCmdList.GREATVAULTODDS(msg, editBox)
    msg = msg:lower()
    local cmd, subCmd, arg1, arg2 = strsplit(' ', msg)

    if cmd == "dev" then -- probably goes at the end of the elseif eventually
        devMode = not devMode -- toggle
        print("Devmode active:", devMode)

    elseif cmd == "help" then
        print("|cFFE6CC99Great Vault Odds:|r |cFF66BBFFhelp menu|r") -- Make a prefix print and colour function
        print("options - displays configurable options")
        print("|cFF66BBFFreset - resets all options to their defaults.|r") -- test colour
        print("dev - toggles dev mode")
        if devMode then
            print("db list: Lists all stored databases")
            print("db gen: Generates a new database")
            print("db compare <list1> [<list2>] - Compares two databases to find errors") -- list 2 optional, compare against main if not there
            print("db compare all - compares all databases to the main one") -- need to add an optional arg to choose which list to compare against
            print("db delete <list>: Deletes the specified table")
            print("debug: Enables DevTool notes to troubleshoot database creation")
        end
        print("----------------------------------------")

    elseif cmd == "gen" then
        generateDBForAllSpecs()
    elseif cmd == "profile" then
        print("Profiling started!")
        local startTotalProfileTime = debugprofilestop()
        local totalRunsToDo = 100
        local completedRuns = 0
        runCount = 0
        profileTable.cached = {}
        profileTable.notCached = {}

        local function onOneRunComplete()
            completedRuns = completedRuns + 1
            if completedRuns == totalRunsToDo then
                local endTotalProfileTime = debugprofilestop() - startTotalProfileTime
                local cachedTableTotal, notCachedTableTotal = 0, 0

                for _, v in pairs(profileTable.cached) do
                    cachedTableTotal = cachedTableTotal + v
                end
                for _, v in pairs(profileTable.notCached) do
                    notCachedTableTotal = notCachedTableTotal + v
                end

                profileTable.cached.total = cachedTableTotal
                profileTable.notCached.total = notCachedTableTotal

                addToDevTool(CopyTable(profileTable.cached), "cached profiles")
                addToDevTool(CopyTable(profileTable.notCached), "uncached profiles")

                print("Total profiling time expected to be near:", endTotalProfileTime)
                print("Total run count:", runCount)
            end
        end

        for i = 1, totalRunsToDo do
            generateDBForAllSpecs(false, true, onOneRunComplete)
        end
    elseif cmd == "reset" then
        print("resetting table")
        GreatVaultOddsDB = {}
        GreatVaultOddsDB.eligibleItems = {}
        GreatVaultOddsDB.eligibleItemCount = {}
    else
        print("unrecognized command", cmd)
    end
end

local playerSpec = {}
local playerClass
local firstTooltipRun = true
local function tooltipHandler(tooltip, data) -- surely I don't have to nilcheck tooltip and data?
    if not data then
        print("Error, data does not exist - GreatVaultOdds")
        addToDevTool(CopyTable(data), "GreatVaultOdds - plain data for "..tooltip:GetName()) -- might get a nil error here if tooltip also doesn't exist?
    else
        local itemID = data.id -- https://warcraft.wiki.gg/wiki/Struct_TooltipData
        if seasonLootEligibility.eligibleItems[itemID] then -- itemID exists in current season dungeons
        -- Do we need to nilCheck seasonLootEligibility and then eligible items AND eligible item count, and then we can check for item id, and then class, and then spec if necessary, and then slot if count
            local tooltipText = "GreatVaultOdds: "

            if firstTooltipRun then
                -- define tooltipText after className and append the className (need to use localised version, so UnitClass)
                playerClass, _ = UnitClassBase("player") -- in the future, might wanna call this outside of the handler to reduce function calls, do once player login and then watch event player loot spec changed or spec changed(is that an event?)
                for specName, _ in pairs(cachedIDs[playerClass].specData) do -- specName, specTable
                    table.insert(playerSpec, specName)
                end
                table.sort(playerSpec) -- double check sorted the same way we have in our table
                -- local specID = GetLootSpecialization() -- rename variable to current loot spec
                -- local specID = GetLootSpecialization() > 0 and GetLootSpecialization() or GetSpecializationInfo(GetSpecialization()) -- probably too convoluted
                -- specID should be leftText, others be rightText MAYBE??? Code doesn't reflect this right now but that is why I saved specID
                --[[
                if specID == 0 then -- loot spec is set to current specialisation
                    local specIndex = GetSpecialization()
                    specID = GetSpecializationInfo(specIndex)
                end
                --]]
                firstTooltipRun = false
            end
            -- gets all specs for a class, add .specID or whatever if I combine specid and icon id. right now I don't use the specid but maybe I will? -- in order to preserve the order,
            -- specid in wow is done by alphabetical spec name, so can put the keys that are the specs in an array, table.sort them, and then loop through that array with ipairs to call the corresponding key in the normal table
            -- would this be bad performance wise to sort a table every time I hover over item tooltip? How would I cache this? Do it this way first, then optimise later.

            for _, specName in ipairs(playerSpec) do
                if not seasonLootEligibility.eligibleItems[itemID][playerClass] then -- why is this in loop?
                    tooltipText = tooltipText.." item is not loot eligible for your class!" -- this will appear for all items that are in the database but not eligible for to be looted by this class. Do we want it to say anything? Or better to be blank?
                    break
                else -- item is loot eligible for the class, can combine this with the next line
                    --[[
                    for the table etc etc
                    if specFromTable == current spec then
                        left text = current spec
                    else
                        right text = right text .. some value
                    --]]
                    if seasonLootEligibility.eligibleItems[itemID][playerClass][specName] then -- item is loot eligible for the spec
                    local iconID = cachedIDs[playerClass].specData[specName].iconID
                    local iconText = "|T"..iconID..":0|t"
                    tooltipText = tooltipText..iconText.." "..specName..": 1/"..seasonLootEligibility.eligibleItemCount[playerClass][specName].allSlots.." " -- want to sort this to go in order of index or table, rn is random -- NIL CHECK NUMVALID ITEMS AAAAAAAAAAAAAAAAAAAAA
                    else
                        -- not loot eligible, do nothing for now
                    end
                end
            end
            tooltip:AddLine(tooltipText)--, red, green, blue, wrapText)
            -- tooltip:AddDoubleLine(leftText, rightText, leftR, leftG, leftB, rightR, rightG, rightB)
            -- Do I have to handle this: The tooltip resizes in its OnShow handler,[1] so calling this function on an already-visible tooltip will cause the new line to appear outside of the tooltip's backdrop.
        end
    end
end

if TooltipDataProcessor then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, tooltipHandler)
end
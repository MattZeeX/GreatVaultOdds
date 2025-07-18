---@diagnostic disable: undefined-global
-- Profiling DB gen function method

local equippableCache = {}
local profileTable = {}
local runCount
local function generateDBForAllSpecs(alreadyRan, profiling, doneCallback)
    local currentTime = debugprofilestop() -- do this at start of command because wanna only return the number once after both function calls happen
    local firstDebug = true -- currently unused
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

-- Slash command
if cmd == "profile" then
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
end
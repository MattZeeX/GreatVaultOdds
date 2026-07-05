local addonName, GreatVaultOddsNS = ...

local classSpecIDs = GreatVaultOddsNS.ClassSpecIDs
local Utils = GreatVaultOddsNS.Utils
local Tooltip = GreatVaultOddsNS.Tooltip
local DBGenerator = GreatVaultOddsNS.DBGenerator
local SlashCommands = GreatVaultOddsNS.SlashCommands
local Core = GreatVaultOddsNS.Core
local LootSource = GreatVaultOddsNS.LootSource
local ignoredLootItemIDs = GreatVaultOddsNS.IgnoredLootItemIDs or {}
local raidEncounterDataByMilestoneSeasonID = GreatVaultOddsNS.RaidEncounterKillStatisticIDsByMilestoneSeasonID
local raidEncounterIndexByJournalEncounterID = GreatVaultOddsNS.RaidEncounterIndexByJournalEncounterID

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

local function activeRaidIterator()
    local index = 0
    return function()
        local journalInstanceID, instanceName, dungeonAreaMapID, isWorldBoss
        repeat
            index = index + 1
            journalInstanceID = EJ_GetInstanceByIndex(index, true)
            if not journalInstanceID then return end

            EJ_SelectInstance(journalInstanceID)
            instanceName, _, _, _, _, _, dungeonAreaMapID = EJ_GetInstanceInfo(journalInstanceID)
            isWorldBoss = dungeonAreaMapID == 0
        until not isWorldBoss

        return journalInstanceID, instanceName
    end
end

local function specificRaidIterator(milestoneSeasonID)
    local seasonRaidData = raidEncounterDataByMilestoneSeasonID[milestoneSeasonID]
    local index = 0
    local journalInstanceIDs = {}

    for journalInstanceID in pairs(seasonRaidData or {}) do
        table.insert(journalInstanceIDs, journalInstanceID)
    end

    return function()
        index = index + 1
        local journalInstanceID = journalInstanceIDs[index]
        if not journalInstanceID then return end

        EJ_SelectInstance(journalInstanceID)
        return journalInstanceID, seasonRaidData[journalInstanceID].instanceName
    end
end

local function raidIterator(milestoneSeasonID)
    if milestoneSeasonID then return specificRaidIterator(milestoneSeasonID) end

    return activeRaidIterator()
end

local function getConfiguredRaidBossCount(milestoneSeasonID, journalInstanceID)
    local seasonRaidData = milestoneSeasonID and raidEncounterDataByMilestoneSeasonID[milestoneSeasonID]
    local raidData = seasonRaidData and seasonRaidData[journalInstanceID]

    return raidData and raidData.bosses and #raidData.bosses or 0
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
local function generateDungeonDBForAllSpecs(milestoneSeasonID)
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
                    if lootDataCached and not ignoredLootItemIDs[itemID] then -- rename variable, was more accurate when testing cached loot but now care about if loot data is available. Cached by us as equippable vs data cached by the game.
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
end

local function addCumulativeBossTotals(raidCounts, maxBossIndex)
    local runningTotal = 0

    for bossIndex = 1, maxBossIndex do
        runningTotal = runningTotal + (raidCounts.bossTotals[bossIndex] or 0)
        raidCounts.cumulativeBossTotals[bossIndex] = runningTotal
    end
end

local function generateRaidDBForAllSpecs(milestoneSeasonID)
    local eligibleItemsByID = GreatVaultOddsDB.eligibleItems
    local eligibleItemCountsByClass = GreatVaultOddsDB.eligibleItemCount

    for className, classData in pairs(classSpecIDs) do
        eligibleItemCountsByClass[className] = eligibleItemCountsByClass[className] or {}
        local classCounts = eligibleItemCountsByClass[className]

        for specName, specTable in pairs(classData.specData) do
            EJ_SetLootFilter(classData.classID, specTable.specID)

            classCounts[specName] = classCounts[specName] or {}
            local specCounts = classCounts[specName]

            specCounts.raidTotals = specCounts.raidTotals or {}
            local raidTotalsByInstance = specCounts.raidTotals

            for journalInstanceID, instanceName in raidIterator(milestoneSeasonID) do
                EJ_SelectInstance(journalInstanceID)
                EJ_SetDifficulty(DifficultyUtil.ID.PrimaryRaidNormal)

                raidTotalsByInstance[journalInstanceID] = raidTotalsByInstance[journalInstanceID] or {}
                local raidCounts = raidTotalsByInstance[journalInstanceID]
                raidCounts.totalItems = raidCounts.totalItems or 0
                raidCounts.bossTotals = raidCounts.bossTotals or {}
                raidCounts.cumulativeBossTotals = raidCounts.cumulativeBossTotals or {}

                local maxBossIndex = getConfiguredRaidBossCount(milestoneSeasonID, journalInstanceID)

                C_EncounterJournal.SetSlotFilter(Enum.ItemSlotFilterType.NoFilter)
                for lootIndex = 1, EJ_GetNumLoot() do
                    local itemInfo = C_EncounterJournal.GetLootInfoByIndex(lootIndex)
                    local itemID = itemInfo and itemInfo.itemID
                    local sourceJournalEncounterID = itemInfo and itemInfo.encounterID
                    local bossInfo = sourceJournalEncounterID and raidEncounterIndexByJournalEncounterID[sourceJournalEncounterID]
                    local lootDataCached = itemID and C_Item.IsItemDataCachedByID(itemID)
                    local shouldProcessItem = lootDataCached and not ignoredLootItemIDs[itemID]

                    if bossInfo and shouldProcessItem then
                        local knownRaidBoss = bossInfo.journalInstanceID == journalInstanceID
                        local bossIsInRequestedSeason = not milestoneSeasonID or bossInfo.seasonID == milestoneSeasonID

                        if knownRaidBoss and bossIsInRequestedSeason then
                            local known = equippableCache[itemID]
                            if known == nil then
                                known = C_Item.IsEquippableItem(itemID)
                                equippableCache[itemID] = known
                            end

                            if known then
                                eligibleItemsByID[itemID] = eligibleItemsByID[itemID] or {}
                                local itemEntry = eligibleItemsByID[itemID]

                                itemEntry[className] = itemEntry[className] or {}
                                local eligibleSpecs = itemEntry[className]

                                if not eligibleSpecs[specName] then
                                    eligibleSpecs[specName] = true

                                    itemEntry.sources = itemEntry.sources or {}
                                    itemEntry.sources.raid = {
                                        journalInstanceID = journalInstanceID,
                                        journalEncounterID = sourceJournalEncounterID,
                                        bossIndex = bossInfo.bossIndex,
                                    }

                                    specCounts.raidTotalItems = (specCounts.raidTotalItems or 0) + 1
                                    raidCounts.totalItems = raidCounts.totalItems + 1

                                    raidCounts.bossTotals[bossInfo.bossIndex] = raidCounts.bossTotals[bossInfo.bossIndex] or 0
                                    raidCounts.bossTotals[bossInfo.bossIndex] = raidCounts.bossTotals[bossInfo.bossIndex] + 1

                                    if bossInfo.bossIndex > maxBossIndex then
                                        maxBossIndex = bossInfo.bossIndex
                                    end
                                end
                            end
                        end
                    end
                end

                addCumulativeBossTotals(raidCounts, maxBossIndex)
            end
        end
    end
end

local function normaliseDBGenerationOptions(options)
    if type(options) == "table" then return options end

    return {
        milestoneSeasonID = options,
    }
end

-- generateDBForAllSpecs
function DBGenerator.generateDBForAllSpecs(options, alreadyRan)
    local generationOptions = normaliseDBGenerationOptions(options)
    local milestoneSeasonID = generationOptions.milestoneSeasonID
    local lootSource = generationOptions.lootSource

    EJ_SelectTier(EJ_GetNumTiers())
    disableEJ()

    if not lootSource or lootSource == LootSource.Dungeon then
        generateDungeonDBForAllSpecs(milestoneSeasonID)
    end

    if not lootSource or lootSource == LootSource.Raid then
        generateRaidDBForAllSpecs(milestoneSeasonID)
    end

    enableEJ()
    if not alreadyRan then
        C_Timer.After(0.5, function() DBGenerator.generateDBForAllSpecs(generationOptions, true) end) -- Run again after a delay to capture any loot that became cached after initial query
    else
        local generatedLootSource = lootSource or "dungeon and raid"
        print("Great Vault Odds", generatedLootSource, "loot DB generation complete.")
    end
end

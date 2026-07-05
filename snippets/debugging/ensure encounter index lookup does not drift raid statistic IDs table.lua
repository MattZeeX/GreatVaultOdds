---@diagnostic disable: undefined-global
-- Compares the RaidEncounterIndexByCombatEncounterID lookup to ensure it does not differ from RaidEncounterKillStatisticIDsByMilestoneSeasonID over time
-- due to not updating consistently/simultaneously

local function validateRaidEncounterIndex()
    local errors = {}

    -- Pass 1: every boss-table combat encounter should exist in the combat encounter lookup.
    for seasonID, seasonRaidData in pairs(raidEncounterKillStatisticIDsByMilestoneSeasonID) do
        for journalInstanceID, raidData in pairs(seasonRaidData) do
            for bossIndex, bossData in ipairs(raidData.bosses) do
                local indexedBoss = raidEncounterIndexByCombatEncounterID[bossData.combatEncounterID]

                if not indexedBoss then
                    table.insert(errors, {
                        type = "missingEncounterIndex",
                        combatEncounterID = bossData.combatEncounterID,
                        encounterName = bossData.encounterName,
                        seasonID = seasonID,
                        journalInstanceID = journalInstanceID,
                        bossIndex = bossIndex,
                    })
                elseif indexedBoss.seasonID ~= seasonID
                    or indexedBoss.journalInstanceID ~= journalInstanceID
                    or indexedBoss.bossIndex ~= bossIndex then
                    table.insert(errors, {
                        type = "mismatchedEncounterIndex",
                        combatEncounterID = bossData.combatEncounterID,
                        encounterName = bossData.encounterName,
                        expectedSeasonID = seasonID,
                        actualSeasonID = indexedBoss.seasonID,
                        expectedJournalInstanceID = journalInstanceID,
                        actualJournalInstanceID = indexedBoss.journalInstanceID,
                        expectedBossIndex = bossIndex,
                        actualBossIndex = indexedBoss.bossIndex,
                    })
                end

                local indexedJournalBoss = raidEncounterIndexByJournalEncounterID[bossData.journalEncounterID]

                if not indexedJournalBoss then
                    table.insert(errors, {
                        type = "missingJournalEncounterIndex",
                        journalEncounterID = bossData.journalEncounterID,
                        encounterName = bossData.encounterName,
                        seasonID = seasonID,
                        journalInstanceID = journalInstanceID,
                        bossIndex = bossIndex,
                    })
                elseif indexedJournalBoss.seasonID ~= seasonID
                    or indexedJournalBoss.journalInstanceID ~= journalInstanceID
                    or indexedJournalBoss.bossIndex ~= bossIndex then
                    table.insert(errors, {
                        type = "mismatchedJournalEncounterIndex",
                        journalEncounterID = bossData.journalEncounterID,
                        encounterName = bossData.encounterName,
                        expectedSeasonID = seasonID,
                        actualSeasonID = indexedJournalBoss.seasonID,
                        expectedJournalInstanceID = journalInstanceID,
                        actualJournalInstanceID = indexedJournalBoss.journalInstanceID,
                        expectedBossIndex = bossIndex,
                        actualBossIndex = indexedJournalBoss.bossIndex,
                    })
                end
            end
        end
    end

    -- Pass 2: every combat encounter lookup entry should point back to a real boss-table entry.
    for combatEncounterID, indexedBoss in pairs(raidEncounterIndexByCombatEncounterID) do
        local seasonRaidData = raidEncounterKillStatisticIDsByMilestoneSeasonID[indexedBoss.seasonID]
        local raidData = seasonRaidData and seasonRaidData[indexedBoss.journalInstanceID]
        local bossData = raidData and raidData.bosses[indexedBoss.bossIndex]

        if not bossData then
            table.insert(errors, {
                type = "orphanedEncounterIndex",
                combatEncounterID = combatEncounterID,
                seasonID = indexedBoss.seasonID,
                journalInstanceID = indexedBoss.journalInstanceID,
                bossIndex = indexedBoss.bossIndex,
            })
        elseif bossData.combatEncounterID ~= combatEncounterID then
            table.insert(errors, {
                type = "staleEncounterIndex",
                combatEncounterID = combatEncounterID,
                seasonID = indexedBoss.seasonID,
                journalInstanceID = indexedBoss.journalInstanceID,
                bossIndex = indexedBoss.bossIndex,
                bossTableCombatEncounterID = bossData.combatEncounterID,
                bossTableEncounterName = bossData.encounterName,
            })
        end
    end

    -- Pass 3: every journal encounter lookup entry should point back to a real boss-table entry.
    for journalEncounterID, indexedBoss in pairs(raidEncounterIndexByJournalEncounterID) do
        local seasonRaidData = raidEncounterKillStatisticIDsByMilestoneSeasonID[indexedBoss.seasonID]
        local raidData = seasonRaidData and seasonRaidData[indexedBoss.journalInstanceID]
        local bossData = raidData and raidData.bosses[indexedBoss.bossIndex]

        if not bossData then
            table.insert(errors, {
                type = "orphanedJournalEncounterIndex",
                journalEncounterID = journalEncounterID,
                seasonID = indexedBoss.seasonID,
                journalInstanceID = indexedBoss.journalInstanceID,
                bossIndex = indexedBoss.bossIndex,
            })
        elseif bossData.journalEncounterID ~= journalEncounterID then
            table.insert(errors, {
                type = "staleJournalEncounterIndex",
                journalEncounterID = journalEncounterID,
                seasonID = indexedBoss.seasonID,
                journalInstanceID = indexedBoss.journalInstanceID,
                bossIndex = indexedBoss.bossIndex,
                bossTableJournalEncounterID = bossData.journalEncounterID,
                bossTableEncounterName = bossData.encounterName,
            })
        end
    end

    return errors
end

function PlayerRaidProgress.ValidateRaidProgressionData()
    local errors = validateRaidEncounterIndex()

    if #errors == 0 then
        print("GreatVaultOdds raid progression data validation passed.")
        return true
    end

    print("GreatVaultOdds raid progression data validation failed:", #errors, "error(s)")
    Utils.addToDevTool(errors, "GreatVaultOdds Raid Progression Data Errors")
    return false
end

---@diagnostic disable: undefined-global
-- Compares the RaidEncounterIndexByEncounterID lookup to ensure it does not differ from RaidEncounterKillStatisticIDsByMilestoneSeasonID over time
-- due to not updating consistently/simultaneously

local function validateRaidEncounterIndex()
    local errors = {}

    -- Pass 1: every boss-table encounter should exist in the encounter lookup.
    for seasonID, seasonRaidData in pairs(raidEncounterKillStatisticIDsByMilestoneSeasonID) do
        for journalInstanceID, raidData in pairs(seasonRaidData) do
            for bossIndex, bossData in ipairs(raidData.bosses) do
                local indexedBoss = raidEncounterIndexByEncounterID[bossData.encounterID]

                if not indexedBoss then
                    table.insert(errors, {
                        type = "missingEncounterIndex",
                        encounterID = bossData.encounterID,
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
                        encounterID = bossData.encounterID,
                        encounterName = bossData.encounterName,
                        expectedSeasonID = seasonID,
                        actualSeasonID = indexedBoss.seasonID,
                        expectedJournalInstanceID = journalInstanceID,
                        actualJournalInstanceID = indexedBoss.journalInstanceID,
                        expectedBossIndex = bossIndex,
                        actualBossIndex = indexedBoss.bossIndex,
                    })
                end
            end
        end
    end

    -- Pass 2: every encounter lookup entry should point back to a real boss-table entry.
    for encounterID, indexedBoss in pairs(raidEncounterIndexByEncounterID) do
        local seasonRaidData = raidEncounterKillStatisticIDsByMilestoneSeasonID[indexedBoss.seasonID]
        local raidData = seasonRaidData and seasonRaidData[indexedBoss.journalInstanceID]
        local bossData = raidData and raidData.bosses[indexedBoss.bossIndex]

        if not bossData then
            table.insert(errors, {
                type = "orphanedEncounterIndex",
                encounterID = encounterID,
                seasonID = indexedBoss.seasonID,
                journalInstanceID = indexedBoss.journalInstanceID,
                bossIndex = indexedBoss.bossIndex,
            })
        elseif bossData.encounterID ~= encounterID then
            table.insert(errors, {
                type = "staleEncounterIndex",
                encounterID = encounterID,
                seasonID = indexedBoss.seasonID,
                journalInstanceID = indexedBoss.journalInstanceID,
                bossIndex = indexedBoss.bossIndex,
                bossTableEncounterID = bossData.encounterID,
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

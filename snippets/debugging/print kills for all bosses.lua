---@diagnostic disable: undefined-global
-- Prints a heading for the raid instances, and then for each boss outputs the kill count for all difficulties on one line

local currentSeason = 105
for instanceID, instanceInfo in pairs(GreatVaultOddsNS.RaidEncounterKillStatisticIDsByMilestoneSeasonID[currentSeason]) do
    print("**"..instanceInfo.instanceName.."**")
    for bossIndex, bossInfo in ipairs(instanceInfo.bosses) do
        print(bossIndex..":", bossInfo.encounterName..":", "LFR:", GetStatistic(bossInfo.killStatisticIDs[17])..",", "N:", GetStatistic(bossInfo.killStatisticIDs[14])..",", "H:", GetStatistic(bossInfo.killStatisticIDs[15])..",", "M:", GetStatistic(bossInfo.killStatisticIDs[16])..",")
    end
end

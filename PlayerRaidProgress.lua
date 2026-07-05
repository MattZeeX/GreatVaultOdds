local addonName, GreatVaultOddsNS = ...

local Utils = GreatVaultOddsNS.Utils
local Tooltip = GreatVaultOddsNS.Tooltip
local DBGenerator = GreatVaultOddsNS.DBGenerator
local SlashCommands = GreatVaultOddsNS.SlashCommands
local Core = GreatVaultOddsNS.Core
local PlayerRaidProgress = GreatVaultOddsNS.PlayerRaidProgress

local raidEncounterKillStatisticIDsByMilestoneSeasonID = GreatVaultOddsNS.RaidEncounterKillStatisticIDsByMilestoneSeasonID
local raidEncounterIndexByCombatEncounterID = GreatVaultOddsNS.RaidEncounterIndexByCombatEncounterID
local raidDifficultyID = GreatVaultOddsNS.RaidDifficultyID

local raidProgressCache = {}

local function getKillCountFromBossData(bossData, difficultyID)
    local statisticID = bossData.killStatisticIDs[difficultyID] -- Add error message return for devtool
    if not statisticID then return end

    local rawValue = GetStatistic(statisticID)
    local killCount
    if rawValue == "--" then
        killCount = 0
    else
        killCount = tonumber(rawValue)
    end

    return killCount, statisticID, rawValue
end

local function getHighestKilledBossIndex(milestoneSeasonID, instanceID, difficultyID)
    local seasonRaidData = raidEncounterKillStatisticIDsByMilestoneSeasonID[milestoneSeasonID] -- Add error message return for devtool
    local raidData = seasonRaidData and seasonRaidData[instanceID] -- Add error message return for devtool
    if not raidData then return end

    for bossIndex = #raidData.bosses, 1, -1 do
        local killCount, statisticID = getKillCountFromBossData(raidData.bosses[bossIndex], difficultyID) -- if the data table has a nil value at an index, this call will error when statistic tries to index a nil value I assume

        if not (statisticID and killCount) then
            return
        end

        if killCount > 0 then
            return bossIndex
        end
    end

    return 0
end

function PlayerRaidProgress.RefreshProgression(milestoneSeasonID)
    if not milestoneSeasonID then return end

    local seasonRaidData = raidEncounterKillStatisticIDsByMilestoneSeasonID[milestoneSeasonID]
    if not seasonRaidData then return end

    raidProgressCache[milestoneSeasonID] = raidProgressCache[milestoneSeasonID] or {}
    local seasonProgress = raidProgressCache[milestoneSeasonID]

    for instanceID in pairs(seasonRaidData) do
        seasonProgress[instanceID] = seasonProgress[instanceID] or {}
        local instanceProgress = seasonProgress[instanceID]
        for difficultyName, difficultyID in pairs(raidDifficultyID) do
            instanceProgress[difficultyID] = getHighestKilledBossIndex(milestoneSeasonID, instanceID, difficultyID)
        end
    end
end

function PlayerRaidProgress.GetHighestKilledBossIndex(milestoneSeasonID, journalInstanceID, difficultyID)
    if not (milestoneSeasonID and journalInstanceID and difficultyID) then return end

    local seasonProgress = raidProgressCache[milestoneSeasonID]
    local instanceProgress = seasonProgress and seasonProgress[journalInstanceID]
    local highestKilledBossIndex = instanceProgress and instanceProgress[difficultyID]

    return highestKilledBossIndex
end

function PlayerRaidProgress.MarkEncounterKilled(combatEncounterID, difficultyID)
    if not combatEncounterID or not difficultyID then return end

    local bossInfo = raidEncounterIndexByCombatEncounterID[combatEncounterID]
    if not bossInfo then return end

    local bossSeasonID = bossInfo.seasonID
    local bossInstanceID = bossInfo.journalInstanceID
    local newBossIndex = bossInfo.bossIndex
    if not (bossSeasonID and bossInstanceID and newBossIndex) then return end

    if bossSeasonID ~= Core.GetActiveMilestoneSeasonID() then return end

    raidProgressCache[bossSeasonID] = raidProgressCache[bossSeasonID] or {}
    local seasonProgress = raidProgressCache[bossSeasonID]

    seasonProgress[bossInstanceID] = seasonProgress[bossInstanceID] or {}
    local instanceProgress = seasonProgress[bossInstanceID]

    local oldBossIndex = instanceProgress[difficultyID] or 0
    if newBossIndex > oldBossIndex then instanceProgress[difficultyID] = newBossIndex end
end

local function buildBossKillsDebugReport(milestoneSeasonID)
    local debugReport = {
        milestoneSeasonID = milestoneSeasonID,
        raids = {},
    }

    local seasonRaidData = raidEncounterKillStatisticIDsByMilestoneSeasonID[milestoneSeasonID]
    if not seasonRaidData then
        print("GreatVaultOdds has not configured raid data for milestone season ID:", milestoneSeasonID)
        return
    end

    for instanceID, raidData in pairs(seasonRaidData) do
        local raidReport = {
            -- instanceName = raidData.instanceName,
            instanceID = instanceID,
            difficulties = {},
        }

        debugReport.raids[raidData.instanceName] = raidReport

        for difficultyName, difficultyID in pairs(raidDifficultyID) do
            local highestKilledBossIndex = getHighestKilledBossIndex(milestoneSeasonID, instanceID, difficultyID)

            local difficultyReport = {
                highestKilledBossIndex = highestKilledBossIndex,
                bosses = {},
            }

            raidReport.difficulties[difficultyName] = difficultyReport

            for bossIndex, bossData in ipairs(raidData.bosses) do
                local killCount, statisticID, rawValue = getKillCountFromBossData(bossData, difficultyID)

                difficultyReport.bosses[bossIndex] = {
                    combatEncounterID = bossData.combatEncounterID,
                    journalEncounterID = bossData.journalEncounterID,
                    encounterName = bossData.encounterName,
                    statisticID = statisticID,
                    rawValue = rawValue,
                    killCount = killCount,
                    killed = killCount ~= nil and killCount > 0,
                    missingStatistic = statisticID == nil,
                    invalidStatisticValue = statisticID ~= nil and killCount == nil,
                }
            end
        end
    end

    return debugReport
end

function PlayerRaidProgress.OutputBossKillsDebugReport(milestoneSeasonID)
    local selectedMilestoneSeasonID = milestoneSeasonID or Core.GetActiveMilestoneSeasonID()

    if not selectedMilestoneSeasonID then print("No milestone season ID provided and GreatVaultOdds has no active milestone season ID yet.") return end

    local debugReport = buildBossKillsDebugReport(selectedMilestoneSeasonID)
    if not debugReport then return end

    Utils.addToDevTool(debugReport, "GreatVaultOdds Boss Kills")
end

function PlayerRaidProgress.OutputProgressCache()
    Utils.addToDevTool(CopyTable(raidProgressCache), "GreatVaultOdds Progression Cache")
end

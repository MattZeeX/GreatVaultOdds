local addonName, GreatVaultOddsNS = ...

local classSpecIDs = GreatVaultOddsNS.ClassSpecIDs
local Utils = GreatVaultOddsNS.Utils
local Tooltip = GreatVaultOddsNS.Tooltip
local DBGenerator = GreatVaultOddsNS.DBGenerator
local SlashCommands = GreatVaultOddsNS.SlashCommands
local Core = GreatVaultOddsNS.Core
local PlayerRaidProgress = GreatVaultOddsNS.PlayerRaidProgress
local raidDifficultyID = GreatVaultOddsNS.RaidDifficultyID

local activeLootDB

local playerSpecNames
local playerClassName
local hasSortedPlayerSpecs = false

local tooltipStyle = { -- Includes future tooltip format styles
    dropRateSeparator = {"||", " || ", "  || ", " / ", "  / ", ", "},
    lootSourceSeparator = {"||", " || ", "  || ", " / ", "  / ", ", "},
    specLabel = ": "
}

local activeLootSourceSeparator = tooltipStyle.lootSourceSeparator[2]
local activeDropRateSeparator = tooltipStyle.dropRateSeparator[2]
local activeSpecLabel = tooltipStyle.specLabel

local ADDON_TOOLTIP_HEADER = "GreatVaultOdds"
local UNAVAILABLE_ODDS_COLOR = "|cffb0b0b0"
local COLOR_END = "|r"
local DUNGEON_LOOT_SOURCE_TOOLTIP_HEADER = "Vault"..activeLootSourceSeparator.."M+"..activeLootSourceSeparator.."Boss"

local RAID_DIFFICULTY_DISPLAY_ORDER = {
    {label = "LFR", difficultyID = raidDifficultyID.LFR},
    {label = "N", difficultyID = raidDifficultyID.Normal},
    {label = "H", difficultyID = raidDifficultyID.Heroic},
    {label = "M", difficultyID = raidDifficultyID.Mythic},
}

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

local function getSpecCounts(className, specName)
    return activeLootDB.eligibleItemCount[className] and activeLootDB.eligibleItemCount[className][specName]
end

local function getSpecIconText(className, specName)
    local iconID = classSpecIDs[className].specData[specName].iconID
    return "|T"..iconID..":0|t"
end

local function getNormalTooltipColoredLabel(label)
    return NORMAL_FONT_COLOR:WrapTextInColorCode(label..":").." "
end

local function getUnavailableOddsText()
    return UNAVAILABLE_ODDS_COLOR.."N/A"..COLOR_END
end

local function buildDungeonSpecOddsLine(className, specName, sourceInfo)
    local instanceID = sourceInfo.instanceID
    local encounterID = sourceInfo.encounterID
    if not (instanceID and encounterID) then return end

    local specCounts = getSpecCounts(className, specName)
    local seasonTotal = specCounts and specCounts.seasonTotalItems

    local dungeonCounts = specCounts and specCounts.dungeonTotals and specCounts.dungeonTotals[instanceID]
    local dungeonTotal = dungeonCounts and dungeonCounts.totalItems

    local bossTotalsByEncounter = dungeonCounts and dungeonCounts.bossTotals
    local bossTotal = bossTotalsByEncounter and bossTotalsByEncounter[encounterID]

    local missingLootData = not (seasonTotal and dungeonTotal and bossTotal)
    if missingLootData then return end

    local iconText = getSpecIconText(className, specName)
    return iconText.." "..specName..activeSpecLabel.."1/"..seasonTotal..activeDropRateSeparator.."1/"..dungeonTotal..activeDropRateSeparator.."1/"..bossTotal
end

local function buildRaidBossOddsLine(className, specName, raidSource)
    local journalInstanceID = raidSource.journalInstanceID
    local bossIndex = raidSource.bossIndex
    if not (journalInstanceID and bossIndex) then return end

    local specCounts = getSpecCounts(className, specName)
    local raidCounts = specCounts and specCounts.raidTotals and specCounts.raidTotals[journalInstanceID]
    local bossTotal = raidCounts and raidCounts.bossTotals and raidCounts.bossTotals[bossIndex]
    if not bossTotal then return end

    local iconText = getSpecIconText(className, specName)
    return iconText.." "..specName.." "..getNormalTooltipColoredLabel("Boss").."1/"..bossTotal
end

local function buildRaidVaultOddsLine(className, specName, raidSource)
    local journalInstanceID = raidSource.journalInstanceID
    local bossIndex = raidSource.bossIndex
    if not (journalInstanceID and bossIndex) then return end

    local specCounts = getSpecCounts(className, specName)
    local raidCounts = specCounts and specCounts.raidTotals and specCounts.raidTotals[journalInstanceID]
    local cumulativeBossTotals = raidCounts and raidCounts.cumulativeBossTotals
    if not cumulativeBossTotals then return end

    local milestoneSeasonID = Core.GetActiveMilestoneSeasonID()
    local difficultyOdds = {}

    for _, difficultyInfo in ipairs(RAID_DIFFICULTY_DISPLAY_ORDER) do
        local highestKilledBossIndex = PlayerRaidProgress.GetHighestKilledBossIndex(milestoneSeasonID, journalInstanceID, difficultyInfo.difficultyID)
        local vaultTotal = highestKilledBossIndex and highestKilledBossIndex >= bossIndex and cumulativeBossTotals[highestKilledBossIndex]
        local vaultOddsText = vaultTotal and "1/"..vaultTotal or getUnavailableOddsText()

        table.insert(difficultyOdds, difficultyInfo.label..": "..vaultOddsText)
    end

    return "  "..getNormalTooltipColoredLabel("Vault")..table.concat(difficultyOdds, activeLootSourceSeparator)
end

local function buildRaidSpecOddsLines(className, specName, raidSource)
    local tooltipLines = {}

    local bossOddsLine = buildRaidBossOddsLine(className, specName, raidSource)
    if bossOddsLine then table.insert(tooltipLines, bossOddsLine) end

    local vaultOddsLine = buildRaidVaultOddsLine(className, specName, raidSource)
    if vaultOddsLine then table.insert(tooltipLines, vaultOddsLine) end

    return tooltipLines
end

local function appendPlayerClassDungeonTooltipLines(tooltip, itemID, sourceInfo)
    ensurePlayerSpecsSorted()

    local tooltipColor = Utils.getTooltipColorForClass(playerClassName)
    local playerEligibleSpecs = activeLootDB.eligibleItems[itemID][playerClassName]
    if not playerEligibleSpecs then
        tooltip:AddLine("Item is not loot eligible for your class!", tooltipColor.r, tooltipColor.g, tooltipColor.b)
        return
    end

    for _, specName in ipairs(playerSpecNames) do
        if playerEligibleSpecs[specName] then
            local specTooltipLine = buildDungeonSpecOddsLine(playerClassName, specName, sourceInfo)
            if specTooltipLine then
                tooltip:AddLine(specTooltipLine, tooltipColor.r, tooltipColor.g, tooltipColor.b)
            end
        end
    end
end

local function appendPlayerClassRaidTooltipLines(tooltip, itemID, raidSource)
    ensurePlayerSpecsSorted()

    local tooltipColor = Utils.getTooltipColorForClass(playerClassName)
    local playerEligibleSpecs = activeLootDB.eligibleItems[itemID][playerClassName]
    if not playerEligibleSpecs then
        tooltip:AddLine("Item is not loot eligible for your class!", tooltipColor.r, tooltipColor.g, tooltipColor.b)
        return
    end

    for _, specName in ipairs(playerSpecNames) do
        if playerEligibleSpecs[specName] then
            local specTooltipLines = buildRaidSpecOddsLines(playerClassName, specName, raidSource)
            for _, specTooltipLine in ipairs(specTooltipLines) do
                tooltip:AddLine(specTooltipLine, tooltipColor.r, tooltipColor.g, tooltipColor.b)
            end
        end
    end
end

local function tooltipHandler(tooltip, data) -- surely I don't have to nilcheck tooltip and data?
    if not data then
        print("Error, data does not exist - GreatVaultOdds")
        Utils.addToDevTool(data, "GreatVaultOdds - plain data for "..tooltip:GetName()) -- Might get a nil error here if tooltip also doesn't exist? Wanted to use CopyTable(data) but if data is nil will error.
        return
    end

    local itemID = data.id -- https://warcraft.wiki.gg/wiki/Struct_TooltipData
    if not activeLootDB then return end -- redundant, tooltip handler should never be registered without a valid DB
    if activeLootDB.eligibleItems[itemID] then -- itemID exists in current season dungeons
        local itemEntry = activeLootDB.eligibleItems[itemID]
        local sourceInfo = itemEntry.sources
        if not sourceInfo then return end
        local raidSource = sourceInfo.raid
        local hasDungeonSource = sourceInfo.instanceID and sourceInfo.encounterID
        if not (raidSource or hasDungeonSource) then return end -- Maybe we still want to display the tooltip anyway, for the totals? If not, maybe don't need separate early returns?
        local devModeActive = GreatVaultOddsAddonOptions.devMode
        tooltip:AddLine(" ") -- Add a gap between the last tooltip line and our tooltip
        if raidSource then
            tooltip:AddLine(ADDON_TOOLTIP_HEADER..":")
        else
            tooltip:AddLine(ADDON_TOOLTIP_HEADER..": "..DUNGEON_LOOT_SOURCE_TOOLTIP_HEADER)
        end

        if devModeActive then -- Dirty hack to see all specs in devMode
            local classTooltipsByID = {}
            for className, classData in pairs(classSpecIDs) do
                if activeLootDB.eligibleItems[itemID][className] then
                    local eligibleSpecs = {}
                    for specName in pairs(classData.specData) do
                        if activeLootDB.eligibleItems[itemID][className][specName] then
                            table.insert(eligibleSpecs, specName)
                        end
                    end
                    table.sort(eligibleSpecs)
                    local finalTooltip = ""
                    for _, sortedSpecName in ipairs(eligibleSpecs) do
                        if raidSource then
                            local specTooltipLines = buildRaidSpecOddsLines(className, sortedSpecName, raidSource)
                            for _, specTooltipLine in ipairs(specTooltipLines) do
                                finalTooltip = finalTooltip..specTooltipLine.." "
                            end
                            finalTooltip = finalTooltip.."|| Instance Items: "..activeLootDB.eligibleItemCount[className][sortedSpecName].raidTotals[raidSource.journalInstanceID].totalItems.." "
                        else
                            local specTooltipLine = buildDungeonSpecOddsLine(className, sortedSpecName, sourceInfo)
                            if specTooltipLine then
                                finalTooltip = finalTooltip..specTooltipLine.." "
                            end
                        end
                    end
                    classTooltipsByID[classData.classID] = finalTooltip -- Could check if ~="", can store an empty tooltip if finalTooltip is still the empty string, though this should never occur unless a class isn't valid. But if it isn't valid it won't be here, and if it is valid then it will have a corresponding spec and tooltip unless db is malformed/corrupted, but I notice that before shipping.
                    -- I am only indexing by classID so that I can simply use table.sort for the final tooltip to be sorted "Blizz-like"
                    -- I could just sort by classSpecIDs[className].classID
                end
            end
            local eligibleClasses = {}
            for classID in pairs(classTooltipsByID) do
                table.insert(eligibleClasses, classID)
            end
            table.sort(eligibleClasses)
            for _, classID in ipairs(eligibleClasses) do
                local tooltipColor = Utils.getTooltipColorForClass(classID)
                tooltip:AddLine(classTooltipsByID[classID], tooltipColor.r, tooltipColor.g, tooltipColor.b) -- will add custom text wrapping as a config option
            end
        else -- The normal path for the end-user tooltip, sorry it's here at the bottom. I will invert the if block I promise.
            if raidSource then
                appendPlayerClassRaidTooltipLines(tooltip, itemID, raidSource)
            else
                appendPlayerClassDungeonTooltipLines(tooltip, itemID, sourceInfo)
            end
        end
    end
end

function Tooltip.SetActiveLootDB(lootDB)
    activeLootDB = lootDB
end

function Tooltip.RegisterTooltipHandler()
    if TooltipDataProcessor then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, tooltipHandler)
    end
end

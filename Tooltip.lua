local addonName, GreatVaultOddsNS = ...
GreatVaultOddsNS.Tooltip = GreatVaultOddsNS.Tooltip or {}

local classSpecIDs = GreatVaultOddsNS.ClassSpecIDs
local Utils = GreatVaultOddsNS.Utils
local Tooltip = GreatVaultOddsNS.Tooltip
local DBGenerator = GreatVaultOddsNS.DBGenerator

local activeLootDB

local playerSpecNames
local playerClassName
local hasSortedPlayerSpecs = false

local tooltipStyle = { -- Includes future tooltip format styles
    dropRateSeparator = {"||", " || ", "  || ", " / ", "  / ", ", "},
    lootSourceSeparator = {"||", " || ", "  || ", " / ", "  / ", ", "},
    specLabel = ": "
}

local activeSeparator = tooltipStyle.lootSourceSeparator[2]

local ADDON_TOOLTIP_HEADER = "GreatVaultOdds"
local LOOT_SOURCE_TOOLTIP_HEADER = "Vault"..activeSeparator.."M+"..activeSeparator.."Boss"

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
    local specCounts = activeLootDB.eligibleItemCount[className] and activeLootDB.eligibleItemCount[className][specName]
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

    local tooltipColor = Utils.getTooltipColorForClass(playerClassName)
    local playerEligibleSpecs = activeLootDB.eligibleItems[itemID][playerClassName]
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
        Utils.addToDevTool(data, "GreatVaultOdds - plain data for "..tooltip:GetName()) -- Might get a nil error here if tooltip also doesn't exist? Wanted to use CopyTable(data) but if data is nil will error.
        return
    end

    local itemID = data.id -- https://warcraft.wiki.gg/wiki/Struct_TooltipData
    if not activeLootDB then return end -- redundant, tooltip handler should never be registered without a valid DB
    if activeLootDB.eligibleItems[itemID] then -- itemID exists in current season dungeons
        local itemEntry = activeLootDB.eligibleItems[itemID]
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
                        local specTooltipLine = buildSpecOddsLine(className, sortedSpecName, instanceID, encounterID)
                        if specTooltipLine then
                            finalTooltip = finalTooltip..specTooltipLine.." "
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
            appendPlayerClassTooltipLines(tooltip, itemID, instanceID, encounterID)
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

---@diagnostic disable: undefined-global
-- Collects data for eligible specs and concatenates them into "chunks". Uses a frame + font string for that frame to determine the width of the tooltip.
-- If the tooltip + a new chunk is too wide, displays the tooltip and starts making a new tooltip with the new chunk, otherwise it keeps building the tooltip with new chunks.
-- When a new chunk is generated with a different class, the specs start on a new line.

local measureFrame = CreateFrame("Frame")
local measureText = measureFrame:CreateFontString(nil, "ARTWORK", "GameTooltipText")
measureText:SetJustifyH("LEFT")

local SPEC_TOOLTIP_MAX_WIDTH = 260
local SPEC_TOOLTIP_COLOR = { 1, 0.82, 0 }
local ENTRY_GAP = " "

local function TextWidth(text)
    measureText:SetText(text or "")
    return measureText:GetStringWidth()
end

local function MakeSpecChunk(iconMarkup, specName, oddsText)
    return string.format("%s %s: %s", iconMarkup, specName, oddsText)
end

local function AddPackedChunksAsLines(tooltip, chunks, maxWidth)
    local currentLine = ""

    for i = 1, #chunks do
        local chunk = chunks[i]
        local candidate = currentLine == "" and chunk or (currentLine .. ENTRY_GAP .. chunk)

        -- If candidate tooltip is too wide, displays the old tooltip and starts a new chunk. Otherwise continues expanding tooltip.
        if currentLine == "" or TextWidth(candidate) <= maxWidth then
            currentLine = candidate
        else
            tooltip:AddLine(currentLine, SPEC_TOOLTIP_COLOR[1], SPEC_TOOLTIP_COLOR[2], SPEC_TOOLTIP_COLOR[3], false)
            currentLine = chunk
        end
    end

    if currentLine ~= "" then
        tooltip:AddLine(currentLine, SPEC_TOOLTIP_COLOR[1], SPEC_TOOLTIP_COLOR[2], SPEC_TOOLTIP_COLOR[3], false)
    end
end

-- Unnecessary if we choose to use later loop/discard AddClassGroupedSpecLines func call
local function AddClassGroupedSpecLines(tooltip, classGroups, eligibleClassNames, maxWidth)
    for _, className in ipairs(eligibleClassNames) do
        AddPackedChunksAsLines(tooltip, classGroups[className], maxWidth)
    end
end

-- Dev branch
local classGroups = {}

for className, classData in pairs(classSpecIDs) do
    if seasonLootDB.eligibleItems[itemID][className] then -- ensure sub-tables exist first ofc
        local eligibleSpecs = {}

        for specName in pairs(classData.specData) do
            if seasonLootDB.eligibleItems[itemID][className][specName] then
                table.insert(eligibleSpecs, specName)
            end
        end

        table.sort(eligibleSpecs)

        if #eligibleSpecs > 0 then -- Probably unnecessary because if itemID exists there is an eligible spec unless I manually mess up database.
            classGroups[className] = {}

            for _, specName in ipairs(eligibleSpecs) do
                local iconID = classData.specData[specName].iconID
                local oddsText = "1/" .. seasonLootDB.eligibleItemCount[className][specName].allSlots
                local chunk = MakeSpecChunk("|T" .. iconID .. ":0|t", specName, oddsText)
                table.insert(classGroups[className], chunk)
            end
        end
    end
end

tooltip:AddLine("GreatVaultOdds:")

local eligibleClassNames = {}
for className in pairs(classGroups) do
    table.insert(eligibleClassNames, className)
end

table.sort(eligibleClassNames, function(a, b)
    return classSpecIDs[a].classID < classSpecIDs[b].classID
end)

-- Makes and displays the tooltip, separated by class. Can be replaced by AddClassGroupedSpecLines func call
for _, className in ipairs(eligibleClassNames) do
    AddPackedChunksAsLines(tooltip, classGroups[className], SPEC_TOOLTIP_MAX_WIDTH)
end

-- Can be replaced by above loop
AddClassGroupedSpecLines(tooltip, classGroups, eligibleClassNames, SPEC_TOOLTIP_MAX_WIDTH)

-- Regular user branch
local specChunks = {}

for _, specName in ipairs(playerSpecNames) do
    if seasonLootDB.eligibleItems[itemID][playerClassName][specName] then
        local iconID = classSpecIDs[playerClassName].specData[specName].iconID
        local oddsText = "1/" .. seasonLootDB.eligibleItemCount[playerClassName][specName].allSlots
        local chunk = MakeSpecChunk("|T" .. iconID .. ":0|t", specName, oddsText)
        table.insert(specChunks, chunk)
    end
end

if #specChunks > 0 then
    tooltip:AddLine("GreatVaultOdds:")
    AddPackedChunksAsLines(tooltip, specChunks, SPEC_TOOLTIP_MAX_WIDTH)
end

-- Example table structure
local classGroups = {
    WARRIOR = {
        MakeSpecChunk("|T136146:0|t", "Arms", "1/56"),
        MakeSpecChunk("|T132347:0|t", "Fury", "1/56"),
        MakeSpecChunk("|T132341:0|t", "Protection", "1/60"),
    },
    ROGUE = {
        MakeSpecChunk("|T236270:0|t", "Assassination", "1/57"),
        MakeSpecChunk("|T132320:0|t", "Outlaw", "1/60"),
        MakeSpecChunk("|T132303:0|t", "Subtlety", "1/57"),
    },
}

-- Better to store the original info per spec/class and build the text chunk later. Example info.
classGroups = {
    WARRIOR = {
        {
            className = "WARRIOR", -- Porbably unnecessary key
            classID = 1,
            specName = "Arms",
            iconID = 132355,
            oddsDenominator = 56,
        },
        {
            className = "WARRIOR",
            classID = 1,
            specName = "Fury",
            iconID = 132347,
            oddsDenominator = 56,
        },
    },
    ROGUE = {
        {
            className = "ROGUE",
            classID = 4,
            specName = "Assassination",
            iconID = 236270,
            oddsDenominator = 57,
        },
    },
}

-- Full example w/ re-used code
local measureFrame = CreateFrame("Frame")
local measureText = measureFrame:CreateFontString(nil, "ARTWORK", "GameTooltipText")
measureText:SetJustifyH("LEFT")

local SPEC_TOOLTIP_MAX_WIDTH = 260
local SPEC_TOOLTIP_COLOR = { 1, 0.82, 0 }
local ENTRY_GAP = "  "

local function TextWidth(text)
    measureText:SetText(text or "")
    return measureText:GetStringWidth()
end

local function MakeSpecChunk(iconMarkup, specName, oddsText)
    return string.format("%s %s: %s", iconMarkup, specName, oddsText)
end

-- Requires new function to make the chunk from the spec/class info
local function MakeSpecChunkFromEntry(entry)
    local iconMarkup = "|T" .. entry.iconID .. ":0|t"
    local oddsText = "1/" .. entry.oddsDenominator
    return MakeSpecChunk(iconMarkup, entry.specName, oddsText)
end

local function AddPackedChunksAsLines(tooltip, chunks, maxWidth)
    local currentLine = ""

    for i = 1, #chunks do
        local chunk = chunks[i]
        local candidate = currentLine == "" and chunk or (currentLine .. ENTRY_GAP .. chunk)

        if currentLine == "" or TextWidth(candidate) <= maxWidth then
            currentLine = candidate
        else
            tooltip:AddLine(currentLine, SPEC_TOOLTIP_COLOR[1], SPEC_TOOLTIP_COLOR[2], SPEC_TOOLTIP_COLOR[3], false)
            currentLine = chunk
        end
    end

    if currentLine ~= "" then
        tooltip:AddLine(currentLine, SPEC_TOOLTIP_COLOR[1], SPEC_TOOLTIP_COLOR[2], SPEC_TOOLTIP_COLOR[3], false)
    end
end

local function BuildClassGroupsForItem(itemID)
    local classGroups = {}

    for className, classData in pairs(classSpecIDs) do
        local eligibleItemClasses = seasonLootDB.eligibleItems[itemID]
        local eligibleSpecsForClass = eligibleItemClasses and eligibleItemClasses[className]

        if eligibleSpecsForClass then
            local entries = {}

            for specName in pairs(classData.specData) do
                if eligibleSpecsForClass[specName] then
                    table.insert(entries, { -- info stored per spec/class
                        className = className,
                        classID = classData.classID,
                        specName = specName,
                        iconID = classData.specData[specName].iconID,
                        oddsDenominator = seasonLootDB.eligibleItemCount[className][specName].allSlots,
                    })
                end
            end

            table.sort(entries, function(a, b)
                return a.specName < b.specName
            end)

            if #entries > 0 then
                classGroups[className] = entries
            end
        end
    end

    return classGroups
end

local function GetSortedEligibleClassNames(classGroups)
    local eligibleClassNames = {}

    for className in pairs(classGroups) do
        table.insert(eligibleClassNames, className)
    end

    table.sort(eligibleClassNames, function(a, b)
        return classSpecIDs[a].classID < classSpecIDs[b].classID
    end)

    return eligibleClassNames
end

local function AddClassGroupsToTooltip(tooltip, classGroups, eligibleClassNames, maxWidth)
    for _, className in ipairs(eligibleClassNames) do
        local entries = classGroups[className]
        local chunks = {}

        for i = 1, #entries do
            chunks[i] = MakeSpecChunkFromEntry(entries[i]) -- chunk created with spec/class info later
        end

        AddPackedChunksAsLines(tooltip, chunks, maxWidth)
    end
end

-- Usage
tooltip:AddLine("GreatVaultOdds:")

local classGroups = BuildClassGroupsForItem(itemID)
local eligibleClassNames = GetSortedEligibleClassNames(classGroups)

AddClassGroupsToTooltip(tooltip, classGroups, eligibleClassNames, SPEC_TOOLTIP_MAX_WIDTH)

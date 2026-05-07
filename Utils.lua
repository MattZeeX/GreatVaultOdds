local addonName, GreatVaultOddsNS = ...
GreatVaultOddsNS.Utils = GreatVaultOddsNS.Utils or {}
GreatVaultOddsNS.Tooltip = GreatVaultOddsNS.Tooltip or {}
GreatVaultOddsNS.DBGenerator = GreatVaultOddsNS.DBGenerator or {}
GreatVaultOddsNS.SlashCommands = GreatVaultOddsNS.SlashCommands or {}
GreatVaultOddsNS.Core = GreatVaultOddsNS.Core or {}

local classNameByID = GreatVaultOddsNS.ClassNameByID
local Utils = GreatVaultOddsNS.Utils
local Tooltip = GreatVaultOddsNS.Tooltip
local DBGenerator = GreatVaultOddsNS.DBGenerator

local classColors = RAID_CLASS_COLORS
local fallbackColor = CreateColor(1.000, 0.824, 0.000) or {r = 1, g = 0.824, b = 0}
local normalFontColor = NORMAL_FONT_COLOR or fallbackColor


-- addToDevTool
function Utils.addToDevTool(data, name)
    if not DevTool then return end -- or (not devMode and not debugLogging), can make a separate loggingEnabled function if wanna handle both

    if data ~= nil then -- Data could potentially be a meaningful false, I assume that there is no such thing as a meaningful nil here?
        DevTool:AddData(data, name)
    else
        DevTool:AddData(tostring(data), name)
    end
end

-- getClassColorTable
function Utils.getClassColorTable(className) -- Accepts classID or classFile and returns respective Class Color object
    if type(className) == "number" then -- className is ID, not classFile
        className = classNameByID[className]
    end

    return classColors[className]
end

-- getTooltipColorForClass
function Utils.getTooltipColorForClass(className) -- Accepts classID or classFile and returns respective Class Color object or fallbackColor object/table if missing
    return Utils.getClassColorTable(className) or normalFontColor
end

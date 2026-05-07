---@diagnostic disable: undefined-global
-- Counts and prints items that were already cached prior to generating the DB

local tempTable = {}
local tempCounter = 0 -- I need to reset these on each run. Presumably I was usually only uncaching items by relogging so wasn't an issue but in theory multiple runs in same session will trip on itself with this. Delete on alreadyRan

-- turn this into a function that is enabled on dev mode or maybe on logging
if not alreadyRan and not tempTable[itemID] then -- alreadyRan false when the DB gen function was called for the first time.
    tempTable[itemID] = true
    tempCounter = tempCounter + 1
    print(itemID, "Item "..itemInfo.name.." already cached")
end
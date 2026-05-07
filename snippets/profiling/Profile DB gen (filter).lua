---@diagnostic disable: undefined-global
-- Profiling DB gen filter method, with some func implementation commented out

local profileTable = {}
local runCount
local function generateDBForAllSpecsFilter(alreadyRan, profiling, doneCallback)
    local currentTime = debugprofilestop() -- do this at start of command because wanna only return the number once after both function calls happen
    if profiling then
        GreatVaultOddsDB = {}
        runCount = runCount + 1
    end
    local funcCount = 0 -- if checking number of func calls is as expected
    local cachedStatus = true
    -- local totalUncachedItems = 0
    local seenItems = {}

    if not lootDataCached then
        cachedStatus = false
        --if not seenItems[itemID] then
            --totalUncachedItems = totalUncachedItems + 1
            --seenItems[itemID] = true
        --end
    end

    local finalTime = debugprofilestop() - currentTime
    --if totalUncachedItems > 0 then
        --cachedStatus = false
    --end
    if funcCount > 219 then
        print("total funcs exceed 219", funcCount)
    end
    if profiling then
        if cachedStatus == true then
            profileTable.cached[runCount] = finalTime
        elseif cachedStatus == false then
            profileTable.notCached[runCount] = finalTime
        end
    end
    if not alreadyRan then
        C_Timer.After(0.5, function() generateDBForAllSpecsFunc(true, profiling, doneCallback) end) -- Run again after a delay to capture any loot that became cached after initial query
    else
        if doneCallback then
            doneCallback()
        end
    end
end
-- slash command
    if cmd == "profile" then
        print("Profiling started!")
        local startTotalProfileTime = debugprofilestop()
        local totalRunsToDo = 100
        local completedRuns = 0
        runCount = 0
        profileTable.cached = {}
        profileTable.notCached = {}

        local function onOneRunComplete()
            completedRuns = completedRuns + 1
            if completedRuns == totalRunsToDo then
                local endTotalProfileTime = debugprofilestop() - startTotalProfileTime
                local cachedTableTotal, notCachedTableTotal = 0, 0

                for _, v in pairs(profileTable.cached) do
                    cachedTableTotal = cachedTableTotal + v
                end
                for _, v in pairs(profileTable.notCached) do
                    notCachedTableTotal = notCachedTableTotal + v
                end

                profileTable.cached.total = cachedTableTotal
                profileTable.notCached.total = notCachedTableTotal

                addToDevTool(CopyTable(profileTable.cached), "cached profiles")
                addToDevTool(CopyTable(profileTable.notCached), "uncached profiles")

                print("Total profiling time expected to be near:", endTotalProfileTime)
                print("Total run count:", runCount)
            end
        end

        for i = 1, totalRunsToDo do
            generateDBForAllSpecsFilter(false, true, onOneRunComplete)
        end
    end

local addonName, GreatVaultOddsNS = ...
local devMode = true -- temporary
local debugLogging = false

if devMode or debugLogging then
    print("devMode:", devMode, "debugLogging:", debugLogging, "dingus!") -- print on login
end

--[[
-- TODO: For debugging, check if table already exists in index 1, if not, create it normally. If it does exist, when an item is found for a spec, check first indexed table and see if it is found, if true do nothing, if it is not found
-- make a new table equal to the highest index + 1 and store that item for class/spec as true. After all items have been collected, now loop through the original base table at index 1 and for each item/class/spec in that table
-- check the new table and if it does *not* exist, add it to the new table but equal to FALSE so we know it was missing. This way everything that is the same shouldn't be in new table, everything that was found that did not previously exist
-- should be noted in the new table, and everything that did previously exist but was not found this time is noted as FALSE in new table. Can repeat muiltiple times with new tables to see how many times the bug occurs. Important to note
-- that we should always make a new indexed table so that we know how many times we run, and if that index is only holds a blank table then we know that it was fully equal to the original table.

-- ABOVE is good in the sense that every time I generate a new table it checks, but what I think should do is set up a devmode where I can compare any 2 tables and it'll tell me the diffs, so I think I do actually wanna store the entire table and not just
-- the diffs, and then I can either print the diffs in human legible form or create a new table of diffs only and dump the table. First, make a new savedvariable for testing purposes, this is a table that stores other tables indexed (only reason it is indexed
-- is because it keeps it sorted if I wanna look at it in the file manually, but maybe don't care about that and can just have the key be the table "name" and then the following table I talk about below can be sorted and output therefore), and each table has a \
-- key that is the name of the table (which is their original index?? so if I delete it has the same name still), and then is ofc the table of loot eligiblity. Then on addonloaded, create a LOCAL table of subtables that has a key of name which is the name of the
-- table, and then a key of index which has the updated index of the table. Idea is in game I can /list the tables and see all the names, and then when I delete or add new ones the names are preserved but ofc index changes so this rememebers their index.
-- When table is created or deleted have to update this local table.
-- So there will be a command to compare 2 tables, with it comparign the 2nd arg to the 1st arg ofc. Also add a command to compare ALL tables to the selected table, so takes 1 arg and then ofc don't comapre that same table with itself casue redundant

-- SO ideal outputs could be 1. outputs sorted table so that I can use diffchecker, or 2. can just shows diffs in each new table (need some way to indicate that only the specs are different, spell id exists if possible), or 3. could make a table that has
-- the diffs in a human format, like a key of "all added item ids" and then value is the ids, and then "all missing item IDs" and then can have the keys of the item ids, with the true/false values of the missing/additional specs

-- add a command to set in debug mode, and don't allow you to use debug commands unless in debug mode? Set a debug flag up here. Also with debug flag enable devtool being added.
--]] -- after every item has been looped through, in debug mode if it existed already we did nothing and if it did not exist but we found it here we set it to true in new table, now we will now need to loop through the original table
    -- and compare all those items to ones in our new table, and if any exist in the original table but not the new table we set them to false in the new table to find all diffs

--[[
if cmd == help then
    print("/help does this")
    print("/defaults does that")
    if debug then
        print("/db compare does this")
        print("/db delete does that")
    end
end
]]

--[[ if diff table is empty, then set it to "no differences" or something
if next(myTable) == nil then
   -- myTable is empty
end
--]]

local cachedIDs = { -- cached specID, is there a way to get non localised version of spec name? will this be a problem? -- potentially worth separating into two tables like in dsune's addon with classes and specs as seperate tables indexed by numbers equal to classID
    WARRIOR = { -- classData table
        specData = {
            Arms = { -- specTable
                specID = 71,
                iconID = 132355
            },
            Fury = {
                specID = 72,
                iconID = 132347
            },
            Protection = {
                specID = 73,
                iconID = 132341
            }
        },
        classID = 1
    },
    PALADIN = {specData = {Holy = {specID = 65, iconID = 135920}, Protection = {specID = 66, iconID = 236264}, Retribution = {specID = 70, iconID = 135873}}, classID = 2},
    HUNTER = {specData = {["Beast Mastery"] = {specID = 253, iconID = 461112}, Marksmanship = {specID = 254, iconID = 236179}, Survival = {specID = 255, iconID = 461113}}, classID = 3},
    ROGUE = {specData = {Assassination = {specID = 259, iconID = 132292}, Outlaw = {specID = 260, iconID = 135340}, Subtlety = {specID = 261, iconID = 132320}}, classID = 4},
    PRIEST = {specData = {Discipline = {specID = 256, iconID = 135940}, Holy = {specID = 257, iconID = 237542}, Shadow = {specID = 258, iconID = 136207}}, classID = 5},
    DEATHKNIGHT = {specData = {Blood = {specID = 250, iconID = 135770}, Frost = {specID = 251, iconID = 135773}, Unholy = {specID = 252, iconID = 135775}}, classID = 6},
    SHAMAN = {specData = {Elemental = {specID = 262, iconID = 136048}, Enhancement = {specID = 263, iconID = 237581}, Restoration = {specID = 264, iconID = 136052}}, classID = 7},
    MAGE = {specData = {Arcane = {specID = 62, iconID = 135932}, Fire = {specID = 63, iconID = 135810}, Frost = {specID = 64, iconID = 135846}}, classID = 8},
    WARLOCK = {specData = {Affliction = {specID = 265, iconID = 136145}, Demonology = {specID = 266, iconID = 136172}, Destruction = {specID = 267, iconID = 136186}}, classID = 9},
    MONK = {specData = {Brewmaster = {specID = 268, iconID = 608951}, Mistweaver = {specID = 270, iconID = 608952}, Windwalker = {specID = 269, iconID = 608953}}, classID = 10},
    DRUID = {specData = {Balance = {specID = 102, iconID = 136096}, Feral = {specID = 103, iconID = 132115}, Guardian = {specID = 104, iconID = 132276}, Restoration = {specID = 105, iconID = 136041}}, classID = 11},
    DEMONHUNTER = {specData = {Havoc = {specID = 577, iconID = 1247264}, Vengeance = {specID = 581, iconID = 1247265}}, classID = 12},
    EVOKER = {specData = {Devastation = {specID = 1467, iconID = 4511811}, Preservation = {specID = 1468, iconID = 4511812}, Augmentation = {specID = 1473, iconID = 5198700}}, classID = 13},
}

local seasonLootEligibility = { -- in our table will need to assign like a slot id to the item so we know what to count as
    numValidItems = {
        DEATHKNIGHT = {
            Blood = {
                allSlots = 29, Head = 10, Weapon = 12, Body = 7,
            },
            Frost = {
                allSlots = 29,
                Head = 10,
                Weapon = 12,
                Body = 7,
            },
            Unholy = {
                allSlots = 29,
                Head = 10,
                Weapon = 12,
                Body = 7,
            },
        },
        WARLOCK = {
            Affliction = {
                allSlots = 69,
            },
            Destruction = {
                allSlots = 70,
            },
            Demonology = {
                allSlots = 71,
            },
        }
    },
    [234507] = {
        DEATHKNIGHT = {
            Blood = true, Frost = true, Unholy = true,
        },
        MAGE = {
            Fire = true, Frost = true, Arcane = true,
        },
        WARLOCK = {
            Affliction = true, Destruction = true, Demonology = true,
        },
        WARRIOR = {
            Protection = true, Arms = true, Fury = true,
        },
    },
    [157734] = {
        DEATHKNIGHT = {
            Blood = true, Frost = true, Unholy = true,
        },
        MAGE = {
            Fire = true, Frost = true, Arcane = true,
        },
        WARLOCK = {
            Affliction = true, Destruction = true, Demonology = true,
        },
    },
}

local function onEvent(self, event, loadedAddonName) -- what is best practice for naming this function if the event is caps
    if event == "ADDON_LOADED" and loadedAddonName == addonName then -- can this file run before addon is loaded? can I laod into the game before this addon is loaded? Do I need to not do anything until addon is loaded?
        GreatVaultOddsAddonOptions = GreatVaultOddsAddonOptions or {}
        GreatVaultOddsDB = GreatVaultOddsDB or {}
        GreatVaultOddsOutput = GreatVaultOddsOutput or {}
        GreatVaultOddsDumpDB = GreatVaultOddsDumpDB or {}
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", onEvent)

local function addToDevTool(data, name)
    if not DevTool then return end -- or (not devMode and not debugLogging), can make a separate loggingEnabled function if wanna handle both

    if data ~= nil then -- I assume that there is no such thing as a meaningful nil here? Remember, false is meaningful (loook up terminolgoy)
        DevTool:AddData(data, name)
    else
        DevTool:AddData(tostring(data), name) -- I assume there's no nil value that can't be coerced/cast as a string
    end
end

local function instanceIterator()
   local index = 0
   return function()
      local instanceID, instanceName, dungeonAreaMapID, isWorldBoss
      repeat
         index = index + 1
         instanceID = EJ_GetInstanceByIndex(index, false) -- dungeons only
         if not instanceID then return end
         EJ_SelectInstance(instanceID)  -- GET INSTANCE INFO RETURNS 0 FOR MAP ID UNTIL INSTANCE IS SELECTED!?@!?? AAAAAAAAAAAAAAAAAAAAAAAAAAAA
         instanceName, _, _, _, _, _, dungeonAreaMapID = EJ_GetInstanceInfo(instanceID)
         isWorldBoss = dungeonAreaMapID == 0
      until not isWorldBoss
      return instanceID, instanceName
   end
end

--[[
local function instanceIterator()
   local index = 0
   return function()
      index = index + 1
      local id = EJ_GetInstanceByIndex(index, false) -- dungeons only
      local instanceName, _, _, _, _, _, dungeonAreaMapID = EJ_GetInstanceInfo(instanceID)
      local isWorldBoss = dungeonAreaMapID == 0
      return id, instanceName, isWorldBoss
   end
end
--]]

local function disableEJ()
    if EncounterJournal then -- might have to call C_Addons.LoadAddon("Blizzard_EncounterJournal")
        EncounterJournal:UnregisterEvent("EJ_LOOT_DATA_RECIEVED")
        EncounterJournal:UnregisterEvent("EJ_DIFFICULTY_UPDATE")
        EncounterJournal:UnregisterEvent("UNIT_PORTRAIT_UPDATE")
        EncounterJournal:UnregisterEvent("PORTRAITS_UPDATED")
        EncounterJournal:UnregisterEvent("SEARCH_DB_LOADED")
        EncounterJournal:UnregisterEvent("UI_MODEL_SCENE_INFO_UPDATED")
    end
end

local function enableEJ()
    if EncounterJournal then
        EncounterJournal:RegisterEvent("EJ_LOOT_DATA_RECIEVED")
        EncounterJournal:RegisterEvent("EJ_DIFFICULTY_UPDATE")
        EncounterJournal:RegisterEvent("UNIT_PORTRAIT_UPDATE")
        EncounterJournal:RegisterEvent("PORTRAITS_UPDATED")
        EncounterJournal:RegisterEvent("SEARCH_DB_LOADED")
        EncounterJournal:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED")
    end
end

local function generateDBForAllSpecs(firstRun)
    local currentTime = debugprofilestop()
    GreatVaultOddsDB = {} -- wipe table for now, later will handle subtables for the DB
    EJ_SelectTier(EJ_GetNumTiers()) -- need to localise all wow funcs
    --disableEJ() -- if we unregister events we can browse EJ while the addon works and it doesn't overwrite what addon is doing???

    for className, classData in pairs(cachedIDs) do -- className = className, classData = table of specTable and classID 13
        for specName, specTable in pairs(classData.specData) do -- specName = specName, specTable = table of specID and iconID 3
            for instanceID, instanceName in instanceIterator() do -- make this the outer loop to reduce functions calls once I am certain selectinstance won't get overriden, or difficulty filter (or loot filters?)
                EJ_SelectInstance(instanceID) -- why risk it... I should probably just call this and difficulty on every iteration of loop to ensure nobody fucks with it :(
                EJ_SetDifficulty(DifficultyUtil.ID.DungeonChallenge) -- https://github.com/Gethe/wow-ui-source/blob/0b949009d9558869da5c53ac61c23f2d711b1f6f/Interface/AddOns/Blizzard_FrameXMLUtil/DifficultyUtil.lua#L1 I think difficulty resets because m+ doesn't exist tho?
                EJ_SetLootFilter(classData.classID, specTable.specID)
                C_EncounterJournal.SetSlotFilter(Enum.ItemSlotFilterType.NoFilter) -- presumably 15 is better for performance than this enum? cause it's a global? may want a local value in the future anyway when want to search specific slots
                for lootIndex = 1, EJ_GetNumLoot() do
                    local itemInfo = C_EncounterJournal.GetLootInfoByIndex(lootIndex)
                    local itemID = itemInfo and itemInfo.itemID
                    local lootDataCached = itemID and (itemInfo.name ~= nil)
                    if lootDataCached then
                        if not GreatVaultOddsDB then -- consider a function named ensureItemToSpecPath
                            GreatVaultOddsDB = {}
                        end
                        if not GreatVaultOddsDB[itemID] then
                            GreatVaultOddsDB[itemID] = {}
                        end
                        if not GreatVaultOddsDB[itemID][className] then
                            GreatVaultOddsDB[itemID][className] = {}
                        end
                        if GreatVaultOddsDB[itemID][className][specName] then -- Get corresponding item slot and increment that item slot if the item did not previously exist for this spec, and increment the total slots too
                            -- for table comparison, if doesn't exist in our original table then set it to true in comparison table otherwise don't set it to true
                            addToDevTool(itemID, "Item "..itemInfo.name.." already cached for: "..className.." - "..specName)
                        end
                        GreatVaultOddsDB[itemID][className][specName] = true
                    end
                end
            end
        end
    end
    --enableEJ()
    print((debugprofilestop() - currentTime).." milliseconds elapsed")
    -- check if table dump exists, if not - create it
    -- display resulting dump to a frame (define frame outside so new one not created each time?)
    if not firstRun then
        C_Timer.After(0.2, function() generateDBForAllSpecs(true) end)
    end
end

SLASH_GREATVAULTODDS1 = "/gvodds" -- add great vault odds
function SlashCmdList.GREATVAULTODDS(msg, editBox) -- make msg lowercase
    msg = msg:lower()
    local cmd, subCmd, arg1, arg2 = strsplit(' ', msg)

    if cmd == "dev" then -- probably goes at the end of the elseif eventually
        devMode = not devMode -- toggle on/off
        print("Devmode active:", devMode) -- true or false

    elseif cmd == "help" then
        print("|cFFE6CC99Great Vault Odds:|r |cFF66BBFFhelp menu|r") -- Make a prefix print and colour function
        print("options - displays configurable options")
        print("|cFF66BBFFreset - resets all options to their defaults.|r") -- test colour
        print("dev - toggles dev mode")
        if devMode then
            print("db list: Lists all stored databases")
            print("db gen: Generates a new database")
            print("db compare <list1> [<list2>] - Compares two databases to find errors") -- list 2 optional, compare against main if not there
            print("db compare all - compares all databases to the main one") -- need to add an optional arg to choose which list to compare against
            print("db delete <list>: Deletes the specified table")
            print("debug: Enables DevTool notes to troubleshoot database creation")
        end
        print("----------------------------------------")

    elseif cmd == "db" then -- need to handle args now
        if subCmd == "compare" then
            if arg1 == "all" then
                if GreatVaultOddsDB[arg2] then
                    -- compare all tables to the specified table from arg2
                else
                    print(arg2, "is not a valid table. Comparing all tables to: ") -- get whatever table 1 is, or whatever is designated as the main table (flag maybe?)
                end
            elseif GreatVaultOddsDB[arg1] then -- first need to check if arg1 is not nil probably 
                if GreatVaultOddsDB[arg2] then
                    print("Comparing", arg1, "with", arg2) -- compare arg1 table with arg2 table with arg1 table acting as the original
                else
                    print("Table 2 not provided or", arg2, "is not a valid table. Comparing", arg1, "with: ") -- compare with main table. Maybe can merge this with above if because 2 ifs check for arg2. Also here maybe distinguish between
                    -- arg2 not existing vs not being a valid table
                end
            else
                print(arg1, "is not a valid table") -- can we also check if arg2 is a valid table or if it was supposed to be? Can check if arg2 is nil and if not nil then check if it's a valid table and if not say that it is ALSO not a valid table.
            end
        end

    elseif cmd == "gen" then -- should be subcmd ofc
        generateDBForAllSpecs()
    elseif cmd == "reset" then
        print("resetting table")
        GreatVaultOddsDB = {}
        -- delete the dumped table. Not sure if need to nil check first.
        -- just for recreating the table if idk the function got interrupted or fucked in some way?
    else
        print("unrecognized command", cmd)
    end
end

-- TODO: might need checks for addonLoaded for saved variables and stuff
local function tooltipHandler(tooltip, data) -- surely I don't have to nilcheck tooltip and data?
--[[ I think we want to add our data to ALL tooltips, not just gametooltip
    if tooltip ~= GameTooltip then -- nil check tooltip first
        --print("Error, tooltip: "..tooltip.." is not GameTooltip - GreatVaultOdds") -- or don't concatenate a nil value
        print("Error: tooltip is not GameTooltip - GreatVaultOdds")
        print("Tooltip Name: "..tooltip:GetName())
        if DevTool then
            DevTool:AddData(CopyTable(tooltip), "GreatVaultOdds - "..tooltip:GetName())
            DevTool:AddData(CopyTable(data), "GreatVaultOdds - "..tooltip:GetName().."data")
        end
    end
    --]]

    if not data then
        print("Error, data does not exist - GreatVaultOdds")
        addToDevTool(CopyTable(data), "GreatVaultOdds - plain data for "..tooltip:GetName()) -- might get a nil error here if tooltip also doesn't exist?
    else
        local itemID = data.id -- https://warcraft.wiki.gg/wiki/Struct_TooltipData
        if seasonLootEligibility[itemID] then -- itemID exists in current season dungeons
            local tooltipText = "GreatVaultOdds: "
            -- define tooltipText after className and append the className (need to use localised version, so UnitClass)
            local className, classID = UnitClassBase("player") -- in the future, might wanna call this outside of the handler to reduce function calls, do once player login and then watch event player loot spec changed or spec changed(is that an event?)
            local specID = GetLootSpecialization() -- rename variable to current loot spec
            -- local specID = GetLootSpecialization() > 0 and GetLootSpecialization() or GetSpecializationInfo(GetSpecialization()) -- probably too convoluted

            if specID == 0 then -- loot spec is set to current specialisation
                local specIndex = GetSpecialization()
                specID = GetSpecializationInfo(specIndex) -- GetSpecializationInfoForSpecID for future if we want to look at classes other than the player?                
            end
             
            -- specID should be leftText, others be rightText MAYBE??? Code doesn't reflect this right now but that is why I saved specID
            for spec, specTable in pairs(cachedIDs[className].specData) do -- gets all specs for a class, add .specID or whatever if I combine specid and icon id. right now I don't use the specid but maybe I will? -- in order to preserve the order, 
            -- specid in wow is done by alphabetical spec name, so can put the keys that are the specs in an array, table.sort them, and then loop through that array with ipairs to call the corresponding key in the normal table
            -- would this be bad performance wise to sort a table everytime I hover over item tooltip? How would I cache this? Do it this way first, then optimise later.
                if not seasonLootEligibility[itemID][className] then -- why is this in loop?
                    tooltipText = tooltipText.." item is not loot eligible for your class!" -- this will appear for all items that are in the database but not eligible for to be looted by this class. Do we want it to say anything? Or better to be blank?
                    break
                else -- item is loot eligible for the class, can combine this with the next line
                    if seasonLootEligibility[itemID][className][spec] then -- item is loot eligble for the spec
                    tooltipText = tooltipText..spec..": 1/"..seasonLootEligibility.numValidItems[className][spec].allSlots.." " -- want to sort this to go in order of index or table, rn is random -- NIL CHECK NUMVALID ITEMS AAAAAAAAAAAAAAAAAAAAA
                    else
                        -- not loot eligible, do nothing for now
                    end
                end
            end
            tooltip:AddLine(tooltipText)--, red, green, blue, wrapText)
        end
    end
end

    -- TODO: check other addons like pawn to get tooltip inspiration
    -- tooltip:AddLine(tooltipText, red, green, blue, wrapText)
    -- tooltip:AddDoubleLine(leftText, rightText, leftR, leftG, leftB, rightR, rightG, rightB)
    -- GameTooltip:AddLine("|T"..itemTexture..":0|t ")
    -- Do I have to handle this: The tooltip resizes in its OnShow handler,[1] so calling this function on an already-visible tooltip will cause the new line to appear outside of the tooltip's backdrop.



--[[
for className, classData in pairs(cachedIDs) do -- className = className, classData = table of specTable and classID 13
    for specName, specTable in pairs(classData.specData) do -- specName = specName, specTable = table of specID and iconID 3
            EJ_SetLootFilter(classData.classID, specTable.specID) -- classID = 1, specID = 71, 72, 73
            local itemID = exampleFunc
            if not seasonLootEligibility[itemID] then -- HAVE TO MAKE seasonLootEligibility FIRST OR NILCHECK TABLE FIRST
                seasonLootEligibility[itemID] = {} -- technically don't wanna create a table for an itemid unless it is lootable by any spec, but at this point I am assuming it is on the loot table of some spec
            end

            if not seasonLootEligibility[itemID][className] then
                seasonLootEligibility[itemID][className] = {}
            end

            seasonLootEligibility[itemID][className][specName] = true -- probably don't need to nil check here because the above code ensures this will never be nil?
    end
end

--]]

if TooltipDataProcessor then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, tooltipHandler)
end






--[[
for the table etc etc
if specFromTable == current spec then
    left text = current spec
else
    right text = right text .. some value
--]]

--[[
local timer
val = 100
for i = 1, i < val do
    if not timer then
        timer = C_Timer.NewTimer(1, function() print("in 1 second we tested x iterations") end)
    end
end
if timer then -- check if this even can be false
    timer:Cancel()
end
]]
local addonName, GreatVaultOddsNS = ...

-- TODO: For debugging, check if table already exists in index 1, if not, create it normally. If it does exist, when an item is found for a spec, check first indexed table and see if it is found, if true do nothing, if it is not found
-- make a new table equal to the highest index + 1 and store that item for class/spec as true. After all items have been collected, now loop through the original base table at index 1 and for each item/class/spec in that table
-- check the new table and if it does *not* exist, add it to the new table but equal to FALSE so we know it was missing. This way everything that is the same shouldn't be in new table, everything that was found that did not previously exist
-- should be noted in the new table, and everything that did previously exist but was not found this time is noted as FALSE in new table. Can repeat muiltiple times with new tables to see how many times the bug occurs. Important to note
-- that we should always make a new indexed table so that we know how many times we run, and if that index is only holds a blank table then we know that it was fully equal to the original table.

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
    if event == "ADDON_LOADED" and loadedAddonName == addonName then
        GreatVaultOddsDB = GreatVaultOddsDB or {}
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", onEvent)

local function debugHandler(msg, editBox) -- make lowercase
    if msg == "debug" then
        print("debugging now!")
        -- local currentTime = GetTime()
        local currentTime = GetTimePreciseSec()

        if EncounterJournal then -- put in a function --on first login ej isn't loaded so events aren't unregistered, if we unregister events we can browse EJ while the addon works and it doesn't overwrite what addon is doing???
            EJ_SelectTier(EJ_GetNumTiers()) -- test if this selects currently selected tier if given nil or if it always selects the last one/current season?
            EncounterJournal:UnregisterEvent("EJ_LOOT_DATA_RECIEVED")
            EncounterJournal:UnregisterEvent("EJ_DIFFICULTY_UPDATE")
            EncounterJournal:UnregisterEvent("UNIT_PORTRAIT_UPDATE")
            EncounterJournal:UnregisterEvent("PORTRAITS_UPDATED")
            EncounterJournal:UnregisterEvent("SEARCH_DB_LOADED")
            EncounterJournal:UnregisterEvent("UI_MODEL_SCENE_INFO_UPDATED") -- ?
        end

        for className, classData in pairs(cachedIDs) do -- className = className, classData = table of specTable and classID 13
            for specName, specTable in pairs(classData.specData) do -- specName = specName, specTable = table of specID and iconID 3
                local instanceIndex = 1
                local instanceID = EJ_GetInstanceByIndex(instanceIndex, false) -- dungeons only, not raids
                while instanceID do -- maybe better to have while loop be the outer loop and for loop the inner loop cause currentl we change the EJ for each spec, but with loop outside we change it only 8 times (num dungeons) and get all the loot for each spec in the loop
                    EJ_SelectInstance(instanceID)
                    local instance_name, _, _, _, _, _, dungeonAreaMapID = EJ_GetInstanceInfo(instanceID)
                    local isWorldBoss = dungeonAreaMapID == 0
                    if not isWorldBoss then
                        EJ_SetDifficulty(DifficultyUtil.ID.DungeonChallenge)
                        EJ_SetLootFilter(classData.classID, specTable.specID) -- could define these as local vars lol -- in this code example, should probably call lootfilter and difficulty outside the loop, assuming they stick when I open a new instance in the encounter journal. I think difficulty resets because m+ doesn't exist tho?
                        C_EncounterJournal.SetSlotFilter(Enum.ItemSlotFilterType.NoFilter) -- presumably 15 is better for performance than this enum? cause it's a global? may want a local value in the future anyway when want to search specific slots
                        for lootIndex = 1, EJ_GetNumLoot() do
                            local itemInfo = C_EncounterJournal.GetLootInfoByIndex(lootIndex)
                            if itemInfo and itemInfo.itemID then
                                local itemID = itemInfo.itemID

                                if not GreatVaultOddsDB then GreatVaultOddsDB = {} end -- take out all these if nots and make a function maybe for clarify, called nilCheckTable or initialiseTables or initialiseEmptyTables initialiseNilTables
                                -- if table doesn't exist and we are in debug mode then cancel debug mode and generate table normally DOUBLE CHECK WHAT HAPPENS IF SAVED VARIABLES IS EMPTY, DOES IT SAVE A BLANK TABLE??
                                --[[ Is this sillier?
                                    GreatVaultOddsDB = GreatVaultOddsDB or {}
                                --]]

                                if not GreatVaultOddsDB[itemID] then
                                    -- if debug mode then add to our new table
                                    -- else do as normal below
                                    GreatVaultOddsDB[itemID] = {} -- technically don't wanna create a table for an itemid unless it is lootable by any spec, but at this point I am assuming it is on the loot table of some spec
                                end
                    
                                if not GreatVaultOddsDB[itemID][className] then
                                    -- if debug mode then add to our new table
                                    -- else do as normal below
                                    GreatVaultOddsDB[itemID][className] = {}
                                end

                                -- if debug mode then check if specName = true in original true, if yes then do nothing, if it doesn't exist then set it to true in our current table
                                -- else do as normal below (might check if it exists in original table anyway, and if true then do nothing cause why overwrite, and this can help handle our debug logic from above)
                    
                                -- check if this is not true and then do it otherwise do nothing? Does that optimise performance in any way xD?
                                GreatVaultOddsDB[itemID][className][specName] = true -- probably don't need to nil check here because the above code ensures this will never be nil?
                                -- also get corresponding item slot and increment that item slot if the item did not previously exist for this spec and increment the total slots too
                            end
                        end
                    end
                    instanceIndex = instanceIndex + 1
                    instanceID = EJ_GetInstanceByIndex(instanceIndex, false) -- can I find num of instance indexes so I can make this a for loop? Even not, surely can use a statelses iterator instead of a manual one??
                end
            end
        end -- after every item has been looped through, in debug mode if it existed already we did nothing and if it did not exist but we found it here we set it to true in new table, now we will now need to loop through the original table
        -- and compare all those items to ones in our new table, and if any exist in the original table but not the new table we set them to false in the new table to find all diffs

        if EncounterJournal then
            EncounterJournal:RegisterEvent("EJ_LOOT_DATA_RECIEVED")
            EncounterJournal:RegisterEvent("EJ_DIFFICULTY_UPDATE")
            EncounterJournal:RegisterEvent("UNIT_PORTRAIT_UPDATE")
            EncounterJournal:RegisterEvent("PORTRAITS_UPDATED")
            EncounterJournal:RegisterEvent("SEARCH_DB_LOADED")
            EncounterJournal:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED")
        end

        print((GetTimePreciseSec() - currentTime).." seconds elapsed")
        -- print("This took "..(SecondsToTime(GetTime()-currentTime)))
        -- print("This took "..(GetTime()-currentTime).." seconds")
        -- check if table dump exists, if not - create it
        -- display resulting dump to a frame (define frame outside so new one not created each time?)
        -- also save to saved variables in case
    elseif msg == "reset" then
        print("resetting table")
        -- delete the dumped table. Not sure if need to nil check first.
        -- just for recreating the table if idk the function got interrupted or fucked in some way?
    end
end

SLASH_GREATVAULTODDS1 = "/gvodds"
SlashCmdList.GREATVAULTODDS = debugHandler

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
        if DevTool then DevTool:AddData(CopyTable(data), "GreatVaultOdds - plain data for "..tooltip:GetName()) end -- might get a nil error here if tooltip also doesn't exist?
    else
        local itemID = data.id
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
                    tooltipText = tooltipText..spec..": 1/"..seasonLootEligibility.numValidItems[className][spec].allSlots.." " -- want to sort this to go in order of index or table, rn is random
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
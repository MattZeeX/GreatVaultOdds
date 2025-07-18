---@diagnostic disable: undefined-global
-- Unused snippets from tooltip handler, to format tooltip with current loot spec on left

local playerSpec = {}
local playerClass
local firstTooltipRun = true
local function tooltipHandler(tooltip, data) -- surely I don't have to nilcheck tooltip and data?
    if not data then
        print("Error, data does not exist - GreatVaultOdds")
        addToDevTool(CopyTable(data), "GreatVaultOdds - plain data for "..tooltip:GetName()) -- might get a nil error here if tooltip also doesn't exist?
    else
        local itemID = data.id -- https://warcraft.wiki.gg/wiki/Struct_TooltipData
        if seasonLootEligibility.eligibleItems[itemID] then -- itemID exists in current season dungeons
        -- Do we need to nilCheck seasonLootEligibility and then eligible items AND eligible item count, and then we can check for item id, and then class, and then spec if necessary, and then slot if count
            local tooltipText = "GreatVaultOdds: "

            if firstTooltipRun then
                -- define tooltipText after className and append the className (need to use localised version, so UnitClass)
                playerClass, _ = UnitClassBase("player") -- in the future, might wanna call this outside of the handler to reduce function calls, do once player login and then watch event player loot spec changed or spec changed(is that an event?)
                for specName, _ in pairs(cachedIDs[playerClass].specData) do -- specName, specTable
                    table.insert(playerSpec, specName)
                end
                table.sort(playerSpec) -- double check sorted the same way we have in our table
                -- local specID = GetLootSpecialization() -- rename variable to current loot spec
                -- local specID = GetLootSpecialization() > 0 and GetLootSpecialization() or GetSpecializationInfo(GetSpecialization()) -- probably too convoluted
                -- specID should be leftText, others be rightText MAYBE??? Code doesn't reflect this right now but that is why I saved specID
                --[[
                if specID == 0 then -- loot spec is set to current specialisation
                    local specIndex = GetSpecialization()
                    specID = GetSpecializationInfo(specIndex)
                end
                --]]
                firstTooltipRun = false
            end
            -- gets all specs for a class, add .specID or whatever if I combine specid and icon id. right now I don't use the specid but maybe I will? -- in order to preserve the order,
            -- specid in wow is done by alphabetical spec name, so can put the keys that are the specs in an array, table.sort them, and then loop through that array with ipairs to call the corresponding key in the normal table
            -- would this be bad performance wise to sort a table every time I hover over item tooltip? How would I cache this? Do it this way first, then optimise later.

            for _, specName in ipairs(playerSpec) do
                if not seasonLootEligibility.eligibleItems[itemID][playerClass] then -- why is this in loop?
                    tooltipText = tooltipText.." item is not loot eligible for your class!" -- this will appear for all items that are in the database but not eligible for to be looted by this class. Do we want it to say anything? Or better to be blank?
                    break
                else -- item is loot eligible for the class, can combine this with the next line
                    --[[
                    for the table etc etc
                    if specFromTable == current spec then
                        left text = current spec
                    else
                        right text = right text .. some value
                    --]]
                    if seasonLootEligibility.eligibleItems[itemID][playerClass][specName] then -- item is loot eligible for the spec
                    local iconID = cachedIDs[playerClass].specData[specName].iconID
                    local iconText = "|T"..iconID..":0|t"
                    tooltipText = tooltipText..iconText.." "..specName..": 1/"..seasonLootEligibility.eligibleItemCount[playerClass][specName].allSlots.." " -- want to sort this to go in order of index or table, rn is random -- NIL CHECK NUMVALID ITEMS AAAAAAAAAAAAAAAAAAAAA
                    else
                        -- not loot eligible, do nothing for now
                    end
                end
            end
            tooltip:AddLine(tooltipText)--, red, green, blue, wrapText)
            -- tooltip:AddDoubleLine(leftText, rightText, leftR, leftG, leftB, rightR, rightG, rightB)
            -- Do I have to handle this: The tooltip resizes in its OnShow handler,[1] so calling this function on an already-visible tooltip will cause the new line to appear outside of the tooltip's backdrop.
        end
    end
end
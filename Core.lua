local addonName, GreatVaultOddsNS = ...

local Utils = GreatVaultOddsNS.Utils
local Tooltip = GreatVaultOddsNS.Tooltip
local DBGenerator = GreatVaultOddsNS.DBGenerator
local SlashCommands = GreatVaultOddsNS.SlashCommands
local Core = GreatVaultOddsNS.Core
local PlayerRaidProgress = GreatVaultOddsNS.PlayerRaidProgress

-- https://wago.tools/db2/MythicPlusSeason?sort%5BMilestoneSeason%5D=desc
-- For testing viewing a future season
local manualMilestoneSeasonIDOverride = false -- 105
local activeMilestoneSeasonID

function Core.GetActiveMilestoneSeasonID()
    return activeMilestoneSeasonID
end

local debugLogging = false

Core.defaultAddonOptions = {
    devMode = false,
}

local function addMissingDefaults(userOptions, defaultOptions) -- Validates that all empty user options are populated with default values
    for option, defaultValue in pairs(defaultOptions) do
        local userValue = userOptions[option]

        if type(defaultValue) == "table" then
            if type(userValue) ~= "table" then
                userOptions[option] = CopyTable(defaultValue) -- Prevents accidental editing of the default addon options table
            else
                addMissingDefaults(userValue, defaultValue)
            end
        elseif userValue == nil then
            userOptions[option] = defaultValue
        end
    end
end

local lootDBInitializationFailed = false
local lootDBValidationFailed = false
local function validateLootDB(lootDB, milestoneSeasonID)
    local hasValidLootDB = lootDB and lootDB.eligibleItems and lootDB.eligibleItemCount

    if not hasValidLootDB and not lootDBValidationFailed then
        -- prints error on the first failure only
        -- redundant because function only gets called once
        lootDBValidationFailed = true
        print("GreatVaultOdds has no valid loot DB for milestone season ID:", milestoneSeasonID)
    end

    return hasValidLootDB
end

local function trySetActiveLootDB(self)
    local _, milestoneSeasonID = C_MythicPlus.GetCurrentSeasonValues()
    milestoneSeasonID = manualMilestoneSeasonIDOverride or milestoneSeasonID

    if not milestoneSeasonID or milestoneSeasonID == -1 then
        C_MythicPlus.RequestMapInfo()
        return
    end

    self:UnregisterEvent("CHALLENGE_MODE_MAPS_UPDATE")

    activeMilestoneSeasonID = milestoneSeasonID

    PlayerRaidProgress.RefreshProgression(activeMilestoneSeasonID)

    local activeLootDB = GreatVaultOddsNS.LootDBByMilestoneSeasonID and GreatVaultOddsNS.LootDBByMilestoneSeasonID[activeMilestoneSeasonID]

    if not activeLootDB and not lootDBInitializationFailed then
        -- prints error on the first failure only
        -- redundant because function only gets this far once
        lootDBInitializationFailed = true
        print("GreatVaultOdds has no loot DB for milestone season ID:", activeMilestoneSeasonID)
        return
    end

    if validateLootDB(activeLootDB, activeMilestoneSeasonID) then -- inverse? But why?
        Tooltip.SetActiveLootDB(activeLootDB)
        Tooltip.RegisterTooltipHandler()
    end
end

local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddonName = ...

        if loadedAddonName == addonName then -- consider inverting the condition
            GreatVaultOddsAddonOptions = GreatVaultOddsAddonOptions or {}
            GreatVaultOddsDB = GreatVaultOddsDB or {}
            GreatVaultOddsDB.eligibleItems = GreatVaultOddsDB.eligibleItems or {}
            GreatVaultOddsDB.eligibleItemCount = GreatVaultOddsDB.eligibleItemCount or {}
            addMissingDefaults(GreatVaultOddsAddonOptions, Core.defaultAddonOptions)
            self:UnregisterEvent("ADDON_LOADED")
        end
    elseif event == "PLAYER_LOGIN" then
        trySetActiveLootDB(self)

        if GreatVaultOddsAddonOptions.devMode or debugLogging then
            C_Timer.After(5, function()
                print("GreatVaultOdds devMode:", GreatVaultOddsAddonOptions.devMode, "debugLogging:", debugLogging)
            end)
        end
        self:UnregisterEvent("PLAYER_LOGIN")
    elseif event == "CHALLENGE_MODE_MAPS_UPDATE" then
        trySetActiveLootDB(self)
    elseif event == "ENCOUNTER_END" then
        local encounterID, encounterName, difficultyID, groupSize, success = ...
        if success ~= 1 then return end
        PlayerRaidProgress.MarkEncounterKilled(encounterID, difficultyID)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
frame:RegisterEvent("ENCOUNTER_END")
frame:SetScript("OnEvent", OnEvent)

SlashCommands.RegisterSlashCommands()

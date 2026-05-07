local addonName, GreatVaultOddsNS = ...

local classSpecIDs = GreatVaultOddsNS.ClassSpecIDs
local Utils = GreatVaultOddsNS.Utils
local Tooltip = GreatVaultOddsNS.Tooltip
local DBGenerator = GreatVaultOddsNS.DBGenerator

-- https://wago.tools/db2/MythicPlusSeason?sort%5BMilestoneSeason%5D=desc
local manualMilestoneSeasonIDOverride = false -- 105

local debugLogging = false

local defaultAddonOptions = {
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
local function validateLootDB(lootDB, activeMilestoneSeasonID)
    local hasValidLootDB = lootDB and lootDB.eligibleItems and lootDB.eligibleItemCount

    if not hasValidLootDB and not lootDBValidationFailed then
        -- prints error on the first failure only
        -- redundant because function only gets called once
        lootDBValidationFailed = true
        print("GreatVaultOdds has no valid loot DB for milestone season ID:", activeMilestoneSeasonID)
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
    local activeMilestoneSeasonID = milestoneSeasonID
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

local function OnEvent(self, event, loadedAddonName)
    if event == "ADDON_LOADED" and loadedAddonName == addonName then
        GreatVaultOddsAddonOptions = GreatVaultOddsAddonOptions or {}
        GreatVaultOddsDB = GreatVaultOddsDB or {}
        GreatVaultOddsDB.eligibleItems = GreatVaultOddsDB.eligibleItems or {}
        GreatVaultOddsDB.eligibleItemCount = GreatVaultOddsDB.eligibleItemCount or {}
        addMissingDefaults(GreatVaultOddsAddonOptions, defaultAddonOptions)
        self:UnregisterEvent("ADDON_LOADED")
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
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
frame:SetScript("OnEvent", OnEvent)

local function showHelp() -- TODO: Make show help have option to display help for specific function too, so can /gvodds help db and get info for db specifically with more detail
    print("|cFFE6CC99Great Vault Odds|r will display the chance of each spec receiving an item in the Great Vault on the corresponding item's tooltip.")
    print("|cFFE6CC99Great Vault Odds|r |cFF66BBFFHelp Menu:|r") -- TODO: Make a prefix print and colour function
    print("|cFFE6CC99/gvodds|r", "|cFF66BBFFreset|r", "- Resets all options to their defaults")
    print("|cFFE6CC99/gvodds|r", "|cFF66BBFFdev|r", "- Toggles dev mode")
    print("|cFFE6CC99/gvodds|r", "|cFF66BBFFhelp|r", "- Displays this menu")
    if GreatVaultOddsAddonOptions.devMode then
        print("|cFFE6CC99/gvodds|r", "|cFF66BBFFdb|r", "|cFF66BBFFgen|r", "- Generates a DB in your saved variables")
        print("|cFFE6CC99/gvodds|r", "|cFF66BBFFdb|r", "|cFF66BBFFreset|r", "- Deletes the DB in your saved variables")
    end
    print("----------------------------------------")
end

local validCommands = { -- slashCommandMap or commandConfig?
    help = {},
    dev = {},
    reset = {},
    db = {
        devModeRequired = true,
        hasSubCommand = {
            gen = {},
            reset = {}
        },
    },
}

SLASH_GREATVAULTODDS1 = "/gvodds" -- add /greatvaultodds alias
function SlashCmdList.GREATVAULTODDS(msg, editBox)
    msg = msg and msg:lower():gsub("^%s*(.-)%s*$", "%1") or "" -- Trims leading and trailing whitespace, unnecessary

    local args = {}
    for word in msg:gmatch("%S+") do -- non whitespace ("args")
        table.insert(args, word)
    end

    local cmd, subCmd = args[1], args[2]
    local subCmdArgs = {select(3, unpack(args))}

    if cmd == "dev" then -- Allows "dev" commands to be chained in one command as opposed to requiring devMode toggled on and then the intended command to be inputted again.
        GreatVaultOddsAddonOptions.devMode = not GreatVaultOddsAddonOptions.devMode -- toggle
        print("Devmode active:", GreatVaultOddsAddonOptions.devMode)
        if not subCmd then return end -- Quit handler if no further command is chained

        cmd, subCmd = subCmd, subCmdArgs[1] -- Shift args for chained command
        subCmdArgs = {select(2, unpack(subCmdArgs))}
    end

    local validCommand = validCommands[cmd]
    local hasSubCmd = validCommand and validCommand.hasSubCommand
    local validSubCmd = hasSubCmd and hasSubCmd[subCmd]
    -- local expectsArgs = validSubCmd and validSubCmd.args
    -- local validArgs = expectsArgs and expectsArgs[arg1]

    local devModeActive = GreatVaultOddsAddonOptions.devMode
    local devModeRequired = validCommand and validCommand.devModeRequired
    local missingSubCmd = hasSubCmd and not subCmd
    local invalidSubCmd = hasSubCmd and subCmd and not validSubCmd
    -- local missingArgs = expectsArgs and not arg1
    -- local invalidArgs = expectsArgs and arg1 and not validArgs OR why not invalidArgs = not validArgs?

    if not cmd then
        print("No command provided - displaying /gvodds help")
        showHelp()
    elseif not validCommand then
        print("Unrecognised command \""..cmd.."\" - displaying /gvodds help")
        showHelp()
    elseif devModeRequired and not devModeActive then -- Command entered requires devMode but user is not in devMode, irregardless of subcommand validity
        print("The command \""..cmd.."\" requires dev mode to use. Use /gvodds dev to toggle")
    elseif missingSubCmd and not validCommand.hasSubCommand.default then -- Subcommand required but not provided
        print("Missing args for command \""..cmd.."\" - displaying /gvodds help")
        showHelp()
    elseif invalidSubCmd then -- Subcommand provided is not valid for given command
        print("Invalid arg \""..subCmd.."\" for command \""..cmd.."\" - displaying /gvodds help")
        showHelp()
    else -- Command is valid and can proceed
        if cmd == "help" then
            showHelp()
        elseif cmd == "reset" then
            print("Resetting |cFFE6CC99Great Vault Odds|r options to defaults!")
            GreatVaultOddsAddonOptions = CopyTable(defaultAddonOptions)
        elseif devModeActive then -- Dev mode required for these commands, unnecessary line though because of prior verification/guarding
            if cmd == "db" then
                if subCmd == "gen" then
                    -- Optionally generate a DB for a specific season rather than the current tier, based on if milestoneSeasonID is passed as an arg.
                    local inputMilestoneSeasonID = subCmdArgs[1]

                    if not inputMilestoneSeasonID then DBGenerator.generateDBForAllSpecs() return end

                    local requestedMilestoneSeasonID = tonumber(inputMilestoneSeasonID)
                    if not requestedMilestoneSeasonID then print("Invalid arg\""..inputMilestoneSeasonID.."\"") return end

                    C_MythicPlus.RequestMapInfo() -- Required to be called once per session to load functions
                    -- https://warcraft.wiki.gg/wiki/API_C_MythicPlus.RequestMapInfo
                    local _, currentMilestoneSeasonID = C_MythicPlus.GetCurrentSeasonValues()

                    if requestedMilestoneSeasonID == currentMilestoneSeasonID then DBGenerator.generateDBForAllSpecs() return end

                    if not GreatVaultOddsNS.InstanceIDsByMilestoneSeasonID[requestedMilestoneSeasonID] then
                        print("Milestone Season ID:", inputMilestoneSeasonID, "not configured!")
                        return
                    end

                    DBGenerator.generateDBForAllSpecs(requestedMilestoneSeasonID)
                elseif subCmd == "reset" then
                    print("Deleting |cFFE6CC99Great Vault Odds|r SV DB!")
                    GreatVaultOddsDB = {}
                    GreatVaultOddsDB.eligibleItems = {} -- have to re-init the sub-tables
                    GreatVaultOddsDB.eligibleItemCount = {}
                end
            end
        end
    end
end

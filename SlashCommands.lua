local addonName, GreatVaultOddsNS = ...

local Utils = GreatVaultOddsNS.Utils
local Tooltip = GreatVaultOddsNS.Tooltip
local DBGenerator = GreatVaultOddsNS.DBGenerator
local SlashCommands = GreatVaultOddsNS.SlashCommands
local Core = GreatVaultOddsNS.Core
local PlayerRaidProgression = GreatVaultOddsNS.PlayerRaidProgression

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
    progress = {
        devModeRequired = true,
    },
}

local function slashCommandHandler(msg, editBox)
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
            GreatVaultOddsAddonOptions = CopyTable(Core.defaultAddonOptions)
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
            elseif cmd == "progress" then
                -- Temp
                local currentSeason = 105
                for instanceID, instanceInfo in pairs(GreatVaultOddsNS.RaidProgressionStatisticIDs[currentSeason]) do
                    print("**"..instanceInfo.instanceName.."**")
                    for bossIndex, bossInfo in ipairs(instanceInfo.bosses) do
                        print(bossIndex..":", bossInfo.encounterName..":", "LFR:", GetStatistic(bossInfo.statistics[17])..",", "N:", GetStatistic(bossInfo.statistics[14])..",", "H:", GetStatistic(bossInfo.statistics[15])..",", "M:", GetStatistic(bossInfo.statistics[16])..",")
                        --[[
                        for difficultyID, statisticID in pairs(bossInfo.statistics) do
                            local _, achieveName = GetAchievementInfo(statisticID)
                            print("Expected:", achieveName)
                            print("Actual:", instanceInfo.instanceName, bossInfo.encounterName, "on", difficultyID, "difficulty:", GetStatistic(statisticID), "kills")
                            Utils.addToDevTool(GetStatistic(statisticID), "Difficulty "..difficultyID.." kills:")
                        end --]]
                    end
                end
            end
        end
    end
end

function SlashCommands.RegisterSlashCommands()
    SLASH_GREATVAULTODDS1 = "/gvodds" -- add /greatvaultodds alias
    SlashCmdList.GREATVAULTODDS = slashCommandHandler
end

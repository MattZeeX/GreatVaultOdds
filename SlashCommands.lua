local addonName, GreatVaultOddsNS = ...

local Utils = GreatVaultOddsNS.Utils
local Tooltip = GreatVaultOddsNS.Tooltip
local DBGenerator = GreatVaultOddsNS.DBGenerator
local SlashCommands = GreatVaultOddsNS.SlashCommands
local Core = GreatVaultOddsNS.Core
local PlayerRaidProgress = GreatVaultOddsNS.PlayerRaidProgress
local LootSource = GreatVaultOddsNS.LootSource

local function showHelp() -- TODO: Make show help have option to display help for specific function too, so can /gvodds help db and get info for db specifically with more detail
    print("|cFFE6CC99Great Vault Odds|r will display the chance of each spec receiving an item in the Great Vault on the corresponding item's tooltip.")
    print("|cFFE6CC99Great Vault Odds|r |cFF66BBFFHelp Menu:|r") -- TODO: Make a prefix print and colour function
    print("|cFFE6CC99/gvodds|r", "|cFF66BBFFreset|r", "- Resets all options to their defaults")
    print("|cFFE6CC99/gvodds|r", "|cFF66BBFFdev|r", "- Toggles dev mode")
    print("|cFFE6CC99/gvodds|r", "|cFF66BBFFhelp|r", "- Displays this menu")
    if GreatVaultOddsAddonOptions.devMode then
        print("|cFFE6CC99/gvodds|r", "|cFF66BBFFdb|r", "|cFF66BBFFgen|r", "|cFF66BBFF[dungeon|raid] [seasonID]|r", "- Generates a DB in your saved variables")
        print("|cFFE6CC99/gvodds|r", "|cFF66BBFFdb|r", "|cFF66BBFFreset|r", "- Deletes the DB in your saved variables")
        print("|cFFE6CC99/gvodds|r", "|cFF66BBFFdb|r", "|cFF66BBFFoverride|r", "- Sets the active DB to the one in your saved variables. /reload to reset back to the default DB. Big WIP") -- Does not update if you reset DB and re-generate. Also re-registers the tooltip handler.
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
            reset = {},
            override = {},
        },
    },
    progress = {
        devModeRequired = true,
    },
    cache = {
        devModeRequired = true,
    },
}

local validDBGenerationLootSources = {
    [LootSource.Dungeon] = true,
    [LootSource.Raid] = true,
}

local function parseDBGenerationArgs(args)
    local lootSource
    local inputMilestoneSeasonID
    local firstArg = args[1]
    local secondArg = args[2]
    local firstArgIsLootSource = validDBGenerationLootSources[firstArg]

    if firstArgIsLootSource then
        lootSource = firstArg
        inputMilestoneSeasonID = secondArg
    else
        inputMilestoneSeasonID = firstArg
    end

    local milestoneSeasonID = inputMilestoneSeasonID and tonumber(inputMilestoneSeasonID)
    if inputMilestoneSeasonID and not milestoneSeasonID then
        return nil, "Invalid DB generation mode or milestone season ID: "..inputMilestoneSeasonID
    end

    return {
        lootSource = lootSource,
        milestoneSeasonID = milestoneSeasonID,
    }
end

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
                    local generationOptions, errorMessage = parseDBGenerationArgs(subCmdArgs)
                    if not generationOptions then print(errorMessage) return end

                    local requestedMilestoneSeasonID = generationOptions.milestoneSeasonID
                    local activeMilestoneSeasonID = Core.GetActiveMilestoneSeasonID()

                    if requestedMilestoneSeasonID then -- Optionally generate a DB for a specific season rather than the current tier, based on if milestoneSeasonID is passed as an arg.
                        local lootSource = generationOptions.lootSource
                        local shouldGenerateDungeons = not lootSource or lootSource == LootSource.Dungeon
                        local shouldGenerateRaids = not lootSource or lootSource == LootSource.Raid
                        local hasConfiguredDungeons = GreatVaultOddsNS.InstanceIDsByMilestoneSeasonID[requestedMilestoneSeasonID]
                        local hasConfiguredRaids = GreatVaultOddsNS.RaidEncounterKillStatisticIDsByMilestoneSeasonID[requestedMilestoneSeasonID]

                        if shouldGenerateDungeons and not hasConfiguredDungeons then
                            print("Milestone Season ID:", requestedMilestoneSeasonID, "has no configured dungeons!")
                            return
                        end

                        if shouldGenerateRaids and not hasConfiguredRaids then
                            print("Milestone Season ID:", requestedMilestoneSeasonID, "has no configured raids!")
                            return
                        end

                        if activeMilestoneSeasonID and requestedMilestoneSeasonID == activeMilestoneSeasonID then
                            generationOptions.milestoneSeasonID = nil
                        end
                    end

                    if generationOptions.lootSource then
                        print("Generating", generationOptions.lootSource, "loot DB...")
                    else
                        print("Generating dungeon and raid loot DB...")
                    end

                    DBGenerator.generateDBForAllSpecs(generationOptions)
                elseif subCmd == "reset" then
                    print("Deleting |cFFE6CC99Great Vault Odds|r SV DB!")
                    GreatVaultOddsDB = {}
                    GreatVaultOddsDB.eligibleItems = {} -- have to re-init the sub-tables
                    GreatVaultOddsDB.eligibleItemCount = {}
                elseif subCmd == "override" then
                    if GreatVaultOddsDB and GreatVaultOddsDB.eligibleItems and GreatVaultOddsDB.eligibleItemCount then
                        Tooltip.SetActiveLootDB(GreatVaultOddsDB)
                        Tooltip.RegisterTooltipHandler()
                        print("Using generated saved-variable loot DB")
                    else
                        print("Generated saved-variable loot DB is invalid")
                    end
                end
            elseif cmd == "progress" then
                local inputMilestoneSeasonID = subCmd
                local requestedMilestoneSeasonID = inputMilestoneSeasonID and tonumber(inputMilestoneSeasonID)

                if inputMilestoneSeasonID and not requestedMilestoneSeasonID then
                    print("Invalid milestone season ID:", inputMilestoneSeasonID)
                    return
                end

                PlayerRaidProgress.OutputBossKillsDebugReport(requestedMilestoneSeasonID)
            elseif cmd == "cache" then
                PlayerRaidProgress.OutputProgressCache()
            end
        end
    end
end

function SlashCommands.RegisterSlashCommands()
    SLASH_GREATVAULTODDS1 = "/gvodds" -- add /greatvaultodds alias
    SlashCmdList.GREATVAULTODDS = slashCommandHandler
end

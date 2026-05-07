---@diagnostic disable: undefined-global
-- Register a dev specific slash command that force enables dev mode before executing the rest of the handler

SLASH_GVDEV1 = "/gvdev"
SlashCmdList.GVDEV = function()
    GreatVaultOddsAddonOptions.devMode = true
    slashCommandHandler()
end
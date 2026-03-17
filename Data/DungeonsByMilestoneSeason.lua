local addonName, GreatVaultOddsNS = ...

-- Journal instance IDs keyed by Mythic+ milestone season ID.
-- https://wago.tools/db2/JournalInstance
GreatVaultOddsNS.InstanceIDsByMilestoneSeasonID = {
    [105] = { -- Midnight Season 1
        1300, -- Magisters' Terrace
        1315, -- Maisara Caverns
        1316, -- Nexus-Point Xenas
        1299, -- Windrunner Spire
        1201, -- Algeth'ar Academy
        945,  -- The Seat of the Triumvirate
        476,  -- Skyreach
        278,  -- Pit of Saron
    },
}

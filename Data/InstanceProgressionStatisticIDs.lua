local addonName, GreatVaultOddsNS = ...

local DifficultyID = {
LFR = DifficultyUtil.ID.PrimaryRaidLFR,
RaidNormal = DifficultyUtil.ID.PrimaryRaidNormal,
RaidHeroic = DifficultyUtil.ID.PrimaryRaidHeroic,
RaidMythic = DifficultyUtil.ID.PrimaryRaidMythic,
}

-- Current Milestone Season ID = 105
-- Uses journal instance IDs in tandem with dungeon encounter IDs
GreatVaultOddsNS.RaidProgressionStatisticIDs = {
    [105] = {
        [1314] = {
            instanceName = "The Dreamrift",
            bosses = {
                [1] = {
                    encounterID = 3306,
                    encounterName = "Chimaerus, the Undreamt God",
                    statistics = {
                        [DifficultyID.LFR] = 61474,
                        [DifficultyID.RaidNormal] = 61475,
                        [DifficultyID.RaidHeroic] = 61476,
                        [DifficultyID.RaidMythic] = 61477,
                    },
                },
            },
        },
        [1307] = {
            instanceName = "The Voidspire",
            bosses = {
                [1] = {
                    encounterID = 3176,
                    encounterName = "Imperator Averzian",
                    statistics = {
                        [DifficultyID.LFR] = 61276,
                        [DifficultyID.RaidNormal] = 61277,
                        [DifficultyID.RaidHeroic] = 61278,
                        [DifficultyID.RaidMythic] = 61279,
                    },
                },
                [2] = {
                    encounterID = 3177,
                    encounterName = "Vorasius",
                    statistics = {
                        [DifficultyID.LFR] = 61280,
                        [DifficultyID.RaidNormal] = 61281,
                        [DifficultyID.RaidHeroic] = 61282,
                        [DifficultyID.RaidMythic] = 61283,
                    },
                },
                [3] = {
                    encounterID = 3179,
                    encounterName = "Fallen-King Salhadaar",
                    statistics = {
                        [DifficultyID.LFR] = 61284,
                        [DifficultyID.RaidNormal] = 61285,
                        [DifficultyID.RaidHeroic] = 61286,
                        [DifficultyID.RaidMythic] = 61287,
                    },
                },
                [4] = {
                    encounterID = 3178,
                    encounterName = "Vaelgor & Ezzorak",
                    statistics = {
                        [DifficultyID.LFR] = 61288,
                        [DifficultyID.RaidNormal] = 61289,
                        [DifficultyID.RaidHeroic] = 61290,
                        [DifficultyID.RaidMythic] = 61291,
                    },
                },
                [5] = {
                    encounterID = 3180,
                    encounterName = "Lightblinded Vanguard",
                    statistics = {
                        [DifficultyID.LFR] = 61292,
                        [DifficultyID.RaidNormal] = 61293,
                        [DifficultyID.RaidHeroic] = 61294,
                        [DifficultyID.RaidMythic] = 61295,
                    },
                },
                [6] = {
                    encounterID = 3181,
                    encounterName = "Crown of the Cosmos",
                    statistics = {
                        [DifficultyID.LFR] = 61296,
                        [DifficultyID.RaidNormal] = 61297,
                        [DifficultyID.RaidHeroic] = 61298,
                        [DifficultyID.RaidMythic] = 61299,
                    },
                },
            },
        },
        [1308] = {
            instanceName = "March on Quel'Danas",
            bosses = {
                [1] = {
                    encounterID = 3182,
                    encounterName = "Belo'ren, Child of Al'ar",
                    statistics = {
                        [DifficultyID.LFR] = 61300,
                        [DifficultyID.RaidNormal] = 61301,
                        [DifficultyID.RaidHeroic] = 61302,
                        [DifficultyID.RaidMythic] = 61303,
                    },
                },
                [2] = {
                    encounterID = 3183,
                    encounterName = "Midnight Falls",
                    statistics = {
                        [DifficultyID.LFR] = 61304,
                        [DifficultyID.RaidNormal] = 61305,
                        [DifficultyID.RaidHeroic] = 61306,
                        [DifficultyID.RaidMythic] = 61307,
                    },
                },
            },
        },
        [1305] = {
            instanceName = "Sporefall",
            bosses = {
                [1] = {
                    encounterID = 3159,
                    encounterName = "Rotmire",
                    statistics = {
                        [DifficultyID.LFR] = 63233,
                        [DifficultyID.RaidNormal] = 63234,
                        [DifficultyID.RaidHeroic] = 63235,
                        [DifficultyID.RaidMythic] = 63236,
                    },
                },
            },
        },
    },
}

GreatVaultOddsNS.RaidEncounterIndex = {
    [3306] = {
        journalInstanceID = 1314,
        bossIndex = 1,
    },
}

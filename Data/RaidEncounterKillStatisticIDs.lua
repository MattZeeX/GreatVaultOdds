local addonName, GreatVaultOddsNS = ...

GreatVaultOddsNS.RaidDifficultyID = {
    LFR = DifficultyUtil.ID.PrimaryRaidLFR,
    Normal = DifficultyUtil.ID.PrimaryRaidNormal,
    Heroic = DifficultyUtil.ID.PrimaryRaidHeroic,
    Mythic = DifficultyUtil.ID.PrimaryRaidMythic,
}

local raidDifficultyID = GreatVaultOddsNS.RaidDifficultyID

-- Uses journal instance IDs in tandem with dungeon encounter IDs
GreatVaultOddsNS.RaidEncounterKillStatisticIDsByMilestoneSeasonID = {
    [105] = {
        [1314] = {
            instanceName = "The Dreamrift",
            bosses = {
                [1] = {
                    encounterID = 3306,
                    encounterName = "Chimaerus, the Undreamt God",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 61474,
                        [raidDifficultyID.Normal] = 61475,
                        [raidDifficultyID.Heroic] = 61476,
                        [raidDifficultyID.Mythic] = 61477,
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
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 61276,
                        [raidDifficultyID.Normal] = 61277,
                        [raidDifficultyID.Heroic] = 61278,
                        [raidDifficultyID.Mythic] = 61279,
                    },
                },
                [2] = {
                    encounterID = 3177,
                    encounterName = "Vorasius",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 61280,
                        [raidDifficultyID.Normal] = 61281,
                        [raidDifficultyID.Heroic] = 61282,
                        [raidDifficultyID.Mythic] = 61283,
                    },
                },
                [3] = {
                    encounterID = 3179,
                    encounterName = "Fallen-King Salhadaar",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 61284,
                        [raidDifficultyID.Normal] = 61285,
                        [raidDifficultyID.Heroic] = 61286,
                        [raidDifficultyID.Mythic] = 61287,
                    },
                },
                [4] = {
                    encounterID = 3178,
                    encounterName = "Vaelgor & Ezzorak",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 61288,
                        [raidDifficultyID.Normal] = 61289,
                        [raidDifficultyID.Heroic] = 61290,
                        [raidDifficultyID.Mythic] = 61291,
                    },
                },
                [5] = {
                    encounterID = 3180,
                    encounterName = "Lightblinded Vanguard",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 61292,
                        [raidDifficultyID.Normal] = 61293,
                        [raidDifficultyID.Heroic] = 61294,
                        [raidDifficultyID.Mythic] = 61295,
                    },
                },
                [6] = {
                    encounterID = 3181,
                    encounterName = "Crown of the Cosmos",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 61296,
                        [raidDifficultyID.Normal] = 61297,
                        [raidDifficultyID.Heroic] = 61298,
                        [raidDifficultyID.Mythic] = 61299,
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
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 61300,
                        [raidDifficultyID.Normal] = 61301,
                        [raidDifficultyID.Heroic] = 61302,
                        [raidDifficultyID.Mythic] = 61303,
                    },
                },
                [2] = {
                    encounterID = 3183,
                    encounterName = "Midnight Falls",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 61304,
                        [raidDifficultyID.Normal] = 61305,
                        [raidDifficultyID.Heroic] = 61306,
                        [raidDifficultyID.Mythic] = 61307,
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
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 63233,
                        [raidDifficultyID.Normal] = 63234,
                        [raidDifficultyID.Heroic] = 63235,
                        [raidDifficultyID.Mythic] = 63236,
                    },
                },
            },
        },
    },
    [102] = {
        [1302] = {
            instanceName = "Manaforge Omega",
            bosses = {
                [1] = {
                    encounterID = 3129,
                    encounterName = "Plexus Sentinel",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 41633,
                        [raidDifficultyID.Normal] = 41634,
                        [raidDifficultyID.Heroic] = 41635,
                        [raidDifficultyID.Mythic] = 41636,
                    },
                },
                [2] = {
                    encounterID = 3131,
                    encounterName = "Loom'ithar",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 41637,
                        [raidDifficultyID.Normal] = 41638,
                        [raidDifficultyID.Heroic] = 41639,
                        [raidDifficultyID.Mythic] = 41640,
                    },
                },
                [3] = {
                    encounterID = 3130,
                    encounterName = "Soulbinder Naazindhri",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 41641,
                        [raidDifficultyID.Normal] = 41642,
                        [raidDifficultyID.Heroic] = 41643,
                        [raidDifficultyID.Mythic] = 41644,
                    },
                },
                [4] = {
                    encounterID = 3132,
                    encounterName = "Forgeweaver Araz",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 41645,
                        [raidDifficultyID.Normal] = 41646,
                        [raidDifficultyID.Heroic] = 41647,
                        [raidDifficultyID.Mythic] = 41648,
                    },
                },
                [5] = {
                    encounterID = 3122,
                    encounterName = "The Soul Hunters",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 41649,
                        [raidDifficultyID.Normal] = 41650,
                        [raidDifficultyID.Heroic] = 41651,
                        [raidDifficultyID.Mythic] = 41652,
                    },
                },
                [6] = {
                    encounterID = 3133,
                    encounterName = "Fractillus",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 41653,
                        [raidDifficultyID.Normal] = 41654,
                        [raidDifficultyID.Heroic] = 41655,
                        [raidDifficultyID.Mythic] = 41656,
                    },
                },
                [7] = {
                    encounterID = 3134,
                    encounterName = "Nexus-King Salhadaar",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 41657,
                        [raidDifficultyID.Normal] = 41658,
                        [raidDifficultyID.Heroic] = 41659,
                        [raidDifficultyID.Mythic] = 41660,
                    },
                },
                [8] = {
                    encounterID = 3135,
                    encounterName = "Dimensius, the All-Devouring",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 41661,
                        [raidDifficultyID.Normal] = 41662,
                        [raidDifficultyID.Heroic] = 41663,
                        [raidDifficultyID.Mythic] = 41664,
                    },
                },
            },
        },
    },
}

-- Keyed by "dungeon" encounter IDs from ENCOUNTER_END, not Encounter Journal encounter IDs.
-- seasonID is the Mythic+ milestone season ID used to select seasonal loot/progression data.
GreatVaultOddsNS.RaidEncounterIndexByEncounterID = {
    [3306] = {
        seasonID = 105,
        journalInstanceID = 1314,
        bossIndex = 1,
    },
    [3176] = {
        seasonID = 105,
        journalInstanceID = 1307,
        bossIndex = 1,
    },
    [3177] = {
        seasonID = 105,
        journalInstanceID = 1307,
        bossIndex = 2,
    },
    [3179] = {
        seasonID = 105,
        journalInstanceID = 1307,
        bossIndex = 3, -- This is the correct boss order for Voidspire
    },
    [3178] = {
        seasonID = 105,
        journalInstanceID = 1307,
        bossIndex = 4,
    },
    [3180] = {
        seasonID = 105,
        journalInstanceID = 1307,
        bossIndex = 5,
    },
    [3181] = {
        seasonID = 105,
        journalInstanceID = 1307,
        bossIndex = 6,
    },
    [3182] = {
        seasonID = 105,
        journalInstanceID = 1308,
        bossIndex = 1,
    },
    [3183] = {
        seasonID = 105,
        journalInstanceID = 1308,
        bossIndex = 2,
    },
    [3159] = {
        seasonID = 105,
        journalInstanceID = 1305,
        bossIndex = 1,
    },
    [3129] = {
        seasonID = 102,
        journalInstanceID = 1302,
        bossIndex = 1,
    },
    [3131] = {
        seasonID = 102,
        journalInstanceID = 1302,
        bossIndex = 2,
    },
    [3130] = {
        seasonID = 102,
        journalInstanceID = 1302,
        bossIndex = 3,
    },
    [3132] = {
        seasonID = 102,
        journalInstanceID = 1302,
        bossIndex = 4,
    },
    [3122] = {
        seasonID = 102,
        journalInstanceID = 1302,
        bossIndex = 5,
    },
    [3133] = {
        seasonID = 102,
        journalInstanceID = 1302,
        bossIndex = 6,
    },
    [3134] = {
        seasonID = 102,
        journalInstanceID = 1302,
        bossIndex = 7,
    },
    [3135] = {
        seasonID = 102,
        journalInstanceID = 1302,
        bossIndex = 8,
    },
}

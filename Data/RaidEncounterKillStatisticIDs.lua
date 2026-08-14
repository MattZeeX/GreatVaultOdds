local addonName, GreatVaultOddsNS = ...

GreatVaultOddsNS.RaidDifficultyIDs = {
    World = DifficultyUtil.ID.RaidWorld or 250, -- temporary value to prevent nil indexes in versions < 12.1
    LFR = DifficultyUtil.ID.PrimaryRaidLFR,
    Normal = DifficultyUtil.ID.PrimaryRaidNormal,
    Heroic = DifficultyUtil.ID.PrimaryRaidHeroic,
    Mythic = DifficultyUtil.ID.PrimaryRaidMythic,
}

local raidDifficultyIDs = GreatVaultOddsNS.RaidDifficultyIDs

-- Uses journal instance IDs in tandem with combat encounter IDs from ENCOUNTER_END.
GreatVaultOddsNS.RaidEncounterKillStatisticIDsByMilestoneSeasonID = {
    [106] = {
        [1317] = {
            instanceName = "The Tidebound Grotto",
            difficultyDisplayIndexByID = {
                [raidDifficultyIDs.World] = 1,
                [raidDifficultyIDs.Normal] = 2,
                [raidDifficultyIDs.Heroic] = 3,
                [raidDifficultyIDs.Mythic] = 4,
            },
            bosses = {
                [1] = {
                    combatEncounterID = 3379,
                    journalEncounterID = 2849,
                    encounterName = "Nymrissa Wavecaller",
                    killStatisticIDs = {
                        [raidDifficultyIDs.World] = 63613,
                        [raidDifficultyIDs.Normal] = 63614,
                        [raidDifficultyIDs.Heroic] = 63615,
                        [raidDifficultyIDs.Mythic] = 63616,
                    },
                },
            },
        },
        [1320] = {
            instanceName = "The Venomous Abyss",
            difficultyDisplayIndexByID = {
                [raidDifficultyIDs.LFR] = 1,
                [raidDifficultyIDs.Normal] = 2,
                [raidDifficultyIDs.Heroic] = 3,
                [raidDifficultyIDs.Mythic] = 4,
            },
            bosses = {
                [1] = {
                    combatEncounterID = 3470,
                    journalEncounterID = 2888,
                    encounterName = "Nek'zali the Soulcoiler",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 63533,
                        [raidDifficultyIDs.Normal] = 63534,
                        [raidDifficultyIDs.Heroic] = 63535,
                        [raidDifficultyIDs.Mythic] = 63536,
                    },
                },
                [2] = {
                    combatEncounterID = 3445,
                    journalEncounterID = 2874,
                    encounterName = "Entombed Sentinels",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 63537,
                        [raidDifficultyIDs.Normal] = 63538,
                        [raidDifficultyIDs.Heroic] = 63539,
                        [raidDifficultyIDs.Mythic] = 63540,
                    },
                },
                [3] = {
                    combatEncounterID = 3497,
                    journalEncounterID = 2894,
                    encounterName = "The Lost Explorers",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 63541,
                        [raidDifficultyIDs.Normal] = 63552,
                        [raidDifficultyIDs.Heroic] = 63553,
                        [raidDifficultyIDs.Mythic] = 63554,
                    },
                },
                [4] = {
                    combatEncounterID = 3455,
                    journalEncounterID = 2882,
                    encounterName = "Vashnik the Malignant",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 63547,
                        [raidDifficultyIDs.Normal] = 63555,
                        [raidDifficultyIDs.Heroic] = 63556,
                        [raidDifficultyIDs.Mythic] = 63557,
                    },
                },
                [5] = {
                    combatEncounterID = 3420,
                    journalEncounterID = 2871,
                    encounterName = "Sszorak",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 63548,
                        [raidDifficultyIDs.Normal] = 63558,
                        [raidDifficultyIDs.Heroic] = 63559,
                        [raidDifficultyIDs.Mythic] = 63560,
                    },
                },
                [6] = {
                    combatEncounterID = 3421,
                    journalEncounterID = 2887,
                    encounterName = "The Twin Fangs",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 63549,
                        [raidDifficultyIDs.Normal] = 63561,
                        [raidDifficultyIDs.Heroic] = 63562,
                        [raidDifficultyIDs.Mythic] = 63563,
                    },
                },
                [7] = {
                    combatEncounterID = 3429,
                    journalEncounterID = 2883,
                    encounterName = "The Coiled Altar",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 63550,
                        [raidDifficultyIDs.Normal] = 63564,
                        [raidDifficultyIDs.Heroic] = 63565,
                        [raidDifficultyIDs.Mythic] = 63566,
                    },
                },
                [8] = {
                    combatEncounterID = 3492,
                    journalEncounterID = 2895,
                    encounterName = "Ula'tek",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 63551,
                        [raidDifficultyIDs.Normal] = 63567,
                        [raidDifficultyIDs.Heroic] = 63568,
                        [raidDifficultyIDs.Mythic] = 63569,
                    },
                },
            },
        },
    },
    [105] = {
        [1314] = {
            instanceName = "The Dreamrift",
            difficultyDisplayIndexByID = {
                [raidDifficultyIDs.LFR] = 1,
                [raidDifficultyIDs.Normal] = 2,
                [raidDifficultyIDs.Heroic] = 3,
                [raidDifficultyIDs.Mythic] = 4,
            },
            bosses = {
                [1] = {
                    combatEncounterID = 3306,
                    journalEncounterID = 2795,
                    encounterName = "Chimaerus, the Undreamt God",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 61474,
                        [raidDifficultyIDs.Normal] = 61475,
                        [raidDifficultyIDs.Heroic] = 61476,
                        [raidDifficultyIDs.Mythic] = 61477,
                    },
                },
            },
        },
        [1307] = {
            instanceName = "The Voidspire",
            difficultyDisplayIndexByID = {
                [raidDifficultyIDs.LFR] = 1,
                [raidDifficultyIDs.Normal] = 2,
                [raidDifficultyIDs.Heroic] = 3,
                [raidDifficultyIDs.Mythic] = 4,
            },
            bosses = {
                [1] = {
                    combatEncounterID = 3176,
                    journalEncounterID = 2733,
                    encounterName = "Imperator Averzian",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 61276,
                        [raidDifficultyIDs.Normal] = 61277,
                        [raidDifficultyIDs.Heroic] = 61278,
                        [raidDifficultyIDs.Mythic] = 61279,
                    },
                },
                [2] = {
                    combatEncounterID = 3177,
                    journalEncounterID = 2734,
                    encounterName = "Vorasius",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 61280,
                        [raidDifficultyIDs.Normal] = 61281,
                        [raidDifficultyIDs.Heroic] = 61282,
                        [raidDifficultyIDs.Mythic] = 61283,
                    },
                },
                [3] = {
                    combatEncounterID = 3179,
                    journalEncounterID = 2736,
                    encounterName = "Fallen-King Salhadaar",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 61284,
                        [raidDifficultyIDs.Normal] = 61285,
                        [raidDifficultyIDs.Heroic] = 61286,
                        [raidDifficultyIDs.Mythic] = 61287,
                    },
                },
                [4] = {
                    combatEncounterID = 3178,
                    journalEncounterID = 2735,
                    encounterName = "Vaelgor & Ezzorak",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 61288,
                        [raidDifficultyIDs.Normal] = 61289,
                        [raidDifficultyIDs.Heroic] = 61290,
                        [raidDifficultyIDs.Mythic] = 61291,
                    },
                },
                [5] = {
                    combatEncounterID = 3180,
                    journalEncounterID = 2737,
                    encounterName = "Lightblinded Vanguard",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 61292,
                        [raidDifficultyIDs.Normal] = 61293,
                        [raidDifficultyIDs.Heroic] = 61294,
                        [raidDifficultyIDs.Mythic] = 61295,
                    },
                },
                [6] = {
                    combatEncounterID = 3181,
                    journalEncounterID = 2738,
                    encounterName = "Crown of the Cosmos",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 61296,
                        [raidDifficultyIDs.Normal] = 61297,
                        [raidDifficultyIDs.Heroic] = 61298,
                        [raidDifficultyIDs.Mythic] = 61299,
                    },
                },
            },
        },
        [1308] = {
            instanceName = "March on Quel'Danas",
            difficultyDisplayIndexByID = {
                [raidDifficultyIDs.LFR] = 1,
                [raidDifficultyIDs.Normal] = 2,
                [raidDifficultyIDs.Heroic] = 3,
                [raidDifficultyIDs.Mythic] = 4,
            },
            bosses = {
                [1] = {
                    combatEncounterID = 3182,
                    journalEncounterID = 2739,
                    encounterName = "Belo'ren, Child of Al'ar",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 61300,
                        [raidDifficultyIDs.Normal] = 61301,
                        [raidDifficultyIDs.Heroic] = 61302,
                        [raidDifficultyIDs.Mythic] = 61303,
                    },
                },
                [2] = {
                    combatEncounterID = 3183,
                    journalEncounterID = 2740,
                    encounterName = "Midnight Falls",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 61304,
                        [raidDifficultyIDs.Normal] = 61305,
                        [raidDifficultyIDs.Heroic] = 61306,
                        [raidDifficultyIDs.Mythic] = 61307,
                    },
                },
            },
        },
        [1305] = {
            instanceName = "Sporefall",
            difficultyDisplayIndexByID = {
                [raidDifficultyIDs.LFR] = 1,
                [raidDifficultyIDs.Normal] = 2,
                [raidDifficultyIDs.Heroic] = 3,
                [raidDifficultyIDs.Mythic] = 4,
            },
            bosses = {
                [1] = {
                    combatEncounterID = 3159,
                    journalEncounterID = 2711,
                    encounterName = "Rotmire",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 63233,
                        [raidDifficultyIDs.Normal] = 63234,
                        [raidDifficultyIDs.Heroic] = 63235,
                        [raidDifficultyIDs.Mythic] = 63236,
                    },
                },
            },
        },
    },
    [102] = {
        [1302] = {
            instanceName = "Manaforge Omega",
            difficultyDisplayIndexByID = {
                [raidDifficultyIDs.LFR] = 1,
                [raidDifficultyIDs.Normal] = 2,
                [raidDifficultyIDs.Heroic] = 3,
                [raidDifficultyIDs.Mythic] = 4,
            },
            bosses = {
                [1] = {
                    combatEncounterID = 3129,
                    journalEncounterID = 2684,
                    encounterName = "Plexus Sentinel",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 41633,
                        [raidDifficultyIDs.Normal] = 41634,
                        [raidDifficultyIDs.Heroic] = 41635,
                        [raidDifficultyIDs.Mythic] = 41636,
                    },
                },
                [2] = {
                    combatEncounterID = 3131,
                    journalEncounterID = 2686,
                    encounterName = "Loom'ithar",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 41637,
                        [raidDifficultyIDs.Normal] = 41638,
                        [raidDifficultyIDs.Heroic] = 41639,
                        [raidDifficultyIDs.Mythic] = 41640,
                    },
                },
                [3] = {
                    combatEncounterID = 3130,
                    journalEncounterID = 2685,
                    encounterName = "Soulbinder Naazindhri",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 41641,
                        [raidDifficultyIDs.Normal] = 41642,
                        [raidDifficultyIDs.Heroic] = 41643,
                        [raidDifficultyIDs.Mythic] = 41644,
                    },
                },
                [4] = {
                    combatEncounterID = 3132,
                    journalEncounterID = 2687,
                    encounterName = "Forgeweaver Araz",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 41645,
                        [raidDifficultyIDs.Normal] = 41646,
                        [raidDifficultyIDs.Heroic] = 41647,
                        [raidDifficultyIDs.Mythic] = 41648,
                    },
                },
                [5] = {
                    combatEncounterID = 3122,
                    journalEncounterID = 2688,
                    encounterName = "The Soul Hunters",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 41649,
                        [raidDifficultyIDs.Normal] = 41650,
                        [raidDifficultyIDs.Heroic] = 41651,
                        [raidDifficultyIDs.Mythic] = 41652,
                    },
                },
                [6] = {
                    combatEncounterID = 3133,
                    journalEncounterID = 2747,
                    encounterName = "Fractillus",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 41653,
                        [raidDifficultyIDs.Normal] = 41654,
                        [raidDifficultyIDs.Heroic] = 41655,
                        [raidDifficultyIDs.Mythic] = 41656,
                    },
                },
                [7] = {
                    combatEncounterID = 3134,
                    journalEncounterID = 2690,
                    encounterName = "Nexus-King Salhadaar",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 41657,
                        [raidDifficultyIDs.Normal] = 41658,
                        [raidDifficultyIDs.Heroic] = 41659,
                        [raidDifficultyIDs.Mythic] = 41660,
                    },
                },
                [8] = {
                    combatEncounterID = 3135,
                    journalEncounterID = 2691,
                    encounterName = "Dimensius, the All-Devouring",
                    killStatisticIDs = {
                        [raidDifficultyIDs.LFR] = 41661,
                        [raidDifficultyIDs.Normal] = 41662,
                        [raidDifficultyIDs.Heroic] = 41663,
                        [raidDifficultyIDs.Mythic] = 41664,
                    },
                },
            },
        },
    },
}

-- Keyed by combat encounter IDs from ENCOUNTER_END, not Encounter Journal encounter IDs.
-- seasonID is the Mythic+ milestone season ID used to select seasonal loot/progression data.
GreatVaultOddsNS.RaidEncounterIndexByCombatEncounterID = {
    [3379] = {
        seasonID = 106,
        journalInstanceID = 1317,
        bossIndex = 1,
    },
    [3470] = {
        seasonID = 106,
        journalInstanceID = 1320,
        bossIndex = 1,
    },
    [3445] = {
        seasonID = 106,
        journalInstanceID = 1320,
        bossIndex = 2,
    },
    [3497] = {
        seasonID = 106,
        journalInstanceID = 1320,
        bossIndex = 3,
    },
    [3455] = {
        seasonID = 106,
        journalInstanceID = 1320,
        bossIndex = 4,
    },
    [3420] = {
        seasonID = 106,
        journalInstanceID = 1320,
        bossIndex = 5,
    },
    [3421] = {
        seasonID = 106,
        journalInstanceID = 1320,
        bossIndex = 6,
    },
    [3429] = {
        seasonID = 106,
        journalInstanceID = 1320,
        bossIndex = 7,
    },
    [3492] = {
        seasonID = 106,
        journalInstanceID = 1320,
        bossIndex = 8,
    },
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

-- Keyed by Encounter Journal encounter IDs from C_EncounterJournal.GetLootInfoByIndex().
GreatVaultOddsNS.RaidEncounterIndexByJournalEncounterID = {
    [2849] = {
        seasonID = 106,
        journalInstanceID = 1317,
        bossIndex = 1,
    },
    [2888] = {
        seasonID = 106,
        journalInstanceID = 1320,
        bossIndex = 1,
    },
    [2874] = {
        seasonID = 106,
        journalInstanceID = 1320,
        bossIndex = 2,
    },
    [2894] = {
        seasonID = 106,
        journalInstanceID = 1320,
        bossIndex = 3,
    },
    [2882] = {
        seasonID = 106,
        journalInstanceID = 1320,
        bossIndex = 4,
    },
    [2871] = {
        seasonID = 106,
        journalInstanceID = 1320,
        bossIndex = 5,
    },
    [2887] = {
        seasonID = 106,
        journalInstanceID = 1320,
        bossIndex = 6,
    },
    [2883] = {
        seasonID = 106,
        journalInstanceID = 1320,
        bossIndex = 7,
    },
    [2895] = {
        seasonID = 106,
        journalInstanceID = 1320,
        bossIndex = 8,
    },
    [2795] = {
        seasonID = 105,
        journalInstanceID = 1314,
        bossIndex = 1,
    },
    [2733] = {
        seasonID = 105,
        journalInstanceID = 1307,
        bossIndex = 1,
    },
    [2734] = {
        seasonID = 105,
        journalInstanceID = 1307,
        bossIndex = 2,
    },
    [2736] = {
        seasonID = 105,
        journalInstanceID = 1307,
        bossIndex = 3,
    },
    [2735] = {
        seasonID = 105,
        journalInstanceID = 1307,
        bossIndex = 4,
    },
    [2737] = {
        seasonID = 105,
        journalInstanceID = 1307,
        bossIndex = 5,
    },
    [2738] = {
        seasonID = 105,
        journalInstanceID = 1307,
        bossIndex = 6,
    },
    [2739] = {
        seasonID = 105,
        journalInstanceID = 1308,
        bossIndex = 1,
    },
    [2740] = {
        seasonID = 105,
        journalInstanceID = 1308,
        bossIndex = 2,
    },
    [2711] = {
        seasonID = 105,
        journalInstanceID = 1305,
        bossIndex = 1,
    },
    [2684] = {
        seasonID = 102,
        journalInstanceID = 1302,
        bossIndex = 1,
    },
    [2686] = {
        seasonID = 102,
        journalInstanceID = 1302,
        bossIndex = 2,
    },
    [2685] = {
        seasonID = 102,
        journalInstanceID = 1302,
        bossIndex = 3,
    },
    [2687] = {
        seasonID = 102,
        journalInstanceID = 1302,
        bossIndex = 4,
    },
    [2688] = {
        seasonID = 102,
        journalInstanceID = 1302,
        bossIndex = 5,
    },
    [2747] = {
        seasonID = 102,
        journalInstanceID = 1302,
        bossIndex = 6,
    },
    [2690] = {
        seasonID = 102,
        journalInstanceID = 1302,
        bossIndex = 7,
    },
    [2691] = {
        seasonID = 102,
        journalInstanceID = 1302,
        bossIndex = 8,
    },
}

local addonName, GreatVaultOddsNS = ...

GreatVaultOddsNS.RaidDifficultyID = {
    LFR = DifficultyUtil.ID.PrimaryRaidLFR,
    Normal = DifficultyUtil.ID.PrimaryRaidNormal,
    Heroic = DifficultyUtil.ID.PrimaryRaidHeroic,
    Mythic = DifficultyUtil.ID.PrimaryRaidMythic,
}

local raidDifficultyID = GreatVaultOddsNS.RaidDifficultyID

-- Uses journal instance IDs in tandem with combat encounter IDs from ENCOUNTER_END.
GreatVaultOddsNS.RaidEncounterKillStatisticIDsByMilestoneSeasonID = {
    [105] = {
        [1314] = {
            instanceName = "The Dreamrift",
            bosses = {
                [1] = {
                    combatEncounterID = 3306,
                    journalEncounterID = 2795,
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
                    combatEncounterID = 3176,
                    journalEncounterID = 2733,
                    encounterName = "Imperator Averzian",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 61276,
                        [raidDifficultyID.Normal] = 61277,
                        [raidDifficultyID.Heroic] = 61278,
                        [raidDifficultyID.Mythic] = 61279,
                    },
                },
                [2] = {
                    combatEncounterID = 3177,
                    journalEncounterID = 2734,
                    encounterName = "Vorasius",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 61280,
                        [raidDifficultyID.Normal] = 61281,
                        [raidDifficultyID.Heroic] = 61282,
                        [raidDifficultyID.Mythic] = 61283,
                    },
                },
                [3] = {
                    combatEncounterID = 3179,
                    journalEncounterID = 2736,
                    encounterName = "Fallen-King Salhadaar",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 61284,
                        [raidDifficultyID.Normal] = 61285,
                        [raidDifficultyID.Heroic] = 61286,
                        [raidDifficultyID.Mythic] = 61287,
                    },
                },
                [4] = {
                    combatEncounterID = 3178,
                    journalEncounterID = 2735,
                    encounterName = "Vaelgor & Ezzorak",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 61288,
                        [raidDifficultyID.Normal] = 61289,
                        [raidDifficultyID.Heroic] = 61290,
                        [raidDifficultyID.Mythic] = 61291,
                    },
                },
                [5] = {
                    combatEncounterID = 3180,
                    journalEncounterID = 2737,
                    encounterName = "Lightblinded Vanguard",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 61292,
                        [raidDifficultyID.Normal] = 61293,
                        [raidDifficultyID.Heroic] = 61294,
                        [raidDifficultyID.Mythic] = 61295,
                    },
                },
                [6] = {
                    combatEncounterID = 3181,
                    journalEncounterID = 2738,
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
                    combatEncounterID = 3182,
                    journalEncounterID = 2739,
                    encounterName = "Belo'ren, Child of Al'ar",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 61300,
                        [raidDifficultyID.Normal] = 61301,
                        [raidDifficultyID.Heroic] = 61302,
                        [raidDifficultyID.Mythic] = 61303,
                    },
                },
                [2] = {
                    combatEncounterID = 3183,
                    journalEncounterID = 2740,
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
                    combatEncounterID = 3159,
                    journalEncounterID = 2711,
                    encounterName = "Rotmire",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 63233,
                        [raidDifficultyID.Normal] = 63234,
                        [raidDifficultyID.Heroic] = 63235,
                        [raidDifficultyID.Mythic] = 63236,
                    },
                    killStatisticAdjustments = {
                        [raidDifficultyID.Heroic] = {
                            subtractDifficultyID = raidDifficultyID.Mythic,
                        },
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
                    combatEncounterID = 3129,
                    journalEncounterID = 2684,
                    encounterName = "Plexus Sentinel",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 41633,
                        [raidDifficultyID.Normal] = 41634,
                        [raidDifficultyID.Heroic] = 41635,
                        [raidDifficultyID.Mythic] = 41636,
                    },
                },
                [2] = {
                    combatEncounterID = 3131,
                    journalEncounterID = 2686,
                    encounterName = "Loom'ithar",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 41637,
                        [raidDifficultyID.Normal] = 41638,
                        [raidDifficultyID.Heroic] = 41639,
                        [raidDifficultyID.Mythic] = 41640,
                    },
                },
                [3] = {
                    combatEncounterID = 3130,
                    journalEncounterID = 2685,
                    encounterName = "Soulbinder Naazindhri",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 41641,
                        [raidDifficultyID.Normal] = 41642,
                        [raidDifficultyID.Heroic] = 41643,
                        [raidDifficultyID.Mythic] = 41644,
                    },
                },
                [4] = {
                    combatEncounterID = 3132,
                    journalEncounterID = 2687,
                    encounterName = "Forgeweaver Araz",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 41645,
                        [raidDifficultyID.Normal] = 41646,
                        [raidDifficultyID.Heroic] = 41647,
                        [raidDifficultyID.Mythic] = 41648,
                    },
                },
                [5] = {
                    combatEncounterID = 3122,
                    journalEncounterID = 2688,
                    encounterName = "The Soul Hunters",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 41649,
                        [raidDifficultyID.Normal] = 41650,
                        [raidDifficultyID.Heroic] = 41651,
                        [raidDifficultyID.Mythic] = 41652,
                    },
                },
                [6] = {
                    combatEncounterID = 3133,
                    journalEncounterID = 2747,
                    encounterName = "Fractillus",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 41653,
                        [raidDifficultyID.Normal] = 41654,
                        [raidDifficultyID.Heroic] = 41655,
                        [raidDifficultyID.Mythic] = 41656,
                    },
                },
                [7] = {
                    combatEncounterID = 3134,
                    journalEncounterID = 2690,
                    encounterName = "Nexus-King Salhadaar",
                    killStatisticIDs = {
                        [raidDifficultyID.LFR] = 41657,
                        [raidDifficultyID.Normal] = 41658,
                        [raidDifficultyID.Heroic] = 41659,
                        [raidDifficultyID.Mythic] = 41660,
                    },
                },
                [8] = {
                    combatEncounterID = 3135,
                    journalEncounterID = 2691,
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

-- Keyed by combat encounter IDs from ENCOUNTER_END, not Encounter Journal encounter IDs.
-- seasonID is the Mythic+ milestone season ID used to select seasonal loot/progression data.
GreatVaultOddsNS.RaidEncounterIndexByCombatEncounterID = {
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

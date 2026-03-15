local addonName, GreatVaultOddsNS = ...
-- Class IDs: https://warcraft.wiki.gg/wiki/ClassID
-- Class colours: https://warcraft.wiki.gg/wiki/Class_colors
-- Spec IDs: https://warcraft.wiki.gg/wiki/SpecializationID
-- Spec icon IDs: https://wago.tools/db2/ChrSpecialization

GreatVaultOddsNS.ClassNameByID = {
    [1] = "WARRIOR",
    [2] = "PALADIN",
    [3] = "HUNTER",
    [4] = "ROGUE",
    [5] = "PRIEST",
    [6] = "DEATHKNIGHT",
    [7] = "SHAMAN",
    [8] = "MAGE",
    [9] = "WARLOCK",
    [10] = "MONK",
    [11] = "DRUID",
    [12] = "DEMONHUNTER",
    [13] = "EVOKER"
}

-- This is getting messy, I've gotta refactor it into a table with class keys and classIDand then another table with class keys and specData values
GreatVaultOddsNS.ClassSpecIDs = { -- cached specID, is there a way to get non localised version of spec name? will this be a problem? -- potentially worth separating into two tables like in dsune's addon with classes and specs as separate tables indexed by numbers equal to classID
    WARRIOR = { -- classData table
        specData = {
            Arms = { -- specTable
                specID = 71,
                iconID = 132355
            },
            Fury = {
                specID = 72,
                iconID = 132347
            },
            Protection = {
                specID = 73,
                iconID = 132341
            }
        },
        classID = 1,
    },
    PALADIN = {specData = {Holy = {specID = 65, iconID = 135920}, Protection = {specID = 66, iconID = 236264}, Retribution = {specID = 70, iconID = 135873}}, classID = 2},
    HUNTER = {specData = {["Beast Mastery"] = {specID = 253, iconID = 461112}, Marksmanship = {specID = 254, iconID = 236179}, Survival = {specID = 255, iconID = 461113}}, classID = 3},
    ROGUE = {specData = {Assassination = {specID = 259, iconID = 132292}, Outlaw = {specID = 260, iconID = 236286}, Subtlety = {specID = 261, iconID = 132320}}, classID = 4},
    PRIEST = {specData = {Discipline = {specID = 256, iconID = 135940}, Holy = {specID = 257, iconID = 237542}, Shadow = {specID = 258, iconID = 136207}}, classID = 5},
    DEATHKNIGHT = {specData = {Blood = {specID = 250, iconID = 135770}, Frost = {specID = 251, iconID = 135773}, Unholy = {specID = 252, iconID = 135775}}, classID = 6},
    SHAMAN = {specData = {Elemental = {specID = 262, iconID = 136048}, Enhancement = {specID = 263, iconID = 237581}, Restoration = {specID = 264, iconID = 136052}}, classID = 7},
    MAGE = {specData = {Arcane = {specID = 62, iconID = 135932}, Fire = {specID = 63, iconID = 135810}, Frost = {specID = 64, iconID = 135846}}, classID = 8},
    WARLOCK = {specData = {Affliction = {specID = 265, iconID = 136145}, Demonology = {specID = 266, iconID = 136172}, Destruction = {specID = 267, iconID = 136186}}, classID = 9},
    MONK = {specData = {Brewmaster = {specID = 268, iconID = 608951}, Mistweaver = {specID = 270, iconID = 608952}, Windwalker = {specID = 269, iconID = 608953}}, classID = 10},
    DRUID = {specData = {Balance = {specID = 102, iconID = 136096}, Feral = {specID = 103, iconID = 132115}, Guardian = {specID = 104, iconID = 132276}, Restoration = {specID = 105, iconID = 136041}}, classID = 11},
    DEMONHUNTER = {specData = {Havoc = {specID = 577, iconID = 1247264}, Vengeance = {specID = 581, iconID = 1247265}, Devourer = {specID = 1480, iconID = 7455385}}, classID = 12},
    EVOKER = {specData = {Devastation = {specID = 1467, iconID = 4511811}, Preservation = {specID = 1468, iconID = 4511812}, Augmentation = {specID = 1473, iconID = 5198700}}, classID = 13},
}

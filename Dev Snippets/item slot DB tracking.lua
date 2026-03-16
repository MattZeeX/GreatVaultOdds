---@diagnostic disable: undefined-global
-- Potential DB implementation for tracking specific item slots.
-- Uses old DB format, simple to visualise though.

local seasonLootEligibility = { -- We need to assign a slot id to the item in order to know what slot to increment
    eligibleItemCount = {
        DEATHKNIGHT = {
            Blood = { allSlots = 29, Head = 10, Weapon = 12, Body = 7, },
            Frost = { allSlots = 29, Head = 10, Weapon = 12, Body = 7, },
            Unholy = { allSlots = 29, Head = 10, Weapon = 12, Body = 7, },
        },
        HUNTER = {
            ["Beast Mastery"] = { allSlots = 666, },
            Marksmanship = { allSlots = 667, },
            Survival = { allSlots = 668, },
        },
    },
    eligibleItems = {
        [234507] = {
            DEATHKNIGHT = { Blood = true, Frost = true, Unholy = true, },
            MAGE = { Fire = true, Frost = true, Arcane = true, },
            WARLOCK = { Affliction = true, Destruction = true, Demonology = true, },
            WARRIOR = { Protection = true, Arms = true, Fury = true, },
            HUNTER = { ["Beast Mastery"] = true, Marksmanship = true, Survival = true, },
        },
        [157734] = {
            DEATHKNIGHT = { Blood = true, Frost = true, Unholy = true, },
            MAGE = { Fire = true, Frost = true, Arcane = true, },
            WARLOCK = { Affliction = true, Destruction = true, Demonology = true, },
            HUNTER = { ["Beast Mastery"] = true, Marksmanship = true, Survival = true, },
        },
    },
}

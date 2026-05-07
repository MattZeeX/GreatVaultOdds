# API Index

This file groups useful WoW APIs and documentation links by the problems they help solve.

The goal is not to mirror external docs or preserve speculative research. The goal is to make it easier to rediscover which APIs are relevant when solving a similar problem later, and to record short practical notes where the wiki does not fully capture the behaviour or usage details that mattered in testing.

Keep an entry here when it is genuinely useful as a future problem-solving pointer. That usually means one or more of the following are true:

- the API is easy to forget, overlook, or search for by name alone
- it has already been useful to the addon
- the kind of problem it helps solve is likely to recur
- having it grouped with related APIs makes future discovery easier

If an entry is mostly caveats, uncertain behavior, or ongoing investigation, it should usually stay in issue history until the conclusion is clearer.

Project-specific findings that are broader than API usage, or that are better treated as project observations than API notes, belong in [reference.md](./reference.md).

## Encounter Journal / Loot Filtering

### Slot filtering

- [`C_EncounterJournal.GetSlotFilter`](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.GetSlotFilter)
- [`C_EncounterJournal.SetSlotFilter`](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.SetSlotFilter)
- [`C_EncounterJournal.ResetSlotFilter`](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.ResetSlotFilter)
- [`Enum.ItemSlotFilterType`](https://warcraft.wiki.gg/wiki/Enum.ItemSlotFilterType)

Useful for:

- reading or changing the current Encounter Journal item slot filter

### Class/spec loot filtering

- [`EJ_GetLootFilter`](https://warcraft.wiki.gg/wiki/API_EJ_GetLootFilter)
- [`EJ_SetLootFilter`](https://warcraft.wiki.gg/wiki/API_EJ_SetLootFilter)
- [`EJ_ResetLootFilter`](https://warcraft.wiki.gg/wiki/API_EJ_ResetLootFilter)

Useful for:

- reading the current class/spec loot filter
- selecting loot eligibility by class/spec when iterating over an instance's loot

Notes:

- `EJ_ResetLootFilter()` reset the loot filter for class to "all classes" and has no selected specialisation.
- In the same testing, all other filters including slot and difficulty remained unchanged.

### Loot enumeration

- [`EJ_GetNumLoot`](https://warcraft.wiki.gg/wiki/API_EJ_GetNumLoot)
- [`EJ_GetNumEncountersForLootByIndex`](https://warcraft.wiki.gg/wiki/API_EJ_GetNumEncountersForLootByIndex)

Useful for:

- counting loot entries currently exposed by the active Encounter Journal state for instance or encounter, and specific class/spec/item-slot filters
- checking how many encounters are associated with a specific loot entry

### EJ loot data availability event

- [`EJ_LOOT_DATA_RECIEVED`](https://warcraft.wiki.gg/wiki/EJ_LOOT_DATA_RECIEVED)

Useful for:

- reacting when Encounter Journal loot data becomes available
- coordinating work that depends on journal loot data being ready

Notes:

- Blizzard's documented event name uses the misspelling `RECIEVED`.

### Inspect Encounter Journal item metadata

- [`EJ_GetLootInfo`](https://warcraft.wiki.gg/wiki/API_EJ_GetLootInfo)
- [`Struct EncounterJournalItemInfo`](https://warcraft.wiki.gg/wiki/Struct_EncounterJournalItemInfo)
- [`Enum.ItemSlotFilterType`](https://warcraft.wiki.gg/wiki/Enum.ItemSlotFilterType)

Useful for:

- inspecting how the Encounter Journal classifies loot entries
- comparing gear, non-gear, and special-item metadata
- evaluating item metadata such as `displayAsPerPlayerLoot`, `displayAsVeryRare`, and `displayAsExtremelyRare`

## Encounter Journal / Difficulty, Tier, Encounter, and Instance State

### Difficulty state

- [`EJ_GetDifficulty`](https://warcraft.wiki.gg/wiki/API_EJ_GetDifficulty)
- [`EJ_SetDifficulty`](https://warcraft.wiki.gg/wiki/API_EJ_SetDifficulty)
- [`EJ_IsValidInstanceDifficulty`](https://warcraft.wiki.gg/wiki/API_EJ_IsValidInstanceDifficulty)

Useful for:

- reading the currently selected Encounter Journal difficulty
- switching the journal to a specific difficulty before enumerating loot
- validating whether a difficulty is supported for the currently relevant instance

### Tier state

- [`EJ_GetCurrentTier`](https://warcraft.wiki.gg/wiki/API_EJ_GetCurrentTier)
- [`EJ_GetNumTiers`](https://warcraft.wiki.gg/wiki/API_EJ_GetNumTiers)
- [`EJ_SelectTier`](https://warcraft.wiki.gg/wiki/API_EJ_SelectTier)
- [`EJ_GetTierInfo`](https://warcraft.wiki.gg/wiki/API_EJ_GetTierInfo)

Useful for:

- reading the currently selected Encounter Journal tier
- iterating across available tiers
- selecting a tier before traversing its instances and encounters

### Encounter state

- [`EJ_GetEncounterInfo`](https://warcraft.wiki.gg/wiki/API_EJ_GetEncounterInfo)
- [`EJ_SelectEncounter`](https://warcraft.wiki.gg/wiki/API_EJ_SelectEncounter)

Useful for:

- reading information about a specific encounter by ID
- selecting a specific encounter before examining its loot context

### Instance state

- [`EJ_GetInstanceInfo`](https://warcraft.wiki.gg/wiki/API_EJ_GetInstanceInfo)
- [`EJ_GetInstanceByIndex`](https://warcraft.wiki.gg/wiki/API_EJ_GetInstanceByIndex)
- [`EJ_SelectInstance`](https://warcraft.wiki.gg/wiki/API_EJ_SelectInstance)

Useful for:

- traversing the available instances within the selected tier
- reading information about a specific instance by ID
- selecting an instance before applying difficulty, encounter, and loot queries

## Item Data / Item Links

### Item-data readiness patterns

- [`ItemMixin:ContinueOnItemLoad`](https://warcraft.wiki.gg/wiki/ItemMixin#ContinueOnItemLoad)

Useful for:

- handling uncached items during DB generation
- deferring work until item data is actually available

### Check whether an item is an equippable item

- [`C_Item.IsEquippableItem`](https://warcraft.wiki.gg/wiki/API_C_Item.IsEquippableItem)

Useful for:

- checking whether an item should be treated as equippable gear
- filtering out some non-gear loot entries

Notes:

- The wiki documents this as returning `1` if the item is equippable, otherwise `nil`.
- In live testing so far, the practical behaviour appears to be:
  - `true` when the item is equippable and the item data is cached
  - `false` when the item is not equippable
  - `false` when the item data is not yet cached
- Do not assume a falsy result cleanly distinguishes "not equippable" from "not yet cached".

### Item-link context values

- [`ItemLink`](https://warcraft.wiki.gg/wiki/ItemLink)
- [`Enum.ItemCreationContext`](https://warcraft.wiki.gg/wiki/Enum.ItemCreationContext)

Useful for:

- distinguishing different dungeon difficulty reward creation contexts
- investigating how item links differ by difficulty/source

Notes:

- See the observed values in [reference.md](./reference.md#observed-enumitemcreationcontext-values).

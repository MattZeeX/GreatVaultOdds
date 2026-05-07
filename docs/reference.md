# Reference

This file stores project-specific observations, quirks, and non-obvious tested takeaways that are worth recording so they do not need to be rediscovered later.

Use this file for conclusions such as:

- observed game or API behaviour that matters to this addon
- quirks and edge cases discovered through testing
- project-specific takeaways that go beyond a simple API usage note

If a note is mainly about which API to use for a problem, or about practical API usage details that external docs do not explain clearly, it usually belongs in [api-index.md](./api-index.md) instead.

## Encounter Journal

### Encounter Journal state can persist unexpectedly

- Encounter Journal state appears able to "stick" to a selected instance or difficulty and affect later results.
- Opening or changing a dungeon in the journal has previously appeared to produce partial or unexpected item lists until state was reset carefully.
- This is best treated as an observed warning rather than a fully confirmed rule.

### `EJ_SetLootFilter` may be expensive in practice

- Repeated loot-filter changes appear likely to be expensive because the journal refreshes or rebuilds its loot view.
- DB-generation approaches that repeatedly reset loot filters should be profiled before being preferred.

Related:

- [#38](https://github.com/MattZeeX/GreatVaultOdds/issues/38)
- [#89](https://github.com/MattZeeX/GreatVaultOdds/issues/89)

## Loot Classification

### Personal / bonus / very rare loot labels may not map cleanly to addon logic

- Encounter Journal categories such as personal loot, bonus loot, and very rare loot did not appear fully reliable to be excluded as a simple filter for "vault-relevant" items.
- Special items such as mounts, pets, cosmetics, hearthstone-style items, and some unusual dungeon drops may need explicit handling rather than broad category assumptions.

### Initial special-item observations

- Some non-standard loot entries do not currently map cleanly to the categories the addon wants to reason about.
- Initial examples of the [`ItemSlotFilterType`](https://warcraft.wiki.gg/wiki/Enum.ItemSlotFilterType) "other" from the TWW S2 DB:
  - "Golden Snorf": `displayAsPerPlayerLoot`, listed as "bonus loot" in journal UI
  - "Wick's Lead": `displayAsVeryRare`, listed as "very rare" in journal
  - "Schematic: Mecha-Mogul Mk2": no distinction from regular loot
  - "Craboom": no distinction from regular loot
- Encounter Journal loot metadata was useful for testing, but the available booleans were not sufficient as a simple truth source on their own.
- This should be treated as an observations-so-far note until a clearer pattern is established.

### Some item variants may be represented inconsistently

- Some items appear in one stat variant in the journal while another expected variant may not be visible.
- Treat journal representation as a source of edge cases rather than assuming every logical variant will appear cleanly.

## Item Links

### Observed `Enum.ItemCreationContext` values

- `23` has been observed for Mythic 0 dungeon items.
- `2` has been observed for Heroic dungeon items.
- `17` has been observed for Normal dungeon items.

Caveats:

- These observations should still be treated as provisional.
- Dropped items with `bonusIDs` and Mythic+ items may behave differently.

Related:

- [#81](https://github.com/MattZeeX/GreatVaultOdds/issues/81)

## Season IDs

### `GetCurrentDisplaySeasonID()` was not granular enough for DB selection

- [`C_SeasonInfo.GetCurrentDisplaySeasonID()`](https://warcraft.wiki.gg/wiki/API_C_SeasonInfo.GetCurrentDisplaySeasonID) was considered for seasonal DB selection, but it did not distinguish enough of the transitions that matter to this addon.
- In practice, milestone season IDs gave better granularity for the required season boundaries.

Observed milestone season IDs:

- `101` = TWW Season 2
- `102` = TWW Season 3
- `103` = Midnight prepatch during TWW
- `104` = Midnight preseason during Midnight
- `105` = Midnight Season 1

Observed display season IDs:

- `25` = TWW Season 2
- `30` = TWW Season 3
- `31` = some period from Midnight prepatch into preseason
- `34` = Midnight Season 1

Takeaway:

- Prefer milestone season IDs over display season IDs when the addon needs finer seasonal distinctions.

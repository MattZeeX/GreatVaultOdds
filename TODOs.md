### Implementation Required

#### Version 1.0

- Do this

#### Version 1.1

- Do that

### Organisation

- When making issues for features I am implementing, link relevant api wiki pages to help keep things in one place

#### Code Hygiene

- [ ] Sanitise code
  - [ ] Prioritise comment clarity, adding more where necessary
  - [ ] Ensure function and variable names are descriptive
    - [ ] Fix `generateDBForAllSpecs` name
- [ ] Ensure that strsplit gets the "remainder" of the message
- [ ] Localise WoW funcs and enums
  - Consider localising Lua funcs too
- [ ] Abstract out functions

#### Project Structure

- [ ] Organise project directory, use a subfolder for our database
  - Do we want to define our IDs in a separate file?
    - Consider separating our IDs, each into their own table like [dsune](https://github.com/Dsune0/ItemExporter/blob/main/Specializations.lua#L4)
- [ ] Add a nicely styled README like [WeakAuras](https://github.com/WeakAuras/WeakAuras2/blob/main/README.md?plain=1)

#### Database Management

- [ ] Consider separating DBs for each season into separate files
- Look into better solutions to structure the DB
  - Implementation similar to Python flag enum, would require more computation in game but DB will be less lengthy

### Functionality

#### Core Features

- [ ] The tooltip should be sorted by spec name
  - [ ] Bad to sort on every tooltip show, need to cache it
- [ ] Remove invalid Great Vault items from DB
  - Can build DB by item slot
  - Or, can use [`IsEquippableItem`](https://warcraft.wiki.gg/wiki/API_C_Item.IsEquippableItem)
    - Both may break in future season if there is regularly equippable gear that is not available from the vault, like personal loot
    - [`GetLootInfo`](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.GetLootInfo) returns if an item is personal loot
- [ ] Implement numValidItems for each individual slot, and the total field
  - Can achieve this while building our DB
  - When getting items, add the item type to the table
  - Consider doing `spec = itemSlot` instead of `true`
  - Or consider making the itemID table comprised of two sub-tables
    - A subtable of classes as it currently is
    - A subtable of the item slot
      - This subtable could also contain the aliases of the slot
      - i.e. a shield is both an off-hand and a shield, and maybe a weapon
  - Ensure that the "total" count is only incremented if it has not already been done yet for that item ID
    - This is per **spec**
  - We must decrement the total if we remove the item later

#### Debugging and Dev Tools

- [ ] Create various utility/helper functions
  - [ ] Define an `isLootCached` function
    - Iterates through all instances without a loot filter and counts uncached items
    - If > 0 then return false
    - In generate DB function, if this check fails - schedule a callback
      - Or function continues calling itself until the check passes, and then return to main function to continue
      - Or use `ContinueOnItemLoad`
    - Replaces running the function twice
    - If `EJ_LOOT_DATA_RECIEVED` event fired without a payload, could check `isLootCached` func and gen DB if true
    - If the amount of items we check is greater than the cache, we could cause an infinite loop
      - Cache is 2000 items
      - Seasonal items are roughly 250
  - [ ] Logging and debugging functions
    - [ ] Automatically trigger a debugLogging state if an error is encountered
    - [ ] Add already cached items to DevTool
      - Requires some sort of devmode or logging mode enabled
  - [ ] `ensureItemToSpecPath` function to initialise and nil check all DB tables when generating
    - Only if not doing logging or error check with if statements
    - But could still implement this in tandem
  - [ ] Function profiling
    - Implement multiple DB generation methods and run each multiple times with both cached and uncached data
      - Store both the amount of time taken from start to finish as well as the number of function calls
      - These should already be correlated
    - Store the total and average for each implementation, as well as for each "kind" of test (uncached vs cached)
  - [ ] Print functions
    - [ ] Prefix print, will display my addon prefix (coloured) before any message
    - [ ] Pretty print, formats my print using appropriate colours and spacing
      - Alternatively can define constants for colouring
  - [ ] Implement a function to error check the DB
    - I would run this periodically and it would call `DoesItemContainSpec` for each item in the DB
    - If for any item it returns false, we have an error (a false positive)
    - This doesn't check for false negatives, but that is normally not our issue
  - Consider placing these in a separate file
- Do we want to use a devmode toggle?
  - Or a global dev mode that persists through sessions
    - Can store a flag in SVs
    - Or can store character names in a table

#### UI/UX

- [ ] Establish an appropriate style for tooltip implementation, here are some examples:
- [Pawn](https://www.curseforge.com/wow/addons/pawn)
- [Where Do I Get It?](https://www.curseforge.com/wow/addons/where-do-i-get-it)
- [ItemTooltipProfessionIcons](https://www.curseforge.com/wow/addons/itemtooltipprofessionicons)
- [idTip](https://www.curseforge.com/wow/addons/idtip)
- [SpecBisTooltip](https://www.curseforge.com/wow/addons/specbistooltip)
- [BiS-Tooltip](https://www.curseforge.com/wow/addons/bis-tooltip)
- [ ] Implement localisation
  - [ ] Options and help commands
  - [ ] Class/Spec names
  - [ ] Text strings in the tooltip
- [ ] Robust help command
  - [ ] Uses prefix print
  - [ ] Colours command helpfully
    - [ ] Different colour for args and optional params
  - [ ] Clearly explains functionality
- [ ] Finalise my slash command
  - Make sure we are satisfied with the commands
- [ ] Ensure that the DB generation function leaves everything as it found it
  - [ ] Save initial spec filter, slot filter, difficulty filter, selected instance, and selected tier
  - [ ] Add the end, replace all of the filters we changed so that the journal is left as we found it

### Future Enhancements

#### Features

- [ ] When generating DBs, we want to include helpful metadata
  - [ ] Character name
  - [ ] Game version
  - [ ] Season ID
  - [ ] Character level
  - [ ] Number of items already cached
    - Name and item ID of cached items
- [ ] Add functionality to copy the DB directly from a frame
  - Use [this snippet](https://www.wowinterface.com/forums/showthread.php?p=323901#post323901) and the corresponding one in SimC
- [ ] Add a GUI for options
  - Consider adding keybindings for (any) common tasks
- [ ] Add modifier key support
  - We will have more features in the future and this can help to de-clutter the tooltip
- [ ] On tooltip, also show the chance of getting that specific "kind of item"
  - e.g. trinkets
    - Break down into further sub-categories, off-hands vs shields
- [ ] Optionally, allow the player to see the chance from the instance, not just the vault
  - "Which spec is better for me to loot this dungeon chest in?"
  - Could implement an option where it would automatically show on the tooltip when you are in the respective zone
    - Otherwise modifier key, or always shown
- [ ] [Replace the current DB generation method](https://discord.com/channels/@me/444281656246009856/1379024729385603214) of calling the function twice to ensure loot data is cached
  - Consider using the `isLootCached` function we have hypothesized
  - Consider a counter for uncached items, and decrement the counter when the `ContinueOnItemLoad` callback is fired
    - Once counter is equal to 0, proceed with generating the DB
    - Or, once final `EJ_LOOT_DATA_RECIEVED` is fired, can proceed with generating DB
      - Cancel the fallback timer that we schedule to generate or cancel DB if this check never passes
    - Could use this event without registering a `ContinueOnItemLoad` callback, less accurate but more performant
  - Consider calling [`DoesItemContainSpec`](https://warcraft.wiki.gg/wiki/API_C_Item.DoesItemContainSpec) for all items and specs instead
    - This requires a lot of function calls, test with profiling method mentioned in testing section
    - Optionally, can only call this function if item is uncached
- [ ] Should the addon be loaded on classic, we want to display an error message telling them to uninstall
  - Or should we set up our TOC to ensure it can never load outside of retail?
  - How do we accomplish this?
- [ ] `generateDBForAllSpecs` should iterate through instances in the outer loop, and specs as the innermost loop instead of the way it currently is
  - Reduced function calls
- [ ] The tooltip handler should not call functions to get the player's current class and spec
  - Instead, do these checks at login and after a [`PLAYER_SPECIALIZATION_CHANGED`](https://warcraft.wiki.gg/wiki/PLAYER_SPECIALIZATION_CHANGED) event or [`PLAYER_LOOT_SPEC_UPDATED`](https://warcraft.wiki.gg/wiki/PLAYER_LOOT_SPEC_UPDATED)
    - Check the documentation as this event may be unreliable
    - We might have to find an alternative
- [ ] Ensure that the tooltip handler has the appropriate nilchecks, we don't want any lua errors in this as it's player-facing
  - Figure out what is the expected structure of the [tooltip](https://warcraft.wiki.gg/wiki/Struct_TooltipData)
  - Ask around about how to be safe for handling the tooltip

#### Considerations

- [ ] Include info about loot "quality"
  - Chance of getting a "good" item vs a "bad" item
  - If the item is available in multiple loot specs, want to compare lowest quantity of bad items in addition to which has the highest chance of getting item
  - Consider "highlighting" "desirable" loot
  - Summarise undesirable options on vault for each spec
    - Make it clear which spec to open vault as to avoid the most "bad" items
- [ ] When entering our "real" run creating our DB (all data is expected to be cached), what should we do if we encounter a seemingly uncached item?
  - Do we delete the table for that iteration and break out of the function, and call it again after some condition is passed?
    - In theory, we should have checked the initial data and thus it should be accurate
  - Do we skip that item and keep going assuming that will be the only error? And then go back for it later? Or call `DoesItemContainSpec`?
    - But if we have one uncached item, I'd expect more to follow
- [ ] When should the tooltip show?
  - Only in the encounter journal? Or any matching item?
- [ ] If the current season does not match the metadata for our DB, consider automatically building a fallback DB
  - <https://warcraft.wiki.gg/wiki/API_C_SeasonInfo.GetCurrentDisplaySeasonID>
  - Create workflow/process to ensure when a new patch comes out we already have a DB ready
    - Keep the old DB for a few weeks
    - Consider adding multiple patches to the metadata so a single DB supports multiple version (if loot pool is identical)
  - Do we want to implement this if the current patch doesn't match the DB?
  - Prompt the user to check for updates if the addon DB version is less than the fallback DB/game version
  - Do we prefer the fallback DB if the version is the same as the addon DB?
    - Do we want to allow users to generate their own fallback DB if they suspect a bug?
    - [ ] If we add support for user generated DBs, we need to add DB manipulation
      - [ ] Comparison feature, check diffs between two specific tables, or compare all tables to one selected "master" table
      - [ ] List all saved DBs by name
        - This list should be ordered, [single map from names to entries with creation_order stored as metadata](https://chatgpt.com/c/682c56b3-bde4-8005-b549-137a2900a75f)
  - We must update the addon DB version if we fix a bug
    - This version should supersede a fallback DB
  - When do we delete SVs?
    - [ ] Delete all DBs with a version lower than the addon DB?
- [ ] Consider a window that shows a visual representation of the loot specs, and the overlaps they share
  - Could use a venn diagram, want to show the commonality so as to focus on the outlier and what distinguishes between the specs
    - What is the best method of doing this? Could be problematic with Druids having 4 specs
      - How would you show items shared between Guardian/Feral/Boomie (damage) but not Resto, whilst also showing commonality between Guardian/Resto and Boomie/Resto
    - Implementing this may require a redesign of the database structure
      - May need to group similar items together and then use a subtable for the differences
      - Python flag enum
- [ ] Consider calling `C_AddOns.LoadAddOn("Blizzard_EncounterJournal")` to deal with a possible case where we can unregister events from the EJ but then it unloads and thus we can no longer re-register them
- [ ] Consider only modifying specific tooltips
  - ShoppingTooltip is the tooltip when comparing (holding shift) gear
    - There is 1 through 3, but it is unknown what the extras do
  - ItemRefTooltip is the tooltip when clicking an item out of chat
  - ItemRefShoppingTooltip is the tooltip when clicking an item out of chat while holding shift (comparing)
  - Is there a specific tooltip for the dungeon journal?
    - This way we would only show when they look in the journal, not hovering over random items
    - Perhaps not desired, could be an option though
- [ ] Implement a safeguard if another addon (e.g. TSM) is caching item data and thus if we were to assume our items were still cached later, we might run into an issue
  - How can we detect that the item cache is being overwritten?
  - Presumably not possible, does TSM have an API we can use to see if it's using the cache?
  - Inevitably will just have to keep checking if items are cached before we use them
  - Do a test to see what happens if we generate a DB while TSM is caching
- [ ] Find other implementations of DBs and see how they differ from mine
  - Is there a better way to store my data? This harkens back to the flag enum
  - RaiderIO has a DB but it's very complicated

#### Build/Distribution Automation

- [ ] Consider making a WA version of the addon for easier distribution
  - Not feasible to store a DB, so would have to gen on login
    - Could only generate for that class in order to reduce overhead
    - Allows more time to verify/check
- [ ] Automatic releases
  - [BigWigs GitHub Actions](https://github.com/BigWigsMods/packager/wiki/GitHub-Actions-workflow)
  - [Mcitalian wow build tools](https://github.com/Mctalian/wow-build-tools/tree/beta)
- [ ] Automatic TOC bump
  - [Marketplace TOC replacer](https://github.com/marketplace/actions/wow-toc-version-replacer)
  - [p3lim toc updater](https://github.com/p3lim/toc-interface-updater)
  - [Mcitalian TOC updater](https://github.com/Mctalian/toc-interface-updater)

### Testing

- [ ] Identify definitively what fires `EJ_LOOT_DATA_RECIEVED` events
  - Note which fire *blank* payload events
  - [ ] Test [`GetLootInfoByIndex`](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.GetLootInfo) for indices 1 through 10 without running `EJ_GetNumLoot`
  - [ ] Test `EJ_GetNumLoot` for both instance and encounter
    - Where all items are cached except 1
    - Do we get both the blank payload and one with the specific item ID?
  - [ ] Test `EJ_SetDifficulty`
  - [ ] Test [`SetSlotFilter`](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.SetSlotFilter)
  - [ ] Test `EJ_SelectInstance`
  - [ ] Test `EJ_SetLootFilter`
- [ ] Identify what unregistering EJ events does
  - [ ] Does this allow us to click on objects in the journal without changing selected instance or loot filter?
  - [ ] Does it prevent caching new items from clicking on them?
  - [ ] Does it stop firing events?
- [ ] Figure out the behaviour of the EJ
  - What changes the:
    - [ ] Difficulty filter
    - [ ] Loot filter
    - [ ] Slot filter
    - [ ] Selected tier
    - [ ] Selected instance
  - [ ] If something *does* change these, does it immediately rectify it or do we need to call the function again?
  - We want to call the functions as few times as possible so ideally set it outside of a loop
  - [ ] Ensure that journal selections such as `EJ_SelectInstance`, `EJ_SetDifficulty`, `EJ_SetLootFilter`, `SetSlotFilter` are not overwritten when selecting others
    - I expect the difficulty filter will change upon selecting a new instance
    - I also expect that setting the difficulty filter to M+ and then selecting a dungeon without M+ as an option means that the difficulty filter will be wrong for the rest of the instances
      - Even those that do have a M+ option
  - [ ] What occurs if we set the difficulty of a dungeon to M+ if there is no M+ difficulty available?
    - e.g. Violet Hold or TOP
    - Or older pre-legion dungeons?
  - [ ] Triple check that calling `EJ_GetNumLoot` once caches all the data for the selected instance and loot filter
    - [ ] Check what next call of `EJ_GetNumLoot` returns
      - It should obey the current filter, but in prior testing it gave the number of loot for the whole *class*, **not** spec
        - I expected this was a flaw in my initial testing
    - [ ] Identify if it caches any other items, e.g. items in other instances or not for the matching filter
    - [ ] What would occur if for the loot filter selected, all the loot was cached
      - Would calling `EJ_GetNumLoot` result in no `EJ_LOOT_DATA_RECIEVED` event firing because all loot data for the filter is available?
      - Or would it still cache items not for the selected loot filter?
      - I expect it will return the correct number and not fire any events
- [ ] Test what [`EJ_ResetLootFilter`](https://warcraft.wiki.gg/wiki/API_EJ_ResetLootFilter) does
  - [ ] Does it clear the loot filter?
  - [ ] Does it reset it to what was last stored in the CVars?
- [ ] Attempt to identify deterministic behaviour of the item cache
  - Log on to a character without any addons except devmode and lua
  - Dump the entirety of the item cache
  - Cache 100 new items
  - Dump the cache again
  - Fully exit the game, and then reopen it
  - Dump the cache
  - Compare if the cache is identical to what it was prior to logging off
    - If not, what changed?
- [ ] Test what happens if we were to generate a DB while TSM or any other addon is caching a significant amount of items simultaneously
  - [ ] While testing, keep an eye out for "double" `EJ_LOOT_DATA_RECIEVED` events that lack a payload
    - Currently unknown why this occurs
    - Could have negative implications if we implement a callback on this event

### General TODOs

- [ ] Add the required regex so [escape sequences](https://warcraft.wiki.gg/wiki/UI_escape_sequences) in WoW text are not constantly flagged in spell checker for VSCode

### Resources

- <https://github.com/semantic-release/semantic-release>
- <https://github.com/Mctalian/RPGLootFeed/blob/main/.github/workflows/toc-updater.yml>
- <https://github.com/Mctalian/RPGLootFeed/pull/253>
- <https://marketplace.visualstudio.com/items?itemName=probabri.profanitychecker>
- <https://github.com/IEvangelist/profanity-filter> 😳
- <https://gitmoji.dev/>
- <https://gist.github.com/FlyteWizard/468c0a0a6c854ed5780a32deb73d457f>
- <https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet>
- <https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax>
- <https://warcraft.wiki.gg/wiki/API_C_AddOns.GetAddOnMetadata>
- <https://github.com/Gethe/wow-ui-source/blob/0b949009d9558869da5c53ac61c23f2d711b1f6f/Interface/AddOns/Blizzard_FrameXMLUtil/DifficultyUtil.lua#L1>
- <https://warcraft.wiki.gg/wiki/API_EJ_GetInvTypeSortOrder>
- <https://www.wowace.com/projects/ace3/pages/getting-started>
- <https://warcraft.wiki.gg/wiki/Ace3_for_Dummies>
- <https://warcraft.wiki.gg/wiki/World_of_Warcraft_API>
- <https://warcraft.wiki.gg/wiki/FrameXML_functions>
- <https://warcraft.wiki.gg/wiki/Category:HOWTOs>
- [GetLootInfo](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.GetLootInfo) for `encounterIndex` returns nil if the difficulty doesn't exists, e.g. TOP with M+

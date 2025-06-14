### Core functionality for tooltip DB/loot display.

- [ ] [Ensure DB generation restores filters](#issue-TODO)

### **Core Addon Features**

* Ensure DB generation restores Encounter Journal filters

### 📌 Issue: Ensure DB generation restores Encounter Journal filters

**Labels**: `feature`, `core`
**Milestone**: `v1.0`

**Description**:
When running DB generation, EJ filters (like slot, spec, difficulty) are changed.

* [ ] Save filters at start
* [ ] Restore them at the end of the function
* [ ] Ensure no state persists unexpectedly across generations

## 🏷️ 2. Suggested Label System

| Label          | Purpose                                            |
| -------------- | -------------------------------------------------- |
| `feature`      | New gameplay-related functionality                 |
| `bug`          | Unexpected behavior                                |
| `refactor`     | Code structure improvements                        |
| `ui`           | User interface changes                             |
| `tooltip`      | Anything related to tooltip display                |
| `debug`        | Debug tools/logging                                |
| `testing`      | Anything requiring verification                    |
| `event`        | Related to WoW events like `EJ_LOOT_DATA_RECEIVED` |
| `database`     | Data structure or DB manipulation                  |
| `core`         | Foundational systems for the addon                 |
| `localisation` | Translations, class/spec name strings              |
| `automation`   | CI/CD or TOC bumping                               |
| `build`        | Distribution pipeline, WA conversion, etc.         |
| `research`     | Exploratory tasks, e.g., how EJ or cache works     |
| `low-priority` | Optional or polish-related                         |
| `stretch`      | Nice-to-have but not planned                       |

## ✅ 2. Explanation of Sub-Issue Links (placeholders)

In the original parent issue markdown (e.g. `Core Addon Features`), each bullet:
- [ ] Sort tooltip by spec name and cache it
...should eventually link to its corresponding GitHub Issue:
- [ ] [Sort tooltip by spec name and cache it](https://github.com/YourUser/YourRepo/issues/123)


----- missing

Ensure that strsplit gets the "remainder" of the message

Organise project directory, use a subfolder for our database
Do we want to define our IDs in a separate file?
Consider separating our IDs, each into their own table like dsune

Add a nicely styled README like WeakAuras

Add functionality to copy the DB directly from a frame
Use this snippet and the corresponding one in SimC

On tooltip, also show the chance of getting that specific "kind of item"
e.g. trinkets
Break down into further sub-categories, off-hands vs shields

Optionally, allow the player to see the chance from the instance, not just the vault
"Which spec is better for me to loot this dungeon chest in?"
Could implement an option where it would automatically show on the tooltip when you are in the respective zone
Otherwise modifier key, or always shown

Replace the current DB generation method of calling the function twice to ensure loot data is cached
Consider using the isLootCached function we have hypothesized
Consider a counter for uncached items, and decrement the counter when the ContinueOnItemLoad callback is fired
Once counter is equal to 0, proceed with generating the DB
Or, once final EJ_LOOT_DATA_RECIEVED is fired, can proceed with generating DB
Cancel the fallback timer that we schedule to generate or cancel DB if this check never passes
Could use this event without registering a ContinueOnItemLoad callback, less accurate but more performant
Consider calling DoesItemContainSpec for all items and specs instead
This requires a lot of function calls, test with profiling method mentioned in testing section
Optionally, can only call this function if item is uncached

Should the addon be loaded on classic, we want to display an error message telling them to uninstall
Or should we set up our TOC to ensure it can never load outside of retail?
How do we accomplish this?

The tooltip handler should not call functions to get the player's current class and spec
Instead, do these checks at login and after a PLAYER_SPECIALIZATION_CHANGED event or PLAYER_LOOT_SPEC_UPDATED
Check the documentation as this event may be unreliable
We might have to find an alternative

Ensure that the tooltip handler has the appropriate nilchecks, we don't want any lua errors in this as it's player-facing
Figure out what is the expected structure of the tooltip
Ask around about how to be safe for handling the tooltip
Considerations

Include info about loot "quality"
Chance of getting a "good" item vs a "bad" item
If the item is available in multiple loot specs, want to compare lowest quantity of bad items in addition to which has the highest chance of getting item
Consider "highlighting" "desirable" loot
Summarise undesirable options on vault for each spec
Make it clear which spec to open vault as to avoid the most "bad" items

When entering our "real" run creating our DB (all data is expected to be cached), what should we do if we encounter a seemingly uncached item?
Do we delete the table for that iteration and break out of the function, and call it again after some condition is passed?
In theory, we should have checked the initial data and thus it should be accurate
Do we skip that item and keep going assuming that will be the only error? And then go back for it later? Or call DoesItemContainSpec?
But if we have one uncached item, I'd expect more to follow

When should the tooltip show?
Only in the encounter journal? Or any matching item?
Consider only modifying specific tooltips
ShoppingTooltip is the tooltip when comparing (holding shift) gear
There is 1 through 3, but it is unknown what the extras do
ItemRefTooltip is the tooltip when clicking an item out of chat
ItemRefShoppingTooltip is the tooltip when clicking an item out of chat while holding shift (comparing)
Is there a specific tooltip for the dungeon journal?
This way we would only show when they look in the journal, not hovering over random items
Perhaps not desired, could be an option though

Consider a window that shows a visual representation of the loot specs, and the overlaps they share
Could use a venn diagram, want to show the commonality so as to focus on the outlier and what distinguishes between the specs
What is the best method of doing this? Could be problematic with Druids having 4 specs
How would you show items shared between Guardian/Feral/Boomie (damage) but not Resto, whilst also showing commonality between Guardian/Resto and Boomie/Resto
Implementing this may require a redesign of the database structure
May need to group similar items together and then use a subtable for the differences
Python flag enum

Consider calling C_AddOns.LoadAddOn("Blizzard_EncounterJournal") to deal with a possible case where we can unregister events from the EJ but then it unloads and thus we can no longer re-register them
Find other implementations of DBs and see how they differ from mine
Is there a better way to store my data? This harkens back to the flag enum
RaiderIO has a DB but it's very complicated
Build/Distribution Automation

Identify what unregistering EJ events does

Does this allow us to click on objects in the journal without changing selected instance or loot filter?

Does it prevent caching new items from clicking on them?

Does it stop firing events?

Test what EJ_ResetLootFilter does

Does it clear the loot filter?

Does it reset it to what was last stored in the CVars?
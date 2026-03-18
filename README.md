# Great Vault Odds

**Great Vault Odds** is a World of Warcraft addon that makes it trivial to see which loot specialisation gives you the best chance of getting a **specific item** from the current season's dungeon loot pool. It works for the Great Vault, the Mythic+ end-of-dungeon chest, and individual bosses in Normal, Heroic, and Mythic dungeons.

When you hover over an item from this season's dungeons, the tooltip displays **which of your specs** can receive that item and **how large** each spec's eligible loot pool is.

This makes it much easier to answer questions like:

- "Should I open my Vault as a different loot spec for a better chance at this item?"
- "Can I avoid more undesirable items by using a different loot spec?"
- "Which of my specs can receive this item?"

If you care about increasing your chances for better loot, then Great Vault Odds is for you!

## How the information is displayed

For class-eligible current-season dungeon items, Great Vault Odds adds extra lines to the tooltip showing you how likely it is for each spec to receive that item.

The tooltip breaks the numbers down into three levels:

- **Vault**: your total number of eligible current-season Mythic+ Great Vault items for that spec
- **M+**: your total number of eligible items from that specific dungeon for that spec
- **Boss**: your total number of eligible items from that specific boss for that spec

![image](https://media.forgecdn.net/attachments/description/null/description_e9d32ad1-a61a-4688-beee-3dcd86b0251e.png)

In simple terms, the addon helps you compare **how diluted your loot pool is** for each spec.

If one spec can receive fewer total items than another, that usually means it has **better odds** of seeing a specific item in the Vault or from that dungeon/boss.

## Example

Imagine you want one specific item.

- Spec A can receive **58** eligible Mythic+ Vault items
- Spec B can receive **72** eligible Mythic+ Vault items

If both specs can receive your target item, **Spec A has the better odds**, because its loot pool is smaller. You may also want to take into consideration if the other spec can receive any **undesirable items**, i.e. role-specific trinkets.

Great Vault Odds puts that comparison directly on the item tooltip so you do not have to manually check loot tables for each spec and tally up the items.

Great Vault Odds is most useful for classes whose specs span multiple roles or use different primary stats and weapon types. Sorry Warlocks!

## Support

If you have any issues whatsoever, please do not hesitate to leave a comment and I will get in touch ASAP. I am working on cleaning up my GitHub repo to streamline issue reporting.

## Notes

This addon is still a WIP and I intend to keep supporting it. Planned features include:

- Raid support
- More tooltip customisations to show more or less information, as well as controlling the tooltip with modifier keys
- Tooltip beautification
- Allowing you to see loot eligibility for other members of your group, to help roll on loot for friends
- Item slot information, to target specific slots as opposed to specific items
- Great Vault loot spec reminders
- Preconfigured automatic loot spec swapping per boss/dungeon to target the loot you want
- Localisation

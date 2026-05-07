# Resources

This file stores curated external resources that are useful to revisit during development.

Use it for:

- addon examples worth studying
- tools and workflows worth reusing
- documentation and learning resources worth keeping close to hand

## Addon Examples

Examples of addons and codebases with features, patterns, or structure worth studying.

### Loot spec management and auto-swap

- [LootSpecManager](https://www.curseforge.com/wow/addons/lootspecmanager)
- [LootSpecManager Reloaded](https://www.curseforge.com/wow/addons/lootspecmanager-reloaded)
- [AutoLootSpec Advanced](https://www.curseforge.com/wow/addons/autolootspec-advanced)
- [AutoLootSpecSwap](https://www.curseforge.com/wow/addons/autolootspecswap)
- [AutoLootSpec](https://www.curseforge.com/wow/addons/autolootspec)

Useful for: loot spec selection patterns, automation ideas, and related UI flows.

### Tooltip and loot information

- [Pawn](https://www.curseforge.com/wow/addons/pawn): stats comparison display
- [SpecBisTooltip](https://www.curseforge.com/wow/addons/specbistooltip): BiS indicators on tooltips
- [BiS-Tooltip](https://www.curseforge.com/wow/addons/bis-tooltip): alternative BiS display
- [LootSpec-Tooltip](https://www.curseforge.com/wow/addons/lootspec-tooltip): loot spec eligibility display
- [Encounter Journal Loot Spec Icons](https://www.curseforge.com/wow/addons/encounterjournallootspecicons): EJ-integrated loot spec display
- [Where Do I Get It?](https://www.curseforge.com/wow/addons/where-do-i-get-it): item source tracking
- [ItemTooltipProfessionIcons](https://www.curseforge.com/wow/addons/itemtooltipprofessionicons): profession icon display
- [idTip](https://www.curseforge.com/wow/addons/idtip): item ID display on tooltips

Useful for: tooltip hooks, information layout, and display conventions.

### Great Vault and loot quality-of-life

- [Great Vault Loot Spec Reminder](https://www.curseforge.com/wow/addons/great-vault-loot-spec-reminder): reminder before opening the vault
- [ReVault](https://www.curseforge.com/wow/addons/revault): vault sharing and export
- [LootSpecHelper](https://www.curseforge.com/wow/addons/lootspechelper): alternative loot-spec-focused addon

Useful for: player workflow, quality-of-life ideas, data collection, and related feature inspiration.

### Codebase and implementation references

- [WeakAuras2](https://github.com/WeakAuras/WeakAuras2): complex addon architecture; also useful as a README/documentation style reference
- [ItemExporter](https://github.com/Dsune0/ItemExporter): specialisation data handling; see [Specializations.lua](https://github.com/Dsune0/ItemExporter/blob/main/Specializations.lua)
- [RPGLootFeed](https://github.com/Mctalian/RPGLootFeed): similar project structure and release workflow
- [Leatrix Plus](https://github.com/Pdizzle/Leatrix-Plus): simpler, well-structured addon reference
- [Blizzard FrameXML Utilities](https://github.com/Gethe/wow-ui-source/blob/0b949009d9558869da5c53ac61c23f2d711b1f6f/Interface/AddOns/Blizzard_FrameXMLUtil/DifficultyUtil.lua): difficulty utility reference

Useful for: addon structure, data handling, helper patterns, and documentation style.

## Development Workflow, Automation, and Tooling

External tools and references for packaging automation, versioning, commits, and repository workflow.

### Release and packaging

- [BigWigs Packager](https://github.com/BigWigsMods/packager/wiki/GitHub-Actions-workflow): GitHub Actions workflow for WoW addon packaging and release
- [McItalian WoW Build Tools](https://github.com/Mctalian/wow-build-tools/tree/beta): alternative build tools for WoW addons
- [RPGLootFeed TOC Updater Workflow](https://github.com/Mctalian/RPGLootFeed/blob/main/.github/workflows/toc-updater.yml): example TOC version management

### TOC and interface version management

- [p3lim TOC Interface Updater](https://github.com/p3lim/toc-interface-updater)
- [McItalian TOC Interface Updater](https://github.com/Mctalian/toc-interface-updater)

### Commits, versioning, and release notes

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/): commit message format
- [Semantic Release](https://github.com/semantic-release/semantic-release): automated version management
- [commitlint Config Conventional](https://github.com/conventional-changelog/commitlint/tree/master/%40commitlint/config-conventional): commit linting rules
- [Angular Commit Guidelines](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#-commit-message-guidelines): comprehensive commit standards reference
- [Keep a Changelog](https://keepachangelog.com/en/1.1.0/): changelog format conventions

### Git and code review tools

- [Git Graph](https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph): visual git branching and history
- [SemanticDiff](https://semanticdiff.com/docs/what-is-semanticdiff/): semantic code comparison
- [Git Flow Cheatsheet](https://gist.github.com/qoomon/5dfcdf8eec66a051ecd85625518cfd13)

### Publishing and metadata

- [GitHub Releases Management](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository)
- [CurseForge Addon Metadata](https://www.wowinterface.com/forums/showthread.php?p=323901#post323901): metadata and submission requirements
- [GitHub Pages Demo](https://ycl6.github.io/GitHub-Pages-Demo/): example of publishing docs with GitHub Pages

## Documentation and Learning

General development references that are useful to keep nearby.

### WoW addon and API documentation

- [World of Warcraft API](https://warcraft.wiki.gg/wiki/World_of_Warcraft_API): main WoW API hub
- [FrameXML Functions](https://warcraft.wiki.gg/wiki/FrameXML_functions): UI frame scripting reference
- [Category: HOWTOs](https://warcraft.wiki.gg/wiki/Category:HOWTOs): practical addon development guides
- [Warcraft API Events](https://warcraft.wiki.gg/wiki/Category:Events): event-system reference

### UI and tooltip documentation

- [`Struct TooltipData`](https://warcraft.wiki.gg/wiki/Struct_TooltipData): tooltip data structures
- [`UI_escape_sequences`](https://warcraft.wiki.gg/wiki/UI_escape_sequences): colour and formatting escape codes

### Ace3 Framework

- [Ace3 Getting Started](https://www.wowace.com/projects/ace3/pages/getting-started): Ace3 overview and setup
- [Ace3 for Dummies](https://warcraft.wiki.gg/wiki/Ace3_for_Dummies): beginner-friendly Ace3 guide

### Lua and addon-learning references

- [Lua 5.1 Manual](https://www.lua.org/manual/5.1/): WoW uses Lua 5.1
- [Learn Lua in 15 Minutes](http://tylerneylon.com/a/learn-lua/): quick Lua fundamentals
- [Getting Started with WoW Addons](https://warcraft.wiki.gg/wiki/Getting_started_with_WoW_addons): addon development basics

### Markdown and writing

- [Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
- [GitHub Markdown Syntax](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)

# Workflow

This file records the current working conventions for the repo, project board, issues, verification, and releases.

## Branching

- `main` is the latest verified state.
- `dev` is the active working branch and may be ahead of `main`.
- Optional feature branches can branch off `dev` when useful.
- Docs should follow the same branch flow as code.

## Pull Requests and Issue Linking

- During implementation, prefer references such as `Refs #123`.
- Avoid using `Closes #123` or similar until the work has been verified and is actually ready to be concluded.
- PRs are still useful as a solo developer because they separate implementation from verification and merging.

## Project Status Usage

### `Needs Triage`

- Newly captured work that has not yet been reviewed and categorised.
- Drafts usually begin here.

### `Wishlist`

- Real ideas worth keeping, but not active planned work yet.
- Usually do not assign a priority here unless there is a strong reason.

### `Backlog`

- Real candidate work that is approved for future consideration.

### `Upcoming`

- The next small set of tasks likely to be worked on soon.

### `In Progress`

- Actively being implemented or investigated.

### `On Hold`

- Paused due to blockers, missing information, dependencies, or timing.
- Do not use this just because an issue is generally deferred.

### `Verify`

- Implementation is complete.
- Final confirmation, testing, or last-mile polish still remains.

### `Resolved`

- Completed and closed, or intentionally concluded.

## Priority Usage

- `High`: unusually important or urgent.
- `Normal`: default planned work.
- `Low`: deliberately deprioritised work.

Important distinction:

- `Wishlist` means not currently committed.
- `Low` means committed, but lower than other planned work.

## Drafts, Issues, and Docs

- Drafts are for rough capture and early thoughts.
- Issues are for actionable work.
- Docs are for durable knowledge and workflow standards.

Use this rule:

- If it is a rough thought, keep it as a draft.
- If it is a real piece of work, make it an issue.
- If it is a durable conclusion or reusable note, put it in docs.

## Writing Conventions

- Use British English for comments, docs, and ordinary project naming.
- Preserve Blizzard/API naming exactly as documented, even when it uses American spelling or inconsistent naming.
- Use 4-space indentation in Lua and general code files unless a file has a deliberate special format.
- Use 2-space indentation in Markdown docs.
- If DB files later adopt a different indentation style for clarity or compactness, document that change here.
- If a Markdown heading is renamed, update any references to that heading as part of the same change. A repo-wide find/replace is usually the easiest way to do this.

## Research and Documentation

- Investigation issues are the default place to record research, testing, and open questions.
- Docs should usually record only the distilled takeaway once it becomes useful and durable.
- Do not promote unresolved technical questions into `reference.md`.

## Parent Issues and Dependencies

### Parent issues

- Use parent issues only for real multi-issue initiatives.
- Parents should be bounded and eventually closable.
- Child issues are the actual actionable work.

### `blocked by`

- Use `blocked by` when one issue truly cannot proceed until another is resolved.
- Use parent/sub-issue for hierarchy.
- Use `blocked by` for dependency.

These relationships can coexist when appropriate.

## Labels

### `type:*`

Use exactly one type label per issue:

- `type: bug`
- `type: feature`
- `type: enhancement`
- `type: investigation`
- `type: refactor`
- `type: documentation`

### `focus:*`

Usually use one focus label.
Use a second only when the issue genuinely spans multiple areas:

- `focus: core`
- `focus: database`
- `focus: tooltip`
- `focus: ui`
- `focus: debug`
- `focus: automation`
- `focus: localisation`
- `focus: repo`

## Verification and Closing

- Implemented work should generally be verified before issue closure.
- `Verify` is for work that is functionally done but still needs confirmation.
- `On Hold` is for work blocked by dependencies, outside information, or timing.

## Release Philosophy

- Do not release purely for invisible internal cleanup unless it delivers meaningful value.
- Releasing makes most sense when there is user-facing functionality, meaningful compatibility/stability improvement, or packaging/release value worth surfacing.
- `main` may advance without every merge becoming a published release.

## Milestones

- Milestones are primarily release-oriented.
- Use them for work that belongs to a specific release scope or meaningfully shipped in that release.
- Do not use them for every internal work stream.

## Dev-Only Material

- Durable written knowledge belongs in `docs/`.
- Raw snippet files belong in the top-level `snippets/` folder.
- Snippets are not packaged with the addon.

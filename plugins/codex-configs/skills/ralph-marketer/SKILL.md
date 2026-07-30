---
name: ralph-marketer
description: Autonomous SaaS content marketing workflow adapted from the Ralph Wiggum Marketer repo for Codex. Use when the user asks to initialize, continue, inspect, or run an iterative copywriting/content pipeline with PRD stories, SQLite content sources, drafts, review, publishing, progress logs, or founder voice/brand voice analysis.
---

# Ralph Marketer

Use this skill to run a Codex-native version of Ralph Wiggum Marketer. The original Claude slash commands and stop hook are replaced by a file-backed workflow that Codex can continue across turns.

## Quick Start

To initialize a project in the current directory:

```bash
.agents/skills/ralph-marketer/scripts/init-ralph-project.sh
npm install
npm run db:reset
npm test
```

If the skill is installed outside the current workspace, run the `init-ralph-project.sh` script from that skill folder instead.

## Project Layout

After initialization, expect:

```text
scripts/ralph/prd.json
scripts/ralph/progress.txt
scripts/ralph/prompt.md
src/db/init.js
src/db/seed.js
src/db/status.js
src/db/query.js
src/content/list.js
src/test.js
content/drafts/
content/published/
data/content.db
```

## Workflow

1. Check state with `npm run db:status`, `npm run content:list`, and `scripts/ralph/progress.txt`.
2. Read `scripts/ralph/prd.json`.
3. Pick the highest-priority story where `passes` is `false`.
4. Execute only that story unless the user explicitly asks for a longer run.
5. Save drafts in `content/drafts/` and final pieces in `content/published/`.
6. Keep database state in sync with files.
7. Run `npm test`.
8. Mark the story as passed in `scripts/ralph/prd.json`.
9. Append a concise entry to `scripts/ralph/progress.txt`.
10. Commit only when the user asks for commits or the current repository workflow expects them.

When all stories pass, report `<promise>COMPLETE</promise>` to the user.

## Codex Adaptation Notes

- There are no slash commands. Treat user phrases like "init Ralph", "run Ralph", "status do Ralph", or "continua o Ralph" as requests to follow this skill.
- There is no autonomous stop hook in Codex. Continue proactively within the current turn, but do not rely on hook-based self-resumption.
- Prefer small, verifiable iterations. For a broad "run Ralph" request, complete the next story and explain what remains unless the user asks for a full sprint.
- Use `rg`, `sed`, and the provided Node scripts for inspection. Use structured database queries through `better-sqlite3` when changing state.
- For brand voice and content quality guidance, read `references/copywriter-quality-loop.md` only when writing or reviewing content.
- For detailed original agent instructions, read `references/ralph-agent-instructions.md`.

## Database Rules

- Database path: `./data/content.db`.
- Always close `better-sqlite3` connections.
- JSON columns must be serialized/deserialized deliberately: `target_keywords`, `key_messages`, `data_points`, `sources`, and related list fields.
- `content_plan` supports direct source links: `based_on_trend_id`, `based_on_research_id`, and `based_on_comm_id`.
- Valid `content_plan.status` values are `planned`, `researching`, `writing`, `critiquing`, `iterating`, `review`, `published`, and `cancelled`.

## Useful Commands

```bash
npm run db:status
npm run content:list
node src/db/query.js trends active
node src/db/query.js research available
node src/db/query.js comms pending
node src/db/query.js plan
npm test
```

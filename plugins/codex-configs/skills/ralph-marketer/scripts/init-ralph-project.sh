#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_DIR="$SKILL_DIR/assets/ralph-template"
FORCE="${1:-}"

if [ -e scripts/ralph/prd.json ] && [ "$FORCE" != "--force" ]; then
  printf '%s\n' "Ralph project already exists at scripts/ralph/prd.json."
  printf '%s\n' "Re-run with --force to overwrite template-controlled files."
  exit 1
fi

mkdir -p scripts/ralph content/drafts content/published data src/db src/content

cp "$TEMPLATE_DIR/templates/prd.json" scripts/ralph/prd.json
cp "$TEMPLATE_DIR/templates/progress.txt" scripts/ralph/progress.txt
cp "$TEMPLATE_DIR/templates/prompt.md" scripts/ralph/prompt.md
cp "$TEMPLATE_DIR/src/db/init.js" src/db/init.js
cp "$TEMPLATE_DIR/src/db/seed.js" src/db/seed.js
cp "$TEMPLATE_DIR/src/db/status.js" src/db/status.js
cp "$TEMPLATE_DIR/src/db/query.js" src/db/query.js
cp "$TEMPLATE_DIR/src/content/list.js" src/content/list.js
cp "$TEMPLATE_DIR/src/test.js" src/test.js

if [ ! -f package.json ]; then
  cp "$TEMPLATE_DIR/package.json" package.json
fi

touch content/drafts/.gitkeep content/published/.gitkeep data/.gitkeep

if [ ! -d .git ]; then
  git init
fi

printf '%s\n' "Ralph Marketer project files initialized."
printf '%s\n' "Next: npm install && npm run db:reset && npm test"

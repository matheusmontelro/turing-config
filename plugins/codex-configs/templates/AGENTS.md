# AGENTS.md

## Scope

These are repository-level instructions for Codex in `{PROJECT_ROOT}`.
They apply to the whole project unless a more specific `AGENTS.override.md` or nested `AGENTS.md` is added later.

## Project Context

- Project: `{PROJECT_NAME}`, `{SHORT_PRODUCT_DESCRIPTION}`.
- Core product areas: `{CORE_PRODUCT_AREAS}`.
- End users: `{END_USER_TYPES}`.
- Highest priorities:
  - `{CRITICAL_PRIORITY_1}`
  - `{CRITICAL_PRIORITY_2}`
  - `{CRITICAL_PRIORITY_3}`
  - Prefer safety and stability over fast shortcuts.

## Critical Working Rules

- The mandatory analysis and spec gate below applies before every task and takes precedence over all execution workflows.
- Never run production build, deploy, migration, destructive data, or broad restart commands without explicit user approval in the current conversation.
- Use development-mode validation by default. Production builds are the exception and always require explicit approval in the current conversation.
- At the end of any completed adjustment, identify which runtime services load the changed files, restart or reload only those corresponding services when a reload is required, then validate status, health, or logs.
- Never assume a merged, pulled, or edited code change is active in runtime processes until the corresponding process path has been checked and, when needed, reloaded.
- Do not run destructive commands (`git reset --hard`, `git checkout --`, `rm -rf`, `kill`, `pkill`, database drops, broad production restarts unrelated to the current adjustment) without a clear reason and explicit approval, unless the user has already requested that exact operation.
- Never hardcode API keys, tokens, passwords, secrets, database URLs, private certificates, or production credentials.
- Never expose secrets in logs, screenshots, API responses, comments, commits, or final answers.
- If credentials are found in source code, immediately flag the security issue and propose remediation and rotation.

## Mandatory Spec Approval

- Before every task, use the `pre-task-spec-approval` skill, perform a scoped read-only analysis, and present a detailed pt-BR spec for explicit user approval.
- If the project keeps repo-scoped skills, the documented location is `.agents/skills/pre-task-spec-approval/SKILL.md`.
- This gate is universal. It includes analysis, explanations, textual answers, file reads, status checks, searches, diagnostics, simple commands, small edits, configuration, implementation, tests, builds, external actions, and delegated work.
- Before writing the spec, inspect only the relevant request context, files, code, tests, contracts, documentation, history, and status needed to understand the current behavior. Use only operations whose documented semantics are read-only and that create no workspace, cache, record, or external-system changes.
- During discovery, separate confirmed facts, justified inferences, assumptions, and unknowns. Summarize only evidence-backed findings; do not expose private chain-of-thought.
- Before approval, do not edit files, create workspace artifacts, install dependencies, run tests, linters, typechecks, formatters or builds, delegate to subagents, create branches or PRs, execute the requested delivery, or perform any local or external state-changing action.
- The original request is not advance approval. Approval is valid only when the user responds after the latest spec with an unambiguous confirmation such as `approved`, `pode executar`, or `segue com essa spec`.
- The spec must include:
  - analyzed evidence, current behavior, facts, inferences, assumptions, and remaining unknowns;
  - numbered requirements, including every behavior that must be preserved;
  - a detailed, ordered execution plan with affected files or modules and intermediate results;
  - allowed scope, explicitly out-of-scope areas, contracts, and compatibility concerns;
  - a traceability matrix connecting every requirement to an execution step and a test;
  - complete test flows with preconditions, data, steps, expected results, and evidence;
  - applicable success, error, boundary, permission, security, regression, integration, runtime, rollback, and cleanup scenarios, with justified `N/A` entries;
  - risks, stop conditions, reversal, and objective done criteria.
- Do not present the spec while a requirement lacks an implementation step or validation flow.
- After approval, inspect and execute only the approved scope. If discovery requires a material scope change, stop and submit a revised spec for a new approval.
- Approval, rejection, cancellation, revision of the current spec, execution within an approved spec, and its final report do not require another spec.
- Default rule for parallelizable work: `1 approved demand = 1 spec = 1 worktree = 1 branch`.
- Use isolated task worktrees after approval for non-trivial or parallel work:

  ```text
  {WORKTREE_ROOT}/codex-{YYYYMMDD-HHMM}-{descricao-kebab}
  ```

- Use task branches with:

  ```text
  work/codex-{YYYYMMDD-HHMM}-{descricao-kebab}
  ```

- If Codex is already inside an approved task worktree, continue there. If Codex is in the shared checkout, create a task worktree from the approved base branch before implementation.
- Never run multiple unrelated implementation agents in the same checkout or worktree.
- If implementation needs to touch files outside the approved scope, stop and ask for approval of a revised spec before continuing.

## Frontend Workflow

- If the project uses a shared frontend dev server, keep the helper at `tools/ensure-frontend-dev.sh` and validate frontend work through that script.
- Configure the helper with project-specific values or environment variables such as `FRONTEND_DEV_PROJECT_NAME`, `FRONTEND_DEV_CANONICAL_ROOT`, `FRONTEND_DEV_FRONTEND_DIR`, `FRONTEND_DEV_PORT`, `FRONTEND_DEV_PUBLIC_HOST`, `VITE_DEV_PROXY_TARGET`, `FRONTEND_DEV_NPM_SCRIPT`, and `FRONTEND_DEV_START_COMMAND`.
- Use the project's local frontend skill or design-system guidance when one exists. If none exists, inspect nearby components and layout primitives before changing UI.
- Prefer existing design tokens, components, hooks, services, route patterns, and state-management conventions before adding abstractions.
- Mobile is mandatory for user-facing UI. Check fixed footers, safe-area spacing, responsive grids, loading states, empty states, error states, dropdowns, and modals.
- Critical frontend actions must use project-standard confirmation modals, not raw `window.confirm`.
- Do not introduce browser-side calls to `localhost`, `127.0.0.1`, or raw backend ports unless explicitly doing cross-origin diagnostics.

## Runtime And Infra Context

- Frontend: `{FRONTEND_STACK_AND_DEV_SERVER}`.
- Backend: `{BACKEND_STACK_AND_SERVICE}`.
- Database/cache: `{DATABASE_AND_CACHE}`.
- Workers/queues: `{WORKER_SERVICES}`.
- External integrations: `{CRITICAL_EXTERNAL_INTEGRATIONS}`.
- Reverse proxy/deploy: `{PROXY_OR_DEPLOY_CONTEXT}`.
- Important files:
  - `{IMPORTANT_FILE_1}`: `{WHY_IT_MATTERS}`
  - `{IMPORTANT_FILE_2}`: `{WHY_IT_MATTERS}`
  - `{IMPORTANT_FILE_3}`: `{WHY_IT_MATTERS}`

## Backend And Infra Workflow

- For backend, database, queues, webhooks, auth, payments, external integrations, Nginx/proxy, or production-impacting changes, do a focused diagnosis first and summarize risks before editing.
- For large architecture changes, propose a plan and wait for explicit approval.
- Prefer narrow, behavior-preserving changes over broad rewrites.
- Add logs only where they help diagnose real operational failures; avoid noisy logs and never log secrets.
- If restarting services is necessary, explain what will restart and why before doing it; for services corresponding to the completed adjustment, proceed without asking for a separate final approval unless the project explicitly requires one.
- Before the final response for any code/config change, perform a service-impact check:
  - identify every changed path and the process that loads it;
  - restart or reload only matching services needed for the change to take effect;
  - verify each restarted service with status, logs, and a health check when available;
  - if no restart is needed, state why.

## Service Reload Matrix

Use this matrix after every completed adjustment to decide what must be restarted or revalidated.

- Frontend source or styling changes:
  - Do not run a production build by default.
  - Validate with the documented dev-mode flow, usually `./tools/ensure-frontend-dev.sh` when the project includes that helper.
  - Confirm the served URL reflects the change when applicable.
- Frontend dev server config changes:
  - Validate the dev server configuration through the documented dev-mode entrypoint.
  - Restart only when the active dev server is broken, inactive, pointing at the wrong root, or cannot compile changes that already landed in the canonical checkout.
- Backend API, models, services, auth, integrations, or routes:
  - Restart the backend process that loads the changed code when required.
  - Validate service status, focused logs, and a health check when available.
- Worker, queue, scheduler, webhook, or async execution changes:
  - Restart only the worker services that load the changed modules.
  - Restart the backend too when shared runtime modules or API code changed.
- Reverse proxy or deploy config changes:
  - Validate config first.
  - Reload/restart only if validation passes, then verify the affected route.
- Database migration/model/schema changes:
  - Treat as high risk.
  - Validate connection health before and after.
  - Never drop or rewrite production data without explicit approval and a backup plan.

## Code Style

- Use the project's existing language, framework, and file organization.
- Reuse existing local components, hooks, services, schemas, models, and helpers before adding abstractions.
- Do not add dependencies without explaining why the project needs them and why existing tools are insufficient.
- Keep changes scoped to the user's request.
- Add succinct comments only where the code is not self-explanatory.

## Validation

- Run focused checks that match the changed files.
- Prefer fast tests, typechecks, linters, route checks, and health checks over broad expensive commands.
- Do not run production builds unless the user approves them explicitly in the current conversation.
- Report only validations that were actually executed.
- If validation is impossible or unsafe, explain why and name the residual risk.

## Git And Worktree Safety

- The worktree may already contain user changes. Do not revert unrelated files.
- Before editing, inspect relevant files and work with existing changes instead of overwriting them.
- Do not stage the whole dirty checkout. Preserve unrelated local/generated changes that are outside the task.
- Use Portuguese for commit messages and validation reports unless the project policy says otherwise.

## Final Response Expectations

- Summarize what changed and where.
- Mention validation performed.
- Mention runtime/service reload decisions.
- If something was not run because approval is required, say that clearly.

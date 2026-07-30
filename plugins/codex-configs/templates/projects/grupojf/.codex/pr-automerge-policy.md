# Politica de PR com Auto-Merge: Grupo JF

Use esta politica com a skill `post-adjustment-pr-automerge` do plugin `codex-configs`.

## Escopo

- Repositorio GitHub esperado: `matheusmontelro/grupojf`
- Branch base: `main`
- Metodo de merge preferido: `squash`
- Log de sessao: `.codex/sessions.md`
- Skill de pre-implementacao: `.agents/skills/pre-task-spec-approval/SKILL.md`
- Skill de publicacao: `.agents/skills/post-adjustment-pr-automerge/SKILL.md`
- Worktrees de tarefa: `/opt/worktrees/grupojf/codex-{YYYYMMDD-HHMM}-{descricao-kebab}`
- Branches de tarefa: `work/codex-{YYYYMMDD-HHMM}-{descricao-kebab}`

## Validacao Preferida

Comandos base:

```bash
git diff --check
```

Segredos, quando `gitleaks` estiver disponivel:

```bash
gitleaks detect --source . --config .gitleaks.toml --redact --verbose
```

Backend, quando arquivos em `backend/app/` mudarem:

```bash
backend/venv/bin/python -m compileall backend/app
```

Fallback se o venv local nao existir:

```bash
cd backend && python -m compileall app
```

Frontend, quando arquivos em `frontend/src/` mudarem e testes forem viaveis:

```bash
cd frontend && npm test -- --watchAll=false
```

Frontend runtime/dev server, quando a mudanca exigir validar tela ou fluxo:

```bash
./tools/ensure-frontend-dev.sh
```

CI equivalente, somente com aprovacao explicita para build local:

```bash
cd frontend && CI=false npm run build
```

Reporte somente comandos executados de fato. Se uma validacao for inviavel, registre o motivo.

## Restricoes

- Nao publicar PR que dependa de arquivo solto no checkout local.
- Nao incluir arquivos fora do escopo da tarefa.
- Nao commitar `.env`, logs, bancos locais, exports, CSV/XLSX/PDF, dumps, backups, arquivos de midia ou credenciais.
- Nao rodar build de producao, deploy, migracao, seed destrutivo, scripts de exclusao ou restart amplo sem aprovacao explicita.
- Para frontend, nao use `npm run build` como validacao padrao; o build local so entra quando o usuario aprovar ou quando a tarefa for especificamente CI/release.
- Para banco, pagamentos, webhooks, auth, Delta, Bempaggo e WAPI, faca diagnostico e valide contratos antes de editar.
- Preserve alteracoes locais existentes que nao pertencem a sessao.
- Se a implementacao ocorreu no checkout compartilhado, publique por worktree limpo a partir da branch base copiando somente arquivos da sessao.
- Se a implementacao ocorreu em worktree isolado aprovado, valide e publique a partir desse mesmo worktree.

## Observacoes De Seguranca

- Este repositorio ja teve segredos removidos de historico. Antes de PR, verifique diff e arquivos alterados.
- Se encontrar credencial em codigo fonte, sanitize antes de publicar e recomende rotacao.
- Nao imprima valores completos de secrets em terminal, PR, comentario ou resposta final.

# Política de PR com Auto-Merge

Use este arquivo em `.codex/pr-automerge-policy.md` dentro do projeto que deve usar a skill `post-adjustment-pr-automerge`.

Se o projeto ainda usa layout legado, `.agents/pr-automerge-policy.md` também é aceito pela skill. Para projetos novos, prefira `.codex`.

## Escopo

- Repositorio GitHub esperado: `OWNER/REPO`
- Branch base: `main`
- Metodo de merge preferido: `squash`
- Log de sessao: `.codex/sessions.md`
- Skill de pre-implementacao: `pre-task-spec-approval`
- Caminho repo-scoped documentado, se a skill for copiada para o projeto: `.agents/skills/pre-task-spec-approval/SKILL.md`
- Worktrees de tarefa: `{WORKTREE_ROOT}/codex-{YYYYMMDD-HHMM}-{descricao-kebab}`
- Branches de tarefa: `work/codex-{YYYYMMDD-HHMM}-{descricao-kebab}`

## Validacao

Comandos preferidos para este projeto:

```bash
# exemplo
git diff --check
./tools/ensure-frontend-dev.sh
{COMANDO_DE_TESTE_OU_TYPECHECK}
{COMANDO_DE_HEALTH_CHECK_SE_APLICAVEL}
```

Reporte somente comandos executados de fato. Se uma validacao for inviavel, registre o motivo.

Para alteracoes frontend, nunca execute `npm run build`, `npm --prefix frontend run build`, `cd frontend && npm run build` ou outro build de producao sem aprovacao explicita do usuario na conversa atual. Prefira typecheck, lint, testes existentes ou validacao em dev server quando o projeto tiver fluxo dev documentado, como `./tools/ensure-frontend-dev.sh`.

Para alteracoes backend, worker, banco, filas, webhooks ou integracoes externas, use testes ou health checks focados no escopo da mudanca. Reinicie ou recarregue somente os servicos que carregam os arquivos alterados quando isso for exigido pelo projeto.

## Restricoes

- Nao incluir arquivos fora do escopo da tarefa.
- Nao publicar PR que dependa de arquivos soltos no checkout local.
- Nao commitar secrets, credenciais, bancos locais, arquivos de midia temporarios ou logs gerados.
- Preservar alteracoes locais existentes que nao pertencem a sessao.
- Para trabalho paralelo ou nao trivial, implementar em worktree de tarefa aprovado pela spec.
- Se a implementacao ocorreu no checkout compartilhado, publicar somente por worktree limpo criado a partir da branch base, copiando apenas arquivos da sessao.
- Se a implementacao ocorreu em worktree isolado aprovado, validar e publicar a partir desse mesmo worktree, sem criar outro por padrao.

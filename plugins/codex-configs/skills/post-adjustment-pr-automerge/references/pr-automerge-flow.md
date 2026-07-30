# Fluxo de PR Com Auto-Merge (Worktree Validado)

## 1. Verificação de Escopo

Execute:

```bash
pwd
git rev-parse --show-toplevel
git remote get-url origin
gh auth status
```

Continue somente se o diretório estiver dentro de um repositório Git, houver remote `origin` no GitHub e `gh` estiver autenticado para acessar esse repositório.

Se existir `.codex/pr-automerge-policy.md` ou `.agents/pr-automerge-policy.md`, leia antes de decidir branch base, comandos de validação, método de merge e local do log de sessão. Se a política declarar repositório esperado, confirme que o `origin` corresponde a ele antes de publicar.

## 2. Snapshot de Início

Acionado antes de qualquer edição quando o fluxo estiver ativo desde o início:

```bash
mkdir -p .codex
git status --porcelain > .codex/.session-start.txt
```

Esse snapshot ajuda a distinguir alterações da sessão de arquivos já soltos no checkout local.

Se o fluxo for chamado apenas no fim de uma tarefa já iniciada, capture o snapshot imediatamente, registre a limitação no relatório final e use a lista explícita de `SESSION_FILES` como fonte de escopo.

## 3. Variáveis da Sessão

No fim da implementação, defina:

```bash
TS_START_HUMAN="<registrado no início, formato dd/mm HH:MM>"
TS_END_HUMAN="$(TZ='America/Sao_Paulo' date +%d/%m\ %H:%M)"
SLUG_TS="$(TZ='America/Sao_Paulo' date +%Y-%m-%dT%H-%M)"
SHORT_DESC="<kebab-case curto, ex: timeline-auditoria>"
SLUG="codex-${SLUG_TS}-${SHORT_DESC}"
WORKTREE="/tmp/${SLUG}"
ROOT="$(git rev-parse --show-toplevel)"
SESSION_FILES=( "<lista mantida internamente pelo agente, paths relativos>" )
MODE="<shared-checkout | task-worktree>"
PUBLISH_WORKTREE="<worktree que sera validado e publicado>"
TEMP_PUBLISH_WORKTREE="<yes | no>"
PR_BRANCH="<branch que sera enviada ao GitHub>"
```

`SESSION_FILES` deve conter arquivos editados, criados, movidos ou removidos pela sessão. Não use o `git status` inteiro como lista de stage.

## 4. Descobrir Branch Base

Prefira a branch definida pela política local. Se não houver política, use a branch padrão do repositório:

```bash
BASE="$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)"
```

Se `gh` não estiver disponível ou autenticado, não publique PR. Informe o bloqueio e retome depois da autenticação.

Se a política local exigir uma branch base específica, defina explicitamente:

```bash
BASE="<branch-base-do-projeto>"
```

## 5. Pré-voo de Segurança

Antes de copiar arquivos, escaneie os caminhos da sessão:

```bash
printf '%s\n' "${SESSION_FILES[@]}" | rg -n '(^|/)(\.env($|\.)|id_rsa|id_ed25519|.*\.(pem|key|p12|pfx|jks)$|.*(secret|credential).*)' -S | rg -v '\.env(\..*)?\.example$'
```

Depois do `git add` no worktree, escaneie o diff staged:

```bash
git -C "$PUBLISH_WORKTREE" diff --staged --unified=0 | rg -n '^\+[^+]' | rg -n '(ghp_[A-Za-z0-9]{30,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z\-_]{35}|-----BEGIN (RSA|OPENSSH|EC|PRIVATE) KEY-----|password\s*[:=]|api[_-]?key\s*[:=]|sk_live_[A-Za-z0-9]{20,}|sk-proj-[A-Za-z0-9_\-]{20,}|whsec_[A-Za-z0-9]{20,})' -S
```

Se qualquer match aparecer:

1. Pare commit, push e PR.
2. Remova ou oculte o material sensível.
3. Atualize `.gitignore` se necessário.
4. Reexecute os scans até não haver matches.

## 6. Escolher Modo de Publicação

Use `task-worktree` quando a implementação já ocorreu em um worktree isolado da tarefa, criado após spec aprovada. Use `shared-checkout` quando a implementação ocorreu no checkout principal ou em qualquer diretório que possa conter alterações de outras sessões.

Para identificar worktrees disponíveis:

```bash
git worktree list
git branch --show-current
```

No modo `task-worktree`:

```bash
MODE="task-worktree"
PUBLISH_WORKTREE="$ROOT"
TEMP_PUBLISH_WORKTREE="no"
PR_BRANCH="$(git branch --show-current)"
```

Confirme que a branch atual não é a branch base. Se estiver na branch base, crie uma branch de trabalho sem descartar alterações:

```bash
git switch -c "work/$SLUG"
PR_BRANCH="$(git branch --show-current)"
```

No modo `shared-checkout`, crie um worktree temporário a partir do estado oficial mais recente da base:

```bash
MODE="shared-checkout"
PUBLISH_WORKTREE="$WORKTREE"
TEMP_PUBLISH_WORKTREE="yes"
PR_BRANCH="session/$SLUG"
git fetch origin "$BASE"
git worktree add "$WORKTREE" "origin/$BASE"
```

## 7. Copiar Apenas Arquivos da Sessão

Execute este passo somente no modo `shared-checkout`. Não use `git stash`, `git checkout --` ou stage amplo no diretório principal. Faça cópia explícita:

```bash
cd "$ROOT"
for f in "${SESSION_FILES[@]}"; do
  if [ -e "$f" ]; then
    mkdir -p "$WORKTREE/$(dirname "$f")"
    cp -a "$f" "$WORKTREE/$f"
  else
    rm -f "$WORKTREE/$f"
  fi
done
```

Se a tarefa moveu arquivos, garanta que o caminho antigo seja removido no worktree e o caminho novo seja copiado.

No modo `task-worktree`, não copie arquivos de outro checkout. O diretório atual já deve conter a implementação validável da tarefa.

## 8. Branch, Stage e Scan

No modo `shared-checkout`:

```bash
cd "$PUBLISH_WORKTREE"
git checkout -b "$PR_BRANCH"
git add "${SESSION_FILES[@]}"
```

No modo `task-worktree`:

```bash
cd "$PUBLISH_WORKTREE"
git add "${SESSION_FILES[@]}"
```

Rode o scan de conteúdo staged do passo 5. Se o stage ficar vazio, interrompa e explique que não há alteração publicável.

Se `git status --short` mostrar arquivos fora de `SESSION_FILES`, não use `git add .`. Preserve os arquivos e bloqueie a publicação até separar a entrega ou aprovar uma spec revisada.

## 9. Validação Obrigatória no Worktree

Valide o projeto dentro de `$PUBLISH_WORKTREE`, não apenas no checkout principal. Escolha comandos coerentes com a mudança e reporte somente o que rodou de fato.

Exemplos permitidos:

```bash
cd "$PUBLISH_WORKTREE"
python -m pytest <alvo>
cd frontend && npm test -- --watchAll=false
cd frontend && npm run typecheck
```

Para frontend, nunca rode `npm run build`, `npm --prefix frontend run build` ou outro build de produção sem aprovação explícita do usuário na conversa atual. Prefira typecheck, lint, testes existentes ou validação via dev server. Mesmo se uma política local sugerir build, solicite aprovação explícita antes de executar.

Se a validação falhar porque o checkout principal tinha arquivos soltos que não foram copiados:

1. Identifique os caminhos ausentes pelo erro.
2. Confirme se eles são dependências reais da tarefa.
3. Adicione apenas dependências reais a `SESSION_FILES`.
4. Copie os novos caminhos para o worktree.
5. Refaça `git add`, scan de segurança e validação.

Se os arquivos ausentes forem não relacionados, pare o PR e explique o bloqueio. Nunca abra PR que só funciona por causa de arquivos soltos no checkout principal.

## 10. Conferir Conteúdo do PR

Antes do commit:

```bash
git status --short
git diff --cached --name-status
```

O diff deve conter somente arquivos necessários para a tarefa e suficientes para a validação passar no worktree.

## 11. Commit e Push

```bash
git commit -m "<tipo>: <resumo conciso em pt-BR>"
git push -u origin "$PR_BRANCH"
```

Se o push falhar com HTTP 5xx ou erro de rede, não remova o worktree; ofereça retentativa ao usuário.

## 12. Criar PR

Crie um corpo de PR em `$PUBLISH_WORKTREE/.pr-body.md` com as seções obrigatórias:

1. `Contexto`
2. `O que mudou`
3. `Validação`
4. `Riscos`
5. `Reversão`

Abra o PR:

```bash
gh pr create \
  --base "$BASE" \
  --head "$PR_BRANCH" \
  --title "[Codex $TS_END_HUMAN] <tipo>: <resumo>" \
  --body-file "$PUBLISH_WORKTREE/.pr-body.md"
```

## 13. Ativar Auto-Merge

```bash
gh pr merge <numero-ou-url-do-pr> --auto --squash --delete-branch
```

Se a política do repositório não permitir squash, troque para `--merge` ou `--rebase`, conforme a política.

## 14. Limpeza do Worktree

Depois que PR e auto-merge forem configurados, remova somente worktrees temporários criados por este fluxo para publicação:

```bash
cd "$ROOT"
if [ "$TEMP_PUBLISH_WORKTREE" = "yes" ]; then
  git worktree remove "$WORKTREE"
fi
```

Se o PR/push falhou e pode haver retentativa, mantenha o worktree temporário até resolver. Se estiver no modo `task-worktree`, não remova o worktree da tarefa sem pedido explícito do usuário.

## 15. Verificação de Não-Contaminação

Confirme que o diretório principal ficou no estado esperado:

```bash
git status --porcelain | sort > /tmp/.codex-session-end.txt
diff <(sort .codex/.session-start.txt) /tmp/.codex-session-end.txt
```

No modo `shared-checkout`, a diferença esperada é apenas o conjunto de arquivos da sessão. No modo `task-worktree`, confirme que o checkout principal não recebeu alterações inesperadas e que o worktree da tarefa continua preservado. Se aparecer algo inesperado, alerte o usuário e não tente limpar sem aprovação explícita.

## 16. Registrar Sessão

Anexe entrada em `.codex/sessions.md` usando o formato de `references/session-log.md`.

## 17. Tratamento de Falhas

1. `gh` não autenticado: `gh auth login`.
2. Push falhou com erro temporário: manter worktree, oferecer retentativa, não apagar nada.
3. Auto-merge desligado no repositório: reportar bloqueio e fornecer URL do PR.
4. Checks obrigatórios pendentes: manter `--auto` ativo e reportar status de espera.
5. Validação no worktree falhou: não criar PR incompleto; incluir dependências reais ou bloquear.
6. Verificação de não-contaminação falhou: preservar estado e pedir orientação. Nunca usar `git stash drop`, `git reset --hard` ou `git checkout --` para limpar sem aprovação explícita.

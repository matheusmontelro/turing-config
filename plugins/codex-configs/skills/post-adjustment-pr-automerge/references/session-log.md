# Formato do Log de Sessão

A skill anexa uma entrada em `.codex/sessions.md` ao final de cada sessão. O arquivo é cumulativo, apenas append. Não reescreva nem remova entradas anteriores.

## Estrutura do Arquivo

Cabeçalho fixo, criado uma vez se ainda não existir:

```markdown
# Log de Sessões - Codex

Cada entrada representa uma sessão publicada a partir de worktree temporário
validado. O checkout principal continua sendo a fonte de implementação local,
mas o PR nasce de um worktree limpo para evitar arquivos soltos ou alterações
não relacionadas.

---
```

## Formato de Entrada

```markdown
## Sessão {YYYY-MM-DD} {HH:MM} -> {HH:MM} ({duração_minutos}min)

- **Agente:** Codex
- **Slug:** `codex-{YYYY-MM-DDThh-mm}-{descricao-kebab}`
- **Branch:** `session/codex-{...}` ou `work/codex-{...}`
- **PR:** #{numero} ({status: aberto / mergeado / fechado})
- **Base:** `{branch-base}`
- **Worktree:** `/tmp/codex-{...}` (removido / preservado)
- **Arquivos alterados:** {n}
- **Validação no worktree:** {comandos executados ou "não executada: motivo"}
- **Resumo:** {1-2 linhas em pt-BR}
```

## Exemplo

```markdown
## Sessão 2026-05-04 01:30 -> 02:15 (45min)

- **Agente:** Codex
- **Slug:** `codex-2026-05-04T01-30-timeline-auditoria`
- **Branch:** `session/codex-2026-05-04T01-30-timeline-auditoria`
- **PR:** #14 (mergeado)
- **Base:** `main`
- **Worktree:** `/tmp/codex-2026-05-04T01-30-timeline-auditoria` (removido)
- **Arquivos alterados:** 12
- **Validação no worktree:** `cd frontend && npm test -- --watchAll=false`
- **Resumo:** Timeline com auditoria detalhada (tags, fluxos, exclusões CRM).
```

## Regras de Manutenção

1. Append-only. Nunca reescreva entradas anteriores.
2. Ordem cronológica, com entradas mais antigas no topo.
3. Se a sessão falhou ou foi abortada, registrar mesmo assim com `**PR:** -` e `**Status:** abortado: {motivo curto}`.
4. Se houver múltiplos PRs em uma única sessão, listar todos como `#14, #15`.
5. Se a validação no worktree revelou dependências locais faltantes, registrar quantos arquivos foram adicionados ao conjunto final.
6. Se a verificação de não-contaminação alertou, anexar linha extra: `- **Aviso:** working tree principal teve {n} arquivo(s) modificado(s) por outra fonte durante a sessão.`

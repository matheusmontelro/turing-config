---
name: token-capital-capture
description: Capturar Token Capital em sessoes Codex. Use no inicio e no fechamento de tarefas nao triviais, bugs, decisoes tecnicas, deploys, operacao, IA/agentes, mudancas de contrato, dominio, frontend, backend ou qualquer sessao com aprendizado reutilizavel; tambem use quando o usuario perguntar como uma sessao melhora as proximas.
---

# Token Capital Capture

## Objetivo

Transformar sessoes Codex relevantes em inteligencia institucional versionada no
repositorio de Token Capital configurado pelo projeto.

Isto nao treina o modelo base. O ganho pratico vem de contexto reutilizavel:
eventos, memorias, patterns, evals e politicas que futuras sessoes podem ler
antes de repetir decisoes, erros ou investigacoes.

## Configuracao

Usar primeiro o `AGENTS.md` do projeto para descobrir:

- repositorio de Token Capital;
- caminho local do clone;
- regras de privacidade;
- comando ou script de criacao de evento.

Quando o projeto nao definir outro destino, usar:

```text
repo: matheusmontelro/token-capital-turing
local_path: /tmp/token-capital-turing
event_script: scripts/create-development-event.py
```

## Regra Obrigatoria

Toda sessao Codex deve fazer uma decisao explicita de captura antes do resumo
final:

1. Criar um `development_event` quando a sessao gerar commit, mudanca de
   codigo/config/docs, deploy, investigacao tecnica, decisao, padrao recorrente,
   erro, feedback, mudanca em agentes/IA ou aprendizado reutilizavel.
2. Se a sessao for trivial ou apenas leitura sem aprendizado reutilizavel,
   declarar no resumo final que nao houve evento e por que.
3. Nunca gravar segredos, logs sensiveis, dados pessoais brutos ou conteudo
   privado desnecessario no Token Capital. Preferir resumo, referencia e impacto.

## Inicio da Sessao

Para tarefas nao triviais, procurar contexto existente antes de implementar:

```bash
cd <token-capital-local-path>
rg -n "<dominio|erro|feature|rota|skill|agente>" intelligence .codex docs
```

Se o clone local nao existir, criar ou atualizar conforme o repositorio definido
no projeto:

```bash
git clone <token-capital-repo-url> <token-capital-local-path>
```

Use memorias, patterns, evals e decisoes encontrados como contexto de entrada,
sem copiar material irrelevante para a conversa.

## Fechamento da Sessao

Depois de validar a entrega principal, criar o evento no repo de Token Capital.
Quando o repo usar `scripts/create-development-event.py`, o formato basico e:

```bash
cd <token-capital-local-path>
python3 scripts/create-development-event.py \
  --slug "<slug-curto>" \
  --summary "<o que aconteceu>" \
  --intent "<por que a sessao existiu>" \
  --source-repo "<owner/repo-da-entrega>" \
  --source-path "<path-local-da-entrega>" \
  --branch "<branch-da-entrega>" \
  --file-changed "<path>=<create|update|delete>" \
  --validation "<comando>=<resultado>" \
  --knowledge-created "<aprendizado reutilizavel>" \
  --token-capital-effect "<como melhora sessoes futuras>"
```

Adicionar links quando existirem:

- `--memory-link <id>`
- `--pattern-link <id>`
- `--eval-link <id>`
- `--decision-link <id>`

Versionar o evento no repositorio de Token Capital conforme o fluxo definido
pelo projeto.

## Promocao de Conhecimento

Criar artefatos adicionais quando o evento apontar recorrencia:

- `memory`: regra curta que uma futura sessao deve lembrar.
- `pattern`: problema ou oportunidade que apareceu mais de uma vez.
- `eval`: comportamento que deve ser testado para impedir regressao.
- `decision`: escolha arquitetural, operacional ou de produto com alternativas.
- `policy`: regra obrigatoria para proximas specs ou operacoes.

Nao criar artefatos extras por volume. Criar apenas quando houver consumidor
claro e impacto pratico em futuras sessoes.

## Resumo Final

No resumo final da sessao, informar uma das duas opcoes:

- `Token Capital:` evento criado/atualizado com caminho e link.
- `Token Capital:` nao criado, com motivo curto.

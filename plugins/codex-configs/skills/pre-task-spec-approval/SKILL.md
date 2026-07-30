---
name: pre-task-spec-approval
description: Monte uma spec curta e aprovavel antes de tarefas de codigo nao triviais. Use quando Codex receber uma demanda vaga, task de Jira, feature, bug fix, refactor, mudanca backend/frontend/config, trabalho em paralelo com outros agentes, ou qualquer ajuste que precise de escopo, arquivos permitidos/proibidos, validacao e criterio de pronto antes de editar arquivos.
---

# Spec Antes de Codar

## Objetivo

Transformar uma demanda em linguagem natural em uma spec revisavel pelo usuario antes de qualquer implementacao nao trivial. A spec deve reduzir ambiguidade, definir limites de edicao e preparar a tarefa para execucao em worktree/branch isolado quando houver risco de concorrencia.

## Regra Central

Antes da aprovacao explicita do usuario, trabalhe somente em modo leitura.

Permitido antes da aprovacao:

1. Inspecionar arquivos, rotas, testes, historico Git e configuracoes.
2. Rodar comandos de diagnostico somente leitura, como `rg`, `sed`, `git status`, `git diff`, `git log`, `git show`, `ls` e verificacoes que nao alterem estado.
3. Fazer perguntas curtas quando a demanda tiver uma decisao de produto que nao pode ser inferida da codebase.

Proibido antes da aprovacao:

1. Editar, criar, mover, remover ou formatar arquivos.
2. Criar migrations, branches, commits, PRs ou alterar servicos.
3. Instalar dependencias, rodar builds de producao, reiniciar processos ou executar comandos destrutivos.
4. Criar abstracoes compartilhadas, renomear modulos ou alterar contratos publicos sem estar na spec aprovada.

## Quando Exigir Spec

Exija spec para qualquer tarefa de codigo ou configuracao que nao seja claramente trivial.

Exemplos que exigem spec:

1. Feature nova.
2. Bug fix com causa ainda desconhecida.
3. Refactor ou renomeacao.
4. Mudanca em backend, banco, webhooks, mensageria, Nginx, autenticacao, pagamentos ou integracoes.
5. Mudanca frontend que altera fluxo, layout relevante, API, estado, permissao ou comportamento responsivo.
6. Qualquer trabalho que possa rodar em paralelo com outro agente.

Pode pular a spec quando a tarefa for apenas analise, resposta textual, leitura de arquivo, comando simples, ou edicao pequena e explicitamente localizada pelo usuario. Se houver duvida, gere a spec.

## Workflow

1. Registrar que a tarefa esta em modo spec e que nenhuma edicao sera feita ainda.
2. Explorar a codebase em leitura para encontrar arquivos provaveis, padroes locais, testes existentes e areas de risco.
3. Identificar alteracoes locais ja existentes que possam afetar a tarefa; nao assumir que pertencem a sessao.
4. Escrever a spec em portugues do Brasil, com linguagem que um usuario nao tecnico consiga aprovar.
5. Aguardar aprovacao explicita antes de editar. Aceite respostas como "aprovado", "pode fazer", "manda", "segue" ou equivalente claro.
6. Se o usuario pedir ajustes, revise a spec e aguarde nova aprovacao.
7. Depois da aprovacao, criar ou usar um worktree/branch isolado quando a tarefa for nao trivial, paralela ou tocar mais de um modulo.
8. Encaminhar a implementacao para o fluxo normal do repositorio e finalizar com a skill de PR/automerge quando houver mudanca de arquivo.

## Template Obrigatorio

Use este formato, adaptando o nivel de detalhe ao risco da tarefa:

```markdown
## Spec Proposta

### Objetivo
{O resultado que o usuario quer, em uma ou duas frases.}

### Comportamento Esperado
- {Caso principal esperado.}
- {Erros, limites ou estados vazios relevantes.}
- {Comportamentos existentes que devem ser preservados.}

### Escopo Permitido
- `{arquivo-ou-modulo-provavel}`
- `{arquivo-ou-modulo-provavel}`

### Fora de Escopo
- {Areas que nao serao tocadas.}
- {Contratos, servicos ou fluxos criticos que serao preservados.}

### Contratos e Compatibilidade
- {Endpoints, funcoes, componentes, schemas, eventos ou integracoes afetadas.}
- {Compatibilidade que precisa ser mantida.}

### Worktree e Branch
- Base prevista: `{branch-base}`
- Branch sugerida: `work/codex-{data-hora}-{descricao-kebab}`
- Worktree sugerido: `{WORKTREE_ROOT}/codex-{data-hora}-{descricao-kebab}`
- Regra: 1 demanda aprovada = 1 spec = 1 worktree = 1 branch = 1 PR.

### Validacao Esperada
- `{comando ou verificacao focada}`
- `{teste, health check ou verificacao manual coerente}`

### Riscos e Pontos de Atencao
- {Risco real ou "baixo risco" com justificativa curta.}
- {Condicao que faria o agente parar e reportar antes de continuar.}

### Criterio de Pronto
- {Como saber que a tarefa terminou.}
- {O que o resumo final deve confirmar.}
```

## Regras Para Worktrees Paralelos

Depois da aprovacao, use worktree isolado por padrao para tarefas nao triviais:

```text
{WORKTREE_ROOT}/codex-{YYYYMMDD-HHMM}-{descricao-kebab}
```

Use branch:

```text
work/codex-{YYYYMMDD-HHMM}-{descricao-kebab}
```

Se o agente ja estiver dentro de um worktree isolado da tarefa, continue nele. Se estiver no checkout principal compartilhado, crie o worktree a partir da branch base aprovada antes de editar.

Nunca coloque dois agentes implementando demandas diferentes no mesmo worktree. Se a tarefa precisar tocar arquivo fora do escopo aprovado, pare, explique o motivo e peça aprovacao de uma spec revisada.

## Tom da Spec

Escreva para decisao, nao para impressionar tecnicamente. O usuario deve conseguir responder "sim, e isso" ou "nao, nao mexe nessa parte" sem precisar entender detalhes internos da stack.

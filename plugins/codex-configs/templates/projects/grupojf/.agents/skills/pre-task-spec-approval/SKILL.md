---
name: pre-task-spec-approval
description: Criar uma spec curta e aprovavel antes de qualquer tarefa solicitada ao Codex. Usar sempre, inclusive para analise, resposta textual, leitura de arquivo, busca, diagnostico, comando simples, edicao pequena, configuracao ou implementacao, bloqueando ferramentas e execucao ate a aprovacao explicita da spec.
---

# Spec Antes de Qualquer Tarefa

## Objetivo

Transformar toda tarefa em uma spec revisavel pelo usuario antes de qualquer
analise, inspecao ou execucao. A spec deve tornar objetivo, escopo, acoes,
ferramentas, validacao, riscos e criterio de pronto claros antes do trabalho.

## Regra Central

A primeira resposta substantiva a toda nova tarefa deve ser uma spec. Antes da
aprovacao explicita da spec, nao execute a tarefa nem chame ferramentas, mesmo
que a operacao seja simples, reversivel ou somente leitura.

Permitido antes da aprovacao:

1. Interpretar apenas a mensagem do usuario e o contexto ja presente.
2. Fazer uma pergunta curta somente quando for impossivel montar uma spec segura
   sem a resposta.
3. Apresentar ou revisar a spec.
4. Receber aprovacao, rejeicao, cancelamento ou pedido de ajuste da spec.

Proibido antes da aprovacao:

1. Chamar qualquer ferramenta, subagente, conector, navegador, terminal ou API.
2. Inspecionar arquivos, repositorios, logs, historico, status, mensagens,
   calendarios, documentos ou sistemas externos.
3. Rodar comandos, buscas, diagnosticos, testes, builds ou validacoes, inclusive
   os que nao alteram estado.
4. Responder a analise solicitada, produzir a entrega ou iniciar qualquer parte
   operacional da tarefa.
5. Editar, criar, mover, remover, formatar, instalar, enviar, publicar,
   versionar, reiniciar ou alterar estado local ou externo.

## Cobertura Universal

Exija spec para toda tarefa, sem excecao por tamanho ou aparente simplicidade.
Isso inclui:

1. Analise, explicacao, revisao, pesquisa ou resposta textual.
2. Leitura de arquivo, consulta de status, busca local ou navegacao web.
3. Comando simples, diagnostico ou verificacao somente leitura.
4. Edicao pequena, correcao, configuracao, refactor ou feature.
5. Instalacao, teste, build, automacao ou operacao em sistema externo.
6. Trabalho delegado a outro agente.

Nao crie uma nova spec para:

1. Aprovar, rejeitar, cancelar ou pedir ajuste da spec atual.
2. Executar etapas e responder dentro do escopo de uma spec ja aprovada.
3. Entregar o resumo final da tarefa aprovada.

A solicitacao original nao vale como aprovacao antecipada. Considere aprovada
somente uma resposta enviada depois da spec mais recente, como "aprovado",
"pode executar", "segue com essa spec" ou equivalente inequivoco.

## Workflow

1. Identificar a nova tarefa e entrar em modo spec sem chamar ferramentas.
2. Escrever a spec em portugues do Brasil usando apenas o pedido e o contexto ja
   disponivel. Marcar como "a confirmar depois da aprovacao" o que depender de
   inspecao.
3. Encerrar a resposta pedindo aprovacao explicita e aguardar.
4. Se o usuario pedir ajustes, revisar a spec e aguardar nova aprovacao.
5. Depois da aprovacao, inspecionar o contexto necessario e executar somente o
   escopo aprovado.
6. Se a descoberta exigir ampliar ou mudar materialmente o escopo, parar,
   apresentar uma spec revisada e aguardar nova aprovacao.
7. Concluir com as validacoes e o criterio de pronto aprovados.

## Template Obrigatorio

Use este formato em toda tarefa. Para pedidos simples, mantenha cada secao em
uma linha; nunca elimine o gate:

```markdown
## Spec Proposta

### Objetivo
{O resultado que o usuario quer, em uma ou duas frases.}

### Acoes Previstas
- {Inspecoes, comandos, ferramentas ou alteracoes que serao executados depois da aprovacao.}

### Escopo Permitido
- {Arquivos, sistemas, dados ou assuntos cobertos; use "a confirmar depois da aprovacao" quando necessario.}

### Fora de Escopo
- {O que nao sera consultado, alterado ou executado.}

### Validacao Esperada
- {Como o resultado sera conferido.}

### Riscos e Pontos de Atencao
- {Risco real ou "baixo risco", com justificativa curta.}

### Criterio de Pronto
- {Como saber que a tarefa terminou.}

### Aprovacao
Responda "aprovado" para autorizar exatamente esta spec.
```

## Regras Para Worktrees Paralelos

A exigencia de spec e universal; o isolamento e condicional. Depois da
aprovacao, use worktree isolado para tarefas nao triviais, paralelas ou que
toquem mais de um modulo:

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

Escreva para decisao, nao para impressionar tecnicamente. A spec deve ser
proporcional ao risco, mas sempre clara o bastante para o usuario saber
exatamente o que sera autorizado.

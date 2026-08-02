---
name: pre-task-spec-approval
description: Analisar minuciosamente toda nova solicitacao em modo somente leitura e criar uma spec detalhada, rastreavel e aprovavel antes de executar a tarefa ou alterar estado. Usar sempre, inclusive para analise, resposta textual, leitura, busca, diagnostico, comando simples, edicao, configuracao ou implementacao; exigir plano por etapas, fluxos completos de validacao e aprovacao explicita antes da execucao.
---

# Analise e Spec Antes de Qualquer Tarefa

## Objetivo

Transformar toda solicitacao em uma spec fiel ao pedido e ao contexto real. Antes
de escrever a spec, analisar evidencias relevantes em modo somente leitura. Na
spec, ligar cada requisito a uma etapa de execucao e a um fluxo de validacao.

## Regra Central

Iniciar toda nova tarefa com descoberta minuciosa e limitada ao escopo, seguida
da spec. Antes da aprovacao explicita, nao executar a entrega nem realizar
qualquer acao que altere estado local ou externo.

A analise anterior a spec nao e implementacao. Ela serve somente para reduzir
ambiguidade, confirmar o estado atual e produzir um plano executavel.

Permitido antes da aprovacao:

1. Interpretar a solicitacao e o contexto ja presente.
2. Inspecionar, em modo somente leitura, os arquivos, codigo, testes, contratos,
   configuracoes, documentacao, historico e status estritamente relevantes.
3. Consultar fontes externas ou conectores em modo somente leitura somente
   quando forem necessarios e estiverem dentro do escopo solicitado.
4. Usar somente ferramentas cuja operacao documentada seja de leitura e que nao
   criem arquivos, caches, registros ou alteracoes no sistema consultado.
5. Fazer uma pergunta curta quando uma decisao material continuar impossivel de
   inferir depois da descoberta segura.
6. Apresentar ou revisar a spec e receber sua aprovacao, rejeicao ou cancelamento.

Proibido antes da aprovacao:

1. Editar, criar, mover, remover ou formatar arquivos.
2. Criar branch, worktree, commit, PR, migration ou artefato no workspace.
3. Instalar dependencias; executar testes, linters, typechecks, formatadores ou
   builds; disparar automacoes; ou delegar trabalho a subagentes.
4. Executar deploys, reinicios, escritas em banco, chamadas externas mutaveis ou
   qualquer comando que possa gerar cache, fixture, cobertura ou outro estado.
5. Executar a entrega pedida, enviar mensagens, publicar conteudo ou alterar
   qualquer sistema.
6. Ampliar a investigacao para dados, sistemas ou pessoas sem relacao necessaria
   com a solicitacao.

## Analise Obrigatoria Antes da Spec

Completar esta sequencia antes de redigir a spec:

1. Decompor o pedido em resultado desejado, atores, entradas, saidas, regras,
   restricoes e comportamentos a preservar.
2. Inspecionar o estado atual e localizar implementacoes, contratos, testes,
   documentacao e convencoes que governam a demanda.
3. Registrar evidencias concretas, como arquivos, modulos, rotas, schemas,
   comandos existentes, documentacao ou estado consultado.
4. Separar fatos confirmados, inferencias justificadas, hipoteses e pontos ainda
   desconhecidos. Nunca apresentar suposicao como fato.
5. Mapear camadas e fluxos afetados, dependencias, compatibilidade, permissoes,
   dados, seguranca, concorrencia, runtime e reversao quando aplicaveis.
6. Numerar todos os requisitos, inclusive comportamentos a preservar, como
   `R1`, `R2` e assim por diante.
7. Derivar etapas de execucao `E1`, `E2` e testes `T1`, `T2` diretamente dos
   requisitos analisados.
8. Confirmar que cada requisito possui ao menos uma etapa e uma validacao
   correspondente antes de apresentar a spec.

Expor ao usuario somente o resumo verificavel dessa analise: evidencias, fatos,
inferencias, lacunas e decisoes. Nao expor raciocinio privado ou cadeia de
pensamento.

## Cobertura Universal

Exigir spec para toda tarefa, sem excecao por tamanho ou aparente simplicidade:

1. Analise, explicacao, revisao, pesquisa ou resposta textual.
2. Leitura de arquivo, consulta de status, busca local ou navegacao web.
3. Comando simples, diagnostico ou verificacao.
4. Edicao pequena, correcao, configuracao, refactor ou feature.
5. Instalacao, teste, build, automacao ou operacao externa.
6. Trabalho delegado a outro agente.

Nao criar nova spec para aprovar, rejeitar, cancelar ou revisar a spec atual;
executar etapas ja aprovadas; ou entregar o resumo final da mesma tarefa.

A solicitacao original nao vale como aprovacao antecipada. Considerar aprovada
somente uma resposta posterior a spec mais recente, como "aprovado", "pode
executar" ou equivalente inequivoco.

## Workflow

1. Identificar a nova tarefa e entrar em modo de analise somente leitura.
2. Executar a analise obrigatoria e conferir o gate de qualidade.
3. Perguntar somente se restar uma decisao bloqueante que mudaria materialmente
   o plano.
4. Escrever a spec em portugues do Brasil com evidencias, etapas e testes
   concretos.
5. Encerrar pedindo aprovacao explicita e aguardar.
6. Revisar a spec e renovar o pedido de aprovacao quando o usuario ajustar o
   escopo.
7. Depois da aprovacao, criar isolamento quando necessario e executar somente o
   plano autorizado.
8. Parar e apresentar spec revisada se uma descoberta posterior exigir mudanca
   material de escopo, contrato, risco ou validacao.
9. Concluir executando as validacoes aprovadas e relatando evidencias reais.

## Template Obrigatorio

Usar todas as secoes abaixo. Em tarefas simples, ser conciso sem remover analise,
rastreabilidade ou validacao.

```markdown
## Spec Proposta

### Analise Realizada
- Fontes e evidencias consultadas: {arquivos, contratos, testes, docs ou sistemas}.
- Estado atual confirmado: {comportamento existente relevante}.
- Fatos confirmados: {fatos verificaveis}.
- Inferencias e hipoteses: {itens ainda nao confirmados e seu impacto}.

### Objetivo
{Resultado exato que o usuario espera.}

### Requisitos e Comportamento Esperado
- R1. {Requisito observavel}.
- R2. {Comportamento, erro, limite ou estado relevante}.
- R3. Preservar {contratos e comportamentos que nao podem regredir}.

### Plano de Execucao
1. E1. {Etapa, local afetado, acao e resultado intermediario esperado}.
2. E2. {Etapa seguinte e sua dependencia}.

### Escopo Permitido
- {Arquivos, modulos, sistemas ou dados cobertos}.

### Fora de Escopo
- {O que nao sera consultado, alterado ou executado}.

### Contratos e Compatibilidade
- {APIs, schemas, eventos, permissoes, dados ou integracoes afetados}.

### Matriz de Rastreabilidade
| Requisito | Etapa de execucao | Teste ou evidencia |
|---|---|---|
| R1 | E1 | T1 |
| R2 | E2 | T2, T3 |
| R3 | E1, E2 | T3 |

### Fluxos Completos de Teste
| ID | Cenario | Pre-condicoes e dados | Passos | Resultado esperado | Evidencia |
|---|---|---|---|---|---|
| T1 | Fluxo principal | {...} | {...} | {...} | {comando, resposta, tela ou log} |
| T2 | Erro ou limite | {...} | {...} | {...} | {...} |

- Cobrir ou justificar como `N/A`: fluxo principal; erros e limites; estados
  vazios; permissoes, autenticacao e isolamento de dados; seguranca; regressao;
  integracao; persistencia e migracao; concorrencia; responsividade e
  acessibilidade; runtime, observabilidade e health check; reversao e limpeza.
- Para entregas nao tecnicas, adaptar os fluxos para verificacao de fontes,
  completude, fidelidade, formato e criterios objetivos de qualidade.

### Riscos, Condicoes de Parada e Reversao
- Risco: {risco e mitigacao}.
- Parar se: {condicao que exige nova decisao ou spec revisada}.
- Reverter por: {procedimento seguro ou N/A justificado}.

### Worktree e Branch
- Base: `{branch-base}`.
- Branch/worktree: `{isolamento previsto ou N/A justificado}`.

### Criterio de Pronto
- {Resultado verificavel, testes aprovados e evidencia final esperada}.

### Aprovacao
Responda "aprovado" para autorizar exatamente esta spec.
```

## Regras Para os Fluxos de Teste

1. Especificar pre-condicoes, dados, passos, resultado esperado e evidencia; nao
   listar apenas o nome de um comando.
2. Cobrir o caminho principal e os modos de falha plausiveis descobertos.
3. Incluir testes focados, integrados e de regressao na proporcao do impacto.
4. Nomear comandos e checks reais encontrados no projeto. Nao inventar scripts.
5. Distinguir validacao planejada de validacao ja executada.
6. Marcar uma categoria como `N/A` somente com justificativa concreta.
7. Incluir validacao de runtime quando a mudanca somente se torna ativa apos
   reload, restart, deploy, migration ou processamento assincrono.
8. Definir limpeza de fixtures, artefatos e dados temporarios.

## Gate de Qualidade da Spec

Nao apresentar a spec enquanto qualquer item abaixo falhar:

1. O objetivo corresponde ao pedido, sem ampliar silenciosamente o escopo.
2. Evidencias sustentam o estado atual descrito.
3. Fatos, inferencias e lacunas estao separados.
4. O plano possui ordem, dependencias e resultados intermediarios claros.
5. Todo requisito aparece na matriz de rastreabilidade.
6. Os testes validam sucesso, falhas e preservacao dos contratos relevantes.
7. Riscos, condicoes de parada, reversao e criterio de pronto sao objetivos.
8. O usuario consegue entender exatamente o que sua aprovacao autoriza.

## Regras Para Worktrees Paralelos

Depois da aprovacao, usar worktree isolado para tarefas nao triviais, paralelas
ou que toquem mais de um modulo:

```text
{WORKTREE_ROOT}/codex-{YYYYMMDD-HHMM}-{descricao-kebab}
```

Usar branch:

```text
work/codex-{YYYYMMDD-HHMM}-{descricao-kebab}
```

Nunca colocar demandas diferentes no mesmo worktree. Se a implementacao exigir
arquivo ou sistema fora do escopo aprovado, parar e pedir aprovacao de uma spec
revisada.

## Tom da Spec

Escrever para decisao. Ser detalhado onde houver impacto, risco ou dependencia e
direto onde a tarefa for simples. Nao usar generalidades como "testar tudo" ou
"ajustar o necessario"; nomear comportamento, etapa e evidencia.

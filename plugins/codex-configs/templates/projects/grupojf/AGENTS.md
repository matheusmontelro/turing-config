# AGENTS.md

## Escopo

Estas instrucoes sao de nivel de repositorio para Codex no Grupo JF.
Elas valem para todo o monorepo, salvo se uma pasta receber um `AGENTS.override.md`
ou outro `AGENTS.md` mais especifico.

## Contexto Do Projeto

- Projeto: Grupo JF, monorepo de gestao administrativa, financeira, vendas, contratos digitais, anamneses e relatorios.
- Backend: FastAPI em `backend/app`, Python 3.12 no CI, PostgreSQL via `psycopg2` e SQLAlchemy.
- Frontend: React com Create React App em `frontend`, TypeScript/TSX, React Router, MUI, Tailwind helpers, lucide-react e Heroicons.
- Areas criticas: autenticacao, permissoes por unidade, pacientes/dependentes, vendas/pre-vendas, boletos/carnes, faturas, splits, webhooks, contratos digitais, anamnese digital, WAPI/WhatsApp, integracoes Delta/Bempaggo e relatorios financeiros.
- Usuarios finais: equipe operacional, financeiro, gestores de unidade, vendedores, dentistas e pacientes em fluxos publicos.

## Prioridades

- Proteger dados de pacientes, informacoes financeiras e credenciais.
- Preservar compatibilidade de rotas, payloads, permissao por unidade e fluxos publicos.
- Preferir mudancas pequenas, diagnosticaveis e reversiveis.
- Evitar refactors amplos quando a demanda for ajuste pontual.
- Validar com comandos focados e reportar somente o que foi executado.

## Regras Criticas

- Nunca rode deploy, migracao, seed destrutivo, limpeza de banco, script de exclusao, restart amplo de producao ou build de producao sem aprovacao explicita do usuario na conversa atual.
- Nunca use `git reset --hard`, `git checkout --`, `rm -rf`, `kill`, `pkill` ou comandos destrutivos sem motivo claro e aprovacao explicita, salvo quando o usuario pedir exatamente isso.
- Nunca hardcode API keys, tokens, senhas, URLs completas de banco, certificados privados ou credenciais de producao.
- Nunca exponha segredos em logs, screenshots, commits, comentarios ou respostas finais.
- Se encontrar credencial em codigo fonte, pare para sinalizar o risco, remova ou proponha remocao por variaveis de ambiente, e recomende rotacao.
- Este repositorio ja teve segredos em historico. Antes de versionar alteracoes, rode uma checagem de segredos no diff e, quando possivel, Gitleaks.
- Trate `backend/app/database/db.py`, `.env*`, webhooks, auth, pagamentos, WAPI, Delta e Bempaggo como areas sensiveis.

## Fluxo Codex

- Antes de toda tarefa, use a skill repo-scoped `.agents/skills/pre-task-spec-approval/SKILL.md` e apresente uma spec em pt-BR para aprovacao explicita.
- O gate e universal: vale para analise, explicacao, resposta textual, leitura de arquivo, status, busca, diagnostico, comando simples, edicao pequena, configuracao, implementacao, testes, builds, acoes externas e trabalho delegado.
- A primeira resposta substantiva deve ser a spec. Antes da aprovacao, nao chame ferramentas, inspecione arquivos ou sistemas, navegue, rode comandos, delegue trabalho, responda a analise solicitada nem altere estado local ou externo.
- Antes da aprovacao, use apenas o contexto ja presente para apresentar ou revisar a spec e, quando indispensavel, fazer uma pergunta bloqueante.
- O pedido original nao e aprovacao antecipada. A autorizacao so vale quando o usuario responder depois da spec mais recente com confirmacao inequivoca, como `aprovado`, `pode executar` ou `segue com essa spec`.
- Se a skill nao estiver instalada na sessao, siga o mesmo formato: objetivo, acoes previstas, escopo permitido, fora de escopo, validacao, riscos e criterio de pronto.
- Depois da aprovacao, leia os arquivos relevantes, verifique `git status --short --branch` e execute apenas o escopo aprovado.
- Se a descoberta exigir mudanca material de escopo, pare, apresente uma spec revisada e aguarde nova aprovacao.
- Aprovacao, rejeicao, cancelamento ou revisao da spec atual, execucao dentro da spec aprovada e resposta final nao exigem uma nova spec.
- Se o trabalho aprovado for paralelo, grande ou tocar mais de um modulo, use worktree e branch isolados:

```text
/opt/worktrees/grupojf/codex-{YYYYMMDD-HHMM}-{descricao-kebab}
work/codex-{YYYYMMDD-HHMM}-{descricao-kebab}
```

## Arquivos E Rotas Para Priorizar

- Backend app: `backend/app/main.py`, `backend/app/routers/`, `backend/app/middleware/`, `backend/app/database/`.
- Integracoes: `backend/app/delta_recorrente_sdk/`, `backend/app/anamnese_digital/`, routers de webhook e faturas.
- Frontend API clients: `frontend/src/api/axiosInstance.ts`, `frontend/src/api/`, `frontend/src/routes/ProtectedRoute.tsx`.
- Frontend telas: `frontend/src/pages/`, `frontend/src/components/`, `frontend/src/hooks/`, `frontend/src/styles/`.
## Frontend

- O frontend usa Create React App, nao Vite.
- Para servidor dev compartilhado, use `./tools/ensure-frontend-dev.sh`.
- Nao introduza chamadas browser-side para `localhost`, `127.0.0.1` ou portas cruas de backend sem estar diagnosticando CORS/proxy explicitamente.
- Antes de alterar UI, inspecione componentes proximos, tokens em `frontend/src/styles/tokens.ts`, padroes de rotas, modais, tabelas e estados existentes.
- Mobile e obrigatorio para UI de usuario: confira grid, modal, dropdown, loading, erro, estado vazio, rodape fixo e espaco seguro.
- Acoes criticas devem usar modal/padrao do projeto, nao `window.confirm`.
- O projeto possui muitos warnings ESLint legados. Nao transforme limpeza ampla de warnings em parte de uma tarefa pontual.
- O CI usa `CI=false npm run build` para validar bundle sem bloquear por warnings legados. Nao rode build de producao localmente sem aprovacao explicita.

## Backend, Banco E Integracoes

- Para auth, permissoes, vendas, pagamentos, webhooks, contratos, anamnese, splits, relatorios ou banco, faca diagnostico focado antes de editar.
- Preserve contratos de API consumidos pelo frontend, inclusive nomes de campos existentes e codigos de erro esperados.
- Nao execute scripts soltos de investigacao/exclusao na raiz ou em `backend/` sem ler o conteudo e confirmar o impacto.
- Nao rode migracoes, updates manuais, deletes, truncates ou scripts que escrevem no banco sem aprovacao explicita e plano de rollback.
- Logs novos devem ajudar diagnostico real e nunca imprimir payloads sensiveis, tokens, senhas, documentos, cartoes, dados pessoais completos ou headers de auth.
- Se tocar configuracao de banco, prefira variaveis de ambiente e placeholders em `.env.example`.

## Validacao

Escolha validacoes conforme os arquivos alterados:

- Sempre que houver alteracao versionada: `git diff --check`.
- Segredos: `gitleaks detect --source . --config .gitleaks.toml --redact --verbose`, quando o binario estiver disponivel.
- Backend: `backend/venv/bin/python -m compileall backend/app` quando o venv existir; senao `cd backend && python -m compileall app`.
- Frontend unitario/React: `cd frontend && npm test -- --watchAll=false` quando a mudanca tiver testes viaveis.
- Frontend runtime: `./tools/ensure-frontend-dev.sh` quando a tarefa exigir validar tela/fluxo em dev server.
Reporte somente comandos realmente executados. Se nao rodar algo por risco, tempo, ambiente ou aprovacao pendente, diga isso claramente.

## Git E Versionamento

- A worktree pode estar suja com alteracoes do usuario. Nunca reverta trabalho que voce nao fez.
- Nao use `git add .`; stage apenas arquivos da sessao.
- Nao commite `.env`, logs, bancos locais, exports, CSV/XLSX/PDF, dumps, backups ou arquivos gerados.
- Mensagens de commit devem ser em portugues do Brasil, curtas e objetivas.

## Resposta Final

- Resuma o que mudou e onde.
- Liste validacoes executadas.
- Informe decisoes de runtime/restart. Se nenhum restart foi necessario, diga por que.
- Aponte riscos ou pendencias reais, especialmente seguranca, credenciais e dependencias vulneraveis.

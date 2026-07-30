# Codex Configs

Repositorio para versionar configuracoes reutilizaveis do Codex: skills, plugins, templates de projeto, fluxos editoriais e politicas de workflow.

## Estrutura

```text
.
├── .agents/
│   ├── skills/
│   │   ├── aprofundador -> ../../plugins/codex-configs/skills/aprofundador
│   │   ├── humanizer-br -> ../../plugins/codex-configs/skills/humanizer-br
│   │   ├── pre-task-spec-approval -> ../../plugins/codex-configs/skills/pre-task-spec-approval
│   │   └── ralph-marketer -> ../../plugins/codex-configs/skills/ralph-marketer
│   └── plugins/
│       └── marketplace.json
└── plugins/
    └── codex-configs/
        ├── .codex-plugin/
        │   └── plugin.json
        ├── skills/
        │   ├── aprofundador/
        │   ├── humanizer-br/
        │   ├── pre-task-spec-approval/
        │   └── ralph-marketer/
        └── templates/
            ├── AGENTS.md
            ├── projects/
            │   └── grupojf/
            └── tools/
                └── ensure-frontend-dev.sh
```

## Regra de conformidade com a documentacao do Codex

Toda implementacao deste repositorio deve seguir a documentacao oficial atual do Codex.

Antes de criar, mover ou alterar skills, plugins, marketplaces, manifests, templates de projeto, hooks, MCPs ou caminhos de instalacao, confira as referencias oficiais e preserve os nomes/caminhos documentados. Se houver conflito entre um padrao local antigo e a documentacao atual, a documentacao atual do Codex e a fonte da verdade.

Regras praticas:

- Skills descobertas diretamente em um repositorio devem ficar em `.agents/skills/<skill-name>/SKILL.md`.
- Plugins distribuiveis devem ter manifest em `plugins/<plugin-name>/.codex-plugin/plugin.json`.
- Marketplaces repo-scoped devem ficar em `.agents/plugins/marketplace.json`.
- O `source.path` de um marketplace local deve comecar com `./` e resolver a partir da raiz do marketplace.
- Caminhos de manifest como `skills`, `hooks`, `mcpServers` e `apps` devem ser relativos ao root do plugin e comecar com `./`.
- Nao use caminhos legados ou inventados, como `.codex/skills`, para discovery repo-scoped de skills, a menos que a documentacao oficial passe a documentar esse caminho.
- Se este repositorio usar symlinks em `.agents/skills`, mantenha o alvo apontando para `plugins/codex-configs/skills` para evitar drift entre skill local e plugin distribuivel.

## Skills

`pre-task-spec-approval` exige uma spec curta em pt-BR antes de toda tarefa, inclusive analise, leitura, busca, comando simples ou edicao pequena. Nenhuma ferramenta ou execucao e permitida antes da aprovacao explicita da spec.

`humanizer-br` faz revisao editorial em portugues do Brasil para remover marcas de texto gerado por IA, melhorar ritmo, clareza, naturalidade e voz autoral.

`aprofundador` deve ser usado depois do `humanizer-br` quando o texto precisa de mais analise, contexto, implicacao estrategica, comparacao ou sintese.

`ralph-marketer` adapta o fluxo Ralph Wiggum Marketer para Codex, com pipeline de conteudo SaaS, PRD, SQLite, rascunhos, revisao e publicacao.

## Uso em projetos

### Uso direto como repo de skills

Ao abrir este repositorio no Codex, as skills devem aparecer via `.agents/skills`. Esses diretorios sao symlinks para `plugins/codex-configs/skills`, que e a fonte unica do conteudo.

Se copiar as skills para outro projeto e quiser discovery direto pelo Codex, copie ou sincronize para:

```text
.agents/skills/<skill-name>/SKILL.md
```

### Uso como plugin distribuivel

Para expor o bundle como plugin local, mantenha:

```text
.agents/plugins/marketplace.json
plugins/codex-configs/.codex-plugin/plugin.json
plugins/codex-configs/skills/
```

Depois de alterar marketplace, plugin ou skills, reinicie o Codex para garantir nova descoberta.

### Templates de projeto

Copie os templates para o projeto que vai receber as regras:

```text
AGENTS.md
```

No `AGENTS.md`, substitua os placeholders como `{PROJECT_NAME}`, `{WORKTREE_ROOT}` e `{CRITICAL_PRIORITY_1}` pelas regras do projeto.

Se o projeto tiver frontend com dev server compartilhado, copie `plugins/codex-configs/templates/tools/ensure-frontend-dev.sh` para:

```text
tools/ensure-frontend-dev.sh
```

Depois, substitua os placeholders ou configure variaveis como `FRONTEND_DEV_PROJECT_NAME`, `FRONTEND_DEV_CANONICAL_ROOT`, `FRONTEND_DEV_FRONTEND_DIR`, `FRONTEND_DEV_PORT`, `FRONTEND_DEV_PUBLIC_HOST`, `VITE_DEV_PROXY_TARGET`, `FRONTEND_DEV_NPM_SCRIPT` e `FRONTEND_DEV_START_COMMAND`.

Se a copia nao preservar permissoes de execucao, rode `chmod +x tools/ensure-frontend-dev.sh`.

### Preset Grupo JF

O preset do Grupo JF fica em:

```text
plugins/codex-configs/templates/projects/grupojf/
```

Ele contem:

```text
AGENTS.md
.agents/skills/pre-task-spec-approval/SKILL.md
.codex/config.toml
tools/ensure-frontend-dev.sh
```

Para aplicar no checkout do Grupo JF:

```bash
cp plugins/codex-configs/templates/projects/grupojf/AGENTS.md /opt/grupojf/AGENTS.md
mkdir -p /opt/grupojf/.agents/skills /opt/grupojf/.codex /opt/grupojf/tools
cp -R plugins/codex-configs/templates/projects/grupojf/.agents/skills/pre-task-spec-approval /opt/grupojf/.agents/skills/
cp plugins/codex-configs/templates/projects/grupojf/.codex/config.toml /opt/grupojf/.codex/config.toml
cp plugins/codex-configs/templates/projects/grupojf/tools/ensure-frontend-dev.sh /opt/grupojf/tools/ensure-frontend-dev.sh
chmod +x /opt/grupojf/tools/ensure-frontend-dev.sh
```

No Grupo JF, mantenha `.codex/dev-logs/`, `.codex/sessions.md` e arquivos de ambiente fora do Git.

## O que nao esta incluso

Este repositorio guarda configuracoes reutilizaveis. Skills locais e especificas de um produto, como uma skill de frontend de um projeto particular, nao devem ser copiadas para ca.

## Referencias oficiais

- Skills do Codex: https://developers.openai.com/codex/skills
- Plugins do Codex: https://developers.openai.com/codex/plugins/build#plugin-structure
- Marketplace de plugins: https://developers.openai.com/codex/plugins/build#marketplace-metadata
- Configuracao do Codex: https://developers.openai.com/codex/config-basic

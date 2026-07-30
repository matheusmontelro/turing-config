---
name: post-adjustment-pr-automerge
description: Impõe um fluxo de fim de tarefa com criação de PR, validação em worktree isolado e tentativa de auto-merge. Use em repositórios GitHub confiáveis quando uma implementação, correção ou refatoração de código deve terminar publicada em PR sem misturar arquivos soltos do checkout local.
---

# PR Com Auto-Merge Após Ajustes

## Objetivo

Garantir que todo ajuste de código concluído termine com criação de PR e tentativa de auto-merge, **isolado em worktree validado**, sem misturar trabalho de outras sessões, edições manuais ou arquivos soltos do checkout local.

## Regra Central: Trabalho Isolado, PR Validado

O diretório ativo da tarefa é a fonte de verdade para implementação e experiência local. Ele pode ser o checkout compartilhado do usuário ou um worktree isolado criado depois de uma spec aprovada. O PR deve nascer do conjunto validado da tarefa, sem misturar arquivos soltos de outras sessões.

Esta skill opera em dois modos:

1. **Modo checkout compartilhado:** a implementação aconteceu no checkout principal ou em um diretório com alterações de outras sessões. Para publicar, crie um worktree limpo a partir da branch base e copie apenas os arquivos da sessão.
2. **Modo worktree de tarefa:** a implementação já aconteceu em um worktree isolado e aprovado para essa demanda. Use esse worktree como origem de validação, commit, push e PR. Não crie um segundo worktree por padrão.

1. Edite, crie e valide arquivos localmente no checkout atual antes de qualquer push ou PR.
2. Mantenha uma lista dos arquivos editados nesta sessão. Não confie apenas em `git status` no fim.
3. Para publicar a partir de checkout compartilhado, crie um worktree limpo a partir da branch base e copie apenas os arquivos necessários da tarefa.
4. Para publicar a partir de worktree de tarefa, confirme que a branch e o diff pertencem somente à spec aprovada.
5. Valide dentro do worktree que será publicado. Se a validação falhar por arquivo local faltante, inclua o arquivo somente quando ele for dependência real da tarefa e repita a validação.
6. Se o diretório ativo estiver sujo com alterações fora da sessão, preserve-as. Trabalhe com elas quando forem relacionadas; se forem conflitantes ou indispensáveis mas fora de escopo, explique o bloqueio antes de seguir.
7. O PR deve conter exatamente o conjunto validado no worktree: nem menos que o necessário para rodar, nem arquivos não relacionados.
8. Nunca deixe o usuário com um PR mergeado no GitHub mas sem as mesmas mudanças aplicadas no diretório local da tarefa.

## Política do Repositório

Antes de aplicar esta skill, procure por uma política local em `.codex/pr-automerge-policy.md` ou `.agents/pr-automerge-policy.md`. Se existir, ela define exceções do projeto, como branch base esperada, comandos de validação preferidos, método de merge e restrições de publicação.

Se não houver política local:

1. Use a branch padrão do GitHub como base.
2. Prefira `--squash` para auto-merge.
3. Escolha validações coerentes com os arquivos alterados e reporte somente comandos realmente executados.
4. Para frontend, nunca rode `npm run build`, `npm --prefix frontend run build` ou outro build de produção sem aprovação explícita do usuário na conversa atual; prefira typecheck, lint, testes existentes ou validação via dev server.

## Idioma Obrigatório

Use sempre português do Brasil em toda comunicação humana gerada por esta skill:

1. Mensagens para o usuário.
2. Título e corpo do PR.
3. Comentários no GitHub.
4. Relatos de validação, riscos, bloqueios e próximos passos.
5. Mensagens de commit, quando forem criadas por este fluxo.

Preserve em inglês apenas comandos, nomes de flags, paths, identificadores técnicos, nomes próprios de ferramentas e termos exigidos por APIs.

## Identidade do Agente

Esta skill pertence ao fluxo do Codex neste repositório.

1. Use `Codex` como agente em logs de sessão, títulos de PR, corpos de PR, comentários e mensagens operacionais.
2. Use o prefixo de título `[Codex DD/MM hh:mm]`.
3. Não use `Claude` em textos gerados por esta skill, exceto ao citar literalmente histórico já existente.

## Checagem de Escopo

Aplique esta skill somente depois que as checagens passarem:

1. Confirme que o diretório atual está dentro de um repositório Git.
2. Confirme que há um remote `origin`.
3. Confirme que o remote aponta para GitHub em formato HTTPS ou SSH.
4. Confirme que `gh` está instalado e autenticado para o owner do repositório.
5. Se a política local declarar um repositório esperado, confirme que `origin` corresponde a ele antes de publicar.

Se uma das checagens falhar, ignore esta skill e informe o motivo em uma frase. Não crie PR sem remote GitHub ou sem autenticação funcional.

## Início da Sessão (Obrigatório)

Antes de qualquer edição, quando esta skill estiver ativa desde o início da tarefa:

1. Registrar timestamp de início no fuso `America/Sao_Paulo`.
2. Capturar snapshot do estado pré-sessão para detectar contaminação no fim:
   ```bash
   mkdir -p .codex
   git status --porcelain > .codex/.session-start.txt
   ```
3. Manter, internamente, a lista de arquivos editados nesta sessão. Para arquivos criados, movidos ou removidos, registrar o caminho final e o caminho anterior quando houver.

Se esta skill for acionada somente no fim de uma tarefa já iniciada, registre o snapshot no primeiro momento possível, deixe isso claro no relatório final e confie na lista explícita de arquivos da sessão em vez de ampliar o escopo pelo `git status`.

## Checagem de Segurança (Obrigatória)

Antes de stage, commit, push ou criação de PR no worktree isolado:

1. Escaneie os caminhos alterados procurando padrões sensíveis (`.env`, arquivos de chave/certificado, secrets, credentials).
2. Escaneie o diff staged procurando padrões de tokens/chaves e cabeçalhos de chave privada.
3. Se houver match sensível, pare o fluxo e sanitize/remova o conteúdo primeiro.
4. Nunca imprima valores completos de secrets no terminal ou no corpo do PR; mascare os valores.
5. Se um secret já tiver sido enviado ao remoto, reporte o incidente e solicite rotação da credencial.

Templates `.env*.example` são permitidos somente quando o scan do diff staged confirmar que contêm apenas placeholders.

## Fluxo Obrigatório de Fim de Tarefa

Depois de implementar qualquer alteração de código solicitada pelo usuário:

1. Calcule timestamp final, duração e slug curto: `codex-YYYY-MM-DDThh-mm-<descrição-kebab>`.
2. Confirme que as edições estão no checkout local atual e liste os caminhos editados nesta sessão.
3. Escolha o modo:
   - se estiver em worktree de tarefa aprovado, use o worktree atual como worktree de publicação;
   - se estiver no checkout compartilhado, crie worktree isolado a partir da branch base e copie apenas os arquivos da sessão.
4. Execute as checagens de segurança no worktree que será publicado.
5. Valide dentro do worktree que será publicado. Para frontend, use validações permitidas como typecheck/lint/test quando existirem, ou servidor local somente quando a tarefa exigir execução manual/dev server.
6. Se a validação falhar por dependência ausente que existe solta no checkout local, adicione esse arquivo à lista da sessão apenas se for parte real da entrega, copie para o worktree e repita segurança + validação. Se o arquivo for não relacionado, bloqueie o PR e explique.
7. Abra PR a partir da branch do worktree e ative auto-merge.
8. Verifique que o checkout compartilhado não recebeu desvio inesperado. No modo checkout compartilhado, a diferença esperada é o snapshot inicial mais os arquivos da sessão; no modo worktree de tarefa, o worktree da tarefa deve permanecer preservado.
9. Registre a sessão no log configurado pelo projeto; use `.codex/sessions.md` quando não houver política local. O formato está em `references/session-log.md`.
10. Retorne URL do PR, estratégia de merge escolhida, status do auto-merge, validações executadas e confirme que o checkout local contém as mudanças.
11. Se houver bloqueio, reporte o bloqueio exato e forneça o comando de próximo passo mais curto.

## Regras de Qualidade do PR

Use mensagens objetivas no PR e evite texto genérico:

1. Use o formato de título `[Codex DD/MM hh:mm] <tipo>: <resumo conciso em pt-BR>`.
2. Inclua as seções: `Contexto`, `O que mudou`, `Validação`, `Riscos`, `Reversão`.
3. Reporte somente validações que foram realmente executadas.
4. Prefira `--squash` para auto-merge, exceto se a política do repositório exigir outro método.

## Tratamento de Falhas

1. Se `gh` não estiver autenticado: informe o bloqueio e peça autenticação antes de retomar.
2. Se push falhar com HTTP 5xx ou erro de rede: documentar, manter o worktree e oferecer retentativa antes de abortar.
3. Se auto-merge estiver desativado: reportar bloqueio e fornecer link do PR.
4. Se checks obrigatórios estiverem pendentes: manter `--auto` ativo e reportar status de espera.
5. Se a validação no worktree falhar por arquivos faltantes do checkout local: não criar PR incompleto; incluir dependências reais ou bloquear.
6. Se a verificação de não-contaminação falhar: nunca usar `git stash drop`, `git reset --hard` ou `git checkout --` para limpar sem aprovação explícita; preservar o estado e pedir orientação.
7. Se um worktree de tarefa contiver arquivos fora da spec aprovada, não publique tudo junto; separe a entrega ou peça aprovação de escopo revisado.

## Referência de Comandos

Leia `references/pr-automerge-flow.md` antes de executar comandos de PR.
Use o formato em `references/session-log.md` ao registrar a sessão.

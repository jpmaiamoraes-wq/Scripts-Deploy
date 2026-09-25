# Onboarding Deploy — Repasse Técnico para Desenvolvedores

> Documento de transferência de conhecimento (TKT) do sistema **Sankhya Onboarding Deploy**.
> Versão em produção na **plataforma Mitra** (reconstrução completa da versão anterior, que era um
> proxy Python + HTML/JS vanilla rodando na máquina do Gerente de Projetos).
> Última atualização: 24/08/2026 · Autor original: Adelcione Marques (`adelcione.marques@sankhya.com.br`)

---

## 1. O que é

Plataforma que automatiza a entrada de cada novo cliente Sankhya no processo de implantação, do
momento em que a venda é fechada no Ploomes até o consultor receber o pacote pronto para parametrizar
o ERP (ou a Folha de Pagamento). Substitui e-mails, planilhas paralelas e pastas locais não
padronizadas.

**Objetivo de negócio**: reduzir o trabalho manual do GP por projeto, eliminar retrabalho fiscal e
padronizar o handoff para o time de implantação.

**Estado atual**: em produção, dois funis ativos — **Gestão Empresarial** (fiscal/ERP, 12 etapas) e
**Gestão de Pessoas** (Folha, 7 etapas + Revisão). Importação direta da API REST do Ploomes.

---

## 2. Stack técnico

| Camada | Tecnologia | Por quê |
|---|---|---|
| **Front-end** | React 19 + TypeScript + Vite + Tailwind (CSS variables) | Padrão de projetos Mitra — sem servidor próprio de front, build estático |
| **Roteamento** | react-router-dom (BrowserRouter) | `/` (login) → Kanban; `/onboarding/:codigo` → portal do cliente (público) |
| **Back-end** | Server Functions da plataforma Mitra (SQL / JAVASCRIPT) | Sem servidor próprio — cada operação é uma função hospedada e versionada pela plataforma |
| **Persistência** | Banco do projeto Mitra (tabelas `OB_*`) | Substituiu o `localStorage` do navegador da versão anterior — dados agora vivem no servidor, não na máquina do GP |
| **Transporte do link do cliente** | Rota + token: `/onboarding/:codigo` | Substituiu o payload gzip+base64url no fragmento da URL (`#data=...`) da versão anterior — hoje o estado fica no banco, o link só carrega o código do projeto |
| **Storage de arquivos** | Google Drive (Service Account, JWT assinado em Server Function) | Ver `DOC_DRIVE_INTEGRACAO.md` |
| **CRM** | Ploomes REST API v2 (OData) | Importa negociações ganhas via SF tipo INTEGRATION/JAVASCRIPT |
| **Enriquecimento cadastral** | CNPJa (SEFAZ) + ICP | ICP é a fonte oficial de dados cadastrais; SEFAZ/CNPJa fica só com Inscrição Estadual |
| **E-mail** | SMTP próprio (Gmail STARTTLS), implementado manualmente em Server Function | Ver seção 7 — decisão histórica, não usa `sendEmailMitra` |
| **Autenticação** | Login nativo da plataforma Mitra (SSO + e-mail/senha) | Substituiu qualquer autenticação própria — sem tabela de usuários customizada |

---

## 3. Arquitetura em uma página

```
┌──────────────────────────────────────────────────────────────────────────┐
│                    NAVEGADOR DO GP (autenticado via Mitra)                │
│                                                                            │
│   KanbanPage (+ ConfigPanel, AuditoriaPanel, ConvitesPanel, GestoresPanel)│
│        │  executeServerFunctionMitra (mitra-interactions-sdk)             │
└────────┼───────────────────────────────────────────────────────────────────┘
         ▼
┌────────────────────────────────────────────────────────────────────────┐
│                 SERVER FUNCTIONS (plataforma Mitra)                     │
│   SQL          → CRUD nas tabelas OB_* (grande maioria das operações)   │
│   JAVASCRIPT   → Drive (JWT + fetch), SMTP manual, Ploomes, cálculos    │
│                  de inatividade, exclusão em cascata, LGPD              │
└──────┬─────────────┬─────────────┬─────────────┬────────────┬──────────┘
       ▼             ▼             ▼             ▼            ▼
  ┌─────────┐  ┌──────────┐  ┌────────────┐  ┌─────────┐  ┌─────────┐
  │ Ploomes │  │ CNPJa /  │  │  Sankhya   │  │ Gmail   │  │ Google  │
  │ REST    │  │ ICP      │  │  MGE/TCSELC│  │ SMTP    │  │ Drive   │
  └─────────┘  └──────────┘  └────────────┘  └─────────┘  └─────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                  NAVEGADOR DO CLIENTE (sem login — portal público)        │
│   OnboardingRouter → resolve o FUNIL do projeto e escolhe:                 │
│     OnboardingPage    (fiscal, Gestão Empresarial, INALTERADO)            │
│     OnboardingGpPage  (Folha, Gestão de Pessoas, 7 etapas + Revisão)       │
│        │  SFs PÚBLICAS (sem token) via configurePortalPublic()            │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Estrutura de arquivos

```
frontend/src/
├── pages/
│   ├── LoginPage.tsx           ← login nativo Mitra (SSO + e-mail)
│   ├── KanbanPage.tsx          ← painel do GP: board, config, filtros, exportação (~800+ linhas)
│   ├── OnboardingRouter.tsx    ← dispatcher público: escolhe o wizard pelo FUNIL do projeto
│   ├── OnboardingPage.tsx      ← portal do cliente — modelo fiscal (Gestão Empresarial)
│   ├── OnboardingGpPage.tsx    ← portal do cliente — modelo Folha (Gestão de Pessoas, GP7_STEPS)
│   └── SalvarPacotePage.tsx    ← geração do pacote final para a equipe de implantação
│
├── components/kanban/          ← 16+ componentes: KanbanCard, ProjectModal, AdminModal,
│                                  EmailSettingsModal, DriveSettingsModal, ProcResponsaveisModal,
│                                  AuditoriaPanel, ConvitesPanel, GestoresPanel, PloomesModal,
│                                  ConsultoresModal, RespostasModal, FileViewerModal, DashboardPanel,
│                                  StatusView, SendEmailModal
│
├── lib/
│   ├── api.ts                  ← SF ids, callSF/callSFRaw/callPublicSF, configuração do SDK
│   ├── onboarding.ts           ← STEPS/GP_STEPS/GP7_STEPS, tipos, helpers de domínio (Project, etc.)
│   ├── roles.ts                ← papéis de acesso (ver seção 6)
│   ├── mitra-auth.ts           ← sessão (template Mitra, inalterado)
│   └── docsContent / utils     ← utilidades diversas
│
backend/
├── setup-backend.mjs           ← schema inicial (núcleo Kanban/Empresarial)
├── add-*.mjs                   ← ~150 scripts incrementais (1 unidade de mudança cada, nunca reexecutados)
├── sf_*.js                     ← código-fonte das Server Functions tipo JAVASCRIPT
├── migrations/ + migrations.yaml  ← histórico append-only de schema/SF (gerado pela plataforma)
└── documentacao/                 ← fonte destes 3 documentos (publicados como .md via uploadFilePublicMitra)
```

---

## 5. Modelo de dados (tabelas `OB_*`)

**Núcleo (ambos os funis):**

- `OB_PROJECTS` — 1 linha por onboarding. `CODIGO` (identificador do link), `ID_NEGOCIO` (Ploomes),
  `RAZAO_SOCIAL`, `CNPJ_PRINCIPAL`, `RESPONSAVEL(+EMAIL)`, `GERENTE_PROJETOS(+EMAIL)`,
  `CENTRO_RESULTADO`, `CURRENT_STEP` (0-11), `STATUS` (EM_ANDAMENTO/PAUSADO/CONCLUIDO/CANCELADO/
  EM_VALIDACAO), `DRIVE_FOLDER_URL`, `LINK_URL/LINK_TOKEN`, `ORIGIN` (MANUAL/PLOOMES_API), `FUNIL`
  (decide qual wizard o cliente vê), `REOPEN_COUNT/SCOPE`, `GP_ETAPA` (etapa atual no wizard de Folha).
- `OB_COMPANIES` — matriz + filiais por projeto (fonte oficial cadastral, combinando ICP + SEFAZ).
- `OB_STEPS` — estado por (projeto, etapa): `DATA_JSON` guarda as respostas do wizard fiscal.
- `OB_FILES` — metadado de cada arquivo enviado (categoria, tamanho, URL de storage).
- `OB_ALERTS` / `OB_EVENTS` — timeline e alertas por projeto.
- `OB_CNPJA_CACHE` — cache do enriquecimento cadastral por CNPJ.
- `OB_CONFIG` — chave/valor central: `GDRIVE_SA`, `GDRIVE_ROOT`, `GDRIVE_ROOT_GP`, `SMTP`, regras de
  aviso automático, destinatários em cópia.
- `OB_AUDIT` — histórico de alterações (autor, data, o que mudou) para a tela de Auditoria.
- `OB_CONVITES` — acompanhamento de convites de acesso à plataforma (quem convidou, quando acessou).
- `OB_PROJECT_CONSULTORES` — vínculo explícito de Consultor Sankhya por onboarding.
- `OB_PROC_RESPONSAVEIS` — cadastro global de responsáveis pela procuração eletrônica.
- `OB_XML_RESUMO` — resumo agregado dos XMLs processados por projeto.

**Modelo Gestão de Pessoas (`OB_GP_*`)** — uma tabela por seção do wizard de Folha:
`OB_GP_EMPRESAS`, `OB_GP_CONFIG`, `OB_GP_ARQUIVOS`, `OB_GP_BENEFICIOS`, `OB_GP_SINDICATOS`,
`OB_GP_CALCULO`, `OB_GP_CONTRATOS`, `OB_GP_RESIDUOS`, `OB_GP_REAJUSTE`, `OB_GP_MEDIAS`,
`OB_GP_DECLARACOES`, `OB_GP_LGPD`, `OB_GP_RESPONSAVEIS`, `OB_GP_PLANILHA_CONFIG`, e tabelas de
referência tributária (`OB_GP_FPAS4`, `OB_GP_FPAS_CNAE`, `OB_GP_RAT4`, `OB_GP_RAT7`,
`OB_GP_RAT_CNAE`, `OB_GP_CPRB_CNAE`, `OB_GP_CODIGOS_RECOLHIMENTO`, `OB_GP_TERCEIROS_COMP`) usadas para
preencher a etapa Tributário a partir do CNAE.

> As 5 etapas antigas do modelo GP de 12 etapas (Cálculo, Contratos, Resíduos, Reajuste, Médias) foram
> fundidas na etapa única "Sindicato e Regras" do modelo atual de 7 etapas (`GP7_STEPS`, em
> `lib/onboarding.ts`) — as tabelas continuam existindo por trás, só a jornada do cliente mudou.

---

## 6. Modelo de permissões (`lib/roles.ts`)

Escopo por **e-mail**, resolvido no login (`ob_whoamiRole`) — não há tabela de usuários própria, o
papel é lido de `OB_USER_ROLES` (por e-mail) e cruzado com a sessão nativa Mitra.

| `RoleKey` | Escopo | Pode excluir/reabrir? |
|---|---|---|
| `admin` (Administrador Onboarding) | Todos os projetos | **Sim** — único papel que pode |
| `central` (Gerente Central Deploy) | Todos os projetos | Não |
| `consultor` (Consultor Deploy) | Todos os projetos | Não |
| `gerente` (Gerente de Projetos) | Projetos onde é o GP (por e-mail) | Somente leitura |
| `coordenador` (Coordenador de Serviços) | Projetos dos GPs liderados (via `TSIUSU.AD_GERENTE/AD_NUCARGO` no Sankhya) | Somente leitura |
| `consultor_sankhya` | Só projetos com vínculo explícito em `OB_PROJECT_CONSULTORES` | Somente leitura, sem dados sensíveis |

Funções-chave:

- `isAdmin(role)` → `admin`, `central` ou `consultor` — acesso de edição total, mas **não** exclusão.
- `isAdminOnboarding(role)` → **apenas** `admin` — propositalmente mais estrito, guarda as duas ações
  destrutivas (excluir projeto / reabrir onboarding).
- `isReadOnly(role)` → `gerente`, `coordenador`, `consultor_sankhya`.
- **Fail-closed**: papel vazio/desconhecido não libera nada — é preciso o valor exato bater.
- `SUPERADMIN_EMAILS` — allowlist hardcoded (hoje só `adelcione.marques@sankhya.com.br`) que sempre
  resolve como `admin` pleno, independente do que estiver cadastrado em `OB_USER_ROLES` — proteção
  contra o desenvolvedor se trancar fora por um erro de cadastro.
- `isSankhyaEmail()` — trava de **duas camadas** (tela + servidor) que restringe o papel
  `consultor_sankhya` a e-mails `@sankhya.com.br`; a barreira que vale de fato é a do servidor (nas SFs
  `ob_consultorAdd`/`ob_ensureConsultorRole`).

---

## 7. Fluxos críticos

### Importação de venda Ploomes → Kanban

```
1. GP clica "🌐 Buscar Ploomes" → digita CNPJ/nome → "Buscar agora"
2. Front chama SF (INTEGRATION/JAVASCRIPT) que consulta api2.ploomes.com/Deals
   (User-Agent de navegador — Cloudflare bloqueia User-Agent customizado, erro 1010)
3. SF mapeia: Deal.Id → idNegocio · Owner.Email → responsavelEmail · Pipeline.Name → funil
4. GP seleciona e importa → cada deal cria um OB_PROJECTS na etapa 0
```

### Geração e consumo do link de onboarding

```
1. GP clica "🚀 Iniciar Onboarding" → CURRENT_STEP: 0 → 1
2. Sistema gera o link: https://<dominio>/onboarding/<codigo>  (sem payload no fragmento)
3. Cliente abre → OnboardingRouter resolve o FUNIL via SF pública (getProject) com retry
4. Router escolhe OnboardingPage (fiscal) ou OnboardingGpPage (Folha) e monta o estado
   a partir do banco (OB_STEPS/OB_GP_*), não de um payload comprimido na URL
```

### Upload do cliente → Google Drive

Detalhado em `DOC_DRIVE_INTEGRACAO.md`. Resumo: o arquivo sobe primeiro para o storage do Mitra
(`uploadFileLoadableMitra`), depois uma Server Function (`ob_driveUpload`) baixa desse storage e
repassa ao Drive em streaming, garantindo a pasta do projeto (`ob_driveFolder`) por um marcador
`[codigo]` no nome.

### Alerta de CNPJ não licenciado / monitor de inatividade

Cruza os CNPJs detectados no SPED/XML com a base de licenças Sankhya (`TCSELC`/`sf_sankhya_licencas_
cliente.js`); se houver CNPJ fora da lista, dispara e-mail ao Responsável Comercial com o GP em cópia.
O monitor de inatividade roda periodicamente e usa as regras configuráveis em `OB_CONFIG` (dias de
paralisação, intervalo entre lembretes, máximo de lembretes) — ver `sf_reminder_onboarding.js`.

---

## 8. Integrações externas

| Sistema | Como é acessado | Observação |
|---|---|---|
| **Ploomes REST v2** | SF chamando `api2.ploomes.com` direto | User-Agent de navegador obrigatório (Cloudflare) |
| **ICP** | SF (`ob_cnpjaOffice`) | Fonte **oficial** de dados cadastrais + regime tributário |
| **CNPJa (SEFAZ)** | SF (`ob_cnpjaOffice`) | Reduzido a **apenas Inscrição Estadual** desde a migração para ICP (ver histórico git) |
| **Sankhya MGE / TCSELC** | SF (`sf_sankhya_licencas_cliente.js`) | Consulta de licenças contratadas por CNPJ |
| **Google Drive** | SF JAVASCRIPT com JWT assinado manualmente | Sem lib externa — ver `DOC_DRIVE_INTEGRACAO.md` |
| **Gmail SMTP** | SF JAVASCRIPT com diálogo SMTP manual sobre socket (`sf_send_onboarding_email.js`) | **Não usa `sendEmailMitra`** — decisão herdada da versão anterior, mantida por compatibilidade com as regras de negócio já implementadas (lembretes, CC dinâmico, templates HTML) |

> **Nota de arquitetura:** a maioria dos projetos Mitra usa `sendEmailMitra` (SDK) para envio de
> e-mail. Este projeto implementa o protocolo SMTP manualmente porque a lógica de regras (quem entra
> em cópia, template por tipo de alerta, throttling de lembretes) foi portada da versão Python
> original com poucas mudanças. Migrar para `sendEmailMitra` é um item de melhoria válido, mas não
> trivial — a lógica de templates/regras precisaria ser preservada.

---

## 9. Modelo de permissões da `mitra-interactions-sdk` aplicado neste projeto

Todas as telas do painel do GP exigem login (usuário `dev` ou `business` da plataforma — não confundir
com os papéis de negócio da seção 6, que são uma camada **adicional** sobre o usuário Mitra). O portal
do cliente (`OnboardingRouter` e páginas filhas) é **público**: usa Server Functions marcadas como
`publicExecution: true` e `configurePortalPublic()` configura o SDK sem token. CRUD REST nativo
(`listRecordsMitra` etc.) não é usado em nenhuma tela — toda leitura/escrita passa por Server Function
SQL, tanto para telas internas quanto para o portal público.

---

## 10. Como editar/rodar este projeto

Não há "rodar localmente" no sentido antigo (proxy + HTML). O projeto vive dentro da chain Mitra:

```bash
# Backend — instalar deps e (só quando necessário) criar novas SFs/tabelas via script incremental
cd backend && npm install && node add-nome-do-script.mjs

# Frontend — desenvolvimento
cd frontend && npm install
npm run build     # sempre depois de alterar src/ — o preview usa o dist/, não o código fonte
```

Sincronização de equipe via git (branch de trabalho + `main`) — ver `CLAUDE.md` do projeto para o
fluxo exato de SYNC/SHARE. Migrations (`backend/migrations/` + `migrations.yaml`) são geradas
automaticamente pela plataforma a cada DDL/SF executado — nunca editadas manualmente.

---

## 11. Pontos de atenção / débitos técnicos

### Conhecidos

1. **SMTP manual, não `sendEmailMitra`** (seção 8) — funciona, mas é código não padrão do ecossistema
   Mitra; qualquer troca de senha da conta de envio (`atendimento.deployagent@sankhya.com.br`) exige
   gerar nova senha de aplicativo do Gmail.
2. **Dedup de upload no Drive é só por nome** (ver `DOC_DRIVE_INTEGRACAO.md`, seção 6) — reenvio de
   arquivo com conteúdo diferente e mesmo nome não substitui automaticamente.
3. **JWT do Drive assinado manualmente em 4 SFs** sem módulo compartilhado — mudança no protocolo do
   Google exige tocar nas 4 ao mesmo tempo.
4. **`find-or-create` de pasta no Drive não é atômico** — duas requisições simultâneas para o mesmo
   projeto podem, em teoria, criar 2 pastas com o mesmo marcador `[codigo]`. Não observado em produção.
5. **Ploomes via Cloudflare** — hoje contornado com User-Agent de navegador; se a proteção do Ploomes
   mudar, pode ser necessário migrar para um conector oficial.

### Onde tem código sensível

- `backend/sf_drive_folder.js` / `sf_drive_upload.js` / `sf_drive_test.js` — autenticação Drive (JWT)
- `backend/sf_send_onboarding_email.js` — protocolo SMTP manual + templates de e-mail
- `backend/sf_reminder_onboarding.js` — regras de inatividade e throttling de lembretes
- `backend/sf_delete_project_full.js` — exclusão em cascata (tabelas `OB_*` + lixeira do Drive)
- `frontend/src/lib/roles.ts` — modelo de permissões (fail-closed, superadmin allowlist)
- `frontend/src/pages/OnboardingRouter.tsx` — dispatcher que decide o wizard do cliente pelo `FUNIL`

### Pendente / nice-to-have

- [ ] Migrar SMTP manual para `sendEmailMitra` (preservando regras de negócio)
- [ ] Verificação de conteúdo (hash) no dedup de upload do Drive, não só nome
- [ ] Extrair o bloco de autenticação JWT do Drive para um módulo compartilhado entre as 4 SFs
- [ ] Webhook do Ploomes em vez de busca sob demanda

---

## 12. Documentação adicional

- **`DOC_DRIVE_INTEGRACAO.md`** — como a integração com o Google Drive funciona (Server Functions,
  autenticação, upload em partes)
- **`MANUAL_USUARIO.md`** — manual operacional para o Gerente de Projetos (não-técnico)
- Ambos disponíveis para download em **Configurações → Documentação**, dentro do próprio sistema.

---

## 13. Contatos

| Papel | Pessoa | E-mail |
|---|---|---|
| Owner do produto | Adelcione Marques | adelcione.marques@sankhya.com.br |
| Conta Ploomes / SMTP | — | atendimento.deployagent@sankhya.com.br |

---

*Documento atualizado em 24/08/2026 para refletir a reconstrução do sistema na plataforma Mitra.
Atualize a versão correspondente ao fazer mudanças significativas no fluxo ou na stack (ou gere uma
nova versão pela tela Configurações → Documentação).*

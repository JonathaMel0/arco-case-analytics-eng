# Progresso do Case — Analytics Engineer Arco

> Deadline: **11 de agosto às 14h**
> Repositório: github.com/JonathaMel0/arco-case-analytics-eng

---

## Visão geral

| # | Passo | Status |
|---|---|---|
| 1 | Subir dados no BigQuery (raw) | ✅ Feito |
| 2 | Construir modelos dbt (clean → curated → report) | ✅ Feito |
| 3 | Subir tudo no GitHub | ⏳ Parcial |
| 4 | Conectar Metabase e construir relatório | ⏳ Parcial |
| 5 | Documentações | ⏳ Parcial |

---

## Detalhes por passo

### ✅ Passo 1 — BigQuery raw

- 20 tabelas carregadas via `upload_to_bigquery.py`
- Projeto: `arco-analytics-eng`, dataset `raw`
- Contagens validadas contra os CSVs originais

---

### ✅ Passo 2 — Modelos dbt

**Projeto:** `dbt_arco/` — dbt 1.12.0 + BigQuery adapter + dbt_utils

**Estrutura de pastas** (100% alinhada com guidelines):
```
models/
├── clean/
│   ├── crm/          (5 modelos)
│   ├── erp_a/        (5 modelos)
│   ├── erp_b/        (4 modelos)
│   ├── fin/          (1 modelo)
│   └── support/      (4 modelos)
├── curated/
│   └── school_operations/
│       ├── school/staging/    (4 stagings + 1 final)
│       ├── account_manager/   (1 final)
│       ├── contract/          (1 final)
│       ├── order/staging/     (2 stagings + 1 final)
│       ├── order_item/staging/(2 stagings + 1 final)
│       ├── delivery/staging/  (2 stagings + 1 final)
│       └── ticket/            (1 final)
└── report/
    └── school_operations/
        ├── report__school_operations__monthly__school_order_metrics.sql
        └── report__school_operations__ytd__am_portfolio_metrics.sql
```

**Resultado:** `dbt run` → PASS=39 ERROR=0

**Conformidade com guidelines verificada:**
- ✅ Nomenclatura: `<camada>__<domínio/sistema>__<tipo>__<entidade>`
- ✅ Stagings em `<entidade>/staging/`
- ✅ Pastas no singular (`school/`, `order/`, `delivery/`)
- ✅ `final` CTE + `SELECT * FROM final` em todos os modelos
- ✅ Entity-centric: apenas IDs de ligação entre entidades
- ✅ `generate_schema_name` macro: datasets `clean`, `curated`, `report` sem prefixo

---

### ⏳ Passo 3 — GitHub

- [x] Repositório criado: `JonathaMel0/arco-case-analytics-eng`
- [x] RFC commitada (commit `832b985`)
- [ ] **Falta commitar:** `dbt_arco/`, `upload_to_bigquery.py`, `.gitignore` atualizado
- [ ] Atualizar `.gitignore` com entradas do dbt (`target/`, `dbt_packages/`, `logs/`, `.venv/`)

**Ação:** `git add . && git commit -m "feat: dbt project clean/curated/report layers" && git push`

---

### ⏳ Passo 4 — Metabase

- [x] Metabase conectado ao BigQuery via service account `metabase-reader`
- [x] Datasets `clean`, `curated`, `report` visíveis
- [ ] **Falta construir o dashboard** com os dados do report:
  - Card 1: Pedidos por escola por mês (de `report__monthly__school_order_metrics`)
  - Card 2: Volume financeiro por mês
  - Card 3: Taxa de entrega bem-sucedida
  - Card 4: Tickets por escola
  - Card 5: Portfolio YTD por Account Manager (de `report__ytd__am_portfolio_metrics`)

---

### ⏳ Passo 5 — Documentações

| Documento | Status | Onde |
|---|---|---|
| RFC de modelagem | ✅ Completo | `RFC_Modelagem_Arco.md` |
| Documentação técnica do dbt (`schema.yml`) | ❌ Falta | A criar em cada pasta do dbt |
| README do projeto | ❌ Falta | `README.md` na raiz |
| Documentação do dashboard | ❌ Falta | Após construir o Metabase |

**O que falta em documentação técnica:**

`schema.yml` em cada camada com:
- Descrição de cada modelo
- Testes: `unique`, `not_null`, `accepted_values`, `relationships`
- Descrição das colunas principais

---

## Ordem sugerida para finalizar

```
1. [ ] Atualizar .gitignore
2. [ ] Commitar e fazer push do dbt_arco/ + upload_to_bigquery.py
3. [ ] Criar schema.yml com descrições e testes nas 3 camadas
4. [ ] dbt test (validar testes)
5. [ ] Construir dashboard no Metabase (5 cards)
6. [ ] Criar README.md do projeto
7. [ ] Documentar o dashboard
8. [ ] Commit final e push
```

---

## Diferenciais já entregues (além do pedido)

- Implementação real rodando no BigQuery (não só RFC)
- dbt com 39 modelos funcionando
- Metabase conectado e pronto para dashboard
- Arquitetura 100% alinhada com os 4 guidelines do case
- Resolução documentada dos problemas de qualidade (CNPJ, 15 status ERP-B, 315 contratos sobrepostos)

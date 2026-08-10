# Arco Educação — Case Analytics Engineer

Implementação completa do case técnico: modelagem analítica em BigQuery com dbt, testes automatizados e dashboard no Metabase.

> O briefing original do case está em [`candidato/README_CASE_BRIEFING.md`](candidato/README_CASE_BRIEFING.md).
> A RFC de modelagem (design doc) está em [`RFC_Modelagem_Arco.md`](RFC_Modelagem_Arco.md).

---

## Arquitetura

```
Fontes (5 sistemas)
    └── BigQuery: dataset raw (20 tabelas)
            └── dbt clean (20 views)     — tipagem, renomeação, filtros de qualidade
                    └── dbt curated (17 tabelas) — entidades unificadas entre sistemas
                            └── dbt report (2 tabelas)  — grão analítico pronto para consumo
                                    └── Metabase — dashboard "School Operations: Visão Executiva"
```

### Sistemas de origem

| Sistema | Tabelas raw |
|---|---|
| CRM | `crm_account`, `crm_user`, `crm_product`, `crm_service_contract`, `crm_contract_line_item` |
| ERP A | `erp_a_customer`, `erp_a_salesperson`, `erp_a_sales_order`, `erp_a_sales_order_item`, `erp_a_delivery`, `erp_a_invoice` |
| ERP B | `erp_b_escola`, `erp_b_vendedor`, `erp_b_pedido`, `erp_b_item_pedido` |
| Financeiro | `fin_nota_fiscal` |
| Suporte | `support_organization`, `support_user`, `support_ticket`, `support_ticket_tag` |

---

## Projeto dbt

```
dbt_arco/
├── dbt_project.yml
├── packages.yml              # dbt_utils 1.4.1
├── macros/
│   └── generate_schema_name.sql   # datasets sem prefixo de target
├── models/
│   ├── sources.yml
│   ├── clean/                # 20 views — uma por tabela raw
│   │   ├── crm/     (5)
│   │   ├── erp_a/   (5)
│   │   ├── erp_b/   (4)
│   │   ├── fin/     (1)
│   │   └── support/ (4) + schema.yml em cada pasta
│   ├── curated/
│   │   └── school_operations/
│   │       ├── school/        (staging × 4 + final)
│   │       ├── account_manager/
│   │       ├── contract/
│   │       ├── order/         (staging × 2 + final)
│   │       ├── order_item/    (staging × 2 + final)
│   │       ├── delivery/      (staging × 2 + final)
│   │       └── ticket/
│   └── report/
│       └── school_operations/
│           ├── report__school_operations__monthly__school_order_metrics.sql
│           └── report__school_operations__ytd__am_portfolio_metrics.sql
```

### Convenção de nomenclatura

```
<camada>__<domínio/sistema>__<tipo>__<entidade>

Exemplos:
  clean__crm__current__account
  curated__school_operations__event__order
  report__school_operations__monthly__school_order_metrics
```

### Materialização por camada

| Camada | Materialização | Dataset BigQuery |
|---|---|---|
| `clean` | view | `clean` |
| `curated` | table | `curated` |
| `report` | table | `report` |

---

## Como executar

### Pré-requisitos

- Python 3.13+
- Conta GCP com acesso ao projeto `arco-analytics-eng`
- `gcloud` autenticado (`gcloud auth application-default login`)

### Setup

```bash
python -m venv .venv
.venv\Scripts\activate          # Windows
pip install dbt-bigquery==1.12.0 dbt-utils
```

### Rodar os modelos

```bash
cd dbt_arco

# Rodar todos os modelos
dbt run

# Rodar com recriação completa das tabelas
dbt run --full-refresh

# Rodar apenas uma camada
dbt run --select clean.*
dbt run --select curated.*
dbt run --select report.*

# Executar os 130 testes de qualidade
dbt test
```

### Perfil dbt (`~/.dbt/profiles.yml`)

```yaml
arco_analytics:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: arco-analytics-eng
      dataset: dbt_dev
      location: southamerica-east1
      threads: 4
```

---

## Testes de qualidade

130 testes dbt distribuídos nos 13 `schema.yml` das 3 camadas:

| Tipo | Cobertura |
|---|---|
| `unique` | Todas as PKs |
| `not_null` | Campos obrigatórios |
| `accepted_values` | Status, priority, source_system, account_type |
| `relationships` | FKs críticas (order_item → order, contract → account_manager) |

```bash
dbt test
# Done. PASS=130 WARN=0 ERROR=0
```

---

## Tabelas de report

### `report__school_operations__monthly__school_order_metrics`

Grão: escola × mês. Responde a **P1 do case** — visão consolidada de venda por escola ao longo do tempo.

| Coluna | Descrição |
|---|---|
| `school_id`, `school_name`, `city`, `state` | Identificação da escola |
| `month` | Mês de referência (DATE) |
| `total_orders`, `active_orders`, `cancelled_orders` | Volume de pedidos |
| `ordered_amount`, `ordered_quantity` | Valor e quantidade pedida |
| `total_deliveries`, `successful_deliveries`, `quantity_delivered` | Entregas |
| `total_tickets`, `avg_resolution_hours` | Atendimento |

### `report__school_operations__ytd__am_portfolio_metrics`

Grão: account manager × ano. Responde a **P2 do case** — comparação de AMs pelo volume vendido no ano.

| Coluna | Descrição |
|---|---|
| `account_manager_id`, `account_manager_name` | Identificação do AM |
| `year` | Ano de referência (máximo disponível nos dados) |
| `total_contracts`, `total_contracted_amount` | Contratos ativos |
| `total_orders`, `total_schools_served`, `ordered_amount` | Volume comercial |
| `total_tickets`, `avg_resolution_hours` | Atendimento da carteira |

---

## Dashboard Metabase

**Nome**: School Operations — Visão Executiva  
**Fonte**: datasets `report` e `curated` do BigQuery  
**Acesso**: via service account `metabase-reader`

13 cards organizados em 6 seções:

| Seção | Cards | Responde |
|---|---|---|
| KPIs de Topo | Cards 1-4 | Números executivos YTD |
| Tendência Financeira | Cards 5-6 | Evolução mensal de pedidos e valor |
| Saúde da Entrega | Cards 7-8 | Taxa de entrega e volume por estado |
| Suporte | Cards 9-10 | Tickets e tempo de resolução |
| Visão por Escola | Card 13 | **P1**: top escolas + filtro para drill-down |
| Performance por AM | Cards 11-12 | **P2**: ranking e tabela YTD por AM |

Filtros globais: Período, Estado, Escola.

---

## Decisões de modelagem relevantes

- **Unificação de escola**: join por CNPJ entre CRM, ERP A, ERP B e Suporte — a entidade `curated__school_operations__current__school` é a âncora de identidade
- **Tickets → escola**: rota `ticket.organization_id → support_organization.cnpj → school.cnpj` (cnpj_cliente do ticket estava vazio na maioria dos casos)
- **Datas inválidas**: 4 entregas com `delivery_date = 2204` filtradas no curated (`BETWEEN 2010 AND 2030`)
- **Ano de referência YTD**: usa `MAX(EXTRACT(YEAR FROM order_date))` em vez de `CURRENT_DATE()` para funcionar com dados históricos
- **surrogate key**: `dbt_utils.generate_surrogate_key` nos modelos `order`, `order_item` e `delivery` para gerar `*_id` unificado entre sistemas

---

## Estrutura de arquivos

```
.
├── README.md                        ← este arquivo
├── RFC_Modelagem_Arco.md            ← design doc / RFC
├── PROGRESSO.md                     ← acompanhamento do case
├── METABASE_DASHBOARD.md            ← guia de construção do dashboard
├── upload_to_bigquery.py            ← carga inicial dos CSVs no BigQuery raw
├── candidato/
│   ├── README_CASE_BRIEFING.md      ← briefing original do case
│   ├── data/                        ← CSVs e DuckDB originais
│   └── guidelines/                  ← guidelines de modelagem da Arco
└── dbt_arco/                        ← projeto dbt completo
```

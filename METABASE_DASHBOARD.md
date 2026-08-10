# Dashboard Metabase — School Operations: Visão Executiva

**Projeto BigQuery**: `arco-analytics-eng`
**Dataset de produção**: `report`
**Metabase**: conectado via service account `metabase-reader`

---

## Estrutura do Dashboard

```
Dashboard: "School Operations — Visão Executiva"
│
├── [Seção 1] KPIs de Topo          → 4 cards Metric em linha
├── [Seção 2] Tendência Financeira  → 2 charts
├── [Seção 3] Saúde da Entrega      → 2 charts
├── [Seção 4] Suporte               → 2 cards
└── [Seção 5] Performance por AM    → 2 cards
```

---

## Filtros Globais

Adicionar antes de criar os cards via **"Add a filter"** no topo do dashboard:

| Filtro | Tipo | Campo Alvo |
|--------|------|------------|
| Período | Date Range | `month` |
| Estado | String | `state` |
| Escola | String | `school_name` |

> Conectar cada filtro aos cards ao final, depois que todos estiverem criados.

---

## Seção 1 — KPIs de Topo

> Criar como **4 Metric cards em linha** (layout de 3 colunas cada, total 12 colunas)

---

### Card 1 — Valor Pedido YTD

- **Tipo**: Number
- **Modo**: Modelo (GUI)
- **Tabela**: `report__school_operations__ytd__am_portfolio_metrics`
- **Summarize**: SUM de `ordered_amount`
- **Config**:
  - Title: "Valor Pedido YTD"
  - Number formatting: R$ moeda

---

### Card 2 — Escolas Atendidas YTD

- **Tipo**: Number
- **Modo**: Modelo (GUI)
- **Tabela**: `report__school_operations__ytd__am_portfolio_metrics`
- **Summarize**: SUM de `total_schools_served`
- **Config**:
  - Title: "Escolas Atendidas YTD"

---

### Card 3 — Contratos Ativos YTD

- **Tipo**: Number
- **Modo**: Modelo (GUI)
- **Tabela**: `report__school_operations__ytd__am_portfolio_metrics`
- **Summarize**: SUM de `total_contracts`
- **Config**:
  - Title: "Contratos Ativos YTD"

---

### Card 4 — Taxa de Entrega Bem-sucedida

- **Tipo**: Number
- **Modo**: SQL nativo
- **SQL**:
```sql
SELECT
  ROUND(
    SAFE_DIVIDE(
      SUM(successful_deliveries),
      NULLIF(SUM(total_deliveries), 0)
    ) * 100,
  1) AS taxa_entrega_pct
FROM `arco-analytics-eng.report.report__school_operations__monthly__school_order_metrics`
WHERE total_deliveries > 0
```
- **Config**:
  - Title: "Taxa de Entrega"
  - Suffix: "%"
  - Goal line: 90

---

## Seção 2 — Tendência Financeira

---

### Card 5 — Faturamento Mensal

- **Tipo**: Line chart
- **Modo**: Modelo (GUI)
- **Tabela**: `report__school_operations__monthly__school_order_metrics`
- **Summarize**: SUM de `ordered_amount`, Group by `month`
- **Config**:
  - Title: "Faturamento Mensal (R$)"
  - X axis: month | Y axis: ordered_amount
  - Number formatting Y: R$ moeda
  - Ativar "Trend line"
- **Filtros a conectar**: Período, Estado, Escola

---

### Card 6 — Pedidos Ativos vs Cancelados por Mês

- **Tipo**: Bar chart (stacked)
- **Modo**: SQL nativo
- **SQL**:
```sql
SELECT
  month,
  SUM(active_orders)    AS pedidos_ativos,
  SUM(cancelled_orders) AS pedidos_cancelados
FROM `arco-analytics-eng.report.report__school_operations__monthly__school_order_metrics`
GROUP BY month
ORDER BY month
```
- **Config**:
  - Title: "Pedidos por Mês"
  - Stacked bar: ativar
  - Série "pedidos_ativos": cor verde
  - Série "pedidos_cancelados": cor vermelho
- **Filtros a conectar**: Período

---

## Seção 3 — Saúde da Entrega

---

### Card 7 — Taxa de Entrega por Mês

- **Tipo**: Line chart
- **Modo**: SQL nativo
- **SQL**:
```sql
SELECT
  month,
  ROUND(
    SAFE_DIVIDE(
      SUM(successful_deliveries),
      NULLIF(SUM(total_deliveries), 0)
    ) * 100,
  1) AS taxa_entrega_pct
FROM `arco-analytics-eng.report.report__school_operations__monthly__school_order_metrics`
WHERE total_deliveries > 0
GROUP BY month
ORDER BY month
```
- **Config**:
  - Title: "Taxa de Entrega por Mês (%)"
  - Y axis: min 0, max 100
  - Goal line: 90
- **Filtros a conectar**: Período

---

### Card 8 — Quantidade Entregue por Estado

- **Tipo**: Bar chart horizontal
- **Modo**: Modelo (GUI)
- **Tabela**: `report__school_operations__monthly__school_order_metrics`
- **Summarize**: SUM de `quantity_delivered`, Group by `state`
- **Config**:
  - Title: "Volume Entregue por Estado"
  - Sort: decrescente por quantity_delivered
  - Show values on data points: ativar

---

## Seção 4 — Suporte

---

### Card 9 — Tickets por Mês

- **Tipo**: Line chart
- **Modo**: Modelo (GUI)
- **Tabela**: `report__school_operations__monthly__school_order_metrics`
- **Summarize**: SUM de `total_tickets`, Group by `month`
- **Config**:
  - Title: "Tickets de Suporte por Mês"
  - Ativar "Trend line"
  - Cor: amarelo/laranja para contrastar com Card 5
- **Filtros a conectar**: Período, Escola

---

### Card 10 — Tempo Médio de Resolução

- **Tipo**: Number
- **Modo**: SQL nativo
- **SQL**:
```sql
SELECT
  ROUND(AVG(avg_resolution_hours), 1) AS horas_resolucao_media
FROM `arco-analytics-eng.report.report__school_operations__ytd__am_portfolio_metrics`
WHERE avg_resolution_hours IS NOT NULL
```
- **Config**:
  - Title: "Tempo Médio de Resolução"
  - Suffix: " horas"
  - Goal line: 24 (SLA de referência)

---

## Seção 5 — Performance por Account Manager

---

### Card 11 — Ranking YTD por AM (Tabela)

- **Tipo**: Table
- **Modo**: SQL nativo
- **SQL**:
```sql
SELECT
  account_manager_name                          AS account_manager,
  total_schools_served                          AS escolas_atendidas,
  ordered_amount                                AS valor_pedido_brl,
  total_orders                                  AS pedidos,
  total_contracts                               AS contratos,
  total_tickets                                 AS tickets,
  ROUND(avg_resolution_hours, 1)                AS resolucao_media_horas
FROM `arco-analytics-eng.report.report__school_operations__ytd__am_portfolio_metrics`
ORDER BY ordered_amount DESC
```
- **Config**:
  - Title: "Portfolio YTD por Account Manager"
  - `Valor Pedido (R$)`: formatar como R$ moeda

---

### Card 12 — Faturamento por AM (Ranking Visual)

- **Tipo**: Bar chart horizontal
- **Modo**: Modelo (GUI)
- **Tabela**: `report__school_operations__ytd__am_portfolio_metrics`
- **Summarize**: SUM de `ordered_amount`, Group by `account_manager_name`
- **Config**:
  - Title: "Faturamento por Account Manager (YTD)"
  - Sort: decrescente
  - Show values on data points: ativar
  - Number formatting: R$ moeda

---

## Layout Final (12 colunas Metabase)

```
[Card 1 - 3col] [Card 2 - 3col] [Card 3 - 3col] [Card 4 - 3col]
[Card 5 - 6col]                 [Card 6 - 6col]
[Card 7 - 6col]                 [Card 8 - 6col]
[Card 9 - 6col]                 [Card 10 - 3col] (menor)
[Card 11 - 12col]
[Card 12 - 12col]
```

---

## Checklist de Construção

- [ ] Card 1 — Valor Pedido YTD
- [ ] Card 2 — Escolas Atendidas YTD
- [ ] Card 3 — Contratos Ativos YTD
- [ ] Card 4 — Taxa de Entrega (SQL)
- [ ] Card 5 — Faturamento Mensal
- [ ] Card 6 — Pedidos Ativos vs Cancelados (SQL)
- [ ] Card 7 — Taxa de Entrega por Mês (SQL)
- [ ] Card 8 — Volume por Estado
- [ ] Card 9 — Tickets por Mês
- [ ] Card 10 — Tempo Médio de Resolução (SQL)
- [ ] Card 11 — Tabela Ranking AM
- [ ] Card 12 — Faturamento por AM
- [ ] Filtros globais conectados (Período, Estado, Escola)
- [ ] Dashboard salvo e compartilhado

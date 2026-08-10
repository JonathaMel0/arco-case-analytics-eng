# Estilo de SQL e dbt

## Regras gerais

### SQL

- Palavras-chave em **MAIÚSCULO**: `SELECT`, `WHERE`, `JOIN`, `HAVING`
- Identificadores (nomes de colunas, CTEs) em **minúsculo**
- Funções em **MAIÚSCULO**: `ARRAY_AGG`, `COALESCE`, `LEFT`
- Espaçamento consistente de **4 espaços**
- Quebra de linha após cada coluna selecionada
- Quebra de linha após cada cláusula (`SELECT`, `FROM`, `JOIN`, `WHERE`)
- Linhas com no máximo **100 caracteres**
- Vírgulas **após** os nomes das colunas

### dbt

- Evitar arquivos muito grandes (~300 linhas é sinal de que vale reavaliar)
- CTEs para organizar código — elas substituem subqueries
- Macros para evitar repetição desnecessária
- Adicionar testes sempre que possível (`unique`, `not_null`, `accepted_values`, `relationships`)

## Joins

- Sempre explícitos: `LEFT JOIN`, `INNER JOIN` (nunca join implícito com vírgula)
- Colunas prefixadas com nome/alias da tabela quando houver join
- Evitar `RIGHT JOIN` — inverter a lógica para manter a leitura da esquerda para a direita
- `UNION ALL` ou `UNION DISTINCT` para explicitar a intenção

## CTEs

- Nomes descritivos e em inglês
- A última CTE deve sempre ser a **`final`**
- Todo modelo deve terminar com `SELECT * FROM final`
- Parêntese de abertura na mesma linha do nome, fechamento na linha abaixo da última linha da query

### Exemplo

```sql
WITH orders_with_delivery AS (
    SELECT
        order_id,
        order_date,
        delivery_date,
        DATEDIFF('day', order_date, delivery_date) AS days_to_delivery
    FROM
        {{ ref('clean__erp_a__event__sales_order') }}
    WHERE
        is_cancelled = FALSE
),

final AS (
    SELECT
        *
    FROM
        orders_with_delivery
)

SELECT * FROM final
```

## ORDER BY e GROUP BY

- Evitar `ORDER BY` — ordenação deve ficar a cargo da consulta que consome
- Nunca ordenar por posição (`ORDER BY 1, 2`) — usar nomes explícitos
- Preferir `GROUP BY ALL` quando houver muitas colunas de agrupamento
- Evitar `DISTINCT` quando `GROUP BY` já deduplica

## Subqueries

Evitar subqueries — preferir CTEs. Exceções: construção de arrays ou structs.

## Comentários

- Usar `--` para comentários SQL linha a linha
- Em projetos dbt, usar `{# comentário #}` para informações que não devem aparecer na query compilada
- Variáveis globais no início do arquivo; variáveis específicas próximas do uso

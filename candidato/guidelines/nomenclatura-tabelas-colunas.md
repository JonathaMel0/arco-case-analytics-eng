# Nomenclatura de tabelas e colunas

## Princípios gerais

- Todos os nomes de tabelas e colunas em **snake_case** e **letras minúsculas**
- **Idioma**: preferencialmente **inglês**. Termos de negócio sem tradução clara podem ficar em português (sem acentuação)
- **Descritividade**: cada nome é descritivo e único dentro do seu contexto
- **Sem prefixos técnicos**: não usar `tbl_`, `dim_`, `fato_`, `_table`, etc.
- **Consistência**: para um mesmo conceito, usar sempre o mesmo termo em todos os lugares

## Modelos

Cada modelo (arquivo `.sql` + tabela resultante) segue o formato:

```
<camada>__<domínio>__<tipo>__<entidade>
```

Separação por **duplo underscore** (`__`) entre os componentes. Exemplo:

```
curated__school_operations__current__school
```

### Camada

Define onde o modelo vive no pipeline (`clean`, `curated`, `report`). Veja [Camadas de modelagem](camadas-modelagem.md) para o que cada camada representa.

### Domínio

Área funcional do negócio (ex.: `school_operations`, `billing`, `support`). Em **snake_case**, **singular** quando fizer sentido. O domínio agrupa entidades que têm afinidade analítica entre si.

> A camada `clean` não usa domínio — usa o **sistema de origem** no lugar (`clean__crm__...`, `clean__erp_a__...`).

### Tipo

Define o que cada linha da tabela representa:

| Tipo | Descrição | Exemplo |
|---|---|---|
| `current` | Estado atual da entidade (1 linha por entidade) | `curated__school_operations__current__school` |
| `timeline` | Histórico de mudanças (SCD / snapshot) | `curated__school_operations__timeline__contract` |
| `event` | Eventos ou transações (múltiplas por entidade) | `curated__school_operations__event__order` |
| `daily`, `weekly`, `monthly` | Métricas agregadas por período | `report__school_operations__monthly__school_metrics` |

Tabelas `timeline` devem conter: `state_valid_from`, `state_valid_to` (com `'9998-12-31 23:59:59 UTC'` para o estado atual) e `is_current_state` (boolean).

### Entidade

Nome da entidade de negócio, sempre no **singular** (`school`, não `schools`). Veja [Entity-centric](entity-centric.md).

### Stagings

Modelos intermediários (uma staging por fonte que alimenta a entidade) seguem o formato:

```
staging__<camada>__<domínio>__<tipo>__<entidade>__<marca>
```

Exemplos:

```
staging__curated__school_operations__current__school__crm
staging__curated__school_operations__current__school__erp_a
```

### Exemplos completos

```
clean__crm__current__account
clean__erp_a__event__sales_order
curated__school_operations__current__school
curated__school_operations__event__order
curated__billing__timeline__contract
report__school_operations__monthly__school_delivery_metrics
```

## Colunas

### Chaves primárias e estrangeiras

- Sufixo `_id` para identificadores
- A PK usa o nome da entidade: `school_id`, `order_id`
- FKs espelham o nome da PK na tabela de origem

### Booleans

Prefixar com `is_` ou `has_`:
- `is_active`, `is_deleted`, `has_delivery`

### Datas e timestamps

- `_date` para datas (sem hora): `order_date`, `birth_date`
- `_at` para timestamps (com hora): `created_at`, `updated_at`

### Evitar

- **Abreviações obscuras**: `onb_inst_id` → `onboarding_institution_id`
- **Mistura de idiomas ou notações legadas**: `dt_nasc`, `nu_aluno` → `birth_date`, `student_number`
- **CamelCase**: `customerID` → `customer_id`
- **Repetir o nome da tabela na coluna**: em `current__user`, usar `name` e não `user_name`

### Exemplos

| Bom | Ruim | Razão |
|---|---|---|
| `customer_id`, `created_at` | `customerID`, `dateCreated` | snake_case, sufixo temporal |
| `is_active` | `active` | Prefixo boolean |
| `order_date` | `dt_pedido` | Sem abreviação legada |
| `crm_account_id` | `id_conta_crm` | Padrão origem + termo |

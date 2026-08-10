# Camadas de modelagem

A modelagem é organizada em **três camadas** com responsabilidades distintas. Cada camada se apoia na anterior e tem um propósito claro: separar "limpeza de origem" de "modelagem de entidade" de "consumo analítico" evita acoplar decisões que pertencem a níveis diferentes do pipeline.

```
raw  →  clean  →  curated  →  report
```

## Clean

Tabelas que preservam a granularidade da raw, aplicando padronização sem mudar o que cada linha representa.

- **O que faz**: renomeia colunas pro padrão da camada, padroniza tipos, aplica filtros simples (ex.: remove duplicatas, filtra registros claramente inválidos)
- **O que não faz**: não consolida fontes, não muda grão, não calcula métricas
- **Por que existe**: dá um lugar claro pra tratar problemas de origem antes de modelar. Permite que decisões de "como limpar" fiquem separadas de decisões de "como modelar".

Organização: por **sistema de origem**.

## Curated

Tabelas que representam **entidades de negócio**, seguindo a modelagem [entity-centric](entity-centric.md).

- **O que faz**: consolida múltiplas fontes da camada clean numa única entidade; aplica chaves e resolução de entidade; preserva os atributos próprios da entidade
- **Stagings**: passos intermediários (geralmente uma staging por fonte) que alimentam a tabela final da entidade. Vivem dentro da pasta da própria entidade. Quando reutilizadas por mais de uma entidade, vão pra uma pasta `staging_cross/` no domínio.
- **Por que existe**: é a fonte da verdade das entidades de negócio. É a camada estável em que o resto se apoia.

Organização: por **domínio**, com subpastas de **entidade**.

## Report

Tabelas com agregações e métricas para consumo analítico direto.

- **O que faz**: agrega, denormaliza e cruza entidades para responder perguntas específicas de negócio
- **O que não faz**: não cria entidades novas — consome curated
- **Por que existe**: ergonomia e performance pro consumidor final. É a camada onde denormalização é permitida (e às vezes desejada).

Organização: por **domínio** (sem subpastas de entidade).

---

# Organização de pastas

A organização segue uma hierarquia de **camada > domínio > entidade**, espelhando as camadas descritas acima.

```
dbt_project/
├── models/
│   ├── clean/
│   │   └── <sistema>/
│   │       └── clean__<sistema>__<tipo>__<entidade>.sql
│   │
│   ├── curated/
│   │   └── <domínio>/
│   │       ├── staging/
│   │       │   └── staging__curated__<domínio>__<tipo>__<entidade>__<marca>.sql
│   │       └── <entidade>/
│   │           └── curated__<domínio>__<tipo>__<entidade>.sql
│   │
│   └── report/
│       └── <domínio>/
│           └── report__<domínio>__<tipo>__<entidade>.sql
│
├── seeds/
│   └── <domínio>/
│       └── <seed>.csv
│
└── macros/
    ├── cross/
    │   └── <macro>.sql
    └── <camada>/
        └── <domínio>/
            └── <macro>.sql
```

## Exemplos por camada

```
clean/
├── crm/
│   └── clean__crm__current__account.sql
└── erp_a/
    └── clean__erp_a__event__sales_order.sql

curated/
└── school_operations/
    ├── school/
    │   ├── staging/
    │   │   ├── staging__curated__school_operations__current__school__crm.sql
    │   │   └── staging__curated__school_operations__current__school__erp_a.sql
    │   └── curated__school_operations__current__school.sql
    └── order/
        └── curated__school_operations__event__order.sql

report/
└── school_operations/
    └── report__school_operations__monthly__school_delivery_metrics.sql
```

Veja o detalhamento da nomenclatura dos modelos em [Nomenclatura de tabelas e colunas](nomenclatura-tabelas-colunas.md).

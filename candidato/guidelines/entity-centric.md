# Modelagem Entity-Centric

## O que é

A **Modelagem Centrada em Entidades (ECM)** organiza os dados em torno de **entidades de negócio** (Escola, Aluno, Pedido, Contrato), consolidando atributos e métricas próprios da entidade em uma estrutura unificada. Diferente da modelagem tradicional orientada a fatos, o ECM constrói camadas analíticas a partir das entidades-chave que representam coisas ou pessoas que existem ao longo do tempo.

### Comparando com star schema e snowflake

- **Star schema**: tabela fato no centro, com dimensões desnormalizadas (flat) ao redor. Cada análise gira em torno de eventos/transações.
- **Snowflake**: variação do star em que as dimensões são normalizadas em sub-tabelas (ex.: Product → Category → Department). Reduz redundância às custas de mais joins.
- **Entity-centric**: a unidade de modelagem deixa de ser o evento e passa a ser a **entidade**. Cada entidade tem sua própria tabela com atributos próprios;


## Princípio fundamental: fonte única da verdade por entidade

Em ECM, cada entidade é **dona dos seus próprios atributos**. Atributos que descrevem outra entidade **não ficam materializados na tabela** — fica apenas o **ID de ligação**. O cruzamento acontece na camada de consumo (relatórios, marts).

**Exemplo concreto.** Na tabela de Aluno, **não colocamos o nome da escola**. A tabela contém:

- Atributos do aluno: nome, data de nascimento, série, status
- IDs de ligação: `school_id`, `contract_id`

Quando alguém precisa do nome da escola junto dos dados do aluno, faz `JOIN` com a tabela de Escola na hora de montar o relatório. A tabela de Escola continua sendo a única fonte da verdade pro nome da escola.

**Por que importa:**

- **Consistência.** O nome da escola muda em um lugar só (tabela de Escola), e todas as análises refletem a mudança.
- **Sem drift.** Se materializássemos o nome da escola em várias tabelas, mais cedo ou mais tarde alguma ficaria desatualizada.
- **Ownership claro.** Cada entidade responde pelos próprios atributos. Quem quer mudar o conceito muda em um único lugar.
- **Histórico tem tratamento próprio.** Se precisamos do nome da escola **no momento em que o pedido foi feito**, modelamos a entidade com uma estrutura de histórico

**Quando faz sentido desnormalizar.** Em **camadas de consumo** (marts, reports) onde a performance ou a ergonomia compensam. Nunca no core das entidades.

## Nomes de entidades

- **Descrevem o significado no negócio**, não a origem técnica
- **Em inglês**: School, Student, Order, Contract
- **No singular**: identifique uma coisa, evite preposições e conjunções
- **Definição clara**: nenhum outro nome de entidade aparece na definição

## Granularidade

O **grão** é o nível mais baixo de detalhe representado por cada linha da tabela. Responde à pergunta: **"O que exatamente representa cada linha?"**

Exemplos:

| Entidade | Grão |
|---|---|
| School | 1 linha por `school_id` |
| Order | 1 linha por `order_id` |
| Contract | 1 linha por `contract_id` |

Quando o grão da entidade puder ser confundido (ex.: Aluno x Aluno-Matrícula), documente explicitamente e considere se são duas entidades distintas.

## Ambiguidade e resolução de entidades

A ambiguidade de entidades ocorre quando dois ou mais conceitos semelhantes são modelados como entidades distintas, mesmo representando o mesmo objeto de negócio. Geralmente acontece por diferenças de nomenclatura, fonte de dados, ou entendimento dos times.

**Exemplo.** Um mesmo pagamento pode existir no ERP financeiro (com `payment_id` próprio), no gateway de pagamento (com `transaction_id`) e no extrato bancário (com `bank_reference`). A modelagem entity-centric consolida essas fontes numa **única entidade** Pagamento, **preservando os identificadores de origem** como colunas (ex.: `erp_payment_id`, `gateway_transaction_id`, `bank_reference_id`).

## Referências

- [Maxime Beauchemin, Introducing Entity-Centric Data Modeling for Analytics (2023)](https://preset.io/blog/introducing-entity-centric-data-modeling-for-analytics/)
- [Michaël Scherding, Entity-Centric Data Modeling for Analytics (2023)](https://michael-scherding.medium.com/entity-centric-data-modeling-for-analytics-optimizing-kpis-for-effective-decision-making-6f41c36f3df0)

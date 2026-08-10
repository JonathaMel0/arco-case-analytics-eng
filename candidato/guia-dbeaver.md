# Explorando os dados com DBeaver

> Este guia é **uma das alternativas** pra explorar o `case.duckdb`. Você pode usar qualquer ferramenta que conecte ao DuckDB — CLI puro, Harlequin (TUI), notebooks Python, IDEs com suporte SQL, etc. Estamos descrevendo o DBeaver aqui porque é GUI, multiplataforma, gratuita e amplamente conhecida. **Sinta-se à vontade pra usar outra coisa se preferir.**

## Pré-requisitos

- [DBeaver Community](https://dbeaver.io/download/) instalado
- `case.duckdb` gerado (veja "Como explorar os dados" no README principal)

## Criando a conexão

1. Abra o DBeaver
2. **Database → New Database Connection** (ou ícone de tomada no canto superior esquerdo)
3. Busque por **DuckDB** na lista de drivers
4. Em **Path**, navegue até o arquivo `case.duckdb` (dentro da pasta `data/`)
5. Clique em **Test Connection** — na primeira vez, o DBeaver vai oferecer baixar o driver DuckDB. Aceite e aguarde
6. Clique em **Finish**

## Navegando

- No painel **Database Navigator** à esquerda, expanda a conexão → `case` → `main` → `Tables`
- As tabelas do case aparecem listadas
- Clique direito em qualquer tabela → **View Data** pra ver as linhas
- Pra abrir um editor SQL: menu **SQL Editor → New SQL Editor**

## Avisos práticos

- **Lock exclusivo no arquivo.** Enquanto o DBeaver estiver conectado ao `case.duckdb`, outras ferramentas (CLI puro, Harlequin) não conseguem abrir o mesmo arquivo simultaneamente. Feche outras conexões antes de abrir aqui — ou marque a conexão como read-only nas opções avançadas
- **Limites de fetch.** Pra queries grandes, use `LIMIT` no editor SQL — o DBeaver tenta materializar o resultado completo na grid de visualização

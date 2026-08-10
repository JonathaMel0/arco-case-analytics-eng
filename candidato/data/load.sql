-- =============================================================================
-- Case Técnico — Analytics Engineer
-- Script de carga: cria as tabelas e importa os CSVs no DuckDB
-- =============================================================================
--
-- Como usar:
--   1. Instale o DuckDB: https://duckdb.org/docs/installation/
--   2. Abra o terminal e execute:
--        duckdb case.duckdb < load.sql
--   3. Pronto! As tabelas estarão disponíveis no arquivo case.duckdb.
--
-- Alternativa via CLI interativo:
--   duckdb case.duckdb
--   .read load.sql
-- =============================================================================

-- ============== CRM ==============

CREATE OR REPLACE TABLE crm_user AS
SELECT * FROM read_csv_auto('crm_user.csv', header=true);

CREATE OR REPLACE TABLE crm_account AS
SELECT * FROM read_csv_auto('crm_account.csv', header=true);

CREATE OR REPLACE TABLE crm_product AS
SELECT * FROM read_csv_auto('crm_product.csv', header=true);

CREATE OR REPLACE TABLE crm_service_contract AS
SELECT * FROM read_csv_auto('crm_service_contract.csv', header=true);

CREATE OR REPLACE TABLE crm_contract_line_item AS
SELECT * FROM read_csv_auto('crm_contract_line_item.csv', header=true);

-- ============== ERP A ==============

CREATE OR REPLACE TABLE erp_a_salesperson AS
SELECT * FROM read_csv_auto('erp_a_salesperson.csv', header=true);

CREATE OR REPLACE TABLE erp_a_customer AS
SELECT * FROM read_csv_auto('erp_a_customer.csv', header=true);

CREATE OR REPLACE TABLE erp_a_sales_order AS
SELECT * FROM read_csv_auto('erp_a_sales_order.csv', header=true);

CREATE OR REPLACE TABLE erp_a_sales_order_item AS
SELECT * FROM read_csv_auto('erp_a_sales_order_item.csv', header=true);

CREATE OR REPLACE TABLE erp_a_delivery AS
SELECT * FROM read_csv_auto('erp_a_delivery.csv', header=true);

CREATE OR REPLACE TABLE erp_a_invoice AS
SELECT * FROM read_csv_auto('erp_a_invoice.csv', header=true);

-- ============== ERP B ==============

CREATE OR REPLACE TABLE erp_b_vendedor AS
SELECT * FROM read_csv_auto('erp_b_vendedor.csv', header=true);

CREATE OR REPLACE TABLE erp_b_escola AS
SELECT * FROM read_csv_auto('erp_b_escola.csv', header=true);

CREATE OR REPLACE TABLE erp_b_pedido AS
SELECT * FROM read_csv_auto('erp_b_pedido.csv', header=true);

CREATE OR REPLACE TABLE erp_b_item_pedido AS
SELECT * FROM read_csv_auto('erp_b_item_pedido.csv', header=true);

-- ============== Sistema Financeiro ==============

CREATE OR REPLACE TABLE fin_nota_fiscal AS
SELECT * FROM read_csv_auto('fin_nota_fiscal.csv', header=true);

-- ============== Sistema de Atendimento ==============

CREATE OR REPLACE TABLE support_organization AS
SELECT * FROM read_csv_auto('support_organization.csv', header=true);

CREATE OR REPLACE TABLE support_user AS
SELECT * FROM read_csv_auto('support_user.csv', header=true);

CREATE OR REPLACE TABLE support_ticket AS
SELECT * FROM read_csv_auto('support_ticket.csv', header=true);

CREATE OR REPLACE TABLE support_ticket_tag AS
SELECT * FROM read_csv_auto('support_ticket_tag.csv', header=true);

-- ============== Verificação ==============

SELECT 'crm_user' AS tabela, COUNT(*) AS linhas FROM crm_user
UNION ALL SELECT 'crm_account', COUNT(*) FROM crm_account
UNION ALL SELECT 'crm_product', COUNT(*) FROM crm_product
UNION ALL SELECT 'crm_service_contract', COUNT(*) FROM crm_service_contract
UNION ALL SELECT 'crm_contract_line_item', COUNT(*) FROM crm_contract_line_item
UNION ALL SELECT 'erp_a_salesperson', COUNT(*) FROM erp_a_salesperson
UNION ALL SELECT 'erp_a_customer', COUNT(*) FROM erp_a_customer
UNION ALL SELECT 'erp_a_sales_order', COUNT(*) FROM erp_a_sales_order
UNION ALL SELECT 'erp_a_sales_order_item', COUNT(*) FROM erp_a_sales_order_item
UNION ALL SELECT 'erp_a_delivery', COUNT(*) FROM erp_a_delivery
UNION ALL SELECT 'erp_a_invoice', COUNT(*) FROM erp_a_invoice
UNION ALL SELECT 'erp_b_vendedor', COUNT(*) FROM erp_b_vendedor
UNION ALL SELECT 'erp_b_escola', COUNT(*) FROM erp_b_escola
UNION ALL SELECT 'erp_b_pedido', COUNT(*) FROM erp_b_pedido
UNION ALL SELECT 'erp_b_item_pedido', COUNT(*) FROM erp_b_item_pedido
UNION ALL SELECT 'fin_nota_fiscal', COUNT(*) FROM fin_nota_fiscal
UNION ALL SELECT 'support_organization', COUNT(*) FROM support_organization
UNION ALL SELECT 'support_user', COUNT(*) FROM support_user
UNION ALL SELECT 'support_ticket', COUNT(*) FROM support_ticket
UNION ALL SELECT 'support_ticket_tag', COUNT(*) FROM support_ticket_tag
ORDER BY tabela;

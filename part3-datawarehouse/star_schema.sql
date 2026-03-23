-- ============================================================
-- Part 3.1 — Star Schema Design
-- ============================================================

CREATE DATABASE IF NOT EXISTS retail_dw;
USE retail_dw;

-- ============================================================
-- DIMENSION TABLE 1: dim_date
-- Stores date attributes for time-based analysis
-- ============================================================
DROP TABLE IF EXISTS dim_date;
CREATE TABLE dim_date (
    date_id     INT          NOT NULL,   -- surrogate key: YYYYMMDD format
    full_date   DATE         NOT NULL,
    day         INT          NOT NULL,
    month       INT          NOT NULL,
    month_name  VARCHAR(15)  NOT NULL,
    quarter     INT          NOT NULL,
    year        INT          NOT NULL,
    CONSTRAINT pk_dim_date PRIMARY KEY (date_id)
);

-- ============================================================
-- DIMENSION TABLE 2: dim_store
-- Stores store/location attributes
-- ============================================================
DROP TABLE IF EXISTS dim_store;
CREATE TABLE dim_store (
    store_id    VARCHAR(10)  NOT NULL,
    store_name  VARCHAR(100) NOT NULL,
    store_city  VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_dim_store PRIMARY KEY (store_id)
);

-- ============================================================
-- DIMENSION TABLE 3: dim_product
-- Stores product attributes
-- ============================================================
DROP TABLE IF EXISTS dim_product;
CREATE TABLE dim_product (
    product_id      VARCHAR(10)  NOT NULL,
    product_name    VARCHAR(100) NOT NULL,
    category        VARCHAR(50)  NOT NULL,
    unit_price      DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_dim_product PRIMARY KEY (product_id)
);

-- ============================================================
-- FACT TABLE: fact_sales
-- Central table storing measurable sales transactions
-- ============================================================
DROP TABLE IF EXISTS fact_sales;
CREATE TABLE fact_sales (
    fact_id         INT            NOT NULL AUTO_INCREMENT,
    transaction_id  VARCHAR(15)    NOT NULL,
    date_id         INT            NOT NULL,
    store_id        VARCHAR(10)    NOT NULL,
    product_id      VARCHAR(10)    NOT NULL,
    customer_id     VARCHAR(15)    NOT NULL,
    units_sold      INT            NOT NULL,
    unit_price      DECIMAL(10, 2) NOT NULL,
    total_amount    DECIMAL(12, 2) NOT NULL,   -- units_sold * unit_price
    CONSTRAINT pk_fact_sales    PRIMARY KEY (fact_id),
    CONSTRAINT fk_fact_date     FOREIGN KEY (date_id)    REFERENCES dim_date(date_id),
    CONSTRAINT fk_fact_store    FOREIGN KEY (store_id)   REFERENCES dim_store(store_id),
    CONSTRAINT fk_fact_product  FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);

-- ============================================================
-- INSERT: dim_date (covering all months in 2023)
-- ============================================================
INSERT INTO dim_date (date_id, full_date, day, month, month_name, quarter, year) VALUES
(20230115, '2023-01-15', 15, 1,  'January',   1, 2023),
(20230205, '2023-02-05',  5, 2,  'February',  1, 2023),
(20230220, '2023-02-20', 20, 2,  'February',  1, 2023),
(20230331, '2023-03-31', 31, 3,  'March',     1, 2023),
(20230428, '2023-04-28', 28, 4,  'April',     2, 2023),
(20230521, '2023-05-21', 21, 5,  'May',       2, 2023),
(20230604, '2023-06-04',  4, 6,  'June',      2, 2023),
(20230809, '2023-08-09',  9, 8,  'August',    3, 2023),
(20230815, '2023-08-15', 15, 8,  'August',    3, 2023),
(20230829, '2023-08-29', 29, 8,  'August',    3, 2023),
(20231020, '2023-10-20', 20, 10, 'October',   4, 2023),
(20231026, '2023-10-26', 26, 10, 'October',   4, 2023),
(20231118, '2023-11-18', 18, 11, 'November',  4, 2023),
(20231208, '2023-12-08',  8, 12, 'December',  4, 2023),
(20231212, '2023-12-12', 12, 12, 'December',  4, 2023);

-- ============================================================
-- INSERT: dim_store (5 stores — NULL cities corrected)
-- ============================================================
INSERT INTO dim_store (store_id, store_name, store_city) VALUES
('ST01', 'Chennai Anna',    'Chennai'),
('ST02', 'Delhi South',     'Delhi'),
('ST03', 'Bangalore MG',    'Bangalore'),
('ST04', 'Pune FC Road',    'Pune'),
('ST05', 'Mumbai Central',  'Mumbai');

-- ============================================================
-- INSERT: dim_product (16 unique products — categories standardized)
-- ============================================================
INSERT INTO dim_product (product_id, product_name, category, unit_price) VALUES
('PRD01', 'Speaker',     'Electronics', 49262.78),
('PRD02', 'Tablet',      'Electronics', 23226.12),
('PRD03', 'Phone',       'Electronics', 48703.39),
('PRD04', 'Smartwatch',  'Electronics', 58851.01),
('PRD05', 'Atta 10kg',   'Groceries',   52464.00),
('PRD06', 'Jeans',       'Clothing',     2317.47),
('PRD07', 'Biscuits',    'Groceries',   27469.99),
('PRD08', 'Jacket',      'Clothing',    30187.24),
('PRD09', 'Laptop',      'Electronics', 42343.15),
('PRD10', 'Milk 1L',     'Groceries',   43374.39),
('PRD11', 'Saree',       'Clothing',    15000.00),
('PRD12', 'Headphones',  'Electronics', 35000.00),
('PRD13', 'Pulses 1kg',  'Groceries',    8500.00),
('PRD14', 'T-Shirt',     'Clothing',     1800.00),
('PRD15', 'Rice 5kg',    'Groceries',    6500.00),
('PRD16', 'Oil 1L',      'Groceries',    4200.00);

-- ============================================================
-- INSERT: fact_sales (12 cleaned transaction rows)
-- ============================================================
INSERT INTO fact_sales (transaction_id, date_id, store_id, product_id, customer_id, units_sold, unit_price, total_amount) VALUES
('TXN5000', 20230829, 'ST01', 'PRD01', 'CUST045',  3, 49262.78,  147788.34),
('TXN5001', 20231212, 'ST01', 'PRD02', 'CUST021', 11, 23226.12,  255487.32),
('TXN5002', 20230205, 'ST01', 'PRD03', 'CUST019', 20, 48703.39,  974067.80),
('TXN5003', 20230220, 'ST02', 'PRD02', 'CUST007', 14, 23226.12,  325165.68),
('TXN5004', 20230115, 'ST01', 'PRD04', 'CUST004', 10, 58851.01,  588510.10),
('TXN5005', 20230809, 'ST03', 'PRD05', 'CUST027', 12, 52464.00,  629568.00),
('TXN5006', 20230331, 'ST04', 'PRD04', 'CUST025',  6, 58851.01,  353106.06),
('TXN5007', 20231026, 'ST04', 'PRD06', 'CUST041', 16,  2317.47,   37079.52),
('TXN5008', 20231208, 'ST03', 'PRD07', 'CUST030',  9, 27469.99,  247229.91),
('TXN5009', 20230815, 'ST03', 'PRD04', 'CUST020',  3, 58851.01,  176553.03),
('TXN5010', 20230604, 'ST01', 'PRD08', 'CUST031', 15, 30187.24,  452808.60),
('TXN5011', 20231020, 'ST05', 'PRD06', 'CUST045', 13,  2317.47,   30127.11);

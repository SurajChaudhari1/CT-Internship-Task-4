-- CodTech IT Solutions Internship - Task 4
-- Topic: Database Backup and Recovery

-- PHASE 1: Setup
CREATE SCHEMA IF NOT EXISTS task4_backup;

DROP TABLE IF EXISTS task4_backup.orders   CASCADE;
DROP TABLE IF EXISTS task4_backup.products CASCADE;
DROP TABLE IF EXISTS task4_backup.staging  CASCADE;

-- Staging Table
CREATE TABLE task4_backup.staging (
    txn_id      INT            NOT NULL,
    txn_date    DATE           NOT NULL,
    category    VARCHAR(50),
    pname       VARCHAR(150),
    qty         INT,
    unit_price  NUMERIC(10,2),
    revenue     NUMERIC(10,2),
    region      VARCHAR(30),
    payment     VARCHAR(20)
);

-- CSV Import
COPY task4_backup.staging (
    txn_id, txn_date, category, pname,
    qty, unit_price, revenue, region, payment
)
FROM 'D:\Codetech It Solution Internship\Online Sales Data.csv'
DELIMITER ','
CSV HEADER;

-- Products Table
CREATE TABLE task4_backup.products (
    pid       SERIAL         PRIMARY KEY,
    pname     VARCHAR(150)   NOT NULL,
    category  VARCHAR(50)    NOT NULL,
    price     NUMERIC(10,2)  NOT NULL
);

INSERT INTO task4_backup.products (pname, category, price)
SELECT DISTINCT pname, category, unit_price
FROM task4_backup.staging
ORDER BY pname;

-- Orders Table
CREATE TABLE task4_backup.orders (
    oid      INT            PRIMARY KEY,
    odate    DATE           NOT NULL,
    pid      INT            REFERENCES task4_backup.products(pid),
    qty      INT            NOT NULL,
    revenue  NUMERIC(10,2)  NOT NULL,
    region   VARCHAR(30)    NOT NULL,
    payment  VARCHAR(20)    NOT NULL
);

INSERT INTO task4_backup.orders (oid, odate, pid, qty, revenue, region, payment)
SELECT
    s.txn_id,
    s.txn_date,
    p.pid,
    s.qty,
    s.revenue,
    s.region,
    s.payment
FROM task4_backup.staging  AS s
INNER JOIN task4_backup.products AS p
    ON s.pname = p.pname;

-- PHASE 2: Pre-Backup Verification
-- Row count before backup
SELECT 'products' AS tbl, COUNT(*) AS rows FROM task4_backup.products
UNION ALL
SELECT 'orders',           COUNT(*)          FROM task4_backup.orders;

-- Revenue snapshot before backup
SELECT
    ROUND(SUM(revenue), 2)  AS total_revenue,
    COUNT(oid)              AS total_orders,
    MIN(odate)              AS first_order,
    MAX(odate)              AS last_order
FROM task4_backup.orders;


-- PHASE 3: Simulate Failure
DROP TABLE IF EXISTS task4_backup.orders   CASCADE;
DROP TABLE IF EXISTS task4_backup.products CASCADE;
DROP TABLE IF EXISTS task4_backup.staging  CASCADE;

-- Verify tables gone 
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'task4_backup'
  AND table_type = 'BASE TABLE';

-- RESTORE STEP (pgAdmin GUI):

-- PHASE 4: Post Recovery Verification
-- Row count after restore
SELECT 'products' AS tbl, COUNT(*) AS rows FROM task4_backup.products
UNION ALL
SELECT 'orders',           COUNT(*)          FROM task4_backup.orders;

-- Revenue verify (Phase 2 se match hona chahiye)
SELECT
    ROUND(SUM(revenue), 2)  AS total_revenue,
    COUNT(oid)              AS total_orders,
    MIN(odate)              AS first_order,
    MAX(odate)              AS last_order
FROM task4_backup.orders;

-- NULL check after restore
SELECT
    COUNT(*)                                AS total_rows,
    COUNT(*) FILTER (WHERE pid     IS NULL) AS null_pid,
    COUNT(*) FILTER (WHERE revenue IS NULL) AS null_revenue,
    COUNT(*) FILTER (WHERE region  IS NULL) AS null_region
FROM task4_backup.orders;

-- Sample data after restore
SELECT
    o.oid,
    o.odate,
    p.pname,
    p.category,
    o.revenue,
    o.region
FROM task4_backup.orders AS o
INNER JOIN task4_backup.products AS p
    ON o.pid = p.pid
ORDER BY o.odate
LIMIT 10;

-- Category summary after restore
SELECT
    p.category,
    COUNT(o.oid)    AS total_orders,
    SUM(o.revenue)  AS total_revenue
FROM task4_backup.orders AS o
INNER JOIN task4_backup.products AS p
    ON o.pid = p.pid
GROUP BY p.category
ORDER BY total_revenue DESC;
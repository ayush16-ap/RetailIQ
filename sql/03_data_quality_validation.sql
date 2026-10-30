-- ============================================================
-- RetailIQ | 03_data_quality_validation.sql
-- Purpose: Check data completeness, uniqueness, validity,
--          referential integrity, and sales calculations.
-- Run after importing data into customers, products, sales,
-- and order_items.
-- This script is READ-ONLY: it does not modify or delete data.
-- ============================================================

USE retailiq;

-- ============================================================
-- 1. ROW COUNTS
-- Expected based on the current CSV files:
-- customers = 25,000; products = 1,175;
-- sales = 138,116; order_items = 397,569.
-- ============================================================

SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sales', COUNT(*) FROM sales
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;


-- ============================================================
-- 2. PRIMARY-KEY / DUPLICATE CHECKS
-- Each query should return zero rows.
-- ============================================================

-- 2.1 Duplicate customer IDs
SELECT customer_id, COUNT(*) AS occurrences
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 2.2 Duplicate product IDs
SELECT product_id, COUNT(*) AS occurrences
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- 2.3 Duplicate sales order IDs
SELECT order_id, COUNT(*) AS occurrences
FROM sales
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Note: Repeated (order_id, product_id) pairs are present in the
-- source data. Do not delete them automatically. They may represent
-- separate line items. Review them rather than treating them as
-- exact duplicate rows.
SELECT order_id, product_id, COUNT(*) AS occurrences
FROM order_items
GROUP BY order_id, product_id
HAVING COUNT(*) > 1
LIMIT 100;


-- ============================================================
-- 3. NULL / MISSING VALUE CHECKS
-- These counts help identify incomplete records.
-- NULLs are not necessarily errors in every column.
-- ============================================================

SELECT
    SUM(customer_id IS NULL OR TRIM(customer_id) = '') AS missing_customer_id,
    SUM(customer_name IS NULL OR TRIM(customer_name) = '') AS missing_customer_name,
    SUM(customer_age IS NULL) AS missing_customer_age,
    SUM(gender IS NULL OR TRIM(gender) = '') AS missing_gender,
    SUM(customer_city IS NULL OR TRIM(customer_city) = '') AS missing_customer_city,
    SUM(customer_state IS NULL OR TRIM(customer_state) = '') AS missing_customer_state,
    SUM(customer_country IS NULL OR TRIM(customer_country) = '') AS missing_customer_country
FROM customers;

SELECT
    SUM(product_id IS NULL OR TRIM(product_id) = '') AS missing_product_id,
    SUM(product_name IS NULL OR TRIM(product_name) = '') AS missing_product_name,
    SUM(product_category IS NULL OR TRIM(product_category) = '') AS missing_product_category,
    SUM(unit_price IS NULL) AS missing_unit_price,
    SUM(product_cost IS NULL) AS missing_product_cost
FROM products;

SELECT
    SUM(order_id IS NULL OR TRIM(order_id) = '') AS missing_order_id,
    SUM(order_date IS NULL) AS missing_order_date,
    SUM(customer_id IS NULL OR TRIM(customer_id) = '') AS missing_customer_id,
    SUM(order_status IS NULL OR TRIM(order_status) = '') AS missing_order_status
FROM sales;

SELECT
    SUM(order_id IS NULL OR TRIM(order_id) = '') AS missing_order_id,
    SUM(product_id IS NULL OR TRIM(product_id) = '') AS missing_product_id,
    SUM(quantity IS NULL) AS missing_quantity,
    SUM(unit_price IS NULL) AS missing_unit_price,
    SUM(gross_sales IS NULL) AS missing_gross_sales,
    SUM(net_sales IS NULL) AS missing_net_sales,
    SUM(profit IS NULL) AS missing_profit
FROM order_items;


-- ============================================================
-- 4. VALUE-RANGE / BUSINESS-RULE VALIDATION
-- Each query should ideally return zero rows. Review exceptions
-- before changing any data.
-- ============================================================

-- 4.1 Customer ages outside a plausible range
SELECT customer_id, customer_age
FROM customers
WHERE customer_age IS NOT NULL
  AND (customer_age < 0 OR customer_age > 120)
LIMIT 100;

-- 4.2 Negative product prices or costs
SELECT product_id, unit_price, product_cost
FROM products
WHERE unit_price < 0 OR product_cost < 0
LIMIT 100;

-- 4.3 Invalid sales dates or required IDs
SELECT order_id, order_date, customer_id
FROM sales
WHERE order_date IS NULL
   OR customer_id IS NULL
   OR TRIM(customer_id) = ''
LIMIT 100;

-- 4.4 Invalid quantities or negative item financial values
SELECT order_id, product_id, quantity, unit_price,
       discount_amount, gross_sales, tax_amount,
       shipping_cost, net_sales, product_cost, profit
FROM order_items
WHERE quantity IS NULL OR quantity <= 0
   OR unit_price < 0
   OR discount_amount < 0
   OR gross_sales < 0
   OR tax_amount < 0
   OR shipping_cost < 0
   OR net_sales < 0
   OR product_cost < 0
LIMIT 100;

-- 4.5 Discount percentage is stored as a fraction (e.g. 0.10 = 10%).
-- Based on the source CSV, the expected range is 0 to 0.60.
SELECT order_id, product_id, discount_percentage
FROM order_items
WHERE discount_percentage IS NULL
   OR discount_percentage < 0
   OR discount_percentage > 0.60
LIMIT 100;


-- ============================================================
-- 5. REFERENTIAL-INTEGRITY CHECKS
-- Each count should be zero.
-- ============================================================

-- Order items whose order does not exist in sales
SELECT COUNT(*) AS missing_orders
FROM order_items oi
LEFT JOIN sales s ON oi.order_id = s.order_id
WHERE s.order_id IS NULL;

-- Order items whose product does not exist in products
SELECT COUNT(*) AS missing_products
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Sales whose customer does not exist in customers
SELECT COUNT(*) AS missing_customers
FROM sales s
LEFT JOIN customers c ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- ============================================================
-- 6. SALES-CALCULATION CONSISTENCY
-- Investigate differences; do not assume every difference is an error.
-- ============================================================

-- 6.1 Compare gross_sales with expected_gross_sales.
-- A small tolerance is used for decimal/rounding differences.
SELECT
    order_id,
    product_id,
    gross_sales,
    expected_gross_sales,
    gross_sales_difference
FROM order_items
WHERE expected_gross_sales IS NOT NULL
  AND ABS(gross_sales - expected_gross_sales) > 0.02
LIMIT 100;

-- 6.2 Check stored difference against calculated difference.
SELECT
    order_id,
    product_id,
    gross_sales,
    expected_gross_sales,
    gross_sales_difference,
    gross_sales - expected_gross_sales AS calculated_difference
FROM order_items
WHERE expected_gross_sales IS NOT NULL
  AND gross_sales_difference IS NOT NULL
  AND ABS(gross_sales_difference - (gross_sales - expected_gross_sales)) > 0.02
LIMIT 100;

-- 6.3 Summary of profit and sales values (descriptive, not a pass/fail test)
SELECT
    COUNT(*) AS item_rows,
    SUM(gross_sales) AS total_gross_sales,
    SUM(net_sales) AS total_net_sales,
    SUM(profit) AS total_profit,
    SUM(quantity) AS total_quantity
FROM order_items;


-- ============================================================
-- 7. REVIEW POSSIBLE CROSS-TABLE PRICE DIFFERENCES
-- These are review queries, not automatic error checks:
-- product catalogue prices can differ from historical order prices.
-- ============================================================

SELECT
    oi.product_id,
    p.unit_price AS current_catalogue_price,
    oi.unit_price AS order_item_price,
    COUNT(*) AS affected_rows
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE ABS(oi.unit_price - p.unit_price) > 0.02
GROUP BY oi.product_id, p.unit_price, oi.unit_price
ORDER BY affected_rows DESC
LIMIT 100;


-- ============================================================
-- 8. FINAL VALIDATION SUMMARY
-- Quick totals and orphan-reference counts for a final review.
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM customers) AS customers_rows,
    (SELECT COUNT(*) FROM products) AS products_rows,
    (SELECT COUNT(*) FROM sales) AS sales_rows,
    (SELECT COUNT(*) FROM order_items) AS order_items_rows,
    (SELECT COUNT(*)
       FROM order_items oi
       LEFT JOIN sales s ON oi.order_id = s.order_id
      WHERE s.order_id IS NULL) AS order_items_without_sales,
    (SELECT COUNT(*)
       FROM order_items oi
       LEFT JOIN products p ON oi.product_id = p.product_id
      WHERE p.product_id IS NULL) AS order_items_without_products,
    (SELECT COUNT(*)
       FROM sales s
       LEFT JOIN customers c ON s.customer_id = c.customer_id
      WHERE c.customer_id IS NULL) AS sales_without_customers;
      
SELECT
    (SELECT COUNT(*) FROM customers) AS customers_rows,
    (SELECT COUNT(*) FROM products) AS products_rows,
    (SELECT COUNT(*) FROM sales) AS sales_rows,
    (SELECT COUNT(*) FROM order_items) AS order_items_rows;
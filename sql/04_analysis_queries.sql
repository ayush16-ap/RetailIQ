-- ============================================================
-- RetailIQ | 04_analysis_queries.sql
-- Purpose: Answer business questions using the imported,
-- validated RetailIQ tables.
-- Database: MySQL 8+
-- This file contains SELECT queries only; it does not modify data.
-- ============================================================

USE retailiq;


-- ============================================================
-- 1. BUSINESS OVERVIEW / KPI SUMMARY
-- Order-level metrics come from sales.
-- Item-level metrics come from order_items.
-- Keep these separate to avoid double-counting orders.
-- ============================================================

-- 1.1 Order-level overview
SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers_with_orders,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS latest_order_date,
    SUM(order_status = 'Cancelled') AS cancelled_orders,
    SUM(order_status = 'Delivered') AS delivered_orders
FROM sales;

-- 1.2 Item-level sales and profit overview
SELECT
    COUNT(*) AS order_item_rows,
    SUM(quantity) AS units_sold,
    ROUND(SUM(gross_sales), 2) AS total_gross_sales,
    ROUND(SUM(discount_amount), 2) AS total_discount_amount,
    ROUND(SUM(net_sales), 2) AS total_net_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100 * SUM(profit) / NULLIF(SUM(net_sales), 0), 2) AS profit_margin_pct
FROM order_items;


-- ============================================================
-- 2. MONTHLY SALES TRENDS
-- ============================================================

SELECT
    DATE_FORMAT(s.order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT s.order_id) AS total_orders,
    COUNT(DISTINCT s.customer_id) AS unique_customers,
    ROUND(SUM(oi.net_sales), 2) AS net_sales,
    ROUND(SUM(oi.profit), 2) AS total_profit,
    SUM(oi.quantity) AS units_sold
FROM sales s
JOIN order_items oi ON oi.order_id = s.order_id
WHERE s.order_date IS NOT NULL
GROUP BY DATE_FORMAT(s.order_date, '%Y-%m')
ORDER BY order_month;


-- ============================================================
-- 3. PRODUCT AND CATEGORY PERFORMANCE
-- ============================================================

-- 3.1 Category performance
SELECT
    p.product_category,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS order_item_rows,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.net_sales), 2) AS net_sales,
    ROUND(SUM(oi.profit), 2) AS total_profit,
    ROUND(100 * SUM(oi.profit) / NULLIF(SUM(oi.net_sales), 0), 2) AS profit_margin_pct
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_category
ORDER BY net_sales DESC;

-- 3.2 Top 20 products by net sales
SELECT
    p.product_id,
    p.product_name,
    p.product_category,
    p.brand,
    SUM(oi.quantity) AS units_sold,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.net_sales), 2) AS net_sales,
    ROUND(SUM(oi.profit), 2) AS total_profit
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.product_category, p.brand
ORDER BY net_sales DESC
LIMIT 20;

-- 3.3 Products with the lowest total profit (only products with sales)
SELECT
    p.product_id,
    p.product_name,
    p.product_category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.net_sales), 2) AS net_sales,
    ROUND(SUM(oi.profit), 2) AS total_profit
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.product_category
ORDER BY total_profit ASC
LIMIT 20;


-- ============================================================
-- 4. CUSTOMER ANALYSIS
-- Use sales for order/customer metrics to avoid multiplying
-- order-level values by the number of order-item rows.
-- ============================================================

-- 4.1 Customer segment overview
SELECT
    c.customer_segment,
    COUNT(DISTINCT c.customer_id) AS customers_in_segment,
    COUNT(s.order_id) AS orders,
    ROUND(AVG(s.customer_lifetime_value), 2) AS avg_customer_lifetime_value,
    SUM(s.is_repeat_customer IN ('1', 'true', 'TRUE')) AS repeat_customer_order_rows
FROM customers c
LEFT JOIN sales s ON s.customer_id = c.customer_id
GROUP BY c.customer_segment
ORDER BY orders DESC;

-- 4.2 Top 20 customers by number of orders
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    c.customer_city,
    COUNT(s.order_id) AS total_orders,
    ROUND(AVG(s.customer_lifetime_value), 2) AS avg_recorded_lifetime_value,
    MAX(s.order_date) AS latest_order_date
FROM customers c
JOIN sales s ON s.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_segment, c.customer_city
ORDER BY total_orders DESC, latest_order_date DESC
LIMIT 20;

-- 4.3 Customer geography
SELECT
    c.region,
    c.customer_state,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(s.order_id) AS orders
FROM customers c
LEFT JOIN sales s ON s.customer_id = c.customer_id
GROUP BY c.region, c.customer_state
ORDER BY orders DESC
LIMIT 50;


-- ============================================================
-- 5. SALES CHANNEL AND PAYMENT ANALYSIS
-- ============================================================

SELECT
    s.sales_channel,
    COUNT(DISTINCT s.customer_id) AS customers,
    ROUND(SUM(oi.net_sales), 2) AS net_sales,
    ROUND(SUM(oi.profit), 2) AS total_profit
FROM sales s
JOIN order_items oi ON oi.order_id = s.order_id
GROUP BY s.sales_channel
ORDER BY net_sales DESC;

SELECT
    payment_method,
    payment_status,
    COUNT(*) AS orders
FROM sales
GROUP BY payment_method, payment_status
ORDER BY orders DESC;


-- ============================================================
-- 6. DISCOUNTS AND PROFITABILITY
-- discount_percentage is stored as a fraction:
-- 0.10 means 10%, not 0.10%.
-- ============================================================

SELECT
    CASE
        WHEN discount_percentage = 0 THEN 'No discount'
        WHEN discount_percentage <= 0.10 THEN '0%–10%'
        WHEN discount_percentage <= 0.20 THEN '10%–20%'
        WHEN discount_percentage <= 0.30 THEN '20%–30%'
        ELSE '30%+'
    END AS discount_band,
    COUNT(*) AS order_item_rows,
    SUM(quantity) AS units_sold,
    ROUND(SUM(net_sales), 2) AS net_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100 * SUM(profit) / NULLIF(SUM(net_sales), 0), 2) AS profit_margin_pct
FROM order_items
GROUP BY discount_band
ORDER BY MIN(discount_percentage);


-- ============================================================
-- 7. DELIVERY AND RETURNS
-- ============================================================

SELECT
    delivery_status,
    COUNT(*) AS orders,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    ROUND(AVG(estimated_delivery_days), 2) AS avg_estimated_days
FROM sales
GROUP BY delivery_status
ORDER BY orders DESC;

SELECT
    return_status,
    return_reason,
    COUNT(*) AS orders
FROM sales
WHERE return_status IS NOT NULL
  AND TRIM(return_status) <> ''
GROUP BY return_status, return_reason
ORDER BY orders DESC
LIMIT 50;


-- ============================================================
-- 8. RATINGS AND MARKETING
-- ============================================================

SELECT
    review_sentiment,
    COUNT(*) AS orders_with_sentiment,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating
FROM sales
GROUP BY review_sentiment
ORDER BY orders_with_sentiment DESC;

SELECT
    marketing_channel,
    COUNT(*) AS orders,
    COUNT(DISTINCT customer_id) AS customers
FROM sales
GROUP BY marketing_channel
ORDER BY orders DESC;

SELECT
    campaign_name,
    COUNT(*) AS orders,
    COUNT(DISTINCT customer_id) AS customers,
    SUM(coupon_code IS NOT NULL AND TRIM(coupon_code) <> '') AS orders_with_coupon
FROM sales
GROUP BY campaign_name
ORDER BY orders DESC
LIMIT 50;


-- ============================================================
-- 9. SAVE KEY OUTPUTS FOR REPORTING
-- Run the relevant queries above and record the results/insights.
-- Do not interpret correlation as proof of causation.
-- ============================================================

-- 1. Check total rows
SELECT COUNT(*) AS total_order_items
FROM order_items;

-- 2. Check duplicate order-product combinations
SELECT order_id, product_id, COUNT(*) AS occurrences
FROM order_items
GROUP BY order_id, product_id
HAVING COUNT(*) > 1
LIMIT 10;

-- 3. Check missing order references
SELECT COUNT(*) AS missing_orders
FROM order_items oi
LEFT JOIN sales s ON oi.order_id = s.order_id
WHERE s.order_id IS NULL;

-- 4. Check missing product references
SELECT COUNT(*) AS missing_products
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT COUNT(*) AS missing_customer_ids
FROM stg_customers
WHERE customer_id IS NULL
   OR TRIM(customer_id) = '';
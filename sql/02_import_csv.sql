USE retailiq;
SELECT COUNT(*) AS customers_rows FROM stg_customers;
SELECT COUNT(*) AS products_rows FROM stg_products;
SELECT COUNT(*) AS sales_rows FROM stg_sales;
SELECT COUNT(*) AS order_items_rows FROM stg_order_items;

DESCRIBE stg_customers;
DESCRIBE stg_products;
DESCRIBE stg_sales;
DESCRIBE stg_order_items;

SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sales', COUNT(*) FROM sales
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;

DESCRIBE stg_customers;
DESCRIBE customers;

INSERT INTO customers (
    customer_id,
    customer_name,
    customer_age,
    age_range,
    gender,
    customer_segment,
    customer_city,
    customer_state,
    customer_country,
    region,
    customer_postal_code,
    customer_acquisition_cost
)
SELECT
    NULLIF(customer_id, ''),
    NULLIF(customer_name, ''),
    CAST(NULLIF(customer_age, '') AS UNSIGNED),
    NULLIF(age_range, ''),
    NULLIF(gender, ''),
    NULLIF(customer_segment, ''),
    NULLIF(customer_city, ''),
    NULLIF(customer_state, ''),
    NULLIF(customer_country, ''),
    NULLIF(region, ''),
    NULLIF(customer_postal_code, ''),
    CAST(NULLIF(customer_acquisition_cost, '') AS DECIMAL(14,2))
FROM stg_customers;

SELECT COUNT(*) AS customers_loaded
FROM customers;

INSERT INTO products (
    product_id,
    product_name,
    product_category,
    product_subcategory,
    brand,
    supplier,
    unit_price,
    product_cost,
    product_rating,
    price_cost_difference
)
SELECT
    NULLIF(product_id, ''),
    NULLIF(product_name, ''),
    NULLIF(product_category, ''),
    NULLIF(product_subcategory, ''),
    NULLIF(brand, ''),
    NULLIF(supplier, ''),
    CAST(NULLIF(unit_price, '') AS DECIMAL(14,2)),
    CAST(NULLIF(product_cost, '') AS DECIMAL(14,2)),
    CAST(NULLIF(product_rating, '') AS DECIMAL(4,2)),
    CAST(NULLIF(price_cost_difference, '') AS DECIMAL(14,2))
FROM stg_products;

SELECT COUNT(*) AS products_loaded
FROM products;


DESCRIBE stg_sales;
DESCRIBE sales;

SELECT
    order_id,
    order_date,
    customer_id,
    delivery_days,
    is_repeat_customer,
    customer_lifetime_value
FROM stg_sales
LIMIT 5;

USE retailiq;

USE retailiq;

INSERT INTO sales (
    order_id,
    order_date,
    order_status,
    sales_channel,
    customer_id,
    payment_method,
    payment_status,
    currency,
    shipping_method,
    warehouse,
    delivery_days,
    estimated_delivery_days,
    delivery_status,
    return_status,
    return_reason,
    rating,
    customer_rating,
    review_sentiment,
    marketing_channel,
    campaign_name,
    coupon_code,
    loyalty_points_earned,
    loyalty_points_redeemed,
    customer_lifetime_value,
    is_repeat_customer,
    customer_order_count
)
SELECT
    NULLIF(TRIM(order_id), ''),
    STR_TO_DATE(NULLIF(TRIM(order_date), ''), '%Y-%m-%d'),
    NULLIF(TRIM(order_status), ''),
    NULLIF(TRIM(sales_channel), ''),
    NULLIF(TRIM(customer_id), ''),
    NULLIF(TRIM(payment_method), ''),
    NULLIF(TRIM(payment_status), ''),
    NULLIF(TRIM(currency), ''),
    NULLIF(TRIM(shipping_method), ''),
    NULLIF(TRIM(warehouse), ''),

    CAST(CAST(NULLIF(TRIM(delivery_days), '') AS DECIMAL(10,2)) AS UNSIGNED),
    CAST(CAST(NULLIF(TRIM(estimated_delivery_days), '') AS DECIMAL(10,2)) AS UNSIGNED),

    NULLIF(TRIM(delivery_status), ''),
    NULLIF(TRIM(return_status), ''),
    NULLIF(TRIM(return_reason), ''),

    CAST(NULLIF(TRIM(rating), '') AS DECIMAL(4,2)),
    CAST(NULLIF(TRIM(customer_rating), '') AS DECIMAL(4,2)),

    NULLIF(TRIM(review_sentiment), ''),
    NULLIF(TRIM(marketing_channel), ''),
    NULLIF(TRIM(campaign_name), ''),
    NULLIF(TRIM(coupon_code), ''),

    CAST(CAST(NULLIF(TRIM(loyalty_points_earned), '') AS DECIMAL(10,2)) AS UNSIGNED),
    CAST(CAST(NULLIF(TRIM(loyalty_points_redeemed), '') AS DECIMAL(10,2)) AS UNSIGNED),

    CAST(NULLIF(TRIM(customer_lifetime_value), '') AS DECIMAL(14,2)),

    CASE
        WHEN LOWER(TRIM(is_repeat_customer)) = 'true' THEN 1
        WHEN LOWER(TRIM(is_repeat_customer)) = 'false' THEN 0
        WHEN TRIM(is_repeat_customer) = '1' THEN 1
        WHEN TRIM(is_repeat_customer) = '0' THEN 0
        ELSE NULL
    END,
    CAST(CAST(NULLIF(TRIM(customer_order_count), '') AS DECIMAL(10,2)) AS UNSIGNED)
FROM stg_sales;

SHOW CREATE TABLE order_items;
SHOW COLUMNS FROM order_items LIKE 'order_item_id';
ALTER TABLE order_items
DROP PRIMARY KEY,
ADD COLUMN order_item_id BIGINT NOT NULL AUTO_INCREMENT,
ADD PRIMARY KEY (order_item_id);
SELECT COUNT(*) AS existing_rows
FROM order_items;


INSERT INTO order_items (
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_percentage,
    discount_amount,
    gross_sales,
    tax_amount,
    shipping_cost,
    net_sales,
    product_cost,
    profit,
    expected_gross_sales,
    gross_sales_difference
)
SELECT
    TRIM(order_id),
    TRIM(product_id),
    CAST(quantity AS UNSIGNED),
    CAST(unit_price AS DECIMAL(14,2)),
    CAST(discount_percentage AS DECIMAL(9,6)),
    CAST(discount_amount AS DECIMAL(14,2)),
    CAST(gross_sales AS DECIMAL(14,2)),
    CAST(tax_amount AS DECIMAL(14,2)),
    CAST(shipping_cost AS DECIMAL(14,2)),
    CAST(net_sales AS DECIMAL(14,2)),
    CAST(product_cost AS DECIMAL(14,2)),
    CAST(profit AS DECIMAL(14,2)),
    CAST(expected_gross_sales AS DECIMAL(14,2)),
    CAST(gross_sales_difference AS DECIMAL(14,6))
FROM stg_order_items;

select * from customers;
select * from order_items;
select * from products;
select * from sales;
CREATE DATABASE IF NOT EXISTS retailiq;
USE retailiq;

CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(255),
    customer_age INT,
    age_range VARCHAR(50),
    gender VARCHAR(30),
    customer_type VARCHAR(15),
    customer_segment VARCHAR(100),
    customer_city VARCHAR(100),
    customer_state VARCHAR(100),
    customer_country VARCHAR(100),
    region VARCHAR(100),
    customer_postal_code INT,
    customer_acquisition_cost DECIMAL(14,2)
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255),
    product_category VARCHAR(150),
    product_subcategory VARCHAR(150),
    brand VARCHAR(150),
    supplier VARCHAR(150),
    unit_price DECIMAL(10,2),
    product_cost DECIMAL(14,2),
    product_rating DECIMAL(10,1)
) ENGINE=InnoDB;

CREATE TABLE sales (
    order_id VARCHAR(50) PRIMARY KEY,
    order_date DATE,
    order_status VARCHAR(50),
    sales_channel VARCHAR(100),
    customer_id VARCHAR(50) NOT NULL,
    payment_method VARCHAR(100),
    payment_status VARCHAR(50),
    currency VARCHAR(10),
    shipping_method VARCHAR(100),
    warehouse VARCHAR(100),
    delivery_days INT,
    estimated_delivery_days INT,
    delivery_status VARCHAR(50),
    return_status VARCHAR(50),
    return_reason TEXT,
    rating INT,
    customer_rating float,
    review_sentiment VARCHAR(50),
    marketing_channel VARCHAR(100),
    campaign_name VARCHAR(150),
    coupon_code VARCHAR(100),
    loyalty_points_earned INT,
    loyalty_points_redeemed INT,
    customer_lifetime_value DECIMAL(14,2),
    is_repeat_customer VARCHAR(10),
    customer_order_count INT,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
) ENGINE=InnoDB;


CREATE TABLE order_items (
    order_id VARCHAR(50) NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    quantity INT,
    unit_price DECIMAL(14,2),
    discount_percentage DECIMAL(9,6),
    discount_amount DECIMAL(14,2),
    gross_sales DECIMAL(14,2),
    tax_amount DECIMAL(14,2),
    shipping_cost DECIMAL(14,2),
    net_sales DECIMAL(14,2),
    product_cost DECIMAL(14,2),
    profit DECIMAL(14,2),

    PRIMARY KEY (order_id),

    CONSTRAINT fk_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
) ENGINE=InnoDB;

SHOW TABLES;
USE retailiq;

ALTER TABLE order_items
ADD COLUMN expected_gross_sales DECIMAL(14,2),
ADD COLUMN gross_sales_difference DECIMAL(14,6);

ALTER TABLE products
ADD COLUMN price_cost_difference DECIMAL(14,2);

DESCRIBE sales;
DESCRIBE order_items;
DESCRIBE products;
DESCRIBE customers;

select * from customers;
select * from products;
select * from order_items;
select * from sales;

SELECT COUNT(*) 
FROM order_items;
SELECT COUNT(*) 
FROM customers;
SELECT COUNT(*) 
FROM products;
SELECT COUNT(*) 
FROM sales;

SET SQL_SAFE_UPDATES = 0;
SET GLOBAL local_infile = 1;

delete from order_items;
delete from sales;
delete from customers;
delete from products;

Drop table customers;
Drop table order_items;
Drop table products;
Drop table sales;

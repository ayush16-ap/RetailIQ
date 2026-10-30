USE retailiq;

-- 1. Find the 10 most expensive products.
select product_name,unit_price 
from products
order by unit_price desc
limit 10;

-- 2. Count products in each product_category
select product_category,count(product_id) 
from products
group by product_category
order by count(product_id) desc;

-- 3. Find the average, minimum and maximum product price  
select avg(unit_price),min(unit_price),max(unit_price)
from products;

-- 4. Count orders by order_status.
select order_status,count(order_id)
from sales
group by order_status
order by count(order_id) desc;

-- 5. Find total quantity sold across all order items.
select sum(quantity) 
from order_items;

-- 6. Find the top 10 customers by customer_acquisition_cost.
select customer_name,customer_acquisition_cost
from customers
order by customer_acquisition_cost desc
limit 10;

-- 7. List orders placed between two dates of your choice.
select * 
from sales
where order_date between '2022-09-16' and '2022-12-31';

-- 8. Count customers in each region.
select region, count(customer_id) 
from customers
group by region
order by count(customer_id) desc;

-- 9. Find all products with product_rating greater than 4.
select product_name, product_rating
from products
where product_rating>4;

-- 10. Calculate total gross_sales, net_sales and profit from order_items.
select sum(gross_sales),sum(net_sales),sum(profit)
from order_items;

-- 2. Intermediate SQL

-- 1. Find the top 10 product categories by total net sales.
select product_category,sum(net_sales)
from products join order_items
on products.product_id = order_items.product_id
group by product_category
order by sum(net_sales) desc
limit 10;

-- 2. Calculate monthly order counts and monthly net sales.
SELECT
    DATE_FORMAT(s.order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT s.order_id) AS total_orders,
    ROUND(SUM(oi.net_sales), 2) AS monthly_net_sales
FROM sales s
JOIN order_items oi
    ON s.order_id = oi.order_id
WHERE s.order_date IS NOT NULL
GROUP BY DATE_FORMAT(s.order_date, '%Y-%m')
ORDER BY order_month;

-- 3. Find the 20 products generating the highest total profit.
select p.product_id,p.product_name,sum(o.profit) as total_profit
from products p join order_items o
on p.product_id = o.product_id
group by p.product_id,p.product_name
order by sum(o.profit) desc
limit 20;

-- 4. Find customers who have placed more than 5 orders.
select c.customer_id,c.customer_name,count(s.order_id) as total_orders
from customers c join sales s
on c.customer_id = s.customer_id
group by c.customer_id,c.customer_name
having count(s.order_id)>5
order by total_orders desc
limit 20;

-- 5. Calculate the percentage of orders in each order_status.
with my_cte as (
	select count(order_id) as total_orders from sales
)
select s.order_status,
count(s.order_id) AS status_orders,
	ROUND(
		COUNT(s.order_id) * 100.0 / ct.total_orders,
		2
	) AS percentage
from sales s cross join my_cte ct
group by s.order_status, ct.total_orders
order by status_orders desc;

-- 6. Compare average delivery_days with estimated_delivery_days by delivery_status.
select delivery_status,avg(delivery_days),avg(estimated_delivery_days)
from sales
group by delivery_status
order by avg(delivery_days) desc;

-- 7. Find the most frequently used payment_method.
select payment_method,count(payment_method) 
from sales
group by payment_method
order by count(payment_method) desc;

-- 8. Calculate average customer_lifetime_value by customer_segment.
select c.customer_segment,avg(s.customer_lifetime_value)
from customers c join sales s
on c.customer_id=s.customer_id
group by c.customer_segment
order by avg(s.customer_lifetime_value) desc;

-- 9. Find products that have never appeared in order_items.
select p.product_id,p.product_name, count(o.order_id) as total_order
from products p left join order_items o
on p.product_id=o.product_id
where o.order_id is NULL
group by p.product_id,p.product_name
order by count(o.order_id) desc;

-- 10. Find customers who have no orders in sales.
select c.customer_id,c.customer_name, count(s.order_id) as total_order
from customers c left join sales s
on c.customer_id=s.customer_id
where s.order_id is NULL
group by c.customer_id,c.customer_name
order by count(s.order_id) desc;



-- 11. Calculate profit margin percentage for each product category.
SELECT p.product_category,
    ROUND(
        SUM(o.profit) / NULLIF(SUM(o.net_sales), 0) * 100,
        2
    ) AS profit_margin_percentage
FROM products p join order_items o
on p.product_id=o.product_id
group by p.product_category
order by profit_margin_percentage desc;



-- 12. Compare total sales across sales_channel values.
select s.sales_channel, sum(o.gross_sales) as total_sales
from sales s join order_items o
on s.order_id = o.order_id
group by s.sales_channel
order by sum(o.gross_sales) desc;


-- 3. Advanced SQL

-- 1. Rank products by profit within each product_category using a window function.
select p.product_id, p.product_category, sum(o.profit) as total_profit,
rank() over(partition by p.product_category order by sum(o.profit) desc) 
as product_rank
from products p join order_items o
on p.product_id=o.product_id
group by product_id,product_category;

-- 2. Find each customer's first and most recent order date.
select c.customer_id, c.customer_name, 
       min(s.order_date) as first_order, max(s.order_date) as latest_order
from customers c join sales s
on c.customer_id=s.customer_id
group by c.customer_id, c.customer_name
order by first_order; 

-- Approach 1: Using subqueries and JOIN
-- SELECT
--     c.customer_id,
--     c.customer_name,
--     first_orders.order_id AS first_order_id,
--     first_orders.order_date AS first_order_date,
--     last_orders.order_id AS last_order_id,
--     last_orders.order_date AS last_order_date
-- FROM customers c

-- JOIN sales first_orders
--     ON first_orders.customer_id = c.customer_id
--     AND first_orders.order_date = (
--         SELECT MIN(s1.order_date)
--         FROM sales s1
--         WHERE s1.customer_id = c.customer_id
--     )

-- JOIN sales last_orders
--     ON last_orders.customer_id = c.customer_id
--     AND last_orders.order_date = (
--         SELECT MAX(s2.order_date)
--         FROM sales s2
--         WHERE s2.customer_id = c.customer_id
--     )

-- ORDER BY first_order_date;


-- Approach 2: Using window functions (ROW_NUMBER())
-- WITH ranked_orders AS (
--     SELECT
--         customer_id,
--         order_id,
--         order_date,

--         ROW_NUMBER() OVER (
--             PARTITION BY customer_id
--             ORDER BY order_date ASC, order_id ASC
--         ) AS first_rank,

--         ROW_NUMBER() OVER (
--             PARTITION BY customer_id
--             ORDER BY order_date DESC, order_id DESC
--         ) AS last_rank

--     FROM sales
--     WHERE order_date IS NOT NULL
-- )

-- SELECT
--     c.customer_id,
--     c.customer_name,
--     f.order_id AS first_order_id,
--     f.order_date AS first_order_date,
--     l.order_id AS last_order_id,
--     l.order_date AS last_order_date

-- FROM customers c

-- JOIN ranked_orders f
--     ON c.customer_id = f.customer_id
--     AND f.first_rank = 1

-- JOIN ranked_orders l
--     ON c.customer_id = l.customer_id
--     AND l.last_rank = 1

-- ORDER BY first_order_date;

-- 3. Calculate month-over-month net sales growth.
with monthly_sales as (
select DATE_FORMAT(s.order_date, '%Y-%m') AS order_month,
sum(o.net_sales) as total_net_sales
from sales s join order_items o
on s.order_id= o.order_id
where s.order_date IS NOT NULL
group by DATE_FORMAT(s.order_date, '%Y-%m')
)
SELECT
    order_month,
    total_net_sales,
    LAG(total_net_sales) OVER (
        ORDER BY order_month
    ) AS previous_month_sales
FROM monthly_sales
ORDER BY order_month;

-- 4. Find the top 3 products by net sales within each category.
with total_s as (
select p.product_id,p.product_name,p.product_category,
sum(o.net_sales) as total_sales
from products p join order_items o
on p.product_id	= o.product_id
group by p.product_id,p.product_name,p.product_category 
) , ranked_products AS 

(select product_id,product_name,product_category,total_sales,
rank() over(partition by product_category order by total_sales desc) 
as product_rank
from total_s
)
SELECT
    product_id,
    product_name,
    product_category,
    ROUND(total_sales, 2) AS total_sales,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY product_category, product_rank;

-- 5. Create customer order-frequency groups: 1 order, 2–5 orders, and more than 5 orders.
with customer_orders as (
select c.customer_id as cust_id ,c.customer_name as cust_name , 
count(s.order_id) as total_order
from customers c join sales s
on c.customer_id=s.customer_id
group by c.customer_id,c.customer_name
)
select cust_id,cust_name, 
case when total_order=1 then '1'
	 when total_order BETWEEN 2 AND 5 then '2-5'
     when total_order >5 then 'more than 5'
     end as order_frequency
from customer_orders
order by order_frequency;

-- 6. Calculate each category's percentage contribution to total net sales.
with sum_net as (
select sum(net_sales) as total_net_sales
from order_items
),
sum_category_net as (
select p.product_category as prod_cat ,sum(o.net_sales) as cat_net_Sales
from products p cross join order_items o
on p.product_id=o.product_id
group by p.product_category
)
select prod_cat,cat_net_sales,cat_net_sales*100/total_net_sales as perct_contri
from sum_net join sum_category_net
order by perct_contri desc;

-- 7. Find orders whose total item-level net sales exceed the 90th percentile of order totals.
with total_order as (
select order_id, sum(net_sales) AS total_net_sales
from order_items
group by order_id
), ranked_orders as (
select order_id,total_net_sales,
ROW_NUMBER() OVER (ORDER BY total_net_sales) AS rn,
        COUNT(*) OVER () AS total_orders
from total_order
),
percentile_threshold AS (
    SELECT total_net_sales AS threshold
    FROM ranked_orders
    WHERE rn = CEIL(0.90 * total_orders)
)
SELECT
    order_id,
    total_net_sales
FROM total_order
WHERE total_net_sales > (
    SELECT threshold
    FROM percentile_threshold
)
ORDER BY total_net_sales DESC;

-- 8.Compare repeat and non-repeat customers by order count and average order value.

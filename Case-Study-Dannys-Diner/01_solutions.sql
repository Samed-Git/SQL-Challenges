-- ============================================================
-- Case Study: Danny's Diner Solutions
-- Author: Samed
-- Repository: SQL-Challenges
-- ============================================================


-- ------------------------------------------------------------
-- Q1: What is the total amount each customer spent at the restaurant?
-- ------------------------------------------------------------
SELECT 
    s.customer_id,
    SUM(m.price) AS total_amount_spent
FROM sales s
LEFT JOIN menu m
    ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY total_amount_spent DESC;


-- ------------------------------------------------------------
-- Q2: How many days has each customer visited the restaurant?
-- ------------------------------------------------------------
SELECT 
    customer_id,
    COUNT(DISTINCT order_date) AS total_visit_days
FROM sales
GROUP BY customer_id
ORDER BY total_visit_days DESC;


-- ------------------------------------------------------------
-- Q3: What was the first item from the menu purchased by each customer?
-- ------------------------------------------------------------
-- Note: Handles tie cases using DENSE_RANK() if a customer ordered multiple items on their first visit.
WITH ranked_orders AS (
    SELECT 
        customer_id,
        product_id,
        order_date,
        DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rnk
    FROM sales
)
SELECT DISTINCT
    r.customer_id,
    r.order_date,
    m.product_name AS first_order_item
FROM ranked_orders r
LEFT JOIN menu m
    ON r.product_id = m.product_id
WHERE r.rnk = 1;


-- ------------------------------------------------------------
-- Q4: What is the most purchased item on the menu and how many times was it purchased by all customers?
-- ------------------------------------------------------------
WITH top_purchased_item AS (
    SELECT 
        product_id,
        COUNT(product_id) AS total_purchases
    FROM sales
    GROUP BY product_id
)
SELECT TOP 1
    m.product_name AS most_purchased_item,
    t.total_purchases AS times_purchased
FROM top_purchased_item t
JOIN menu m 
    ON t.product_id = m.product_id
ORDER BY t.total_purchases DESC;


-- ------------------------------------------------------------
-- Q5: Which item was the most popular for each customer?
-- ------------------------------------------------------------
WITH customer_product_count AS (
    SELECT 
        customer_id,
        product_id,
        COUNT(product_id) AS total_count
    FROM sales
    GROUP BY customer_id, product_id
),
ranked_customer_products AS (
    SELECT 
        customer_id,
        product_id,
        total_count,
        DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY total_count DESC) AS rnk
    FROM customer_product_count
)
SELECT 
    r.customer_id,
    m.product_name
FROM ranked_customer_products r
LEFT JOIN menu m
    ON r.product_id = m.product_id
WHERE r.rnk = 1;


-- ------------------------------------------------------------
-- Q6: Which item was purchased first by the customer after they became a member?
-- ------------------------------------------------------------
WITH orders_after_membership AS (
    SELECT 
        s.customer_id,
        s.order_date,
        s.product_id,
        m.join_date,
        ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
    FROM sales s
    INNER JOIN members m
        ON s.customer_id = m.customer_id
    WHERE s.order_date >= m.join_date
)
SELECT 
    o.customer_id,
    m.product_name
FROM orders_after_membership o
LEFT JOIN menu m
    ON o.product_id = m.product_id
WHERE o.rnk = 1;


-- ------------------------------------------------------------
-- Q7: Which item was purchased just before the customer became a member?
-- ------------------------------------------------------------
WITH orders_before_membership AS (
    SELECT 
        s.customer_id,
        s.order_date,
        s.product_id,
        m.join_date,
        ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rnk
    FROM sales s
    INNER JOIN members m
        ON s.customer_id = m.customer_id
    WHERE s.order_date < m.join_date
)
SELECT 
    o.customer_id,
    m.product_name
FROM orders_before_membership o
LEFT JOIN menu m
    ON o.product_id = m.product_id
WHERE o.rnk = 1;


-- ------------------------------------------------------------
-- Q8: What is the total items and amount spent for each member before they became a member?
-- ------------------------------------------------------------
WITH pre_membership_orders AS (
    SELECT 
        s.customer_id,
        s.product_id
    FROM sales s
    INNER JOIN members m
        ON s.customer_id = m.customer_id
    WHERE s.order_date < m.join_date
)
SELECT 
    p.customer_id,
    COUNT(p.product_id) AS total_items,
    SUM(m.price) AS total_amount_spent
FROM pre_membership_orders p
LEFT JOIN menu m
    ON p.product_id = m.product_id
GROUP BY p.customer_id;


-- ------------------------------------------------------------
-- Q9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- ------------------------------------------------------------
WITH order_details AS (
    SELECT 
        s.customer_id,
        s.product_id,
        m.product_name,
        m.price
    FROM sales s
    LEFT JOIN menu m
        ON s.product_id = m.product_id
),
calculated_points AS (
    SELECT 
        customer_id,
        CASE 
            WHEN product_name = 'sushi' THEN (price * 20)
            ELSE (price * 10)
        END AS points
    FROM order_details
)
SELECT 
    customer_id,
    SUM(points) AS total_points
FROM calculated_points
GROUP BY customer_id;

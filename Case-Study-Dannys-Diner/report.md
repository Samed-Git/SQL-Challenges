# Case Study #1: Danny's Diner

Solutions for the **Danny's Diner** case study using SQL Server (T-SQL).

---

## Schema Setup

```sql
CREATE DATABASE DannysDiner;
GO
USE DannysDiner;
GO

CREATE TABLE sales (customer_id VARCHAR(1), order_date DATE, product_id INTEGER);
INSERT INTO sales VALUES ('A','2021-01-01',1),('A','2021-01-01',2),('A','2021-01-07',2),('A','2021-01-10',3),('A','2021-01-11',3),('A','2021-01-11',3),('B','2021-01-01',2),('B','2021-01-02',2),('B','2021-01-04',1),('B','2021-01-11',1),('B','2021-01-16',3),('B','2021-02-01',3),('C','2021-01-01',3),('C','2021-01-01',3),('C','2021-01-07',3);

CREATE TABLE menu (product_id INTEGER, product_name VARCHAR(5), price INTEGER);
INSERT INTO menu VALUES (1,'sushi',10),(2,'curry',15),(3,'ramen',12);

CREATE TABLE members (customer_id VARCHAR(1), join_date DATE);
INSERT INTO members VALUES ('A','2021-01-07'),('B','2021-01-09');
```

---

## Case Study Questions & Solutions

### 1. What is the total amount each customer spent at the restaurant?

```sql
SELECT 
    s.customer_id,
    SUM(m.price) AS total_amount_spent
FROM sales s
LEFT JOIN menu m 
    ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY total_amount_spent DESC;
```

| customer_id | total_amount_spent |
| :--- | :--- |
| A | 76 |
| B | 74 |
| C | 36 |

---

### 2. How many days has each customer visited the restaurant?

```sql
SELECT 
    customer_id,
    COUNT(DISTINCT order_date) AS total_visit_days
FROM sales
GROUP BY customer_id
ORDER BY total_visit_days DESC;
```

| customer_id | total_visit_days |
| :--- | :--- |
| B | 6 |
| A | 4 |
| C | 2 |

---

### 3. What was the first item from the menu purchased by each customer?

```sql
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
```

| customer_id | order_date | first_order_item |
| :--- | :--- | :--- |
| A | 2021-01-01 | sushi |
| A | 2021-01-01 | curry |
| B | 2021-01-01 | curry |
| C | 2021-01-01 | ramen |

---

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
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
```

| most_purchased_item | times_purchased |
| :--- | :--- |
| ramen | 8 |

---

### 5. Which item was the most popular for each customer?

```sql
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
```

| customer_id | product_name |
| :--- | :--- |
| A | ramen |
| B | sushi |
| B | curry |
| B | ramen |
| C | ramen |

---

### 6. Which item was purchased first by the customer after they became a member?

```sql
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
```

| customer_id | product_name |
| :--- | :--- |
| A | curry |
| B | sushi |

---

### 7. Which item was purchased just before the customer became a member?

```sql
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
```

| customer_id | product_name |
| :--- | :--- |
| A | sushi |
| B | sushi |

---

### 8. What is the total items and amount spent for each member before they became a member?

```sql
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
```

| customer_id | total_items | total_amount_spent |
| :--- | :--- | :--- |
| A | 2 | 25 |
| B | 3 | 40 |

---

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

```sql
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
```

| customer_id | total_points |
| :--- | :--- |
| A | 860 |
| B | 940 |
| C | 360 |

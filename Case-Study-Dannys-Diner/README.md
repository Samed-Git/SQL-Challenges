# Danny's Diner — SQL Case Study

A SQL Server (T-SQL) solution to **Case Study #1: Danny's Diner** from the [8 Week SQL Challenge](https://8weeksqlchallenge.com/case-study-1/).

The project explores customer purchasing behavior using a small restaurant dataset. It focuses on querying relational data, aggregating transactions, analyzing customer activity, and applying SQL window functions to answer business questions.

## Tools

- **Microsoft SQL Server** — relational database engine
- **SQL Server Management Studio (SSMS)** — query development and execution
- **T-SQL** — data definition, data insertion, and analytical queries

## Dataset

The case study uses three tables:

| Table | Description |
|---|---|
| `sales` | Customer transactions, including customer ID, order date, and product ID. |
| `menu` | Menu items and their prices. |
| `members` | Customers' membership join dates. |

The SQL script creates the `DannysDiner` database, defines these tables, and inserts the case study's sample data.

## Business Questions

The solution answers all nine questions in the case study:

1. How much each customer spent.
2. How many days each customer visited.
3. Which menu items each customer purchased on their first visit.
4. The most purchased menu item overall.
5. Each customer's most popular menu item.
6. The first item purchased after becoming a member.
7. The last item purchased before becoming a member.
8. The number of items and total amount spent before membership.
9. The loyalty points earned by each customer, including the sushi points multiplier.

## SQL Concepts Demonstrated

- Database and table creation using `CREATE DATABASE` and `CREATE TABLE`.
- Loading sample records with `INSERT INTO`.
- Combining tables with `JOIN` and `LEFT JOIN`.
- Aggregation using `SUM()`, `COUNT()`, and `GROUP BY`.
- Filtering and sorting with `WHERE` and `ORDER BY`.
- Common Table Expressions (CTEs).
- Window functions: `DENSE_RANK()` and `ROW_NUMBER()`.
- Conditional logic with `CASE`.
- Handling ties when identifying first purchases and popular products.

## Project Files

| File | Purpose |
|---|---|
| `queries.sql` | Complete T-SQL script: database setup, sample data, and solutions to all nine questions. |
| `report.md` | Case study questions, SQL solutions, and query results. |

## How to Run

1. Open SQL Server Management Studio and connect to a SQL Server instance.
2. Open `queries.sql`.
3. Execute the script. It creates the `DannysDiner` database, creates and populates the tables, then runs the analytical queries.

> The script uses SQL Server syntax (T-SQL), including `GO` and `TOP`, so it is intended for Microsoft SQL Server.

## Repository

[View this case study on GitHub](https://github.com/Samed-Git/SQL-Challenges/tree/main/Case-Study-Dannys-Diner)

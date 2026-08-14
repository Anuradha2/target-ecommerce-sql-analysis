/*==============================================================================
Project      : Target Brazil E-commerce Analysis
Author       : Anuradha Sarkar
Tools        : Google BigQuery
Language     : SQL
Dataset      : Target Brazil E-commerce Dataset
Period       : Sep 2016 – Oct 2018

Description:
This project analyzes Target Brazil's e-commerce data to uncover customer
behavior, sales trends, logistics performance, freight costs, delivery
efficiency, and payment patterns using SQL.

==============================================================================*/

/*==============================================================================
SECTION 1: DATA EXPLORATION
==============================================================================*/

/*------------------------------------------------------------------------------
Business Question 1:
What are the data types of all columns in the customers table?

Objective:
Understand the schema of the customers table before beginning the analysis.
------------------------------------------------------------------------------*/

SELECT
    column_name,
    data_type
FROM
    `Target.INFORMATION_SCHEMA.COLUMNS`
WHERE
    table_name = 'customers';

/*------------------------------------------------------------------------------
Business Question 2:
What is the time range covered by the orders dataset?

Objective:
Identify the earliest and latest order dates available in the dataset.
------------------------------------------------------------------------------*/

SELECT 
    min(order_purchase_timestamp) AS first_order_purchased,
    max(order_purchase_timestamp) AS last_order_purchased
FROM 
    `Target.orders`;

/*------------------------------------------------------------------------------
Business Question 3:
How many unique cities and states placed orders during the analysis period?

Objective:
Measure the geographical coverage of Target Brazil's customer base.
------------------------------------------------------------------------------*/

SELECT 
    COUNT(DISTINCT c.customer_city) AS total_cities,
    COUNT(DISTINCT c.customer_state) AS total_states
FROM 
    `Target.customers` c INNER JOIN `Target.orders` o ON c.customer_id = o.customer_id;

/*==============================================================================
SECTION 2: IN-DEPTH EXPLORATION
==============================================================================*/

/*------------------------------------------------------------------------------
Business Question 4:
Is there a growing trend in the number of orders placed over time?

Objective:
Analyze yearly order volume to identify whether Target Brazil experienced
growth in customer orders over the analysis period.
------------------------------------------------------------------------------*/

SELECT 
    FORMAT_DATE("%Y-%m", order_purchase_timestamp) AS year_month, 
    COUNT(DISTINCT order_id) AS order_count
FROM `Target.orders`
GROUP BY 1
ORDER BY 1;

/*------------------------------------------------------------------------------
Business Question 5:
Can we see any monthly seasonality in the number of orders placed?

Objective:
Analyze order volume by month to identify recurring seasonal patterns in
customer purchasing activity.
------------------------------------------------------------------------------*/

SELECT 
    FORMAT_DATETIME("%B", order_purchase_timestamp) AS month, 
    COUNT(DISTINCT order_id) AS order_count
FROM `Target.orders`
GROUP BY 1
ORDER BY MIN(extract(MONTH FROM order_purchase_timestamp));

/*------------------------------------------------------------------------------
Business Question 6:
During what time of the day do Brazilian customers mostly place their orders?

Objective:
Analyze order volume across different time-of-day segments to identify when
customers are most active on the platform.

Time Segments:
00:00–06:00 → Dawn
07:00–12:00 → Morning
13:00–18:00 → Afternoon
19:00–23:00 → Night
------------------------------------------------------------------------------*/

WITH hrs AS (
    SELECT
        order_id,
        EXTRACT(HOUR FROM order_purchase_timestamp) AS hours
    FROM `Target.orders`
)

SELECT
    CASE
        WHEN hours BETWEEN 0 AND 6 THEN 'Dawn'
        WHEN hours BETWEEN 7 AND 12 THEN 'Morning'
        WHEN hours BETWEEN 13 AND 18 THEN 'Afternoon'
        WHEN hours BETWEEN 19 AND 23 THEN 'Night'
    END AS time_of_day,
    COUNT(*) AS order_count
FROM hrs
GROUP BY 1
ORDER BY 2 DESC;

/*==============================================================================
SECTION 3: REGIONAL ANALYSIS
==============================================================================*/

/*------------------------------------------------------------------------------
Business Question 7:
How does the number of orders placed in each state change month over month?

Objective:
Analyze monthly order volume across Brazilian states to identify regional
order trends and understand how e-commerce activity has evolved over time.
------------------------------------------------------------------------------*/

SELECT
    c.customer_state,
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    FORMAT_DATETIME('%B', o.order_purchase_timestamp) AS month,
    COUNT(o.order_id) AS order_count
FROM `Target.customers` AS c
INNER JOIN `Target.orders` AS o
    ON c.customer_id = o.customer_id
GROUP BY 1, 2, 3
ORDER BY
    1,
    2,
    MIN(EXTRACT(MONTH FROM o.order_purchase_timestamp));




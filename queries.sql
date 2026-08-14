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

/*------------------------------------------------------------------------------
Business Question 8:
How are customers distributed across all the states?

Objective:
Analyze the number of customers across Brazilian states to understand the
geographical distribution of Target Brazil's customer base.
------------------------------------------------------------------------------*/

SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_id) AS customer_count
FROM `Target.customers` AS c
INNER JOIN `Target.orders` AS o
    ON c.customer_id = o.customer_id
GROUP BY 1
ORDER BY 2 DESC;

/*------------------------------------------------------------------------------
Business Question 9:
What was the percentage increase in order value from 2017 to 2018 for the
months of January through August?

Objective:
Compare the total payment value of orders between 2017 and 2018 for the
January–August period to measure year-over-year growth in order value.
------------------------------------------------------------------------------*/

WITH total_cost_per_year AS (
    SELECT
        EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
        SUM(p.payment_value) AS total_cost
    FROM `Target.orders` AS o
    INNER JOIN `Target.payments` AS p
        ON o.order_id = p.order_id
    WHERE EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 8
        AND EXTRACT(YEAR FROM o.order_purchase_timestamp) IN (2017, 2018)
    GROUP BY 1
)

SELECT
    year,
    total_cost,
    LAG(total_cost) OVER (ORDER BY year) AS previous_year_cost,
    ROUND(
        (
            (total_cost - LAG(total_cost) OVER (ORDER BY year))
            / LAG(total_cost) OVER (ORDER BY year)
        ) * 100,
        2
    ) AS percentage_increase
FROM total_cost_per_year;

/*------------------------------------------------------------------------------
Business Question 10:
What are the total and average order values for each state?

Objective:
Analyze the total and average value of orders across Brazilian states to
identify high-value regional markets and differences in customer spending.
------------------------------------------------------------------------------*/

WITH total_value_per_order AS (
    SELECT
        o.order_id,
        c.customer_state,
        SUM(oi.price) AS order_value
    FROM `Target.customers` AS c
    INNER JOIN `Target.orders` AS o
        ON c.customer_id = o.customer_id
    INNER JOIN `Target.order_items` AS oi
        ON o.order_id = oi.order_id
    GROUP BY 1, 2
)

SELECT
    customer_state,
    ROUND(SUM(order_value), 2) AS total_order_value,
    ROUND(AVG(order_value), 2) AS average_order_value
FROM total_value_per_order
GROUP BY 1
ORDER BY 2 DESC, 3 DESC;

/*------------------------------------------------------------------------------
Business Question 11:
What are the total and average freight values for each state?

Objective:
Analyze total and average freight costs across Brazilian states to identify
regional differences in shipping costs.
------------------------------------------------------------------------------*/

WITH total_freight_value_per_order AS (
    SELECT
        o.order_id,
        c.customer_state,
        SUM(oi.freight_value) AS order_freight_value
    FROM `Target.customers` AS c
    INNER JOIN `Target.orders` AS o
        ON c.customer_id = o.customer_id
    INNER JOIN `Target.order_items` AS oi
        ON o.order_id = oi.order_id
    GROUP BY 1, 2
)

SELECT
    customer_state,
    ROUND(SUM(order_freight_value), 2) AS total_freight_value,
    ROUND(AVG(order_freight_value), 2) AS average_freight_value
FROM total_freight_value_per_order
GROUP BY 1
ORDER BY 2 DESC, 3 DESC;

/*------------------------------------------------------------------------------
Business Question 12:
How many days does it take to deliver each order, and how does the actual
delivery date compare with the estimated delivery date?

Objective:
Calculate the delivery time for each order and measure the difference between
the actual and estimated delivery dates to evaluate delivery performance.
------------------------------------------------------------------------------*/

SELECT
    order_id,
    DATE_DIFF(
        order_delivered_customer_date,
        order_purchase_timestamp,
        DAY
    ) AS time_to_deliver,
    DATE_DIFF(
        order_estimated_delivery_date,
        order_delivered_customer_date,
        DAY
    ) AS diff_estimated_delivery
FROM `Target.orders`;

/*------------------------------------------------------------------------------
Business Question 13:
Which states have the highest and lowest average freight values?

Objective:
Identify the top 5 states with the highest and lowest average freight values
to understand regional differences in shipping costs.
------------------------------------------------------------------------------*/

WITH total_freight_value_per_order AS (
    SELECT
        o.order_id,
        c.customer_state,
        SUM(oi.freight_value) AS order_freight_value
    FROM `Target.customers` AS c
    INNER JOIN `Target.orders` AS o
        ON c.customer_id = o.customer_id
    INNER JOIN `Target.order_items` AS oi
        ON o.order_id = oi.order_id
    GROUP BY 1, 2
),

average_freight_value AS (
    SELECT
        customer_state,
        ROUND(AVG(order_freight_value), 2) AS average_freight_value
    FROM total_freight_value_per_order
    GROUP BY 1
),

ranked AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY average_freight_value DESC
        ) AS high_rank,
        DENSE_RANK() OVER (
            ORDER BY average_freight_value
        ) AS low_rank
    FROM average_freight_value
)

SELECT
    customer_state,
    average_freight_value,
    CASE
        WHEN high_rank <= 5 THEN 'HIGH'
        WHEN low_rank <= 5 THEN 'LOW'
    END AS freight_category
FROM ranked
WHERE high_rank <= 5
   OR low_rank <= 5;

/*------------------------------------------------------------------------------
Business Question 14:
Which states have the highest and lowest average delivery times?

Objective:
Identify the top 5 states with the highest and lowest average delivery times
to evaluate regional differences in delivery performance.
------------------------------------------------------------------------------*/

WITH delivery_time AS (
    SELECT
        c.customer_state,
        DATE_DIFF(
            o.order_delivered_customer_date,
            o.order_purchase_timestamp,
            DAY
        ) AS time_to_deliver
    FROM `Target.orders` AS o
    INNER JOIN `Target.customers` AS c
        ON o.customer_id = c.customer_id
),

avg_delivery_time AS (
    SELECT
        customer_state,
        ROUND(AVG(time_to_deliver), 2) AS average_delivery_time
    FROM delivery_time
    GROUP BY 1
),

ranked AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY average_delivery_time DESC
        ) AS high_rank,
        DENSE_RANK() OVER (
            ORDER BY average_delivery_time ASC
        ) AS low_rank
    FROM avg_delivery_time
)

SELECT
    customer_state,
    average_delivery_time,
    CASE
        WHEN high_rank <= 5 THEN 'HIGH'
        WHEN low_rank <= 5 THEN 'LOW'
    END AS delivery_time_category
FROM ranked
WHERE high_rank <= 5
   OR low_rank <= 5;

/*------------------------------------------------------------------------------
Business Question 15:
Which are the top 5 states where orders are delivered fastest compared with
the estimated delivery date?

Objective:
Compare the average actual delivery time with the average estimated delivery
time for each state to identify the states with the fastest delivery
performance relative to expectations.
------------------------------------------------------------------------------*/

WITH delivery_time AS (
    SELECT
        c.customer_state,
        AVG(
            DATE_DIFF(
                o.order_delivered_customer_date,
                o.order_purchase_timestamp,
                DAY
            )
        ) AS average_time_to_deliver,
        AVG(
            DATE_DIFF(
                o.order_estimated_delivery_date,
                o.order_purchase_timestamp,
                DAY
            )
        ) AS average_estimated_time_to_deliver
    FROM `Target.customers` AS c
    INNER JOIN `Target.orders` AS o
        ON c.customer_id = o.customer_id
    WHERE o.order_delivered_customer_date IS NOT NULL
    GROUP BY 1
)

SELECT
    customer_state,
    ROUND(
        average_estimated_time_to_deliver - average_time_to_deliver,
        2
    ) AS delivery_speed
FROM delivery_time
ORDER BY 2 DESC
LIMIT 5;




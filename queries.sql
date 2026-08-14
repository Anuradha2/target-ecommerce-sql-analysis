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
Is there a growing trend in the number of orders placed over the years?

Objective:
Analyze yearly order volume to identify whether Target Brazil experienced
growth in customer orders over the analysis period.
------------------------------------------------------------------------------*/

SELECT 
    format_date("%Y-%m", order_purchase_timestamp) AS year_month, 
    COUNT(DISTINCT order_id) AS order_count
FROM `Target.orders`
GROUP BY 1
ORDER BY 1;

/*
Observation:
There is growing trend in number of orders placed over the years which means acquiring more and 
more customers and a consistent growth in order placed by month on month
*/


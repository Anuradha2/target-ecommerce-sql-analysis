# 🛒 Target Brazil E-commerce Analysis using SQL

## 📌 Project Overview

This project analyzes Target Brazil's e-commerce dataset using SQL in Google BigQuery. The objective is to explore customer purchasing behavior, sales trends, delivery performance, freight costs, and payment patterns to generate actionable business insights.

The analysis involves writing SQL queries to answer real-world business questions and transforming raw transactional data into meaningful insights that can support business decision-making.

## 🎯 Business Context

Target is a globally recognized retail company with a strong e-commerce presence in Brazil. This project analyzes approximately **100,000 e-commerce orders** placed between **2016 and 2018** to understand customer purchasing behavior, sales trends, logistics performance, delivery efficiency, and payment patterns.

Using SQL, this project generates data-driven insights and business recommendations that can support marketing, logistics, and operational decision-making.

## 📂 Dataset Information

This project uses the **Target Brazil E-commerce Dataset**, containing approximately **100,000 orders** placed between **2016 and 2018**.

The dataset consists of eight relational tables:

| Table | Description |
|--------|-------------|
| customers | Customer information |
| orders | Order details |
| order_items | Product pricing and freight |
| payments | Payment information |
| products | Product details |
| sellers | Seller information |
| reviews | Customer reviews |
| geolocation | Geographic information |

**Dataset Source:** [Google Drive Dataset](https://drive.google.com/drive/folders/1TGEc66YKbD443nslRi1bWgVd238gJCnb)

## 🔄 Project Workflow

The project followed a structured analytical approach:

1. Explored the dataset and understood table relationships.
2. Performed exploratory data analysis (EDA).
3. Analyzed customer purchasing behavior and order trends.
4. Evaluated regional sales and customer distribution.
5. Assessed logistics performance using freight and delivery metrics.
6. Examined payment methods and installment patterns.
7. Derived business insights and proposed actionable recommendations.

## 🛠️ Tools & SQL Concepts

**Tools**
- Google BigQuery

**SQL Concepts**
- Joins
- Common Table Expressions (CTEs)
- Aggregate Functions
- Window Functions (`LAG`, `DENSE_RANK`)
- CASE Statements
- Date & Time Functions
- GROUP BY
- ORDER BY
- COUNT DISTINCT
- Mathematical Functions (`ROUND`)

## 📊 Business Questions

### 1. Exploratory Analysis
- What is the structure of the dataset?
- What is the time range of the orders?
- How many cities and states placed orders?

### 2. Customer Purchasing Behavior
- Is there a growing trend in the number of orders?
- Is there monthly seasonality in orders?
- During which time of the day do customers place the most orders?

### 3. Regional Analysis
- What is the month-on-month order trend across states?
- How are customers distributed across states?

### 4. Sales, Freight & Delivery Analysis
- What is the percentage increase in order value from 2017 to 2018?
- What are the total and average order values by state?
- What are the total and average freight charges by state?
- Which states have the highest and lowest average freight costs?
- Which states have the highest and lowest average delivery times?
- Which states receive deliveries earlier than the estimated delivery date?

### 5. Payment Analysis
- How do payment methods vary month over month?
- How are orders distributed based on payment installments?



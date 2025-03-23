# SQL Retail Sales Analysis Project

## Project Overview
This project focuses on analyzing retail sales data from a retail store or e-commerce platform. The SQL queries provided in this project help to clean, explore, and analyze the retail sales data to uncover insights about customer behavior, sales trends, and product performance.

The **retail_sales** table contains key information such as transaction IDs, sale date, sale time, customer details, product categories, quantity sold, pricing, cost of goods sold (COGS), and total sales. Various SQL queries have been written to clean the data, perform exploratory analysis, and answer business key questions.

## Table of Contents
1. Data Cleaning
2. Data Exploration
3. Business Analysis Questions
4. Advanced Analytical Queries
5. Project Setup

---

## Data Cleaning

In this section, we perform necessary data cleaning tasks on the `retail_sales` table to ensure data integrity and remove any inconsistencies.

### Checking Null Values
We check for `NULL` values across various columns like `transactions_id`, `sale_date`, `sale_time`, `customer_id`, `gender`, `age`, `category`, `quantity`, `price_per_unit`, `cogs`, and `total_sale`.

```sql
SELECT *
FROM retail_sales
WHERE transactions_id IS NULL;
```

### Removing Rows with Null Values
We remove any rows that contain `NULL` values in critical columns.

```sql
DELETE FROM retail_sales
WHERE transactions_id IS NULL
   OR sale_date IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR age IS NULL
   OR category IS NULL
   OR quantity IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;
```

### Updating Null Values in Age Column
We replace any `NULL` values in the `age` column with the average age of customers.

```sql
UPDATE retail_sales
SET age = CASE 
            WHEN age IS NULL THEN (SELECT AVG(age) FROM retail_sales WHERE age IS NOT NULL)
            ELSE age
          END;
```

---

## Data Exploration

This section explores the data to answer basic business questions, including the total number of sales, unique customers, and categories.

### Total Sales Records

We calculate the total number of sales transactions.

```sql
SELECT COUNT(*) AS total_sales
FROM retail_sales;
```

### Unique Customers

We count the number of unique customers based on `customer_id`.

```sql
SELECT COUNT(DISTINCT(customer_id)) AS customer_count
FROM retail_sales;
```

### Distinct Categories

We list all the distinct product categories.

```sql
SELECT DISTINCT(category) AS categories
FROM retail_sales;
```

---

## Business Analysis Questions

Here we answer specific business-related questions by writing SQL queries that extract insights from the data.

### Q1: Sales on a Specific Date
We retrieve all sales made on `2022-11-05`.

```sql
SELECT *
FROM retail_sales
WHERE sale_date='2022-11-05';
```

### Q2: Sales for Clothing with Quantity >= 4 in Nov 2022
We retrieve all sales where the category is `Clothing` and the quantity sold is greater than or equal to 4 in November 2022.

```sql
SELECT *
FROM retail_sales
WHERE category='Clothing'
    AND quantity>=4
    AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';
```

### Q3: Total Sales per Category
We calculate the total sales for each product category.

```sql
SELECT category,
       SUM(total_sale) as net_sale,
       COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;
```

### Q4: Average Age of Customers in Beauty Category
We find the average age of customers who purchased from the `Beauty` category.

```sql
SELECT ROUND(AVG(age),2) as avg_age
FROM retail_sales
WHERE category='Beauty';
```

### Q5: High Ticket Sales (Total Sale > 1000)
We retrieve all transactions where the total sale is greater than 1000.

```sql
SELECT *
FROM retail_sales
WHERE total_sale>1000;
```

### Q6: Total Transactions by Gender and Category
We find the total number of transactions made by each gender in each category.

```sql
SELECT category,
       gender,
       COUNT(*) as no_of_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category;
```

### Q7: Best Selling Month in Each Year
We calculate the average sale for each month and find out the best-selling month for each year.

```sql
WITH CTE AS
(
SELECT EXTRACT(YEAR FROM sale_date) as year,
       EXTRACT(MONTH FROM sale_date) as month,
       AVG(total_sale) as avg_sales,
       RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS ranks
FROM retail_sales
GROUP BY year,month
)
SELECT year,
       month,
       avg_sales
FROM CTE 
WHERE ranks=1;
```

### Q8: Top 5 Customers Based on Total Sales
We find the top 5 customers who spent the most money.

```sql
SELECT customer_id,
       SUM(total_sale) as net_sale
FROM retail_sales
GROUP BY customer_id
ORDER BY net_sale DESC
LIMIT 5;
```

### Q9: Unique Customers per Category
We find the number of unique customers who purchased items from each category.

```sql
SELECT category,
       COUNT(DISTINCT(customer_id)) AS cnt_of_distinct_customers
FROM retail_sales
GROUP BY category;
```

### Q10: Orders by Shift (Morning, Afternoon, Evening)
We create each shift and the number of orders in each shift (e.g., Morning: <=12, Afternoon: 12-17, Evening: >17).

```sql
WITH hrly_sales AS
(
SELECT *,
       CASE
         WHEN EXTRACT(HOUR FROM sale_time)<12 THEN 'Morning'
         WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
         ELSE 'Evening'
       END AS shift  
FROM retail_sales
)
SELECT shift,
       COUNT(transactions_id) as total_orders
FROM hrly_sales
GROUP BY shift;
```

---

## Advanced Analytical Queries

In this section, we focus on more complex analyses to uncover deeper insights.

### Q11: Average Quantity Sold per Transaction
We find the average quantity sold per transaction across all categories.

```sql
SELECT ROUND(AVG(quantity),2) AS avg_quantity_per_transaction
FROM retail_sales;
```

### Q12: Sales Trend by Day of the Week
We analyze sales trends based on the day of the week to identify higher sales on weekends.

```sql
SELECT TO_CHAR(sale_date, 'Day') AS day_of_week,
       SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY day_of_week
ORDER BY total_sales DESC;
```

### Q13: Month-over-Month Sales Growth
We calculate the growth in sales month-over-month.

```sql
WITH monthly_sales AS
(
  SELECT EXTRACT(YEAR FROM sale_date) AS year,
         EXTRACT(MONTH FROM sale_date) AS month,
         SUM(total_sale) AS total_sales
  FROM retail_sales
  GROUP BY year, month
)
SELECT year,
       month,
       total_sales,
       LAG(total_sales, 1) OVER (ORDER BY year, month) AS prev_month_sales,
       (total_sales - LAG(total_sales, 1) OVER (ORDER BY year, month)) / 
       LAG(total_sales, 1) OVER (ORDER BY year, month) * 100 AS sales_growth_percentage
FROM monthly_sales
ORDER BY year, month;
```

### Q14: Orders by Age Group
We find how the number of orders varies across different age groups (e.g., teenagers, young adults, seniors).

```sql
SELECT CASE 
         WHEN age < 18 THEN 'Under 18'
         WHEN age BETWEEN 18 AND 34 THEN '18-34'
         WHEN age BETWEEN 35 AND 54 THEN '35-54'
         WHEN age >= 55 THEN '55+'
       END AS age_group,
       COUNT(transactions_id) AS total_orders
FROM retail_sales
GROUP BY age_group
ORDER BY age_group;
```

### Q15: Sales Trends by Gender and Age Group
We combine gender and age group to analyze sales trends in different demographic segments.

```sql
SELECT gender,
       CASE 
         WHEN age < 18 THEN 'Under 18'
         WHEN age BETWEEN 18 AND 34 THEN '18-34'
         WHEN age BETWEEN 35 AND 54 THEN '35-54'
         WHEN age >= 55 THEN '55+'
       END AS age_group,
       SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY gender, age_group
ORDER BY total_sales DESC;
```

### Q16: Sales Trends for Specific Category (e.g., Electronics)
We analyze the sales trend for the `Electronics` category over time.

```sql
SELECT EXTRACT(YEAR FROM sale_date) AS year,
       EXTRACT(MONTH FROM sale_date) AS month,
       SUM(total_sale) AS total_sales
FROM retail_sales
WHERE category = 'Electronics'
GROUP BY year, month
ORDER BY year, month;
```

Sure! Here's the updated README with your name and details:

---

## Findings

### Customer Demographics
The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing, Beauty, and Electronics. The analysis of customer age groups helps identify which segments are driving the most sales.

### High-Value Transactions
Several transactions had a total sale amount greater than 1000, indicating premium purchases. These high-ticket sales are useful for identifying high-value customers and products.

### Sales Trends
Monthly analysis shows variations in sales, helping identify peak seasons. Sales growth was noticeable during certain months, indicating potential opportunities for targeted promotions during these peak periods.

### Customer Insights
The analysis identifies the top-spending customers and the most popular product categories. This information can be used to tailor marketing efforts to high-value customers and focus on high-performing product categories.

---

## Reports

### Sales Summary
A detailed report summarizing total sales, customer demographics, and category performance. This helps understand the overall sales picture and the distribution of revenue across different customer segments and product categories.

### Trend Analysis
Insights into sales trends across different months and shifts. This analysis identifies the best-selling months, as well as any seasonal fluctuations in sales, and the impact of different shifts (morning, afternoon, evening) on order volume.

### Customer Insights
Reports on top customers, their spending habits, and unique customer counts per category. This information is key for understanding customer loyalty and preferences across different categories.

---

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering the essentials such as database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

---

## How to Use

### 1. Clone the Repository
Clone this project repository from GitHub.

```bash
git clone https://github.com/rajendra-singh/retail-sales-analysis.git
```

### 2. Set Up the Database
Run the SQL scripts provided in the `database_setup.sql` file to create and populate the database.

```bash
source database_setup.sql
```

### 3. Run the Queries
Use the SQL queries provided in the `analysis_queries.sql` file to perform your analysis.

```bash
source analysis_queries.sql
```

### 4. Explore and Modify
Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions.

---

## Author - Rajendra Singh

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

---

## Stay Updated

For more content on SQL, data analysis, and other data-related topics, make sure to follow me on social media:

- **LinkedIn**: linkedin.com/in/rajendra-singh-shah



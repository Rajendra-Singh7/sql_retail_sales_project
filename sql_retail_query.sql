-- SQL Retail Sales Analysis

-- Create Table
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
(
	transactions_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender VARCHAR(15),
	age INT,
	category VARCHAR(15),
	quantiy INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
);

SELECT * FROM retail_sales
LIMIT 10;

-- Total No of records
SELECT
	COUNT(*)
FROM retail_sales;

-- Data Cleaning
-- Checking null values in columns
SELECT * 
FROM retail_sales
WHERE transactions_id IS NULL

SELECT * 
FROM retail_sales
WHERE sale_date IS NULL

SELECT * 
FROM retail_sales
WHERE sale_time IS NULL

SELECT *
FROM retail_sales
WHERE
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR 
	sale_time IS NULL
	OR 
	customer_id IS NULL
	OR 
	gender IS NULL
	OR 
	age IS NULL
	OR
	category IS NULL
	OR 
	quantity IS NULL
	OR 
	price_per_unit IS NULL
	OR 
	cogs IS NULL
	OR 
	total_sale IS NULL;

-- deleting the rows with null values
DELETE FROM retail_sales
WHERE
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR 
	sale_time IS NULL
	OR 
	customer_id IS NULL
	OR 
	gender IS NULL
	OR 
	category IS NULL
	OR 
	quantity IS NULL
	OR 
	price_per_unit IS NULL
	OR 
	cogs IS NULL
	OR 
	total_sale IS NULL;

--updating/replacing the null values in age column with the average of age column
UPDATE retail_sales
SET age = CASE 
            WHEN age IS NULL THEN (SELECT AVG(age) FROM retail_sales WHERE age IS NOT NULL)
            ELSE age
          END;

-- Data Exploration

-- How many sales we have?
SELECT COUNT(*) AS total_sales
FROM retail_sales;

-- How many unique/distinct customers do we have?
SELECT COUNT(DISTINCT(customer_id)) AS customer_count
FROM retail_sales;

-- How many unique/distinct categories do we have?
SELECT COUNT(DISTINCT(category)) AS category_count
FROM retail_sales;

--List the unique/distinct categories we have?
SELECT DISTINCT(category) AS categories
FROM retail_sales;

-- Data Analysis and Business Key Problems and Answers

-- Q1. Write a SQL query to retrieve all columns for sales made on '2022-11-05'
SELECT *
FROM retail_sales
WHERE sale_date='2022-11-05';

-- Q1. Write a SQL query to retrieve all columns for sales between '2022-11-01' to '2022-11-30'
SELECT *
FROM retail_sales
WHERE sale_date BETWEEN '2022-11-01' AND '2022-11-30';


-- Q2. Write a SQL query to retrieve all transactions where the category is Clothing and the quantity sold is more than or equal to 4 in the month of Nov-2022
SELECT *
FROM retail_sales
WHERE category='Clothing'
	  AND quantity>=4
	  AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';

SELECT *
FROM retail_sales
WHERE category='Clothing'
	  AND quantity>=4
	  AND to_char(sale_date,'YYYY-MM')='2022-11'

-- Q3. Write a SQL query to calculate the total sales for each category.
SELECT category,
	SUM(total_sale) as net_sale,
	COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;


-- Q4. Write a SQL query  to find the average age of customer who purchased items form the 'Beauty' Category
SELECT ROUND(AVG(age),2) as avg_age
FROM retail_sales
WHERE category='Beauty';


-- Q5. Write a SQL query to find all transactions where he total_sales is greater than 1000(High ticket).
SELECT *
FROM retail_sales
WHERE total_sale>1000;

-- Q6. Write a SQL query to find the total number of transactions made by each gender in each category.
SELECT category,
	gender,
	COUNT(*) as no_of_transactions
FROM retail_sales
GROUP BY category,gender
ORDER BY category;

-- Q7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year.
WITH CTE AS
(
SELECT EXTRACT(YEAR FROM sale_date) as year,
	EXTRACT (MONTH FROM sale_date) as month,
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


-- Q8. Write a SQL query to find the top 5 customers based on the highest total sales
SELECT customer_id,
	SUM(total_sale) as net_sale
FROM retail_sales
GROUP BY customer_id
ORDER BY net_sale DESC
LIMIT 5;

-- Q9. Write a query to find the number of unique customers who purchased items from each category.
SELECT category,
	COUNT(DISTINCT(customer_id)) AS cnt_of_distinct_customers
FROM retail_sales
GROUP BY category;

-- Q10. Write a SQL query to create each shift and number of orders(eg Morning<=12, afternoon between 12 to 17 ,evening>17)
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

-- Q11. Find the average quantity sold per transaction across all categories.
SELECT ROUND(AVG(quantity),2) AS avg_quantity_per_transaction
FROM retail_sales;


-- Q12. Analyze sales based on the day of the week to identify trends (e.g., higher sales on weekends).
SELECT TO_CHAR(sale_date, 'Day') AS day_of_week,
       SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY day_of_week
ORDER BY total_sales DESC;


-- Q13. Calculate the growth in sales month-over-month.
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


-- Q14. Find out how the number of orders varies across different age groups (e.g., teenagers, young adults, seniors).
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


-- Q15. Combine gender and age group to analyze sales trends in different demographic segments.
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

-- Q16. Analyze the sales trend for a specific category over time (e.g., monthly sales of "Electronics").
SELECT EXTRACT(YEAR FROM sale_date) AS year,
       EXTRACT(MONTH FROM sale_date) AS month,
       SUM(total_sale) AS total_sales
FROM retail_sales
WHERE category = 'Electronics'
GROUP BY year, month
ORDER BY year, month;

-- Q17. Identify customers who have spent above a certain threshold during the period.
SELECT customer_id,
       SUM(total_sale) AS total_spent
FROM retail_sales
GROUP BY customer_id
HAVING SUM(total_sale) > 8000;

-- Q18. Find customers who haven’t made a purchase within the last 3 months, helping with churn analysis.
SELECT customer_id
FROM retail_sales
WHERE sale_date < CURRENT_DATE - INTERVAL '3 months'
GROUP BY customer_id
HAVING MAX(sale_date) < CURRENT_DATE - INTERVAL '3 months';

--END OF PROJECT






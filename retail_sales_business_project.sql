-- creates the database
CREATE DATABASE retaildb;

-- creates the data table
CREATE TABLE retail_sales
			(
				transactions_id INT PRIMARY KEY, 
				sale_date DATE, 
				sale_time TIME,
				customer_id INT, 
				gender VARCHAR(15),
				age INT,
				category VARCHAR(15),
				quantity INT,
				price_per_unit FLOAT,
				cogs FLOAT,
				total_sale FLOAT
			);
			
-- DATA CLEANING

-- checking the total rows
SELECT 
	COUNT(*)
FROM retail_sales;

-- checking the null values
SELECT * FROM retail_sales
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

-- delete the null values
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


-- DATA EXPLORATION

-- how many record/sales we have?
SELECT COUNT(*) as total_sales FROM retail_sales;

-- how many unique customer we have?
SELECT COUNT(DISTINCT customer_id) as total_customer FROM retail_sales;

-- how many unique categories we have?
SELECT COUNT(DISTINCT category) FROM retail_sales;


-- DATA ANALYSIS / BUSINESS PROBLEMS

-- write a sql query top retrieve all columns for sales made on '2022-11-05'
SELECT * FROM retail_sales WHERE sale_date = '2022-11-05';

-- Write a SQL query to retrieve all transactions 
-- where the category is 'Clothing' and the quantity 
-- sold is more than 4 in the month of Nov-2022
SELECT *
FROM retail_sales
WHERE 
	category = 'Clothing'
	AND
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
	AND
	quantity >= 4;
	
-- Write a SQL query to calculate the total sales 
-- (total_sale) for each category
SELECT 
	category,
	SUM(total_sale) AS total_sales, -- sum total of each category
	COUNT(*) total_order -- total orders of each category
FROM retail_sales
GROUP BY 1;

-- Write a SQL query to find the average age of customers 
-- who purchased items from the 'Beauty' category
SELECT 
	ROUND(AVG(age), 2) as avg_age,
	category
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY 2;

-- Write a SQL query to find all transactions 
-- where the total_sale is greater than 1000
SELECT * FROM retail_sales
WHERE total_sale > 1000;


-- Write a SQL query to find the total number of transactions 
-- (transaction_id) made by each gender in each category
SELECT 
	COUNT(transactions_id),
	gender,
	category
FROM retail_sales
GROUP BY 2,3
ORDER BY 3;

-- Write a SQL query to calculate the average sale for each month. 
-- Find out best selling month in each year
SELECT 
	EXTRACT (YEAR FROM sale_date) as year,
	EXTRACT (MONTH FROM sale_date) as month,
	AVG(total_sale) AS avg_sale,
	RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales
GROUP BY 1,2;

-- check the months having highest rank
-- create subqueries
SELECT * FROM 
(
	SELECT 
		EXTRACT (YEAR FROM sale_date) as year,
		EXTRACT (MONTH FROM sale_date) as month,
		AVG(total_sale) AS avg_sale,
		RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
	FROM retail_sales
	GROUP BY 1,2
) as t1
WHERE rank = 1;

-- Write a SQL query to find the top 5 customers
-- based on the highest total sales
SELECT * FROM retail_sales;

SELECT 
	customer_id,
	SUM(total_sale) as total_sale
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Write a SQL query to find the number of unique 
-- customers who purchased items from each category
SELECT 
	COUNT(DISTINCT customer_id) uniqu_cust_id,
	category
FROM retail_sales
GROUP BY 2;

-- Write a SQL query to create each shift and number of orders 
-- (Example Morning <12, Afternoon Between 12 & 17, Evening >17)
SELECT *,
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'MORNING'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		ELSE 'EVENING'
	END AS shift
FROM retail_sales

-- using CTE extract orders hourly basis
WITH hourly_sale
AS
(
SELECT *,
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'MORNING'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		ELSE 'EVENING'
	END AS shift
FROM retail_sales	
)
SELECT 
	shift,
	COUNT(*) as total_orders
FROM hourly_sale
GROUP BY shift;

-- Calculate the average Sales for each month 
-- if a date column is available.
SELECT 
	AVG(total_sale) as avg_sale,
	EXTRACT(MONTH FROM sale_date) as monthly_sale
FROM retail_sales
GROUP BY 2

-- List the number of transactions per Product_Name
SELECT 
	COUNT(transactions_id) nos_trnxs,
	category
FROM retail_sales
GROUP BY 2

-- Find the highest and lowest Sales values in the dataset
SELECT
	MAX(total_sale),
	MIN(total_sale)
FROM retail_sales

-- Show all products with total sales exceeding a certain threshold
SELECT 
	category,
	COUNT(total_sale)
FROM retail_sales
GROUP BY 1
HAVING COUNT(total_sale) > 460 

-- Retrieve Product_Category with an average sale 
-- amount above a specified value
SELECT 
	category,
	AVG(price_per_unit) as avg_price 
FROM retail_sales
GROUP BY 1
HAVING AVG(price_per_unit) > 100

-- Display the top 5 highest-selling products by Sales value
SELECT 
    category,
    SUM(total_sale) AS total_sales_value
FROM 
    retail_sales
GROUP BY 
    category
ORDER BY 
    total_sales_value DESC
LIMIT 5;

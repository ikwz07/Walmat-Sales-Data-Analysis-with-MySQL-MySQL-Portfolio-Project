CREATE DATABASE IF NOT EXISTS SalesDataWalmart;

CREATE TABLE IF NOT EXISTS Sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6, 4) NOT NULL,
    total DECIMAL(12, 2) NOT NULL,
    date DATETIME NOT NULL, 
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_pct FLOAT(11, 9),
    gross_income FLOAT(12, 4) NOT NULL,
    rating FLOAT(2, 1)
);


-- ------------------------------------------------------------------------------------
-- --------------------------------- Feature Engineering ------------------------------


-- Time_of_day

SELECT 
	time,
    (CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "EVENING"
    END 
    ) As time_of_date
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales 
SET time_of_day = (
	CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "EVENING"
	END 
);

-- day_name

-- First Rename the colum name from data to date --
-- Syntax 

ALTER TABLE table_name CHANGE old_column_name new_column_name datatype;

ALTER TABLE Sales CHANGE data date date;

SELECT 
	date,
    DAYNAME(date) AS day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales SET day_name = DAYNAME(date);

-- month_name

SELECT
	date,
    MONTHNAME(date) AS month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(12);

UPDATE sales SET month_name = MONTHNAME(date);

-- ------------------------------------------------------------------------------------

-- Business Questions to Answer;

-- ------------------------------------------------------------------------------------
-- ---------------------------------- Generaic Questions ---------------------------------alter

-- 1. How many unique cities does the data have? 

SELECT 
	DISTINCT city
FROM sales;

-- 2. In which city is each branch?

SELECT 
	DISTINCT branch
FROM Sales;

SELECT
	 DISTINCT city, branch
FROM Sales;

-- ------------------------------------------------------------------------------------
-- ---------------------------------- Product -----------------------------------------

-- 1. How many unique product lines does the data have?

SELECT
	DISTINCT product_line
FROM Sales;

# OR

SELECT
	 COUNT(DISTINCT product_line)
FROM Sales;

-- 2. What is the most common payment method?

SELECT payment_method,
	   COUNT(payment_method) AS payment_count
FROM Sales
GROUP BY payment_method
ORDER BY payment_count DESC;

-- 3. What is the most selling product line?

SELECT product_line,
	  COUNT(product_line) AS most_selling_product
FROM Sales
GROUP BY product_line
ORDER BY most_selling_product DESC;

-- 4. What is the total revenue by month?

SELECT 
	month_name AS month,
	SUM(total) AS total_revenue
FROM Sales
GROUP BY month
ORDER BY total_revenue DESC;

-- 5. What month had the largest COGS?

SELECT
	month_name AS month, 
    SUM(cogs) AS cogs_count
FROM Sales
GROUP BY month
ORDER BY cogs_count DESC;

-- 6. What product line had the largest revenue?

SELECT
	 Product_line,
     SUM(total) AS largest_revenue
FROM Sales
GROUP BY product_line
ORDER BY largest_revenue DESC;

-- 7. What is the city with the largest revenue?

SELECT
	 branch, city,
     SUM(total) AS largest_revenue
FROM Sales
GROUP BY branch, city
ORDER BY largest_revenue DESC;

-- 8. What product line had the largest VAT?

SELECT
	 product_line,
     AVG(VAT) AS value_audit_tax
FROM Sales
GROUP BY product_line
ORDER BY value_audit_tax DESC;


-- 9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

SELECT
	 product_line,
     AVG(total) AS avg_of_product,
     CASE WHEN AVG(total) > (SELECT AVG(total) FROM Sales) THEN 'Good' ELSE 'BAD' END AS Sale_status
FROM Sales
GROUP BY product_line
ORDER BY Sale_status DESC;

-- 10. Which branch sold more products than average product sold?

SELECT
	 branch,
     SUM(quantity) AS qty
FROM Sales
GROUP BY branch
HAVING SUM(quantity) > AVG(quantity);

-- 11. What is the most common product line by gender?

SELECT
	 gender,
     Product_line,
     COUNT(gender) AS total_count
FROM Sales
GROUP BY gender, product_line
ORDER BY total_count DESC;

-- 12. What is the average rating of each product line?

SELECT
     product_line,
     ROUND(AVG(rating), 2) AS avg_rating
FROM Sales
GROUP BY product_line
ORDER BY avg_rating DESC;


-- ------------------------------------------------------------------------------------
-- ---------------------------------- Sales -----------------------------------------

-- 1. Number of sales made in each time of the day per weekday?

SELECT	
	 time_of_day,
     COUNT(*) AS total_sales
FROM Sales
WHERE day_name = 'Monday'
GROUP BY time_of_day
ORDER BY total_sales;

-- 2. Which of the customer types brings the most revenue?

SELECT
	 customer_type,
     MAX(gross_income) AS most_revenue
FROM Sales
GROUP BY customer_type
ORDER BY most_revenue DESC;

# OR

SELECT
	 customer_type,
     SUM(total) AS most_revenue
FROM Sales
GROUP BY customer_type
ORDER BY most_revenue DESC;

-- 3. Which city has the largest tax percent/ VAT (**Value Added Tax**)?

SELECT
	 city,
     COUNT(*) AS largest_vat
FROM Sales
GROUP BY city
Order BY largest_vat DESC;

# OR

SELECT
    city,
    AVG(VAT) AS average_vat
FROM Sales
GROUP BY city
ORDER BY average_vat DESC;
# LIMIT 1;

-- 4. Which customer type pays the most in VAT?

SELECT
	customer_type,
    AVG(VAT) AS Value_Added_Tax
FROM Sales
GROUP BY customer_type
ORDER BY Value_Added_Tax DESC;
# LIMIT 1;


-- ------------------------------------------------------------------------------------
-- ---------------------------------- Customer -----------------------------------------

-- 1. How many unique customer types does the data have?

SELECT
	 DISTINCT customer_type
FROM Sales;

-- 2. How many unique payment methods does the data have?

SELECT
	 DISTINCT payment_method
FROM Sales;

-- 3. What is the most common customer type?

SELECT
	 customer_type,
     COUNT(*) AS count
FROM Sales
GROUP BY customer_type
ORDER BY count DESC;

-- 4. Which customer type buys the most?

SELECT
	 customer_type,
	 COUNT(*) AS custm_buy
FROM Sales
GROUP BY customer_type;

-- 5. What is the gender of most of the customers?

SELECT
	 gender,
	 COUNT(*) AS gender_type
FROM Sales
GROUP BY gender
ORDER BY gender_type DESC;

-- 6. What is the gender distribution per branch?

SELECT
	 branch,
     COUNT(gender) AS gender_count
FROM Sales
GROUP BY branch
ORDER BY gender_count DESC;

# OR

SELECT
	 branch,
     COUNT(gender) AS gender_count
FROM Sales
WHERE branch = "A"
GROUP BY gender
ORDER BY gender_count DESC;

-- 7. Which time of the day do customers give most ratings?

SELECT
	 time_of_day,
     AVG(rating) AS avg_rating
FROM Sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- 8. Which time of the day do customers give most ratings per branch?

SELECT
	 time_of_day,
     AVG(rating) AS avg_rating
FROM Sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- 9. Which day fo the week has the best avg ratings?

SELECT
	 day_name,
	 AVG(rating) AS avg_rating
FROM Sales
GROUP BY day_name
ORDER BY avg_rating DESC LIMIT 1;

-- 10. Which day of the week has the best average ratings per branch?

SELECT
	 day_name,
	 AVG(rating) AS avg_rating
FROM Sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY avg_rating DESC LIMIT 1;

# or at once the resutl generated

SELECT
	 branch,
     day_name,
	 AVG(rating) AS avg_rating
FROM Sales
GROUP BY branch, day_name
ORDER BY branch, avg_rating DESC;
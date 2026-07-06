-- Create a database retail_sales on PostgreeSQL then create table Retail_sales and add all columns 
-- as it is of the dataset then import the data into it 

CREATE TABLE retail_sales(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(10),
    age INT,
    category VARCHAR(50),   
    quantiy INT,
    price_per_unit NUMERIC(10,2),
    cogs NUMERIC(10,2),
    total_sale NUMERIC(10,2)
);
select * from Retail_sales;
---------------------------------------------------------------

-- cleaning the data 

-- 1. count rows

select count(*) from retail_sales;  -- total rows 2000

select count(*) from retail_sales  -- 10 null
where age is NULL;
 

select count(*) from retail_sales  -- 3 null
where price_per_unit is NUll;

select count(*) from retail_sales   -- 3 null
where cogs is NUll;


select count(*) from retail_sales   -- 3 null
where total_sale is NUll;

select count(*) from retail_sales    -- 3 null
where quantiy is NUll;

------------------------------------------------------------------------
-- handling null values

SELECT *
FROM retail_sales
WHERE age IS NULL
   OR total_sale IS NULL
   OR quantiy IS NULL
   OR cogs IS NULL
   OR price_per_unit IS NULL;

-- now will gonna delet the null values rows of(quantity, price_per_unit, cogs, total_sale) 
-- beacuse it does not have the values for it and we cant calculate profit and all so its useless
-- stay the age column as it because there cogs, sales values are given which will be imp 

delete from retail_sales 
where quantiy is null
or price_per_unit is null
or cogs is null
or total_sale is null;

select count(*) from retail_sales; 

---------------------------------------------------------------------------------
-- check duplicate records 
-- duplicate records check mainaly on id columns 

select count(distinct(transactions_id))
from retail_sales;

select transactions_id , count(*) from retail_sales
group by transactions_id
having count(*) > 1;


with cte as(
select * , row_number() over(order by transactions_id) as rn
from retail_sales
)

select * from cte;   -- here we see all values are unique no duplication


----------------------------------------------------------------------------------------------

-- rename the wrong columns

alter table retail_sales rename quantiy to quantity;

select * from retail_sales;


---------------------------------------------------------------------------------

select count(*) from retail_sales;
-------------------------------------------------------------------------
-- check uniqe values for categorical data
select distinct(gender) from retail_sales;

select distinct(category) from retail_sales;

------------------------------------------------------------------------
-- date validate

-- Date Range
SELECT
    MIN(sale_date),
    MAX(sale_date)
FROM retail_sales;


-- if it gives zero then date column is not have problem
-- Count of Future Dates
SELECT COUNT(*)
FROM retail_sales
WHERE sale_date > CURRENT_DATE;
--------------------------------------------------------------------------
-- check the numerical column have any invalid values (negative..etc)

select price_per_unit from retail_sales 
where price_per_unit <= 0;

select total_sale from retail_sales
where total_sale <= 0;

-----------------------------------------------------------------------------
 # now we ready to validate the business decisions.
-----------------------------------------------------------------------------

--1.How much total revenue has the company generated during the available period?

select sum(total_sale) as total_revenue from retail_sales;

-- OR

SELECT COUNT(*) AS total_transactions,
SUM(total_sale) AS total_revenue,
ROUND(AVG(total_sale), 2) AS average_order_value 
FROM retail_sales;


## Insight : Total revenue generated is 911720 for the total transactions 1997 of an 
            avg_order 456. this metrices provide basline overview of sale performance.
----------------------------------------------------------------------------------
--2.Which product category generates the highest revenue?

select category, sum(total_sale) as High_revenue from retail_sales
group by category
order by sum(total_sale) desc
limit 1;


## Insights : Electronics generated the highest revenue among all product categories,
              making it the largest contributor to overall sales.
------------------------------------------------------------------------------------

--3.Which customer age group spends the most?

select * from retail_sales;


SELECT age,
SUM(total_sale) AS revenue
FROM retail_sales
WHERE age IS NOT NULL
GROUP BY age
ORDER BY revenue DESC;


-- but from age groups use ( case when )

select case when age < 18 then 'below 18'
when age between 18 and 25 then '18-25'
when age between 26 and 35 then '26-35'
when age between 36 and 45 then '36-45'
when age between 46 and 60 then '46-60'
else '60+'
end as age_group, 
sum(total_sale) as total_spend from retail_sales
where age is not null
group by age_group 
order by sum(total_sale) desc;



## Insight : Age group between 46-60 spend most to purchase the products 
            they can be the important customer segment for future growth.
			
------------------------------------------------------------------------------------
--4.Which month generated the highest revenue?

SELECT EXTRACT(MONTH FROM sale_date) AS month, sum(total_sale) as high_revenue
FROM retail_sales
group by month
order by sum(total_sale) desc
limit 1;


## Insight : Month 12 generated the highest revenue that shows the 
            large amount of sales happend in december month
			indicating a seasonal increase in sales during this month.
-------------------------------------------------------------------
--5.Who are the Top 10 customers based on total spending?

select customer_id , sum(total_sale) as total_spending
from retail_sales
group by customer_id
order by sum(total_sale) desc
limit 10;

## Insight : The top 10 customers contributed the highest spending and represent high-value customers
             They may be suitable for loyalty programs and personalized offers.
------------------------------------------------------------------
--6.What is the average order value for each category?

select category, round(avg(total_sale), 2) from retail_sales
group by category;


## Insight : Beauty has the highest average order value,
             indicating that customers spend more per transaction in this category.

--------------------------------------------------------------------

-- 7.Which product category is most popular among male and female customers?

select gender , category , count(category) as categories from retail_sales
group by gender , category
order by categories desc
limit 2;

-- OR

with cte as(
select gender,category, count(*) as total_order,
row_number() over(partition by gender order by count(*) desc) as rn
from retail_sales
group by category, gender
)

select * from cte
where rn = 1; 



## Insight : clothing product is most popular across the male and females 
             order of the clothing product is high then other categories.
			 
------------------------------------------------------------------------------------------
--8.top 5 sales date based on revenue

SELECT sale_date, SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY sale_date
ORDER BY total_revenue DESC
LIMIT 5;


## Insight : On 2022/10/10 the total revenue gain is very high.

-------------------------------------------------------------------------------------------
--9.Which category sells the highest quantity of products?

select category, sum(quantity) from retail_sales
group by category
order by sum(quantity) desc
limit 1;



## Insight : the clothing category selles highest quantity products within this. 
--------------------------------------------------------------------------------------------

--10.Which customer made the highest number of purchases?
select customer_id, count(quantity) from retail_sales
group by customer_id
order by count(quantity) desc
limit 1;


## Insight : Customer ID 3 made the highest number of purchases
            indicating a high level of engagement with the business.
---------------------------------------------------------------------------------------------



















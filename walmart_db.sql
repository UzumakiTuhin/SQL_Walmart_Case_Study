Create database Walmart_db;

use Walmart_db;

Create table sales(
	Invoice_id varchar(30) not null primary key,
    Branch varchar(10) not null,
    City varchar(30) not null,
    Customer_type varchar(30) not null,
    Gender varchar(10) not null,
    Product_line varchar(30) not null,
    Unit_price decimal(10,2) not null,
    Quantity int not null,
    VAT Float(6,4) not null,
    Total decimal(12,4) not null,
    Date datetime not null,
    Time time not null,
    Payment_method varchar(30) not null,
    Cogs decimal(10,2) not null,
    Gross_margin_pct float(11,9),
    Gross_income decimal(12,4) not null,
    rating float(2,1)
);

describe sales;

select * from sales;


-- ---------------------------------------------------------------------------
-- ------------------------- Data Wrangling ------------------------- 

-- we have already eliminated all null values from the table while creating the table




-- ---------------------------------------------------------------------------
-- ------------------------- Feature Engineering ------------------------- 

-- Time_of_day

select Time,
	( case 
		when `Time` between "00:00:00" and "12:00:00" then "Morning"
        when `Time` between "12:01:00" and "16:00:00" then "Afternoon"
        else "Evening"
		End
    ) as Time_of_date
from sales;

alter table sales 
add column Time_of_day varchar(20);

update sales 
set Time_of_day = (
case 
	when `Time` between "00:00:00" and "12:00:00" then "Morning"
	when `Time` between "12:01:00" and "16:00:00" then "Afternoon"
	else "Evening"
	End);
    
SET SQL_SAFE_UPDATES = 0;

-- Day_name

select Date,dayname(Date) as Day_name
from sales;

alter table sales 
add column Day_name varchar(10);

update sales 
set Day_name = dayname(Date);

-- Month_name 

Select Date,monthname(Date) as Month_name
from sales;

alter table sales 
add column Month_name varchar(10);

update sales 
set Month_name = monthname(Date);

-- -----------------------------------------------------------------------
-- -------------------------- Exploratory Data Analysis (EDA) ---------------------------


-- -----------------------------------------------------------------------
-- -------------------------- Generic Question ---------------------------

-- How many unique cities does the data have?

select count(distinct city) as  city_cnt
from sales;

-- there are 3 unique cities in this data

-- in which city is each branch?

select distinct city, branch
from sales;

-- -----------------------------------------------------------------------
-- --------------------------- Product ------------------------------------

-- How many unique product lines does the data have?

select count(distinct product_line) as cnt_of_product_lines
from sales;

-- this data have 6 unique product lines

-- What is the most common payment method?

select payment_method,count(payment_method) as cnt
from sales
Group by payment_method 
order by cnt desc;

-- cash is the most common payment method

-- What is the most selling product line?

select product_line, count(quantity) as cnt
from sales 
group by 1
order by 2 desc;

-- Fashion accessories is the most selling product line

-- What is the total revenue by month?

select month_name as month,sum(total) as total_revenue
from sales
group by 1
order by 1;

-- What month had the largest COGS?

select month_name as month, sum(cogs) as total_cogs
from sales 
group by 1
order by 2 desc;

-- January month had the largest COGS

-- What product line had the largest revenue?

select product_line, sum(total) as total_revenue
from sales 
group by 1
order by 2 desc;

-- Food and Beverages has the largest revenue

-- What is the city with the largest revenue?

select city , sum(total) as total_revenue
from sales 
group by 1
order by 2 desc;

-- Naypyitaw has the largest revenue

-- What product line had the largest VAT?

select product_line , avg(vat) as avg_vat
from sales 
group by 1
order by 2 desc;

-- the product line named Hme and lifestyle had the largest Vat 



-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

select avg(total) as avg_sale
from sales;

select product_line,
	(case
		when avg(total) > (select avg(total) from sales) then "Good"
        else "Bad"
        end
	) as Remark
from sales 
group by 1;

-- Which branch sold more products than average product sold?

select branch, avg(quantity) as qty
from sales
group by 1
having qty > (select avg(quantity) from sales); 

-- Branch c sold more product then avg qty


-- What is the most common product line by gender?

select gender, product_line,count(gender) as cnt
from sales 
group by 1,2
order by 3 desc;

-- What is the average rating of each product line?

select product_line, round(avg(rating),2) as avg_rating
from sales 
group by 1 
order by 2 desc;

-- -----------------------------------------------------------------------
-- -------------------------- Sales --------------------------------------

-- Number of sales made in each time of the day per weekday

select time_of_day, count(time_of_day) as total_sales
from sales
group by 1
order by 2 desc;

-- the stores are having more sales in evening

-- Which of the customer types brings the most revenue?

select customer_type, sum(total) as revenue 
from sales 
group by 1
order by 2 desc;

-- the member customer brings most revenue


-- Which city has the largest tax percent/ VAT (**Value Added Tax**)?

select city, round(avg(vat),2) as tax
from sales
Group by 1
order by 2 desc;

-- Naypyitaw has the largest VAT

-- Which customer type pays the most in VAT?

select	customer_type, round(avg(vat),2) as tax
from sales
Group by 1
order by 2 desc;

-- the members pays the most in VAT

-- --------------------------------------------------------------------------
-- --------------------------- Customer -------------------------------------

-- How many unique customer types does the data have?

select count( distinct customer_type) as cnt 
from sales ;

-- This data has 2 different customer type

-- How many unique payment methods does the data have?

select count( distinct payment_method) as cnt
from sales;

-- this data have 3 distinct payment method

-- What is the most common customer type?

select customer_type,count(*) as count 
from sales 
group by 1
order by 2 desc ;

-- Member is the most common customer type

-- Which customer type buys the most?

select customer_type,sum(quantity) as qty
from sales 
group by 1
order by 2 desc;

-- Member customers buys the most

-- What is the gender of most of the customers?

select gender,count(*) as gender_cnt
from sales 
group by 1
order by 2 desc;

-- What is the gender distribution per branch?

select branch,gender,count(gender) as gender_cnt
from sales 
group by 1,2
order by 1;

-- Which time of the day do customers give most ratings?

select time_of_day,round(avg(rating),2) as ratings
from sales
group by 1
order by 2 desc;	

-- the customers gave most ratings in afternoon

-- Which time of the day do customers give most ratings per branch?

select branch,time_of_day,round(avg(rating),2) as ratings
from sales
group by 1,2
order by 1,3 ;

-- Which day of the week has the best avg ratings?

select day_name,round(avg(rating),2) as ratings
from sales
group by 1
order by 2 desc ;

--  Monday, Friday, Tuesday have the best avg ratings

-- Which day of the week has the best average ratings per branch?

select branch,day_name,round(avg(rating),2) as ratings
from sales
group by 1,2
order by 1,3 desc ; 

-- ---------------------------------------------------------------
-- ----------------------------------------------------------------
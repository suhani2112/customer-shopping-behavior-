select * from customer limit 20 

-- 1 . what is the total revenue genertaed by male vs female customer 
select gender , SUM (purcahse_amount) as revenue
from customer
group by gender 

--2 which customers used discount but still spent more than the avg purchase amt

select customer_id , purcahse_amount 
from customer 
where discount_applied = 'Yes' and purcahse_amount >= (select AVG(purcahse_amount) from customer)

-- 3. which are the top 5 products with higghest avg review rating

select item_purchased , ROUND(AVG(review_rating:: numeric ),2) as "Average Product Rating"
from customer
group by item_purchased
order by avg(review_rating) desc
limit 5 ;

-- 4 . compare the avg purcahse amt between express and standard shipping

select shipping_type ,
ROUND(AVG(purcahse_amount),2)
from customer
where shipping_type in ('Standard' , 'Express')
group by shipping_type 

-- 5 . do subscribed customers spend more ? comppare avg spent and total revenue between subscribers and non subscribers

select subscription_status , 
COUNT (customer_id) as total_customer,
ROUND(AVG(purcahse_amount),2) as avg_spend,
ROUND(SUM(purcahse_amount),2) as total_revenue
from customer
group by subscription_status
order by total_revenue , avg_spend desc ;

--6 which 5 products have the highest percentage of purchase with discount applied

select item_purchased ,
ROUND(100 * SUM( CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/ COUNT(*),2) as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5 ;

-- 7 . segment customer into new , returning , loyal based on their total number of prev purchase and show the cpunt pf each segment

with customer_type as(
select customer_id , previous_purchases,
CASE
	WHEN previous_purchases = 1 THEN 'New'
	WHEN previous_purchases BETWEEN 2 AND 10 THEN ' Returning'
	ELSE 'loyal'
	END AS customer_segment
from customer
)

select customer_segment, count(*) as "Number of Customers"
from customer_type
group by customer_segment

-- 8 what are the top 3 most purchased product within each category

with item_counts as(
select category ,
item_purchased ,
count(customer_id) as total_orders,
ROW_NUMBER() over(partition by category order by count(customer_id) DESC) as item_rank
from customer
group by category, item_purchased
)
select item_rank, category, item_purchased, total_orders
from item_counts
where item_rank<=3;

-- 9 are customers who are repeat buyers more than 5 prev purchases also likely to suubscribers

select subscription_status ,
count(customer_id) as repeat_buyers
from customer
where previous_purchases > 5
group by subscription_status

--10 what is the revenue contribute of each age grp

select age_group, 
sum(purcahse_amount) as total_revenue
from customer
group by age_group 
order by total_revenue desc ; 
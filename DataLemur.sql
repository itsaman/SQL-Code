--Cities With Completed Trades
SELECT distinct u.city, count(1) as total_orders
FROM trades t
inner join users u
on t.user_id = u.user_id
where status = 'Completed'
group by u.city
order by total_orders desc
limit 3

--Page With No Likes
SELECT p.page_id FROM pages p
left join page_likes pl
on p.page_id = pl.page_id
where liked_date is NULL
order by p.page_id

--Laptop vs Mobile Viewership
SELECT 
sum(case when device_type ='laptop' then 1 else 0 end) as "laptop_views",
sum(case when device_type = 'tablet' or device_type = 'phone' then 1 else 0 end) as "mobile_views"
FROM viewership

--Purchasing Activity by Product Type
SELECT order_date,product_type,
sum(quantity)over(partition by product_type order by order_date) as cum_purchased
FROM total_trans
order by order_date

--Teams Power Users
SELECT sender_id, count(message_id) as co
FROM messages
where extract(month from sent_date) = 8 and  EXTRACT(YEAR FROM sent_date) = '2022'
group by sender_id
order by co desc
limit 2

--Highest Number of Products
with temp as (
  SELECT user_id, sum(spend) as total , count(product_id) as co
  from user_transactions
  group by user_id
  having sum(spend) >= 1000
  order by co desc, total desc
)
select user_id, co as product_num
from temp
LIMIT 3

--Histogram of Tweets

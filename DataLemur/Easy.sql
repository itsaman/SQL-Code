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

---- ***Histogram of Tweets***
with temp as(
  SELECT user_id, count(1) as co FROM tweets
  where extract(year from tweet_date) = 2022
  group by user_id
  )
select 
  co as tweet_bucket,
  count(user_id)
from temp
group by co


--- Spare Server Capacity

select dc.datacenter_id, dc.monthly_capacity - temp.total 
from (
  SELECT datacenter_id, sum(monthly_demand) as total
  FROM customers cu
  join forecasted_demand jd
  on cu.customer_id = jd.customer_id
  group by datacenter_id
) temp 
join datacenters dc
on temp.datacenter_id = dc.datacenter_id
order by datacenter_id

-- **Repeat Purchases on Multiple Days**
WITH temp as (
SELECT *, count(user_id)over(partition by DATE(purchase_date),user_id) as rn
FROM purchases
)
select count(distinct user_id) from temp
where user_id not in(select distinct user_id from temp where rn >=2)

--Duplicate Job Listings
select count(distinct company_id) from 
(
select company_id, title, description, count(*)
from job_listings jl
group by company_id, title, description
having count(*)>1
) temp


--Average Post Hiatus (Part 1)
with temp as(
  select user_id, count(1) as co
  from posts
  where EXTRACT(year from post_date) = '2021'
  group by user_id 
  having count(1)>1
), temp2 as(
  select *,
  dense_rank()over(partition by user_id order by post_date) as first
  from posts
  where user_id in (select user_id from temp)
), temp3 as (
  select *,
  dense_rank()over(partition by user_id order by post_date desc) as last
  from posts
  where user_id in (select user_id from temp)
)
select t1.user_id, date_part('day', t2.post_date-t1.post_date)
from temp2 t1
inner join temp3 t2
on t1.user_id = t2.user_id
where t1.first = 1 and t2.last = 1

---**Data Science Skills**-----

with temp as(
select candidate_id from candidates
where skill in ('Python', 'Tableau', 'PostgreSQL')
)
select candidate_id from (
select candidate_id, count(1) as co from temp
group by candidate_id
having count(1)>=3
)temp2

--Final Account Balance

with temp as(
SELECT *,
case when transaction_type = 'Withdrawal' then amount*-1 else amount end as new_amount
FROM transactions
)
select  account_id , sum(new_amount) as final_balance
from temp
group by account_id

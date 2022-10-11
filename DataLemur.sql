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

---User's Third Transaction---

with temp as(
SELECT user_id, spend, transaction_date, dense_rank()over(partition by user_id order by transaction_date) as rn
FROM transactions
)
select user_id, spend, transaction_date 
from temp
where rn = 3 

--Compensation Outliers
with temp as(
SELECT *,AVG(salary)over(partition by title) as avg_sal,
  case when salary > 2* (AVG(salary)over(partition by title)) then 'Overpaid'   
       when salary < (AVG(salary)over(partition by title))/2 then 'Underpaid' 
end as status
FROM employee_pay
)
select employee_id,salary,status from temp
where status is not null
order by employee_id


--***Sending vs. Opening Snaps***----

with temp as(
    SELECT age_bucket,
    sum(case when activity_type = 'open' then time_spent else 0 end) as "open",
    sum(case when activity_type = 'send' then time_spent else 0 end) as "send",
    sum(time_spent) as total
    FROM activities act
    join age_breakdown age
    on act.user_id = age.user_id
    where activity_type in ('send','open')
    group by age_bucket
)
select  age_bucket, 
        ROUND((send/total)*100.0,2) as send_per, 
        ROUND((open/total)*100.0,2) as open_per  
from temp


----Odd and Even Measurements
with temp as (
  SELECT *, 
  row_number()over(partition by EXTRACT(DAY from measurement_time) order by measurement_time::timestamp::time) as rn
  FROM measurements
)
select DATE(measurement_time) as measurement_day, 
sum(case when rn%2 !=0 then measurement_value else 0 end) as "odd_sum",
sum(case when rn%2 = 0 then measurement_value else 0 end) as "even_sum"
from temp
group by DATE(measurement_time)
order by DATE(measurement_time) 


---*** Frequently Purchased Pairs ***----

with CTE_TEMP as(
SELECT 
      tr.transaction_id, 
      tr.product_id, 
      tr.user_id,
      pr.product_name
FROM transactions tr
join products pr
on tr.product_id = pr.product_id
)
select t1.product_name as product1, 
       t2.product_name as product2, 
       count(1) as combo_num 
from CTE_TEMP t1
join CTE_TEMP t2 
on t1.transaction_id = t2.transaction_id 
and t1.product_id > t2.product_id
GROUP BY t1.product_name , t2.product_name
order by combo_num desc
limit 3


--Highest-Grossing Items
with temp as(
  SELECT distinct category, product, sum(spend)over(partition by category,product) as total
  FROM product_spend
  where EXTRACT(Year from transaction_date) = '2022'
), temp2 as(
  select *, dense_rank()over(PARTITION BY category order by total desc) as dk
  from temp
)
select category, product, total from temp2 
where dk <=2;


---First Transaction

with temp as(
select *, dense_rank()over(partition by user_id order by transaction_date) as dk
from user_transactions
)
select count(distinct user_id) from temp
where dk = 1 and spend>=50


--LinkedIn Power Creators (Part 2)

with temp as(
  SELECT pp.profile_id,pp.name,pp.followers,ec.company_id, cp.name, cp.followers,
  case when pp.followers>cp.followers then 1 else 0 end as "filter"
  from personal_profiles pp
  join  employee_company ec
  on pp.profile_id = ec.personal_profile_id
  inner join company_pages cp
  on ec.company_id = cp.company_id
  )
select distinct profile_id from temp where profile_id not in(
select distinct profile_id from temp where filter= 0
)
order by profile_id

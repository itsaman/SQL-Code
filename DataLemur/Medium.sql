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


--User Shopping Sprees
with temp as(
  SELECT *,
  EXTRACT(DAY FROM transaction_date)-row_number()over(partition by user_id order by transaction_date) as rn
  FROM transactions
), temp2 as(
  select user_id, rn, count(1)
  from temp
  group by  user_id, rn
  having count(1)>=3
)
select distinct user_id from temp2

--Photoshop Revenue Analysis
with temp as(
  SELECT *
  FROM adobe_transactions
  where customer_id in (select customer_id from adobe_transactions where product = 'Photoshop')
)
select customer_id, sum(revenue) 
from temp 
where product != 'Photoshop'
group by customer_id
order by customer_id

--Popularity Percentage

with temp as(
select user1 as user,count(*) as c1 from facebook_friends
group by user1
union 
select user2 as user,count(*) as c1 from facebook_friends
group by user2
)
select t.user, (sum(c1)/count(*)over())*100 as popularity_percent
from temp t
group by t.user 
order by t.user


--Classify Business Type
select distinct business_name,
case when lower(business_name) like '%school%' then 'school' 
     when lower(business_name) like '%restaurant%' then 'restaurant'
     when lower(business_name) like '%coffee%' or lower(business_name) like '%cafe%' or lower(business_name) like '%café%' then 'cafe'
else 'other'
end as business_type
from sf_restaurant_health_violations


--Customer Revenue In March
select cust_id,
sum(total_order_cost) as revenue
from orders
where date_part('month',order_date) = 3
group by cust_id
order by revenue desc


--Finding User Purchases
select distinct a.user_id
from amazon_transactions a
left join amazon_transactions b
on a.user_id = b.user_id
where a.id>b.id
and abs(datediff(a.created_at, b.created_at))<=7


--Top 5 States With 5 Star Businesses
select distinct state, count(business_id) as co from yelp_business
where stars = 5
group by state
order by co desc, state asc
limit 6



--Workers With The Highest Salaries
with temp as (
    select w.worker_id, w.first_name, w.salary,t.worker_title,
    dense_rank()oveR(order by salary desc) as dk
    from worker w
    inner join title t
    on w.worker_id = t.worker_ref_id
) 
select worker_title from temp 
where dk = 1 
order by worker_title


--Highest Target Under Manager
with temp as (
select first_name, target 
from salesforce_employees
where manager_id = 13 
)
select * from temp 
where target = (select max(target) from temp )


--Number of violations
select distinct extract(year from inspection_date), 
        count(*)over(partition by extract(year from inspection_date))
from sf_restaurant_health_violations
where business_name = 'Roxanne Cafe' 
and violation_id is not null;


--Host Popularity Rental Prices
with temp as(
    select distinct
    concat(price, room_type, host_since, zipcode, number_of_reviews) as host_id,
        number_of_reviews,
        price
    from airbnb_host_searches
), temp2 as(
select price,
case when number_of_reviews = 0 then 'New'
    when number_of_reviews between 1 and 5 then 'Rising'
    when number_of_reviews between 6 and 15 then 'Trending Up'
    when number_of_reviews between 16 and 40 then 'Popular'
     WHEN number_of_reviews > 40 THEN 'Hot'
end as "popularity_rating"
from temp 
)
select popularity_rating, min(price), avg(price), max(price)
from temp2
group by popularity_rating


--Marketing Campaign Success [Advanced]
SELECT count(DISTINCT user_id)
FROM marketing_campaign
WHERE user_id in
    (SELECT user_id
     FROM marketing_campaign
     GROUP BY user_id
     HAVING count(DISTINCT created_at) >1
     AND count(DISTINCT product_id) >1)
  AND concat((user_id),'_', (product_id)) not in
    (SELECT user_product
     FROM
       (SELECT *,
               rank() over(PARTITION BY user_id
                           ORDER BY created_at) AS rn,
               concat((user_id),'_', (product_id)) AS user_product
        FROM marketing_campaign) x
     WHERE rn = 1 )
     
     --Premium vs Freemium
     
     
with temp as(
select date,
sum(case when paying_customer = 'no' then downloads end) as s1,
sum(case when paying_customer = 'yes' then downloads end) as s2
from ms_acc_dimension acc
inner join ms_user_dimension usr
on acc.acc_id = usr.acc_id
inner join ms_download_facts dow
on usr.user_id = dow.user_id
group by date
order by date
)
select t.date, s1 as non_paying, s2 as paying
from temp t 
where s1>s2

--Reviews of Categories
--NBM
select unnest(string_to_array(categories,';')), sum(review_count) as total
from yelp_business
group by unnest(string_to_array(categories,';'))
order by total desc


--Employee and Manager Salaries
select distinct e1.first_name, e1.salary 
from employee e1
join employee e2
on e1.manager_id = e2.id
where e1.salary>e2.salary

--Highest Salary In Department
with temp as(
select *, dense_rank()over(partition by department order by salary desc) as dk from employee
)
select department,first_name, salary
from temp
where dk =1 
order by salary desc;

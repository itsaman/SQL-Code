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

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

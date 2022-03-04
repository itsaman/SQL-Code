--Pivot
select 
	emp_id, 
	sum(case when salary_component_type = 'salary' then val else null end) as Salary,
	sum(case when salary_component_type = 'bonus' then val else null end) as Bonus,
	sum(case when salary_component_type = 'hike_percent' then val else null end) as Hike
from emp_compensation
group by emp_id


--unpivot
select * from emp_compensation_pivot

select emp_id, 'salary' as salary_component_type, salary as val from emp_compensation_pivot
union all 
select emp_id, 'bonus' as salary_component_type, bonus as val from emp_compensation_pivot
union all
select emp_id, 'hike' as salary_component_type, hike as val from emp_compensation_pivot
order by emp_id

--complex query --1 || Derive Points table for ICC tournament

with temp as (
	select team_1 as team_name, case when team_1 = winner then 1 else 0 end as win_flag
	from icc_world_cup
	union all
	select team_2 as team_name, case when team_2 = winner then 1 else 0 end as win_flag
	from icc_world_cup
)
select team_name, count(team_name) as matches, sum(win_flag) as win, (count(team_name)-sum(win_flag)) as loss
from temp
group by team_name
order by matches desc

-- complex query -2 || Repeated customers
--new customer
with temp as (
select customer_id, min(order_date) as first_date
from customer_orders
group by customer_id
), joined_table as (
select *,
	case when order_date = first_date then 1 else 0 end as new_customer,
	case when order_date != first_date then 1 else 0 end as old_customer
from customer_orders co
inner join temp t 
on t.customer_id = co.customer_id
)
select order_date, sum(new_customer), sum(old_customer)
from joined_table
group by order_date 
order by order_date


-- amount by new customer and old customer

with temp as (
select customer_id, min(order_date) as first_date
from customer_orders
group by customer_id
), joined_table as (
select *,
	case when order_date = first_date then 1 else 0 end as new_customer,
	case when order_date != first_date then 1 else 0 end as old_customer,
	case when order_date = first_date then order_amount else 0 end as new_ammount,
	case when order_date != first_date then order_amount else 0 end as old_amount
from customer_orders co
inner join temp t 
on t.customer_id = co.customer_id
)
select order_date, sum(new_customer), sum(old_customer), sum(new_ammount), sum(old_amount)
from joined_table
group by order_date 
order by order_date

--complez queries - 3 

with temp as (
select *,count(floor) over(partition by name) as total_visits, 
count(floor)over(partition by floor,name) as floor_count
from entries
), temp2 as (
select *, dense_rank()over(partition by name order by floor_count desc) as dk
from temp
), temp3 as(
select distinct name, resources,floor, total_visits, dk
from temp2
), temp4 as (
select name,floor, total_visits,string_agg(resources, ',')over(partition by name) as resources, dk
from temp3
)
select name, floor, total_visits, resources from temp4
where dk =1 



--complex query - 10

with temp as (
	select *, row_number()over(order by date_value), (
		   date_part('day', date_value) - row_number()over(order by date_value)) as diff
	from tasks
	where state = 'success'
), temp2 as (
select *, row_number()over(order by date_value), 
	   (date_part('day', date_value) - row_number()over(order by date_value)) as diff
	from tasks
	where state = 'fail'
), res as (
select * from temp
union all 
select * from temp2
)
select distinct min(date_value)over(partition by diff) as start_date, 
				max(date_value)over(partition by diff) as end_date, 
				state
from res 


--complex query - 9||Market Analysis2 

with temp as (
select *, count(order_date)over(partition by seller_id) as co, 
	dense_rank()over(partition by seller_id order by order_date) as dk
from users urs
left join orders ord
on ord.seller_id = urs.user_id
left join items itm
on ord.item_id = itm.item_id
),temp2 as (
select *, 
case when co >= 2 and dk = 2 and favorite_brand = item_brand then 'yes'
	 when co<2 then 'no'
else 'no'
end as status
from temp
)
select distinct user_id as seller_id, order_date, favorite_brand, item_brand, status
from temp2
where dk =2 or co<2
order by user_id 

-- Game play Analysis ---

select * from activity

--first login date 
with temp as (
select *, dense_rank()over(partition by player_id order by event_date) as dk 
from activity
)
select * from temp 
where dk = 1

--2
with temp as (
select *, row_number()over(partition by player_id order by device_id) as dk 
from activity
)
select * from temp 
where dk = 1 

--3
select player_id, event_date, sum(games_played)over(partition by player_id order by event_date)
from activity

--4
with temp as (
select *, 
lag(event_date)over(partition by player_id order by event_date) as l1,
event_date - lag(event_date)over(partition by player_id order by event_date) as diff
from activity
)
select round(count(diff)/count(*),2) as fraction
from temp 
where diff = 1 

--






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

--Full outer Join
with temp as (
select e1.emp_id as old_id, e2.emp_id as new_id, e1.designation as old_Desi, e2.designation as new_desi from emp_2020 e1
full join emp_2021 e2
on e1.emp_id = e2.emp_id
), temp2 as (
select coalesce(old_id,new_id) as id, 
	case when new_desi is null then 'Resigned'
		 when old_Desi is null then 'New Joiner'
		 when old_Desi != new_desi then 'Promoted'
		 else  'Null'
	end as Comments
from temp
)
select * from temp2 
where comments != 'Null'

--Second Most Recent Activity (NM)
with temp as(
select *,count(1)over(partition by username) as co,
row_number()over(partition by username order by enddate) as rn
from UserActivity
)
select * from temp 
where co = 1 or rn = 2

--SCD 2 implementation(NM)

select * from billings;
select * from HoursWorked;

with date_range as (
select *, 
lead(DATE(bill_date - INTERVAL '1 DAY'),1,'9999-12-31')over(partition by emp_name order by bill_date) as bill_end_date
from billings
)
select dr.emp_name, sum(bill_rate*bill_hrs)
from date_range dr
inner join HoursWorked hw
on dr.emp_name = hw.emp_name and hw.work_date between dr.bill_date and dr.bill_end_date
group by dr.emp_name


--Calculate Mode in SQL

with temp as (
select *, count(id)over(partition by id)  as co from mode
)
select distinct id from temp 
where co = (select max(co) from temp)

with temp as (
select id, count(id) as co from mode
group by id )
select distinct id from temp 
where co = (select max(co) from temp)


--Amazon Prime Subscription Rate SQL
with temp as (
select e.user_id, name, join_date, type, access_date, count(name)over(partition by type) as co
from users2 u
inner join events e on u.user_id = e.user_id
where type = 'Music'
),
temp2 as (
select u.user_id, count(u.user_id)over() as co2
from users2 u
inner join events e on u.user_id = e.user_id
where (access_date - join_date) < 30 and type = 'P'
)
select  temp2.co2,temp.co, (temp2.co2*100/ temp.co)
from temp
join temp2 on temp.user_id = temp2.user_id


--Recommendation System(NM)

select concat(p2.name,' ',p1.name) as pair, count(1) as purchase_freq
from orders2 o1
join orders2 o2
on o1.order_id = o2.order_id and o1.product_id > o2.product_id
inner join products p1 on p1.id = o1.product_id 
inner join products p2 on p2.id = o2.product_id 
group by  p1.name, p2.name


--Rank the duplicate records
 
with temp1 as (
	select id, count(1) as co from list group by id having count(1) > 1
),
temp2 as (
	select id, count(1) as co from list group by id having count(1) = 1
)
select id, concat('DUP',dense_rank()over(order by id)) from list
where id in (select id from temp1)
union all 
select id, case when co = 1 then 'NULL' end as res from temp2
where co = 1
order by id 



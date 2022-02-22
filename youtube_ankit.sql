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

--Derive Points table for ICC tournament

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

-- Repeated customers
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


--complex query - 10

with temp as (
	select *, row_number()over(order by date_value), (date_part('day', date_value) - row_number()over(order by date_value)) as diff
	from tasks
	where state = 'success'
), temp2 as (
select *, row_number()over(order by date_value), (date_part('day', date_value) - row_number()over(order by date_value)) as diff
	from tasks
	where state = 'fail'
), res as (
select * from temp
union all 
select * from temp2
)
select distinct min(date_value)over(partition by diff) as start_date, max(date_value)over(partition by diff) as end_date, state
from res 




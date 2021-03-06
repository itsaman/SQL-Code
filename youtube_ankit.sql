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

--Consecutive Empty Seats

--M1 Row_number
with temp as (
select seat_no,is_empty, (seat_no-row_number()over()) as rn from bms
where is_empty = 'Y'
), temp2 as(
select seat_no,is_empty, count(rn)over(partition by rn) as rn2
from temp 
)
select seat_no from temp2
where rn2>=3

--M2 lag/lead

with temp as (
select *,
lag(is_empty,1)over(order by seat_no) as prev_1,
lag(is_empty,2)over(order by seat_no) as prev_2,
lead(is_empty,1)over(order by seat_no) as next_1,
lead(is_empty,2)over(order by seat_no) as next_2
from bms
)
select * from temp
where is_empty = 'Y' and prev_1 = 'Y' and prev_2 = 'Y'
or is_empty = 'Y' and next_1 = 'Y' and next_2 = 'Y'
or is_empty = 'Y' and next_1 = 'Y' and prev_1 = 'Y'


--Deadly Combination
--M1
with temp as (
select *,
count(student_id)over(partition by student_id) as co,
lag(marks)over(partition by student_id order by subject) as lg1
from exams
)
select * from temp
where co=2 and marks = lg1

--M2
--using group by 
select student_id
from exams
where subject in ('Chemistry', 'Physics')
group by student_id
having count(subject) =2 and count(distinct marks) =1


--Beauty of SQL RANK Function
with temp as (
select *, cases - lag(cases)over(partition by city order by days) as lg1
from covid
)
select distinct city from temp where city not in ( 
select city from temp 
where lg1<0
)


----Google SQL Interview Question
with temp as (
select *, 
row_number()over(partition by company_id, user_id order by language) as rn from company_users
where language not in ('Spanish')
)
select company_id, count(*) from temp
where rn = 2
group by company_id
having count(*)>=2

--Meesho SQL questsion

with temp as (
select *, budget-cost as diff 
from products2, customer_budget
where cost<budget
)
select customer_id,budget,count(*), STRING_AGG(product_id,',') as products
from temp
where diff>= cost
group by customer_id,budget
order by customer_id


----Horizontal Sorting in SQL (NBM)
with temp as(
select sms_date,
case when sender<receiver then sender else receiver end as p1,
case when sender>receiver then sender else receiver end as p2,
sms_no
from subscriber
)
select p1, p2, sum(sms_no)
from temp
group by p1, p2

--1
-- student scored above the avg marks in each subject
with temp as (
select *, avg(marks)over(partition by subject) as avg_marks from students
)
select * from temp
where marks>avg_marks

--2 
with temp as(
select count(distinct studentname) as co from students
where marks>90
)
select co*100/(select count(distinct studentname) from students)
from temp 

--3 second heighest and second lowest for each subjects

with t1 as(
select * from (
select subject,marks, dense_rank()over(partition by subject order by marks desc) as heigh
from students) temp where heigh = 2 
), t2 as (
select * from (
select subject, marks,dense_rank()over(partition by subject order by marks asc) as low 
from students) temp where low =2
)
select t1.subject, t1.marks as second_heighest, t2.marks as second_lowest
from t1
inner join t2
on t1.subject = t2.subject 

--better query

select subject, sum(case when heigh = 2 then marks else null end) as second_heighest,
sum(case when low =2 then marks else null end) as second_lowest
from(
select subject, marks, dense_rank()over(partition by subject order by marks desc) as heigh,
dense_rank()over(partition by subject order by marks asc) as low 
from students) temp
group by subject

--4
select *, case when marks>lg then 'inc' else 'dec' end as status
from (
select *,
lag(marks)over(partition by studentid order by studentid, subject) as lg
from students) temp

-- Count Occurrence of a Character
--1 count spaces

select name, replace(name,' ',''), 
length(name)-length(replace(name,' ','')) as cnt
from strings

--2
select name, replace(name,'Ak',''), 
(length(name)-length(replace(name,'Ak','')))/length('Ak') as cnt
from strings

----Brilliant SQL Interview Question 
--no Subquery, WF, CTE
--NBM
select t1.order_number, t1.order_date,t1.salesperson_id,t1.amount
from int_orders t1
left join int_orders t2
on t1.salesperson_id=t2.salesperson_id 
group by t1.order_number,t1.order_date,t1.cust_id,t1.salesperson_id,t1.amount
having t1.amount>=max(t2.amount)

---SQL ON OFF Problem
--NBM

with temp2 as (
select *,
sum(case when status = 'on' and lg = 'off' then 1 else 0 end)over(order by event_time) as group_key
from( 
select *,
lag(status, 1, status)over(order by event_time) as lg
from event_status)temp
)
select 
min(event_time) as login_time, max(event_time) as log_out, count(1)-1 as cnt
from temp2 
group by group_key


--Students Reports By Geography 
--NBM
select player_group,
min(case when city = 'Mumbai' then name else null end) as Mumbai,
min(case when city = 'Delhi' then name else null end )as Delhi,
min(case when city = 'Bangalore' then name else null end) as Bangalore
from(select *,
row_number()over(partition by city order by name asc) as player_group
from players_location) temp 
group by player_group 
order by player_group


-- Most Asked SQL Problem with a Twist
with temp as(
select *, dense_rank()over(partition by dep_name order by salary desc) as dk,
count(*)over(partition by dep_name) as co
from emp
), temp2 as(
select *, dense_rank()over(partition by dep_name order by salary asc) as dk2 from temp
where co<3
)
select emp_id, emp_name, salary, dep_id, dep_name from temp 
where dk =3
union
select emp_id, emp_name, salary, dep_id, dep_name from temp2
where dk2 = 1


--SQL Interview Question Asked by Udaan

with temp as(
select *,
dense_rank()over(partition by city_id order by extract(year from business_date)) as rn
from business_city
)
select extract(year from business_date) as year, count(1) from temp
where rn = 1 
group by extract(year from business_date)


--PharmEasy SQL| Consecutive Seats in a Movie Theatre
--NBM

with temp1 as(
select *, left(seat,1) as row_id, cast(substring(seat,2,2) as int) as seat_id from movie
), temp2 as (
select *, 
max(occupancy) over(partition by row_id order by seat_id rows between current row and 3 following) as status,
count(occupancy) over(partition by row_id order by seat_id rows between current row and 3 following) as cnt
from temp1
), temp3 as (
select * from temp2 where status = 0 and cnt = 4
)
select temp2.* from temp2 inner join temp3 on temp2.row_id = temp3.row_id and temp2.seat_id between temp3.seat_id and temp3.seat_id+3


--Bosch Scenario Based SQL

with temp as(
select *, sum(call_duration)over(partition by call_number, call_type) as sum_no from call_details
where call_number in(
	select call_number from call_details
	where call_type ='INC'
	INTERSECT
	select call_number from call_details
	where call_type ='OUT'
)
), temp2 as(
select distinct call_type, call_number,sum_no, lag(sum_no)over(partition by call_number) as inc_no  
	from temp
)
select distinct * from temp2
where sum_no>inc_no and call_type != 'SMS'


--2 approach
with temp as(
select call_number,
sum(case when call_type = 'INC' then call_duration else 0 end) as inc_dur,
sum(case when call_type = 'OUT' then call_duration else 0 end) as out_dur
from call_details
group by call_number
)
select * from temp
where inc_dur !=0 and out_dur !=0 and inc_dur<out_dur

--#3 Approach
select call_number,
sum(case when call_type = 'INC' then call_duration else 0 end) as inc_dur,
sum(case when call_type = 'OUT' then call_duration else 0 end) as out_dur
from call_details
group by call_number
Having sum(case when call_type = 'INC' then call_duration else 0 end)>0  and
sum(case when call_type = 'OUT' then call_duration else 0 end)>0 and 
sum(case when call_type = 'OUT' then call_duration else 0 end) > sum(case when call_type = 'INC' then call_duration else 0 end);

--#4 Approach
with temp1 as(
select call_number, sum(call_duration) as out_dur
from call_details
where call_type = 'OUT'
group by call_number
),temp2 as(
select call_number, sum(call_duration) as inc_dur
from call_details
where call_type = 'INC'
group by call_number
)
select temp1.call_number 
from temp1
inner join temp2 on temp1.call_number  = temp2.call_number and  out_dur>inc_dur

---###Last Not Null Value###
--NBM

with temp1 as(
select *,
row_number()over(order by (select null)) as rn
from brands
), temp2 as(
select *, lead(rn,1,100)over(order by rn) as rn2 from temp1
where category is not null 
)
select temp2.category, temp1.brand_name
from temp1 
inner join temp2 on temp1.rn >= temp2.rn and temp1.rn <= temp2.rn2



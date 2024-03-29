--Olympic Gold Medals Problem
select distinct gold, count(gold)over(partition by gold)
from events2 
where gold in (
	select gold as name from events2
	except 
	select silver as name from events2
	except 
	select bronze as name  from events2
)
order by gold


--Leetcode-1412 Hard SQL Problem | Find the Quiet Students in All Exams

with temp as (
	select s2.*, e2.exam_id, e2.score 
	from students2 s2
	inner join exams2 e2
	on s2.student_id = e2.student_id
), temp2 as(
	select *, max(score)over(partition by exam_id) as maxi,
	min(score)over(partition by exam_id) as mini
	from temp
)
select student_id, student_name 
from temp2 
where score != maxi and score != mini
except
select student_id, student_name 
from temp2 where score = maxi or score = mini

--Walmart Labs SQL Interview Question
with temp as (
	select *, row_number()over(partition by callerid,date(datecalled) order by datecalled) as min_c,
	row_number()over(partition by callerid,date(datecalled) order by datecalled desc) as max_c
	from phonelog
), temp2 as (
	select *,lag(recipientid)over(partition by callerid, date(datecalled)) as lg from temp
	where min_c = 1 or max_c = 1 
)
select callerid, recipientid, date(datecalled) from temp2 where recipientid = lg

--Microsoft SQL Interview Question for Data Engineer Positions
with t1 as (
	select *, 70000- sum(salary)over(order by salary asc) as s1 from candidates
	where experience = 'Senior'
), t2 as (
	select *, 70000-s1 as total from t1
	where s1 < 70000
), t3 as (
	select *, sum(salary)over(order by salary asc) as s2 from candidates
	where experience = 'Junior'
), t4 as (
	select * from t3 
	where s2<(select min(total) from t2)
)
select emp_id,experience,salary from t2 
union 
select emp_id,experience,salary from t4

--2 Approach:
with t1 as (
	select *, sum(salary)over(order by salary asc) as s1 from candidates
), t2 as (
	select * from t1
	where s1 < 70000 and experience = 'Senior'
), t3 as(
	select * from t1
	where experience = 'Junior' and  s1 <= (70000 - (select sum(salary) from t2))
)
select emp_id,experience,salary from t2 
union 
select emp_id,experience,salary from t3

--2023
--Interview Question Asked in a Startup
with t1 as (
	select *, row_number()over() as rn from call_start_logs
	),
	t2 as (
		select *, row_number()over() as rn from call_end_logs
	)
select t1.phone_number, t1.start_time, t2.end_time, Extract(epoch from (end_time-start_time))/60 as diff  
from t1
join t2 on t1.rn = t2.rn 


-------Case Study by A Major Travel Company-----------

--1 
with t1 as (
	--total no of users
select segment, count(1) as total_user from user_table
group by segment
), t2 as (
	-- no of flights booked
select ut.segment, count(distinct bt.user_id) as booked_flight from booking_table bt 
left join user_table ut
on bt.user_id = ut.user_id
where bt.line_of_business = 'Flight' 
and bt.booking_date between '2022-04-01' and '2022-04-30'
group by ut.segment
)
select t1.segment, t1.total_user, t2.booked_flight
from t1 join t2 on t1.segment = t2.segment
order by t1.segment;


--2 

with temp as(
select *, dense_rank()over(partition by bt.user_id order by booking_date) as dk
from booking_table bt 
)
select * from temp
where dk = 1 and line_of_business = 'Hotel';

--3 days b/w first booking and last booking 

select user_id, max(booking_date), min(booking_date), (max(booking_date)- min(booking_date))  as days_between
from booking_table
group by user_id;


--4 

select segment, 
sum((case when bt.line_of_business = 'Flight' then 1 else 0 end)) as flights,
sum((case when bt.line_of_business = 'Hotel' then 1 else 0 end)) as hotel 
from booking_table bt
join user_table ut
on ut.user_id = bt.user_id
where EXTRACT('Year' FROM bt.booking_date) = '2022' 
group by segment;

--1 to fetch all the duplicate records in a table.
SET search_path = revision;

select * from (
select *, row_number()over(partition by email order by user_name) as rk
from users) temp
where rk>=2

--2 to fetch the second last record from employee table.
with temp as (
select *,row_number()over(order by emp_id desc) as rn
from employee)
select * from temp 
where rn = 2

--3 to display only the details of employees who either earn 
-- the highest salary or the lowest salary in each department from the employee table.

select emp_id,emp_name,dept_name,salary,
case when dk = 1 or dk2= 1 then min(salary)over(partition by dept_name) end as min_Salary,
case when dk = 1 or dk2= 1 then max(salary)over(partition by dept_name) end as max_Salary
from (
select *, dense_rank()over(partition by dept_name order by salary asc) as dk,
dense_rank()over(partition by dept_name order by salary desc) as dk2
from employee) temp
where dk =1 or dk2 = 1

--4 fetch the details of doctors who work in the same hospital but in different specialty.

select a.* 
from doctors a , doctors b
where a.hospital = b.hospital
and a.speciality != b.speciality

--Same hospital different speciality
select * from(
select *, count(hospital)over(partition by hospital) as co
from doctors) temp
where co >= 2


--5 fetch the users who logged in consecutively 3 or more times
with temp as (
select *,
lead(user_name)over(order by login_id) as l1,
lead(user_name, 2)over(order by login_id) as l2,
lead(user_name, 3)over(order by login_id) as l3
from login_details
)
select distinct user_name from temp
where l1 = l2 and l1 = l3

--6 write a SQL query to interchange the adjacent student names.

select *,
case when id%2 !=0 then lead(student_name,1,student_name)over(order by id)
	 when id%2 =0 then lag(student_name)over(order by id)
	 else student_name
end as name 
from students 

--7 fetch all the records when London had extremely cold temperature for 3 consecutive days or more.
with temp as (
select *,
case when temperature <0 and lead(temperature)over(order by id) <0 and lead(temperature,2)over(order by id)<0 then 'true'
	 when temperature < 0 and lag(temperature)over(order by id) <0 and lag(temperature,2)over(order by id)<0 then 'true'
	 when temperature < 0 and lead(temperature)over(order by id)<0 and lag(temperature)over(order by id)<0 then 'true'
else 'null'
end as flag
from weather
)

select id, city, temperature, day from temp
where flag =  'true'

--8 write a SQL query to get the histogram of specialties of the unique physicians who have done the procedures but never did prescribe anything

select * from EVENT_CATEGORY;
select * from PHYSICIAN_SPECIALITY;
select * from PATIENT_TREATMENT;

with temp as (
select pt.patient_id, pt.event_name, pt.physician_id, ps.speciality, ec.category
from PATIENT_TREATMENT pt
join PHYSICIAN_SPECIALITY ps
on pt.physician_id = ps.physician_id
inner join EVENT_CATEGORY ec
on pt.event_name = ec.event_name
),temp2 as(
select distinct *,
row_number()over(order by speciality)
from temp
)

select distinct speciality, count(speciality)
from temp2 
group by speciality

--9 top 2 accounts with the maximum number of unique patients on a monthly basis

select a.month, a.account_id, a.no_of_unique_patients
from (
		select x.month, x.account_id, no_of_unique_patients,
			row_number() over (partition by x.month order by x.no_of_unique_patients desc) as rn
		from (
				select pl.month, pl.account_id, count(1) as no_of_unique_patients
				from (select distinct to_char(date,'month') as month, account_id, patient_id
						from patient_logs) pl
				group by pl.month, pl.account_id) x
     ) a
where a.rn < 3

--10 Concecutive records

--have primary key
with temp as (
	select *,
	row_number()over(order by id) as rn,
	id - row_number()over(order by id) as diff
	from weather2
	where temperature<0
	),
temp2 as (
	select *,
	count(diff)over(partition by diff) as co
	from temp)

select * from temp2
where co = 4

--when we have no primary key

with wea as (
	select row_number()over() as id, *
	from v_weather),
temp as (
	select *,
	row_number()over(order by id) as rn,
	id - row_number()over(order by id) as diff
	from wea
	where temperature<0
	),
temp2 as (
	select *,
	count(diff)over(partition by diff) as co
	from temp)

select * from temp2
where co = 4


--Based on only date field
with temp as(
	select *,
	row_number()over(order by order_id)  as rn,
	order_date-(cast(row_number()over(order by order_id) as int)) as diff
	from orders
),
temp2 as (
select *, count(diff)over(partition by diff) as co
from temp)
select * from temp2
where co = 3

-----------------------------------------------------------------------------------
--Cherry Academy 
--10 SQL interview Query

--1 Find duplicate records
select empname, count(salary)
from cemployee
group by empname
having count(salary)>=2

--2 delete the duplicate records
with temp as (
	select *,
	row_number()over(partition by empname,salary) as rn
	from cemployee
)
delete from temp 
where rn>1


--3 find manager name for the employee

select e1.empname as employee_name, e2.empname as managername
from cemployee e1
join cemployee e2
on e1.managerid = e2.empid

--4/5/6 Second heighest salary and employee and nthe salary
with temp as (
select *,
dense_rank()over(order by salary desc) as dk
from cemployee
)
select * from temp 
where dk = 2

--7 find max salary from each dept

select * from(
	select *,
	dense_rank()over(partition by e1.deptid order by salary desc) as dk
	from cemployee e1
	inner join cdepartment d
	on e1.deptid = d.deptid
) temp 
where dk =1

--9 Showing single row twice in a result set

select empid, empname,deptid, salary from cemployee where deptid = 1
union all 
select empid, empname,deptid, salary from cemployee where deptid = 1

--10 dept less than 3 employees
select deptname from 
cdepartment where deptid in(
	select deptid from (
		select *,
			   count(empname)over(partition by deptid) as co 
		from cemployee) temp 
		where co<3
)


--Home Assignment

--1 Calculate the average rating given by students to each teacher for each session created. 
--  Also, provide the batch name for which session was conducted.

select att.session_id,se.conducted_by,ba.name, avg(att.rating) as avg_rating
from attendances att
inner join sessions se
on att.session_id = se.id
inner join batches ba
on se.batch_id = ba.id
group by att.session_id, se.conducted_by,ba.name 
order by session_id;

--2 Find the attendance percentage for each session for each batch.
--  Also mention the batch name and users name who has conduct that session

select  se.id, se.batch_id,ba.name,urs.name, count(att.student_id)*100/(select count(*) from attendances) as attendance_perc
from attendances att
inner join student_batch_maps sbm
on att.student_id = sbm.id
inner join batches ba
on sbm.batch_id = ba.id
inner join sessions se
on se.batch_id = ba.id
left join users urs
on se.conducted_by = urs.id
group by se.id, se.batch_id,ba.name,urs.name
order by se.id

--Hierarchical data in SQL
With RECURSIVE TEMP1 AS (
	select emp_id, emp_id as employee_id from hierdata
	UNION ALL
	select t1.emp_id, h.emp_id from temp1 t1 join hierdata h on t1.employee_id = h.reporting_id
)
select * from temp1 order by emp_id, employee_id;

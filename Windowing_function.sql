--Windowing function
select * ,max(salary) over(partition by dept_name) as max_salary
from employee

-- second heighest salary
select * from 
(select *, row_number() over(order by salary desc) as ranking
from employee) temp
where temp.ranking = 2

-- heighest salary in dept
select * from 
(select *,dense_rank() over(partition by dept_name order by salary) as dept_salary
from employee) temp
where temp.dept_salary = 1

--WIITH or CTE
--employee earning more than avg salary of all employee
select * from employee
where salary> (select avg(salary) from employee)
order by salary 

--average_salary is a table name and av_salary is a column name 
--we have to use table name in from statement

with average_salary(av_salary) as
	(select avg(salary) from employee)
select * from employee, average_salary av
where salary> av.av_salary

select * from sales

-- find stores whose sales were better than the average sales 

with total_sales(avg_sales) as 
	(select avg(quantity*cost) from sales)
select product from 
sales, total_sales ts
where (quantity*cost)>ts.avg_sales;


-- second heighest salary
select * from(
select *, dense_rank()over(order by salary desc) as sal_rank
from employee)temp
where sal_rank = 2

-- duplicate rows
select salary,count(*)
from employee
group by salary
Having count(*)>1

-- first 5 record
select * from
(select *, row_number() over(order by emp_id desc) as ro
from employee)temp
where temp.ro < 6

--duplicate
select first_name,count(*)
from employees
group by first_name
having count(*)>1

--duplicate by using windowing function
select * from(
select *,
row_number()over(partition by first_name order by employee_id) as rn
from employees ) temp
where temp.rn>1

-- second last record from a table 
select * from (
select *, row_number()over(order by employee_id desc) as rn
from employees) temp
where temp.rn = 2

--heighest and lowest salary in each department

--not good
select * from (
select *, dense_rank()over(partition by department_id order by salary asc) as sa
from employees) temp
where temp.sa = 1
union all
select * from 
(select *, dense_rank()over(partition by department_id order by salary desc) as sd
from employees) temp
where temp.sd=1
order by department_id

---correct way
select *,
first_value(salary) over(partition by dept_name order by salary desc) as high_salary,
last_value(salary) over(partition by dept_name order by salary desc range between unbounded preceding and unbounded following ) as min_salary
from employee;

--doctors in same hospital but different specialty
select dr.name, dr.speciality,dr.hospital 
from doctors dr, doctors ds
where dr.hospital = ds.hospital
and dr.id <> ds.id
and dr.speciality <> ds.speciality

---doctors in same speciality
select dr.id,dr.name, dr.speciality,dr.hospital 
from doctors dr, doctors ds
where dr.id <> ds.id
and dr.hospital = ds.hospital




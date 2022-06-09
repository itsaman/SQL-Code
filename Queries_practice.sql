**********************************
---Geeks for Geeks sql (youtube)
**********************************

--second heighest salary of an employee
select * from(
select *,
dense_rank()over(order by salary desc) as rn
from employees) temp
where temp.rn = 2

select top 1 * from employees
where salary < (select max(salary) from employees)
order by salary desc

-- heighest paid employee from each department
select * from (
select *,
dense_rank()over(partition by department order by salary desc) as rn
from employees) temp
where temp.rn = 1

--alternative records
select * from employees
where employee_id%2 = 0

select * from employees
where employee_id%2 != 0

--duplicates of a column and its frequency 
select first_name,count(*) 
from employees
group by first_name
Having count(*)>1
order by count(*) desc

--pattern matching 
select * from employees
where first_name like 'M%'

select * from employees
where first_name like '%M'

select * from employees
where first_name like '%M%'

select * from employees
where first_name not like '%M%'

--pattern searching
select * from employees
where len(first_name) = 4 

select first_name, hire_date from employees
where month(hire_date) = 12

select * from employees 
where first_name like '_L%_M%_'

select * from employees 
where first_name like '%LL%'

-- display Nth row 
select * from
(select *,
row_number() over(order by employee_id) rn
from employees) temp
where temp.rn =3

--top 9 sql queries video (youtube)

-- third heighest salary/ Nth heighest salary
-- if there is no third heighest salary then print null

select * from(
select *,
dense_rank()over(order by salary desc) as rn
from employees) temp
where temp.rn = 3

--duplicates using windowing function
select * from 
(select *,
row_number()over(partition by first_name order by employee_id) rn
from employees) temp
where temp.rn>1

--first and last record

select * from employees
where employee_id = (select min(employee_id) from employees)

select * from employees
where employee_id = (select max(employee_id) from employees)

--employee working in the same department
select distinct *
from employees e1, employees e2
where e1.department = e2.department
and e1.employee_id <> e2.employee_id;

--last 3 records from a table 



********************************************
--Master SQL for DS Udemy Course(BRAVE PART)
********************************************
use job_ready;

select * from students;
select * from student_enrollment;
select * from courses;
select * from professors;
select * from teach;

--1 Write a query that finds students who do not take CS180.

SELECT * FROM students
WHERE student_no NOT IN (SELECT student_no FROM student_enrollment WHERE course_no = 'CS180');



--2 Write a query to find students who take CS110 or CS107 but not both.

select * from students 
where student_no IN (select student_no from student_enrollment where course_no = 'CS110' or course_no = 'CS107');


--3 Write a query to find students who take CS220 and no other courses.
(select st.* from students st
inner join student_enrollment se
on st.student_no = se.student_no
where se.course_no = 'CS220')
except
select s1.* from students s1
inner join student_enrollment s2
on s1.student_no = s2.student_no
where course_no <> 'CS220'


-------------------------
use wikibooks_sql;
-------------------------

--3. Select the name of the products with a price less than or equal to $200.
select name,Price
from Products
where price <= 200
-- Select all the products with a price between $60 and $120.
select *
from Products
where price between 60 and 120

--5. Select the name and price in cents (i.e., the price must be multiplied by 100).
select name, price*100
from Products

--7. Compute the average price of all products with manufacturer code equal to 2.
select avg(price) 
from Products
where manufacturer = '2'

--9. Select the name and price of all products with a price larger than or equal to $180, 
--and sort first by price (in descending order), and then by name (in ascending order).

select name, price from Products
where price >=180
order by price desc, name asc

--10. Select all the data from the products, including all the data for each product's manufacturer.

select * from Products p
inner join Manufacturers m
on p.Manufacturer = m.Code

--
select p.name,p.price,m.name
from Products p, Manufacturers m
where p.Manufacturer = m.Code

--12. Select the average price of each manufacturer's products, showing only the manufacturer's code.
select m.code, avg(p.price) as average
from Products p
inner join Manufacturers m
on p.Manufacturer = m.Code
group by m.code

--
select top 1 name, price as min_price
from Products
order by min_price asc

--17. Select the name of each manufacturer which have an average price above $145 
--and contain at least 2 different products.

select m.name, avg(price), count(p.Manufacturer) as co from Manufacturers m
inner join Products p
on m.Code = p.Manufacturer
group by m.name 
having avg(price) >= 145 and count(p.Manufacturer)>=2

select * from Products

insert into Products(code,name,price,Manufacturer) values(11,'Loudspeakers',70,2);
update Products set name = 'Laser Printer' where code = 8;


--------------------------------------------------
-- SQL Scenario Based question (ITJunctionfor All)
--------------------------------------------------

use dataset;

--1
--Transatcion_tbl Table has four columns CustID, TranID, TranAmt, and  TranDate. 
--User has to display all these fields along with maximum TranAmt for each CustID 
--and ratio of TranAmt and maximum TranAmt for each transaction.

select *,round(t.TranAmt/t.maxtrans, 3) as ratio
from(
select *,
max(TranAmt)over(partition by custid) as maxtrans
from Transaction_Tbl) t

--2
--query to find the maximum and minimum values of continuous ‘Sequence’ in each ‘Group’
select 
	[group],
	min([sequence]) as min_number,
	max([sequence]) as max_number
from (
		select *, 
			([sequence] - rn) as split
		from (
				select *,
					  row_number()over(partition by [group] order by [group]) as rn
				from emp) t
								) temp
group by [group],[split]
order by [group];

--3
--Student Table has three columns Student_Name, Total_Marks and Year.
--User has to write a SQL query to display Student_Name, Total_Marks, Year,  Prev_Yr_Marks 
--for those whose Total_Marks are greater than or equal to the previous year.
select temp.student_name, temp.total_marks,temp.[year],temp.previous
from 
(select student_name,total_marks,
lag(Total_marks) over(partition by student_name order by student_name) as previous,
[year]
from student) temp
where temp.Total_Marks>temp.previous

--5
select distinct product_id, temp.co 
from (
select distinct product_id, count(t.rn)over(partition by product_id) as co
from (
select *,
dense_rank()over(partition by product_id order by order_day) as rn
from Order_Tbl)t
) temp
where temp.co > 1

--ordered on 2nd day not on first day

with temp as 
 (  select *,
    dense_rank()over(order by order_day) as rn
    from Order_Tbl )
select product_id from temp
where temp.rn = 2
except
select product_id from temp
where temp.rn = 1
order by product_id


--6
--get the highest sold Products (Quantity*Price) on both the days 

select top 2  ORDER_DAY,PRODUCT_ID,
MAX(QUANTITY*PRICE)over(partition by PRODUCT_ID,ORDER_DAY) as so
from Order_Tbl
order by so desc

--get all products day wise, that was ordered more than once
select distinct ORDER_DAY,PRODUCT_ID
from(
select ORDER_DAY,PRODUCT_ID,
count(PRODUCT_ID)over(partition by PRODUCT_ID,ORDER_DAY) as so
from Order_Tbl) temp
where temp.so > 1

--get all product's total sales on 1st May and 2nd May adjacent to each other-----------

select PRODUCT_ID,
	sum(case when ORDER_DAY='2015-05-01' then quantity*price else 0 end) as tsales1,
	sum(case when ORDER_DAY='2015-05-02' then quantity*price else 0 end) as tsales2 
from Order_Tbl
group by PRODUCT_ID

--9
--team matches
select distinct  concat(a.teamname,' Vs ' ,b.teamname) as matches from team a 
cross join team b
where a.id < b.id 

--11
with matches as(
select team_1 as team, result from match_result
union all 
select team_2 as team, result from match_result)

select team,count(1),
sum(case when team = result then 1 else 0 end) as match_won,
sum(case when result is null then 1 else 0 end) as match_tie,
sum(case when team!= result then 1 else 0 end) as match_lost
from matches
group by team

--12
select * from(
select *,
dense_rank()over(partition by accountnumber order by transactiontime desc) as rn
from Transaction_Table) temp
where temp.rn = 1

--14 cumulative sum 
select *,
sum(quantity)over(partition by productcode order by inventorydate) as running_total
from inventory;

--18 net balance

select TranDate,TranType,Amount,
sum(temp_amount)over(order by trandate) as Net_Balance
from(
select  TranDate,TranID,TranType,Amount,
	case when TranType = 'Credit' then Amount
	    when TranType = 'Debit' then Amount*-1 end as temp_amount
 from Account_Table) temp

--19
select * from studentinfo

select studentname, 'English' as Subject, english as Marks from studentinfo
union all 
select studentname, 'Maths', maths from studentinfo
union all 
select studentname, 'Science', science from studentinfo
order by studentname 

--20
--trade difference <10sec
--price diff >10%
select * from trade_tbl;

with temp as(
	Select trade_id,Trade_Timestamp,Price
	from Trade_tbl
)
select A.TRADE_ID,
	   B.TRADE_ID,
	   floor(ABS(((B.Price-A.Price)/A.Price)*100))
from temp A
INNER JOIN temp B
on a.TRADE_ID<b.TRADE_ID
where datediff(SECOND,A.Trade_Timestamp,B.Trade_Timestamp) <=10
and ABS(((B.Price-A.Price)/A.Price)*100) >= 10
order by 1

--21 
select * from BalanceTbl


with temp1 as (
	select balance,dates,
	case when lag(balance)over(order by dates) = Balance then 0 else 1 end as rn
	from BalanceTbl
),
temp2 as (
	select balance,dates,
	sum(rn)over(order by dates) as total
	from temp1
)
select balance,
min(dates) as START_date,
max(dates) as end_date
from temp2
group by balance,total


--23(not solved)
select distinct
case when start_location > end_location  then end_location else start_location end as source,
case when start_location > end_location  then start_location else end_location end as dest,
distance
from dbo.Travel_Table;

Select Start_Location,End_Location,Distance from (
Select Start_Location,End_Location,Distance,row_number() over(Partition by Distance order by Distance) as Row_Num 
from Travel_Table) A where Row_Num = 1;

-- 22/12/21
-- scenario based questions(youtube)
--38

with t1 as (
select  *,
lead(id,1)over(order by id) as la,
lead(id,2)over(order by id) as la2
from stadium a
where a.No_Of_People >= 100),
t2 as (
select * from t1 
left join Stadium s
on s.id = t1.id or s.id = t1.la or s.id = t1.la2
);

--2 approach
with temp as (
select *, RANK()over(order by id) as rn
from stadium 
where No_Of_People>=100)

select id,Visit_Date,No_Of_People from temp
where id-rn > 1


--37
with temp as (
select *,
sum(sales)over(partition by continents, country) as total
from salesinfo),
t2 as (
select continents, country, total,
dense_rank()over(partition by continents order by total desc) as dk
from temp)

select distinct continents, country, total from t2
where dk = 1

--23/12/11

--36 adjcent seat

select * from SeatArrangement;

select 
    case when id % 2 <> 0 and id = (select count(*) from SeatArrangement) then id
         when id % 2 <> 0 then id+1
         when id % 2 = 0  then id - 1
    end as id,
    studentname 
from SeatArrangement


--35
--1
select * from employees
where binary_checksum(upper(first_name)) <> binary_checksum(first_name) 

--OR

select * from employees 
where upper(First_name) !=  First_name COLLATE SQL_Latin1_General_CP1_CS_AS

--2
select * from employees

select 
SUBSTRING(First_name,1, CHARINDEX(' ', First_name)-1) as fname,
substring(First_name,CHARINDEX(' ', First_name)+1, LEN(First_name)) as lname
from Employees
where last_name is null or last_name  = ' ';

update Employees
set First_name = SUBSTRING(First_name,1, CHARINDEX(' ', First_name)-1),
 last_name = substring(First_name,CHARINDEX(' ', First_name), LEN(First_name))
where last_name is null or last_name  = ' ';


--3
declare @ex as date set @ex =  '2017-06-30';
with temp as (
select *,datediff(year,Joining_date,@ex) as counts from employees),

temp2 as(
    select 
    case when counts < 1 then '< 1 years'
          when counts >= 1 and counts < 3 then '1-3 years' 
          when counts >=3 and counts < 5 then '3-5 years'
          when counts >=5 then '5+ years'
    end as tenure_in_years
from temp
)

select tenure_in_years, count(*) as employee_counts from temp2
group by tenure_in_years

--4
select * from employees e
where day(e.Birth_date) = day(e.Joining_date)

--5
declare @ex as date set @ex =  '2017-06-30';
with temp as (
select *,datediff(year,Joining_date,@ex) as counts from employees
)
select * from temp
where temp.counts> 5 and year(Birth_date) = (select max(year(birth_date)) from Employees)

--34
with temp as (
select distinct quote_id, Order_Status from OrderStatus
),
temp2 as(
select quote_id, STRING_AGG(order_status,',') as list from temp
group by quote_id
)
select Quote_id,
    case when CHARINDEX('Delivered',list) = 1 and CHARINDEX(',',list) = 0  then 'Completed'
         when CHARINDEX('Delivered',list) > 1 and CHARINDEX(',',list) >0 then 'In Delivery'
         when CHARINDEX('Submitted',list) > 1 and CHARINDEX(',',list) >0 and CHARINDEX('Delivered',list) = 0 then 'Awaiting for Submission'
         else 'Awaiting for Entry'
    end as ord_status
from temp2;

--26/12/21
--33
--Pattern question(not able to understand)

--Base Query
with ap as(
select 'INTERVIEW' AS a, len('INTERVIEW') as b
union all
select substring(a,1,b-1), b-1
from ap where b-1>0

)
select a from ap

--32
with temp as (
select *,
dense_rank()over(partition by deptno order by salary desc) as max_rk,
dense_rank()over(partition by deptno order by salary asc) as min_rk
from Employee_2
)
select empname, deptname, deptno, salary
from temp
where temp.max_rk = 1
union all  
select empname, deptname, deptno, salary
from temp
where temp.min_rk = 1
order by temp.deptno, salary asc

--31
select * from StudentInfo_1

select StudentName, English, Maths, Science
from 
(select StudentName, Subjects, Marks from StudentInfo_1 ) source_table 
PIVOT
(
    max(marks) for subjects in (English, Maths, Science)
) as pivot_table


--30
select * from sales1

--1
select *,
sum(sales)over(partition by product order by sales) as total
from sales1

--2
select *,
min(sales)over(partition by product order by sales) as total
from sales1

--29
--1
select e1.employeename as emp_name, e2.employeename as man_name
from employee_1 as e1, Employee_1 as e2
where e1.managerid = e2.employeeid

--2
select e1.employeename as emp_name, ISNULL(e2.employeename, 'Boss') as man_name
from employee_1 as e1
left join Employee_1 as e2
on e1.managerid = e2.employeeid
 
 
 --27/12/21
 --questions by Vishal Kaushal 

--1
select * from Employee

select max(salary) from Employee
where salary < (select max(salary) from employee)

--2
select * from retail

select retailers, oneplus, realme, celkon, mi
from (select retailers, brand from Retail) r 
PIVOT
(
    max(retailers) for brand in (oneplus, realme, celkon, mi  ) 
) as b


--3
select cast(10 as float)/cast(4 as float);
select 1|1;
Select 2|4;
select 10|20
select 40^30
select ~20

--4
select 
    count(case when ratio = 'MALE' then 1 else null end)*100/count(ratio) as 'Male%',
    count(case when ratio = 'FEMALE' then 1 else null end)*100/count(ratio) as 'FEMALE%'
from gender

--28/12/21

--28
select x,y,z from (
select *,
count(*)over(partition by x,y) as dk
from Sample_1
)temp
where temp.dk>1


--29/12/21
--18
with temp1 as(
select id from alpha
),
temp2 as(
select b.id as id from beta b
left join temp1 t
on t.id = b.id
where b.id not in (select id from temp1)
)
select id from temp2
union all
select id from temp1

--19
with temp1 as(
select id,name,
case when gender ='Male' then 'Female' end as "Gender"
from example18
where gender = 'Male'),
temp2 as(
select id,name,
case when gender ='Female' then 'Male' end as "Gender"
from example18
where gender = 'Female')

select id, name, gender from temp1
union 
select id, name, gender from temp2

--simple apprach
select id, name,
case when gender = 'Male' then 'Female'
     when gender = 'Female' then 'Male'
end as "Gender"
from example18

--22
with temp as (
select  a.id as id, a.name as name, a.salary as salary, a.managerid as managerid
from example22 a, example22 b
where a.managerid = b.id
),
temp2 as (
select *, avg(salary)over(PARTITION by managerid) as rn from temp
)

select managerid, name, rn from temp2  

--40 
with temp as (
select distinct e.SerialNo, e.Name, m.Month_ID as id, m.[Month]  
from Emp_Table e, Month_Table m)

select t.SerialNo, t.Name, t.[Month],emp.amount from temp t
left join Emp_Table emp
on emp.Month_ID = t.id and emp.SerialNo =t.SerialNo


--Nth Highest Salary in SQL| How to find 2nd Highest Salary in SQL| SQL Interview Question
select * from (
select *, dense_rank()over(order by salary desc) as dk
from employee
)temp
where temp.dk =1


--43
--fetch Alternate Records from the Table
--even number records

with temp as (
select *,
row_number()over(order by id) as rn
from students2
)
select * from temp 
where rn%2 = 0

--odd number
with temp as (
select *,
row_number()over(order by id) as rn
from students2
)
select * from temp 
where rn%2 != 0

--
with temp as (
select loc_name, loc_id, cus_id, amount_paid, app,
count(app)over(partition by loc_name, app order by amount_paid) as dk
from Transaction_Tbls ta
inner join customer cu
on ta.cus_id = cu.customer_id
),
temp2 as (
select app, amount_paid, dk,
dense_rank()oveR(order by amount_paid desc)as dk2
from temp
where dk in (0,2) 
)
select upper(left(isnull(app,'Offline'),1))+lower(SUBSTRING(isnull(app,'Offline'),2,LEN(isnull(app,'Offline')))) as app_mode, 
		dk2 as count from temp2
where dk2<=2
order by dk2 desc


--44

with temp as (
select *,
lag(createdat)over(partition by userid order by createdat),
createdat-lag(createdat)over(partition by userid order by createdat) as diff
from Transactions_Amazon
)
select distinct userid from temp
where diff<=7



--49 Number of Calls between two Persons
--NBM

with temp as(
select
case when from_id<to_id then from_id else to_id end as person_1,
case when from_id>to_id then from_id else to_id end as person_2,
duration
from calls
)
select distinct person_1, person_2, 
count(person_1)over(partition by person_1,person_2),
sum(duration)over(partition by person_1,person_2)
from temp;



--total amount recevied by each merchant via cash or online mode

select merchant,
SUM(case when payment_mode = 'CASH' then amount else 0 end) as "cash_payment",
SUM(case when payment_mode = 'ONLINE' then amount else 0 end) as "online_payment"
from payments_data
GROUP BY merchant


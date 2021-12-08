-- from geeks for geeks sql (youtube)
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



--------------------------------------
--Master SQL for DS Course(BRAVE PART)
---------------------------------------
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
---------------------------------------------------------------------
use wikibooks_sql;

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


-------------------------------
-- ItJunction4all youtube sql 
-------------------------------
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



--4(not solved my me)


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

--7
--explode the above data into single unit level records as shown below

--8

--9
--team matches
select distinct  concat(a.teamname,' Vs ' ,b.teamname) as matches from team a 
cross join team b
where a.id < b.id 

--10

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

--13

--14 cumulative sum 

select *,
sum(quantity)over(partition by productcode order by inventorydate) as running_total
from inventory;

--15 print english alphabets 

--16 prime number
--17
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

--22 

--23(not solved)
select distinct
case when start_location > end_location  then end_location else start_location end as source,
case when start_location > end_location  then start_location else end_location end as dest,
distance
from dbo.Travel_Table

Select Start_Location,End_Location,Distance from (
Select Start_Location,End_Location,Distance,row_number() over(Partition by Distance order by Distance) as Row_Num 
from Travel_Table) A where Row_Num = 1

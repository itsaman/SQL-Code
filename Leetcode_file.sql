--Combine Two Tables
Select p.FirstName,p.LastName,a.city,a.state 
from Person p
left join Address a
on p.PersonId=a.PersonId;

--Employees Earning More Than Their Managers
Select e1.name as Employee from Employee e1
join Employee e2
on e1.ManagerId = e2.id
where e1.salary>e2.salary

--Duplicate Emails
select Email
from Person
group by Email
Having
 count(Email)>1
 
 --Customers Who Never Order
 Select Customers.name as Customers from Customers 
Left outer join Orders  on Customers.Id = Orders.CustomerId
where Orders.CustomerId is Null

--Delete Duplicate Emails
delete p1 from person p1
inner join person p2
on p1.id>p2.id
and p1.email=p2.email

--Not Boring Movies
Select id,movie,description,rating from cinema
where id %2 != 0 and description != 'boring'
order by rating desc

--Nth Heighest Salary
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
  RETURN (
      # Write your MySQL query statement below     
     with temp as (
      select *, dense_rank() over(order by salary desc) as rn from Employee  
     )  
    
      select distinct temp.salary from temp
      where temp.rn = N
  );
END

--Swap Salary
update Salary 
set sex = (case when sex = 'f' then 'm' else 'f' end)

--Second Highest Salary
select max(salary) as SecondHighestSalary from employee
where salary<(select max(salary) from employee)

--Rank Scores
select score,dense_rank() over(order by score desc) as "Rank"
from Scores

--Department Top Three Salaries
select temp.dep_name as Department,
        temp.emp_name as Employee,
        temp.sal_emp as Salary
from( 
    select dm.name as dep_name, em.name as emp_name, em.salary as sal_emp, 
    dense_rank() over(partition by dm.name order by em.salary desc) as "ro"
from employee em
join department dm
on em.departmentid=dm.id) temp
where temp.ro <= 3;


--Exchange Seats

select id,
case when id%2!=0 then lead(student,1,student)over(order by id)
    when id%2 = 0 then lag(student)over(order by id)
end as student
from seat

--Find Followers Count
select user_id, count(follower_id) as followers_count
from Followers
group by user_id
order by user_id

--The Latest Login in 2020

with temp as(
select user_id, time_stamp as last_stamp,
dense_rank()over(partition by user_id order by time_stamp desc) as dk
from Logins
where year(time_stamp) = '2020'
)
select user_id, last_stamp
from temp 
where dk =1

--Customer Who Visited but Did Not Make Any Transactions
select customer_id, count(*) as count_no_trans from visits
where visit_id not in(
select distinct visit_id from Transactions
)
group by customer_id
order by count_no_trans desc

--Top Travellers
select name, COALESCE(sum(distance),0) as travelled_distance
from users u
left join rides r
on u.id = r.user_id
group by name
order by travelled_distance desc, name asc

--Market Analysis I
SELECT u.user_id AS buyer_id, join_date, COUNT(order_date) AS orders_in_2019 
FROM Users as u
LEFT JOIN Orders as o
ON u.user_id = o.buyer_id
AND YEAR(order_date) = '2019'
GROUP BY u.user_id

--Capital Gain/Loss
with temp as(
select *, row_number()over(partition by stock_name) as id
from stocks
), temp2 as (
select *,
case when id%2 != 0  then lead(price)over(partition by stock_name order by operation_day) else 0 end as new
from temp 
)
select stock_name, sum(new-price) as capital_gain_loss
from temp2
where new != 0
group by stock_name
order by capital_gain_loss desc

--Sales Analysis III

select product_id,product_name from product 
where product_id not in (
select product_id from sales
where sale_date > '2019-03-31' or sale_date < '2019-01-01'
    )

--Bank Account Summary II
select name, balance from (
select u.name,u.account, sum(amount) as balance
from users u
inner join Transactions t
on u.account = t.account
group by account, name
having sum(amount)>10000
    )temp

--Actors and Directors Who Cooperated At Least Three Times
with temp as (
select *, dense_rank()over(partition by actor_id, director_id order by timestamp) as dk 
from ActorDirector
)
select distinct actor_id, director_id from temp 
where dk>=3

--Tree Node

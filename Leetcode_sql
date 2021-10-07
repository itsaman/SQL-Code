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

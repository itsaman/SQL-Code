--1
select * from shippers;
--2
select categoryname, DESCRIPTION from categories;

--3
select  FirstName, LastName, HireDate 
from employees
where title = 'Sales Representative'

---Intermediate level

--20
select categoryname, count(productname) as pr_count
from categories co
inner join Products pr
on co.categoryid = pr.categoryid
group by categoryname
order by pr_count desc

--21
select country, city, count(*) as totalcustomer
from customers 
group by country, city 
order by totalcustomer desc

--22
select productid,
       productname,
       unitsinstock,
       reorderlevel
from products 
where unitsinstock < reorderlevel
order by productid

--23
select productid,
       productname,
       unitsinstock,
       UnitsOnOrder,
       reorderlevel,
       Discontinued 
from products 
where (unitsinstock+ UnitsOnOrder) <= reorderlevel and Discontinued = 0
order by productid

--24 -- nice 

select customerid,
        companyname,
        region
from(
select  customerid,
        companyname,
        region,
        case when region is null then 0 else 1 end as re
from customers) temp
order by re desc, region asc

--25 and 26

select top 3 shipcountry, avg(freight) as av
from orders 
where year(orderdate) = '1997'  
group by shipcountry
order by av desc


--28 -- nice questions 
select top 3 shipcountry, avg(freight) as av 
from orders
where orderdate BETWEEN '1997-05-06' and '1998-05-06'
GROUP by shipcountry
order by av desc

select top 3 shipcountry, avg(freight) as av 
from orders
where orderdate >= dateadd(yy,-1,(select max(orderdate) from orders))
GROUP by shipcountry
order by av desc

--29

select * from employees;
select * from orders;
select * from products;
select * from [orderdetails]

select  e.employeeid,
        e.lastname,
        ord.orderid,
        prd.productname,
        ode.quantity
from employees e
inner join orders ord
on e.employeeid = ord.employeeid
inner join [orderdetails] as ode
on ord.orderid = ode.orderid 
inner join products prd
on ode.productid = prd.productid

--30 -- not solved

select cust.customerid, ord.customerid
from customers cust
left join orders ord
on cust.customerid = ord.customerid
where ord.customerid is null

--31

-------------------------------------------------
---Advance Questions
-------------------------------------------------

--32

select * from Orders
select * from [OrderDetails]
select * from customers

select ord.customerid, cu.companyname, ord.orderid, sum(det.unitprice * det.quantity) as total
from Orders ord
inner join customers cu
on ord.CustomerID = cu.CustomerID
inner join [OrderDetails] det
on ord.orderid = det.OrderID
where ord.orderdate between '1997-01-01' and '1998-01-01'
group by ord.customerid, cu.companyname, ord.orderid
having sum(det.unitprice * det.quantity) > 10000


--35(get to know about date functions)

select emp.Employeeid as emp_id, orderid, ord.orderdate
from Employees emp
inner join orders ord
on emp.EmployeeID = ord.EmployeeID
where orderdate = dateadd(month,1+datediff(month,0,orderdate),-1)
order by emp_id


select dateadd(month,1+datediff(month,0,'2021-09-12'),-1)

--36

select distinct ord.orderid, count(1) as total
from Orders ord
inner join [orderdetails] odt
on ord.OrderID = odt.OrderID
group by ord.orderid
order by total desc

--38
Select  
 OrderID
From OrderDetails
Where Quantity >= 60
group by orderid, quantity
having count(*)> 1

--39
select * 
from Orderdetails
where orderid in (Select  
 OrderID
From OrderDetails
Where Quantity >= 60
group by orderid, quantity
having count(*)> 1
)

--Cte

with temp as (
        select OrderID
From OrderDetails
Where Quantity >= 60
group by orderid, quantity
having count(*)> 1
)
select *
from OrderDetails where orderid in (select * from temp)

--41
select orderid, orderdate, RequiredDate, ShippedDate
from orders
where ShippedDate > RequiredDate or ShippedDate = RequiredDate

--42
select emp.employeeid, emp.LastName, count(distinct ord.orderid) as total
from employees emp
inner join orders ord
on emp.EmployeeID = ord.EmployeeID
where ord.ShippedDate > ord.RequiredDate or ord.ShippedDate = ord.RequiredDate
group by emp.employeeid, emp.LastName
order by total desc


--43
with temp as (
select emp.employeeid as tid, emp.LastName,count(ord.orderid) as allorder
from employees emp
inner join orders ord
on emp.EmployeeID = ord.EmployeeID
group by emp.employeeid, emp.LastName)

select emp.employeeid, emp.LastName,temp.allorder, count(distinct ord.orderid) as total
from employees emp
inner join orders ord
on emp.EmployeeID = ord.EmployeeID
inner join temp
on ord.EmployeeID = temp.tid
where ord.ShippedDate > ord.RequiredDate or ord.ShippedDate = ord.RequiredDate
group by emp.employeeid, emp.LastName,temp.allorder
order by total desc

--46
with temp as (
select emp.employeeid as tid, emp.LastName,count(ord.orderid) as allorder
from employees emp
inner join orders ord
on emp.EmployeeID = ord.EmployeeID
group by emp.employeeid, emp.LastName)

select emp.employeeid, emp.LastName,temp.allorder, count(distinct ord.orderid) as total, round((count(distinct ord.orderid)/temp.allorder), 6) as per
from employees emp
inner join orders ord
on emp.EmployeeID = ord.EmployeeID
inner join temp
on ord.EmployeeID = temp.tid
where ord.ShippedDate > ord.RequiredDate or ord.ShippedDate = ord.RequiredDate
group by emp.employeeid, emp.LastName,temp.allorder
order by total desc

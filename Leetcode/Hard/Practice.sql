Create database leetcode;
create schema questions;


-- Game play Analaysis part 2

CREATE TABLE Activity (
    player_id INT,
    device_id INT,
    event_date DATE,
    games_played INT,
    PRIMARY KEY (player_id, event_date)
);

INSERT INTO Activity (player_id, device_id, event_date, games_played) VALUES 
(1, 2, '2016-03-01', 5),
(1, 2, '2016-05-02', 6),
(2, 3, '2017-06-25', 1),
(3, 1, '2016-03-02', 0),
(3, 4, '2018-07-03', 5);

-- Solution

select player_id, device_id,
dense_rank()over(partition by player_id order by event_date asc) as dk
from activity
qualify dk =1;


-- Average Salary.sql

CREATE TABLE salary (
    id INT,
    employee_id INT,
    amount INT,
    pay_date DATE,
    PRIMARY KEY (id)
);


CREATE TABLE department (
    employee_id INT,
    department_id INT,
    PRIMARY KEY (employee_id)
);

INSERT INTO salary (id, employee_id, amount, pay_date) VALUES
(1, 1, 9000, '2017-03-31'),
(2, 2, 6000, '2017-03-31'),
(3, 3, 10000, '2017-03-31'),
(4, 1, 7000, '2017-02-28'),
(5, 2, 6000, '2017-02-28'),
(6, 3, 8000, '2017-02-28');


INSERT INTO department (employee_id, department_id) VALUES
(1, 1),
(2, 2),
(3, 2);

Select * from salary;
select * from department;

-- Solution

with temp as (
    select *,
    avg(amount)over(partition by month(pay_date),department_id) as avg_sal,
    avg(amount)over(partition by month(pay_date)) as com_avg
    from salary sl
    join department dp
    on sl.employee_id = dp.employee_id
    order by department_id
)
select distinct left(pay_date,7) as year_month, department_id, 
case when avg_sal > com_avg then 'higher' 
    when com_avg>avg_sal then 'lower'
    else 'Equal'
end as comparission
from temp
order by year_month;



-- Q2 Cumulative Salary



CREATE TABLE Employee (
    Id INT,
    Month INT,
    Salary INT
);

INSERT INTO Employee (Id, Month, Salary) VALUES (1, 1, 20);
INSERT INTO Employee (Id, Month, Salary) VALUES (2, 1, 20);
INSERT INTO Employee (Id, Month, Salary) VALUES (1, 2, 30);
INSERT INTO Employee (Id, Month, Salary) VALUES (2, 2, 30);
INSERT INTO Employee (Id, Month, Salary) VALUES (3, 2, 40);
INSERT INTO Employee (Id, Month, Salary) VALUES (1, 3, 40);
INSERT INTO Employee (Id, Month, Salary) VALUES (3, 3, 60);
INSERT INTO Employee (Id, Month, Salary) VALUES (1, 4, 60);
INSERT INTO Employee (Id, Month, Salary) VALUES (3, 4, 70);

-- Solution

with temp as (
    select *,
    dense_rank()over(partition by id order by month desc) as dk
    from employee
    qualify dk >1
)
Select id, month, sum(salary)over(partition by id order by month) as cum_sum
from temp

  
-- Q3 Find median given frequency of numbers.sql

CREATE TABLE Numbers (
    Number INT,
    Frequency INT
);


INSERT INTO Numbers (Number, Frequency) VALUES (0, 7);
INSERT INTO Numbers (Number, Frequency) VALUES (1, 1);
INSERT INTO Numbers (Number, Frequency) VALUES (2, 3);
INSERT INTO Numbers (Number, Frequency) VALUES (3, 1);

-- Solution
With RECURSIVE recursive_cte as (

    select number, frequency, 1 as cnt from numbers
    union all
    select number, frequency, cnt+1 as cnt from recursive_cte
    where cnt < frequency
)
select *,
percentile_cont(0.5) within group(order by number) over()
from recursive_cte;


-- Q4 Quiet Student 

CREATE OR REPLACE TABLE Student (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(255)
);

-- Create the Exam table
CREATE OR REPLACE TABLE Exam (
    exam_id INT,
    student_id INT,
    score INT,
    PRIMARY KEY (exam_id, student_id),
    FOREIGN KEY (student_id) REFERENCES Student(student_id)
);


-- Insert statements for the Student table
INSERT INTO Student (student_id, student_name) VALUES (1, 'Daniel');
INSERT INTO Student (student_id, student_name) VALUES (2, 'Jade');
INSERT INTO Student (student_id, student_name) VALUES (3, 'Stella');
INSERT INTO Student (student_id, student_name) VALUES (4, 'Jonathan');
INSERT INTO Student (student_id, student_name) VALUES (5, 'Will');

-- Insert statements for the Exam table
INSERT INTO Exam (exam_id, student_id, score) VALUES (10, 1, 70);
INSERT INTO Exam (exam_id, student_id, score) VALUES (10, 2, 80);
INSERT INTO Exam (exam_id, student_id, score) VALUES (10, 3, 90);
INSERT INTO Exam (exam_id, student_id, score) VALUES (20, 1, 80);
INSERT INTO Exam (exam_id, student_id, score) VALUES (30, 1, 70);
INSERT INTO Exam (exam_id, student_id, score) VALUES (30, 3, 80);
INSERT INTO Exam (exam_id, student_id, score) VALUES (30, 4, 90);
INSERT INTO Exam (exam_id, student_id, score) VALUES (40, 1, 60);
INSERT INTO Exam (exam_id, student_id, score) VALUES (40, 2, 70);
INSERT INTO Exam (exam_id, student_id, score) VALUES (40, 4, 80);


Select * from student;
select * from exam;


with temp as (
    select stu.student_name, exm.*,
    dense_rank()over(partition by exam_id order by score asc) as dk_asc,
    dense_rank()over(partition by exam_id order by score desc) as dk_desc,
    from student stu
    join exam exm
    on stu.student_id = exm.student_id
)
select distinct student_name, student_id 
from temp where student_id not in 
(
    select student_id from temp 
    where dk_asc in (1,3) and dk_desc in (1,3)
);

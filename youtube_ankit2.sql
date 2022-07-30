--Olympic Gold Medals Problem
select distinct gold, count(gold)over(partition by gold)
from events2 where gold in (
	select gold as name from events2
	except 
	select silver as name from events2
	except 
	select bronze as name  from events2
)
order by gold


--Leetcode-1412 Hard SQL Problem | Find the Quiet Students in All Exams

with temp as (
select s2.*, e2.exam_id, e2.score from students2 s2
inner join exams2 e2
on s2.student_id = e2.student_id
), temp2 as(
select *, max(score)over(partition by exam_id) as maxi,
min(score)over(partition by exam_id) as mini
from temp
)
select student_id, student_name from 
temp2 where score != maxi and score != mini
except
select student_id, student_name from 
temp2 where score = maxi or score = mini

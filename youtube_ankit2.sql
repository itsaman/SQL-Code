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

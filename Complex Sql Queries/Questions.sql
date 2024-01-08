-- Complex SQL Query 1 |

with temp as (
select team_1, case when team_1 = winner then 1 else 0 end as win_flag from icc_world_cup
union all 
select team_2, case when team_2 = winner then 1 else 0 end as win_flag from icc_world_cup
)
select team_1, count(team_1) as no_of_match, sum(win_flag) as no_of_wins, count(team_1)-sum(win_flag) as no_of_losses
from temp
group by team_1;

--Ameriprise LLC Company SQL Interview Problem
with temp as(
select teamid, sum(case when (criteria1 in ('y','Y') and criteria2 in ('y', 'Y')) then 1 else 0 end) as result from Ameriprise_LLC
group by teamid
having sum(case when (criteria1 in ('y','Y') and criteria2 in ('y', 'Y')) then 1 else 0 END) >=2
)
select al.teamid,al.memberid, al.criteria1, al.criteria2,
case when (criteria1 in ('y','Y') and criteria2 in ('y', 'Y')) and result>=2 then 'YES' else 'NO' end as output
from Ameriprise_LLC al
left join temp t on al.teamid = t.teamid;

-- PayPal SQL Interview Problem (Level Hard) 
With department as (
select  department_id as department_id, avg(salary) as sal  from emp
	group by department_id
), all_data as (
select dep.department_id as dep_id, sal, e.* from department dep, emp e
where dep.department_id != e.department_id
), final_res as (
select *, avg(salary)over(partition by dep_id) as avg_sal
from all_data
)
select dep_id, sal, avg_sal, count(*) as total_emp, sum(salary) from final_res
where sal<avg_sal
group by dep_id, sal, avg_sal

--FAANG Level SQL Question 
with temp as (
select empd_id,  swipe,
case when flag = 'I' then lead(swipe)over(partition by empd_id order by swipe) else NULL end as difftime
from clocked_hours
)
select empd_id, sum(difftime-swipe) as clocked_hours
from temp 
where difftime is not null
group by empd_id;

--2nd way 
with cte as (
select *, row_number()over(partition by empd_id, flag) as rn from clocked_hours
), cte2 as(
select empd_id,max(swipe) - min(swipe) as diff
from cte 
group by empd_id, rn
	)
select empd_id, sum(diff) from cte2
group by empd_id;

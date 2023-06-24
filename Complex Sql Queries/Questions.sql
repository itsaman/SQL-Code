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

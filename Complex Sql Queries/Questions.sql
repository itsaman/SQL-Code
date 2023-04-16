-- Complex SQL Query 1 |

with temp as (
select team_1, case when team_1 = winner then 1 else 0 end as win_flag from icc_world_cup
union all 
select team_2, case when team_2 = winner then 1 else 0 end as win_flag from icc_world_cup
)
select team_1, count(team_1) as no_of_match, sum(win_flag) as no_of_wins, count(team_1)-sum(win_flag) as no_of_losses
from temp
group by team_1;

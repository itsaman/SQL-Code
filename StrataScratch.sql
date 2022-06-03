--Popularity Percentage

with temp as(
select user1 as user,count(*) as c1 from facebook_friends
group by user1
union 
select user2 as user,count(*) as c1 from facebook_friends
group by user2
)
select t.user, (sum(c1)/count(*)over())*100 as popularity_percent
from temp t
group by t.user 
order by t.user


--Classify Business Type
select distinct business_name,
case when lower(business_name) like '%school%' then 'school' 
     when lower(business_name) like '%restaurant%' then 'restaurant'
     when lower(business_name) like '%coffee%' or lower(business_name) like '%cafe%' or lower(business_name) like '%café%' then 'cafe'
else 'other'
end as business_type
from sf_restaurant_health_violations


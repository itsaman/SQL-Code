-- Traffic Source analysis

-- which ads are driving more sessions
select utm_content, 
	   count(distinct ws.website_session_id), 
       count(distinct order_id),
       count(distinct order_id)/count(distinct ws.website_session_id)*100
from website_sessions ws
	left join orders ord
		on ws.website_session_id = ord.website_session_id
where ws.website_session_id between 1000 and 2000 
group by utm_content
order by 2 desc;

-- Site traffic Breakdown
select utm_source, 
	   utm_campaign, http_referer, 
	   count(distinct website_session_id) as co
from website_sessions
where created_at < '2012-04-12'
group by utm_source, utm_campaign, http_referer
order by co desc;

-- conversion rate
select count(ord.website_session_id) as orders, 
	   count(ws.website_session_id) as sessions, 
       count(ord.website_session_id)/count(ws.website_session_id) as csr
from website_sessions ws 
	left join  orders ord
		on ord.website_session_id = ws.website_session_id
where utm_source = 'gsearch' and utm_campaign = 'nonbrand' and ws.created_at < '2012-04-14';

-- Traffic source trending
select week_start_date, sessions from(
select 	week(created_at), 
		min(date(created_at)) as week_start_date, 
		count(distinct website_session_id) as sessions 
from website_sessions
where utm_source = 'gsearch' 
and utm_campaign = 'nonbrand'
and created_at < '2012-05-10'
group by week(created_at)
)temp;

-- Traffic source bid optimization
select device_type,
	   count(distinct ws.website_session_id) as sessions, 
       count(order_id) as orders,
	   count(order_id)/count(distinct ws.website_session_id)*100 as csr
from website_sessions ws
	left join orders ord
		on ws.website_session_id = ord.website_session_id
where ws.created_at < '2012-05-11'and utm_source = 'gsearch' and utm_campaign = 'nonbrand'
group by device_type;


-- Segment Trending

select 
-- week(created_at),
min(date(created_at)),
count(case when device_type = 'mobile' then website_session_id else null end) as 'mobile_ses',
count(case when device_type = 'desktop' then website_session_id else null end) as 'desktop_ses'
from website_sessions
where utm_source = 'gsearch' and utm_campaign = 'nonbrand' and created_at between '2012-04-15' and '2012-06-09'
group by week(created_at)

















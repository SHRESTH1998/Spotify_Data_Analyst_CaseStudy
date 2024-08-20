
/*Q1) Find the total active users each day. */
select Date(event_date) as Day, count(distinct user_id) as DAU 
from activity 
Group by  Date(event_date);

/* Q2) Find the total actove users each week.*/

select week(event_date) as week, count(distinct user_id) as WAU 
from activity 
Group by  week(event_date);

/* Q3) Find the datewise total number of user who made the purchase, the same day they installed the app*/
select event_date, count(user_id) as Number_of_users from
( 
select user_id,event_date, count(event_name) from activity
group by user_id,event_date
having count(event_name)=2
) x
group by event_date;

/*Q4)percentage of paid users in india, USA, and other countries
 where other countries other than India and USA are tagged as others*/
with country_users as
                   ( select case when country in ('USA', 'India') then country else 'others' end as new_country, count(distinct user_id) as user_count from activity
					where event_name = 'app-purchase'
				    group by case when country in ('USA', 'India') then country else 'others' end),
total_users as 
			(select sum(user_count) as total_no_users from country_users)
            
select new_country, round(user_count/total_no_users,2)*100 as percent_users
 from country_users,total_users;
 
 /* Q5) Among all the users who installed the app on any given day, 
 how many did in app purchase on the very next day (give day wise result)*/
WITH prev_data as (
Select *, 
lag(event_name,1) Over (partition by user_id order by event_date) as prev_event_name,
lag(event_date,1) Over (partition by user_id order by event_date) as prev_event_date
from activity) 
select event_date, count(distinct user_id) as user_count from prev_data
where event_name = 'app-purchase' and prev_event_name = 'app-installed' and datediff(event_date,prev_event_date)=1
Group by event_date;

## zapiertest

### About active_churn_users.sql
+ The code returns monthly active users and churn on a daily basis
+ I explored the data and wrote the script in SQL Workbench but would advise setting it up as a Persistent Derived Table in Looker so that it can be visualized
+ I chose SQL Workbench because it's free and recommended by Amazon

### Explaining my approach
1) I created a cte that holds a distinct list of all dates in the data set to be used in step 2
```
WITH d as ( select distinct date datum from source_data.tasks_used_da )
```


4) Finally I joined the subquery I created in steps 1 and 2 to the cte I created in step 1. Choosing to use binary numbers to designate active vs. churned allowed me to easily quantify the number of active and churned users by day in this step; I simply had to sum the active column to get the number of active users and count all records less the sum of active to get churned users.
```
select d.datum , nvl(sum(u.active),0) active , nvl(count(u.active),0)-nvl(sum(u.active),0) churn
from d
left join (
```
3) In this step I grouped the data from step 2 by date (days 0-56) and user id and created a new column that categorizes the grouping as active if the sum of the active column created in step 2 is 1 or greater. The new column accounts for cases where a user was active and churned on the same day due to multiple tasks with overlapping 56-day horizons. If a user has active and churned records for the same day, sum(active) will return a number greater or equal to 1 and the grouping will be categorized as active.
```    
    select datum , user_id , case when sum(active)>=1 then 1 else 0 end active
    from (
```
2) Here I joined the cte from step 1 to the tasks_used_da data set, returning a record for 56 days following the task date. The case statement classifies the user as active (=1) for the 28 days following the task date and as churned (=0) for days 29-56. My choice to use binary logic to classify active vs churned users comes in handy later.
```                
        select t.* , d.datum , d.datum - t.date diff, case when d.datum - t.date <= 28 then 1 else 0 end active
        from source_data.tasks_used_da t
        left join d ON d.datum >= t.date and d.datum <= t.date+56   
```   
```   
   group by datum , user_id
    ) u on u.datum = d.datum
group by d.datum    
order by d.datum
```

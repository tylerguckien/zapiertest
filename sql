WITH d as (
select distinct date datum from source_data.tasks_used_da
    )

select d.datum , nvl(sum(u.active),0) active , nvl(count(u.active),0)-nvl(sum(u.active),0) churn
from d
left join (
    select datum , user_id , case when sum(active)>=1 then 1 else 0 end active
    from (
        select t.* , d.datum , d.datum - t.date diff, case when d.datum - t.date <= 28 then 1 else 0 end active
        from source_data.tasks_used_da t
        left join d ON d.datum >= t.date and d.datum <= t.date+56
        where user_id in ('37','76') )
        group by datum , user_id
    ) u on u.datum = d.datum
group by d.datum    
order by d.datum
;

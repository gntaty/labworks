WITH revenue AS (
    SELECT  /*+ materialize */
        to_char(date_attendance, 'MM-YYYY')      AS month,
        to_char(date_attendance, 'YYYY')         AS year,
        type,
        k.kindergarten,
        country,
        s.service,
        COUNT(s.service)                          quantity_services,
        COUNT(s.service) * s.service_cost         total_revenue
    FROM
             sa_attendances sa
        INNER JOIN ta_source_contracts  ch ON ch.child_lastname = sa.child_lastname
                                             AND ch.child_name = sa.child_name
        INNER JOIN gen_ kindergarten     k ON k.kindergarten = sa.kindergarten
                                         AND k.kindergarten_groups = sa.kindergarten_groups
        INNER JOIN gen_service_type     s ON s.service = sa.service
    GROUP BY
        to_char(date_attendance, 'MM-YYYY'),
        to_char(date_attendance, 'YYYY'),
        type,
        k.kindergarten,
        country,
        s.service,
        s.service_cost
)
select 
        year
        ,first_value (total_revenue) over (partition by country,kindergarten,service,year 
                                            order by total_revenue desc
                                            rows between unbounded preceding and unbounded following 
                                            ) top_revenue,
        first_value (month) over (partition by country,kindergarten,service,year 
                                            order by total_revenue desc
                                            rows between unbounded preceding and unbounded following 
                                            ) top_revenue_month
FROM
    revenue;

--last_value
WITH revenue AS (
    SELECT  /*+ materialize */
        to_char(date_attendance, 'MM-YYYY')      AS month,
        to_char(date_attendance, 'YYYY')         AS year,
        type,
        k.kindergarten,
        country,
        s.service,
        COUNT(s.service)                          quantity_services,
        COUNT(s.service) * s.service_cost         total_revenue
    FROM
             sa_attendances sa
        INNER JOIN ta_source_contracts  ch ON ch.child_lastname = sa.child_lastname
                                             AND ch.child_name = sa.child_name
        INNER JOIN gen_kindergarten     k ON k.kindergarten = sa.kindergarten
                                         AND k.kindergarten_groups = sa.kindergarten_groups
        INNER JOIN gen_service_type     s ON s.service = sa.service
    GROUP BY
        to_char(date_attendance, 'MM-YYYY'),
        to_char(date_attendance, 'YYYY'),
        type,
        k.kindergarten,
        country,
        s.service,
        s.service_cost
)
select distinct
        year
        ,country
        ,last_value (total_revenue) over (partition by year, service,country
                                            order by total_revenue desc
                                            rows between unbounded preceding and unbounded following 
                                            ) last_revenue
        
  from  revenue;
  
  --dense_rank,rank, row_number
create view revenue AS (
    SELECT  /*+ materialize */
        to_char(date_attendance, 'MM-YYYY')      AS month,
        to_char(date_attendance, 'YYYY')         AS year,
        type,
        k.kindergarten,
        country,
        s.service,
        COUNT(s.service)                          quantity_services,
        COUNT(s.service) * s.service_cost         total_revenue
    FROM
             sa_attendances sa
        INNER JOIN ta_source_contracts  ch ON ch.child_lastname = sa.child_lastname
                                             AND ch.child_name = sa.child_name
        INNER JOIN gen_kindergarten     k ON k.kindergarten = sa.kindergarten
                                         AND k.kindergarten_groups = sa.kindergarten_groups
        INNER JOIN gen_service_type     s ON s.service = sa.service
    GROUP BY
        to_char(date_attendance, 'MM-YYYY'),
        to_char(date_attendance, 'YYYY'),
        type,
        k.kindergarten,
        country,
        s.service,
        s.service_cost
);

select 
        year
        ,service
        ,rank () over (partition by kindergarten order by total_revenue desc 
                                            ) rn
        ,dense_rank () over (partition by kindergarten order by total_revenue desc 
                                            ) dens_rn
        ,row_number () over (partition by kindergarten order by total_revenue desc 
                                            ) row_num
from (select 
        year,
        service,
        kindergarten,
        sum(total_revenue)total_revenue
from    revenue
 GROUP BY
        year,
        service,
        kindergarten
       )t1;

 select  country 
        ,year
        ,month
        ,service
        ,max (total_revenue) over( partition by country,year,month           
                     order by year,month   rows between 1 preceding and 1 following ) max_month_3  
 from revenue 


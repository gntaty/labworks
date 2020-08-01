SELECT distinct country,TOTAL_REVENUE,quantity_services
from revenue_mm
model UNIQUE SINGLE REFERENCE
DIMENSION BY(country)
MEASURES (TOTAL_REVENUE,quantity_services)
RULES 
( TOTAL_REVENUE[FOR country IN (SELECT distinct country from revenue_mm )]=SUM(TOTAL_REVENUE)[CV(country)]
    ,quantity_services[FOR country IN (SELECT distinct country from revenue_mm )]=SUM(quantity_services)[CV(country) ]
);

SELECT distinct country,kindergarten
        ,type,TOTAL_REVENUE,quantity_services
from revenue_mm
model UNIQUE SINGLE REFERENCE
PARTITION BY (COUNTRY) DIMENSION BY(KINDERGARTEN,type)
MEASURES (TOTAL_REVENUE,quantity_services)
RULES 
( TOTAL_REVENUE[FOR KINDERGARTEN IN (SELECT distinct KINDERGARTEN from revenue_mm ),ANY]=SUM(TOTAL_REVENUE)[CV(KINDERGARTEN),ANY]
 ,quantity_services[FOR KINDERGARTEN IN (SELECT distinct KINDERGARTEN from revenue_mm ),ANY]=SUM(quantity_services)[CV(KINDERGARTEN),ANY ]
    )
;

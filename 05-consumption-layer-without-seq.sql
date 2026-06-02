ALTER SESSION SET TIMEZONE = 'Asia/Kolkata';
select current_timestamp();


-- changing the context
use role sysadmin;
use warehouse compute_wh;
use schema dt_dbv2.consumption;

-- customer dimension dim table
CREATE OR REPLACE DYNAMIC TABLE dt_dbv2.consumption.customer_dim_dt
    TARGET_LAG='downstream'
    WAREHOUSE=dt_transform_wh
AS
select
    cust_key,
    name,
    address,
    nation_name,
    phone,
    acct_bal,
    mkt_segment
from 
    dt_dbv2.clean.customer_clean_dt;

-- date dim table
CREATE OR REPLACE DYNAMIC TABLE dt_dbv2.consumption.date_dim_dt
    TARGET_LAG='downstream'
    WAREHOUSE=dt_transform_wh
AS
select
    order_date,
    year(order_date) as order_year,
    quarter(order_date) as order_quarter,
    month(order_date) as order_month,
    week(order_date) as order_week,
    dayofmonth(order_date) as order_day
from 
    dt_dbv2.clean.order_clean_dt 
group by 
    order_date,
    order_year,
    order_quarter,
    order_month,
    order_week,
    order_day;



-- priority dim table
CREATE OR REPLACE DYNAMIC TABLE dt_dbv2.consumption.priority_dim_dt
    TARGET_LAG='downstream'
    WAREHOUSE=dt_transform_wh
AS
select
    order_priority
from 
    dt_dbv2.clean.order_clean_dt 
group by order_priority;


-- fact table
CREATE OR REPLACE DYNAMIC TABLE dt_dbv2.consumption.order_fact_dt
    TARGET_LAG='3 minutes'
    WAREHOUSE=dt_transform_wh
AS
select
    oc.cust_key,
    oc.order_date,
    pd.order_priority,
    oc.order_key,
    oc.total_price
from 
    dt_dbv2.clean.order_clean_dt oc
    join dt_dbv2.consumption.customer_dim_dt cd on cd.cust_key = oc.cust_key
    join dt_dbv2.consumption.date_dim_dt dd on dd.order_date = oc.order_date
    join dt_dbv2.consumption.priority_dim_dt pd on pd.order_priority = oc.order_priority;
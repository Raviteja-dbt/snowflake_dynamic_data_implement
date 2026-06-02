ALTER SESSION SET TIMEZONE = 'Asia/Kolkata';
select current_timestamp();


-- changing the context
use role sysadmin;
use warehouse compute_wh;
use schema dt_dbv2.clean;


create warehouse dt_transform_wh 
    with 
    warehouse_size = 'xsmall' 
    warehouse_type = 'standard' 
    auto_suspend = 60 
    auto_resume = true 
    min_cluster_count = 1
    max_cluster_count = 1 
    scaling_policy = 'standard'
    initially_suspended = True;

CREATE OR REPLACE DYNAMIC TABLE dt_dbv2.clean.customer_clean_dt
    TARGET_LAG='2 minutes'
    WAREHOUSE=dt_transform_wh
AS
WITH RankedCustomer AS (
    SELECT
        cust_key,
        name,
        address,
        nation_name,
        phone,
        acct_bal,
        mkt_segment,
        load_ts,
        load_row_number,
        load_file_name,
        ROW_NUMBER() OVER (PARTITION BY cust_key ORDER BY load_ts DESC) AS row_rank
    FROM 
        dt_dbv2.raw.customer_raw 
)
SELECT
    cust_key,
    name,
    address,
    nation_name,
    phone,
    acct_bal,
    mkt_segment,
    load_ts,
    load_row_number,
    load_file_name
FROM
    RankedCustomer
WHERE
    row_rank = 1;

     
-- order dynamic table
CREATE OR REPLACE DYNAMIC TABLE dt_dbv2.clean.order_clean_dt
    TARGET_LAG='20 minutes'
    WAREHOUSE=dt_transform_wh
AS
    SELECT
    order_key,
    cust_key,
    order_status,
    total_price,
    order_date,
    order_priority,
    clerk,
    ship_priority,
    load_ts,
    load_row_number,
    load_file_name
FROM (
    SELECT
        order_key,
        cust_key,
        order_status,
        total_price,
        order_date,
        order_priority,
        clerk,
        ship_priority,
        load_ts,
        load_row_number,
        load_file_name,
        ROW_NUMBER() OVER (PARTITION BY order_key ORDER BY load_ts DESC) AS row_rank
    FROM 
        dt_dbv2.raw.order_raw
) AS RankedOrders
WHERE row_rank = 1;

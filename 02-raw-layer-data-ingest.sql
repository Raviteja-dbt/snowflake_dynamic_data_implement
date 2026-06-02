
-- changing the context
use role sysadmin;
use warehouse compute_wh;
use schema dt_dbv2.raw;

-- create tables inside the raw layer
-- ----------------------------------
create or replace table dt_dbv2.raw.customer_raw (
    cust_key number,
    name text,
    address text,
    nation_name text,
    phone text,
    acct_bal number,
    mkt_segment text,
    load_ts timestamp,
    load_row_number number,
    load_file_name text 
);

-- creating order table with 11 columns
create or replace table dt_dbv2.raw.order_raw (
    order_key number,
    cust_key number,
    order_status text(1),
    total_price number,
    order_date date,
    order_priority text,
    clerk text,
    ship_priority number(1),
    load_ts timestamp,
    load_row_number number,
    load_file_name text 
);

-- customer data pipe
-- -----------------------------------------
create pipe  if not exists  dt_demo_db.raw.customer_pipe_raw
auto_ingest = true
as
copy into dt_dbv2.raw.customer_raw from 
(
select 
    t.$1,t.$2,t.$3,t.$4,t.$5,t.$6,t.$7,
    current_timestamp(),
    metadata$file_row_number,
    metadata$filename
from @customer_stage_ext as t
)
file_format = (format_name = 'dt_dbv2.source.csv_format');

-- customer data task
create or replace task dt_dbv2.raw.copy_to_customer_raw_task
warehouse = compute_wh
as
alter pipe dt_demo_db.raw.customer_pipe_raw refresh;


-- order data pipe
-- -----------------------------------------
create pipe  if not exists  dt_demo_db.raw.order_pipe_raw
auto_ingest = true
copy into dt_dbv2.raw.order_raw from 
(
select 
    t.$1,t.$2,t.$3,t.$4,t.$5,t.$6,t.$7,t.$8,
    current_timestamp(),
    metadata$file_row_number,
    metadata$filename
from @customer_stage_ext as t
)
file_format = (format_name = 'dt_dbv2.source.csv_format');

--Order data task
create or replace task dt_dbv2.raw.copy_to_order_raw_task
warehouse = compute_wh
after dt_dbv2.raw.copy_to_customer_raw_task
as
alter pipe dt_demo_db.raw.order_pipe_raw refresh;


--resume tasks
alter task dt_dbv2.raw.copy_to_order_raw_task resume;
alter task dt_dbv2.raw.copy_to_customer_raw_task resume;
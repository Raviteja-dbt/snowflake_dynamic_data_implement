use role sysadmin;
use warehouse compute_wh;
use schema dt_demo_db.raw;

-- create an employee table
create table dt_demo_db.raw.employee_raw (
    emp_id text primary key,
    first_name text,
    last_name text,
    date_of_birth date,
    date_of_joining date,
    email_address text,
    department text,
    designation text,
    level text,
    office_location text,
    active text,
    load_ts timestamp,
    load_row_number number,
    load_file_name text 
);

-- lets check the data
select count(*) from dt_demo_db.raw.employee_raw; -- no data
select * from dt_demo_db.raw.employee_raw; -- structure


--Creating pipe to load data into raw_table
--drop pipe my_pipe;

create pipe  if not exists  dt_demo_db.raw.employee_pipe_raw
  auto_ingest = true
  as 
  copy into dt_demo_db.raw.employee_raw from 
  (
   select 
       t.$1,t.$2,t.$3,t.$4,t.$5,t.$6,t.$7,t.$8,t.$9,t.$10,t.$11,
       current_timestamp(),
       metadata$file_row_number,
       metadata$filename
   from @dt_demo_db.source.dynamic_tbl_stage as t
   ) file_format=dt_demo_db.source.csv_format on_error=continue;
  

 show pipes;
  
-- created a task that will refresh the pipe.   
create or replace task dt_demo_db.raw.copy_emp_to_raw_task
    warehouse = compute_wh
    schedule = '3 minute'
    as
    alter pipe dt_demo_db.raw.employee_pipe_raw refresh;

-- check the objects + task graph home home page.

-- Make sure that your user must have necessary privileges.
use role accountadmin;
grant execute task, execute managed task on account to role sysadmin;
use role sysadmin;


-- lets resume the task
alter task dt_demo_db.raw.copy_emp_to_raw_task resume;

-- lets check the data
select count(*) from dt_demo_db.raw.employee_raw; -- no data
select * from dt_demo_db.raw.employee_raw; -- structure

=============================================================================================
=============================================================================================

-- leave raw table
create or replace table dt_demo_db.raw.emp_leave_raw (
    emp_id TEXT,
    leave_type TEXT,
    leave_applied_date DATE,
    leave_start_date DATE,
    leave_end_date DATE,
    leave_days INTEGER,
    status TEXT,
    load_ts timestamp,
    load_row_number number,
    load_file_name text
);

-- lets check the data
select count(*) from dt_demo_db.raw.emp_leave_raw; -- no data
select * from dt_demo_db.raw.emp_leave_raw; -- structure

--Creating pipe to load data into raw_table
drop pipe my_pipe;

create pipe if not exists dt_demo_db.raw.employee_leave_pipe_raw
  auto_ingest = true
  as 
copy into dt_demo_db.raw.emp_leave_raw from 
    (
    select 
        t.$1,t.$2,t.$3,t.$4,t.$5,t.$6,t.$7,
        current_timestamp(),
        metadata$file_row_number,
        metadata$filename
    from @dt_demo_db.source.dynamic_tbl_stage as t
    )
    file_format=dt_demo_db.source.csv_format on_error=continue;
	
 show pipes;
 
 -- created a task that will refresh the pipe.   
create or replace task dt_demo_db.raw.copy_emp_leave_to_raw_task
    warehouse = compute_wh
    schedule = '2 minute'
    as
    alter pipe dt_demo_db.raw.employee_leave_pipe_raw refresh;

-- check the objects + task graph home home page.

-- Make sure that your user must have necessary privileges

-- lets resume the task
alter task dt_demo_db.raw.copy_emp_leave_to_raw_task resume;

-- lets check the data
select count(*) from dt_demo_db.raw.emp_leave_raw; -- no data
select * from dt_demo_db.raw.emp_leave_raw; -- structure
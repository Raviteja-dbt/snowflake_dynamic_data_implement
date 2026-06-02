
use role sysadmin;
use warehouse compute_wh;
use schema dt_demo_db.clean;

-- want to create a table that is equivalent to the output of following query
select 
    emp_id,
    first_name,
    last_name,
    date_of_birth as dob,
    date_of_joining as doj,
    email_address as email,
    department,
    designation,
    level,
    office_location,
    active as active_flag
from 
    dt_demo_db.raw.employee_raw 
    where active = 'Yes';

// ------------------------------------------------------

//-- 
-- create a dynamic table.. and here is the structure
create or replace dynamic table 
    dt_demo_db.clean.employees_clean_dt
    (
        emp_id,
        first_name,
        last_name,
        dob comment 'Date of Birth',
        doj comment 'Date of Joining',
        email comment 'Email Address',
        department,
        designation,
        emp_level,
        office_location,
        active_flag comment 'Employee Status' 
    )
    target_lag = '5 minutes'
    warehouse = compute_wh
AS
select 
    emp_id,
    first_name,
    last_name,
    date_of_birth,
    date_of_joining,
    email_address,
    department,
    designation,
    level,
    office_location,
    active
from 
    dt_demo_db.raw.employee_raw 
    where active = 'Yes';


-- now lets load the data...
--Upload one by one file to s3 bucket and observe the Dynamic table behaviour


-- Perform different insert/updated/delete operations

-- bulk delete
-- check the employee records in raw layer
select * from dt_db.raw.employee_raw where emp_id between 1 and 10; 

delete from dt_db.raw.employee_raw where emp_id between 1 and 10; 


--query dynamic tables

select * from dt_db.clean.employees_clean_dt 
where emp_id in (12,17)
order by emp_id;

--where emp_id between 1 and 10;
select * from dt_db.clean.employees_clean_dt order by emp_id;
--where emp_id between 1 and 10;

-- bulk update
select * from dt_db.raw.employee_raw where 
    level = 'L1' and 
    emp_id between 11 and 20;

update dt_db.raw.employee_raw set level = 'L0'
where 
    level = 'L1' and 
    emp_id between 11 and 20;

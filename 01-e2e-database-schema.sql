-- Select role and warehoue
-- --------------------------------
use role sysadmin;
use warehouse compute_wh;

-- Create databsae and schema.
-- ----------------------------------
create or replace database dt_dbv2
comment = 'this is dt_dbv2 database for pipeline using dynamic tables';

use database dt_dbv2;

create or replace schema source
comment = 'this is stage schema in dt_dbv2 database';
create or replace schema raw
comment = 'this is raw schema in dt_dbv2 database';
create or replace schema clean
comment = 'this is clean schema in dt_dbv2 database';
create or replace schema consumption
comment = 'this is consumption schema in dt_dbv2 database';


-- Create file format.
-- --------------------------
create or replace file format dt_dbv2.source.csv_format
    type = 'csv' 
    compression = 'auto' 
    field_delimiter = ',' 
    record_delimiter = '\n'
    skip_header = 1;
	
-- Create an external stage location
-- -----------------------------------------
use role ACCOUNTADMIN;

--create storage integration 
create storage integration s3_int
  type = external_stage
  storage_provider = 's3'
  enabled = true
  storage_aws_role_arn = 'arn:aws:iam::631265985851:role/b21_s3_access_role'
  storage_allowed_locations = ('s3://b21-data-bucket/data/');

grant usage on integration s3_int to role sysadmin;

use role SYSADMIN;

desc integration s3_int;

-- Create an external stage location for customer
-- -----------------------------------------
create or replace stage dt_demo_db.source.customer_stage_ext
storage_integration = s3_int
url = 's3://b21-data-bucket/data/customer/'
file_format = csv_format;
comment = 'this is snowflake external stage to stage the data files under the dt_dbv2/source schema';
  
list @dt_demo_db.source.customer_stage_ext;

-- Create an external stage location for orders
-- -----------------------------------------
 create or replace stage dt_demo_db.source.order_stage_ext
  storage_integration = s3_int
  url = 's3://b21-data-bucket/data/order/'
  file_format = csv_format;
  comment = 'this is snowflake external stage to stage the data files under the dt_dbv2/source schema';
  
list @dt_demo_db.source.order_stage_ext;
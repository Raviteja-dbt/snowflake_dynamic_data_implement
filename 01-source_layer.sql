use role sysadmin;
use warehouse compute_wh;

create or replace database dt_demo_db
comment = 'this is dt_demo_db database for dynamic tables';


create or replace schema source
comment = 'this is source schema in dt_demo_db database';
create or replace schema raw
comment = 'this is raw schema in dt_demo_db database';
create or replace schema clean
comment = 'this is clean schema in dt_demo_db database';
create or replace schema consumption
comment = 'this is consumption schema in dt_demo_db database';

-- change context
use schema dt_demo_db.source;

--create file format
create or replace file format dt_demo_db.source.csv_format (type = 'csv' skip_header = 1);

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
  
 copy the snowflake_aws_iam_arn and snowflake_external_id and paste it at trust relationships..

  create or replace stage dt_demo_db.source.dynamic_tbl_stage
  storage_integration = s3_int
  url = 's3://b21-data-bucket/data/'
  file_format = csv_format;

list @dt_demo_db.source.dynamic_tbl_stage;
   


select 
t.$1,t.$2,t.$3,t.$4,t.$5,t.$6,t.$7,t.$8,t.$9,t.$10,t.$11,
current_timestamp(),
metadata$file_row_number,
metadata$filename
from @dt_demo_db.source.dynamic_tbl_stage as t;

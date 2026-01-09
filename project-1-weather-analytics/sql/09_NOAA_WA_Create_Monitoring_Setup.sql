--Automated Data Quality with DMFs setup
USE WAREHOUSE NOAA_WH;

USE ROLE ACCOUNTADMIN;

GRANT EXECUTE DATA METRIC FUNCTION
ON ACCOUNT
TO ROLE NOAA_ENGINEER;

-- Also grant usage so the role can read system DMFs
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE NOAA_ENGINEER;

--Schedule the DMF on DATA_MART Table

USE ROLE NOAA_ENGINEER;
USE DATABASE NOAA_WEATHER_DB;

--ALTER TABLE DATA_MART.FACT_WEATHER_DAILY
--SET DATA_METRIC_SCHEDULE = 'USING CRON 0 0 * * * UTC'; --each day at midnight

ALTER TABLE DATA_MART.FACT_WEATHER_DAILY
SET DATA_METRIC_SCHEDULE = '10 MINUTE'; -- for demonstation purpuse 

ALTER TABLE DATA_MART.DIM_STATION
SET DATA_METRIC_SCHEDULE = '5 MINUTE'; -- for demonstation purpuse 

---Trigger-Based Scheduling (Optional)
---This makes the metric functions run only when new data arrives.
---ALTER TABLE DATA_MART.FACT_WEATHER_DAILY
---SET DATA_METRIC_SCHEDULE = 'ON INSERT';


--Associate System DMFs for Core Checks
--System DMFs measure quality dimensions like nulls, blanks, uniqueness, and overall volume.

---NULL count on avg_metric_value with expectation added
---Expectations let you define what qualifies as a failure based on the DMF results.
---Example: Null count should be less than 10:

ALTER TABLE DATA_MART.FACT_WEATHER_DAILY
ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
  ON (avg_metric_value)
  EXPECTATION FACT_WEATHER_DAILY_NULL_COUNT_EXP (VALUE < 10);

---Blank count on metric_name
ALTER TABLE DATA_MART.FACT_WEATHER_DAILY
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.BLANK_COUNT
    ON (metric_name);

---Get total row count
ALTER TABLE DATA_MART.FACT_WEATHER_DAILY
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.ROW_COUNT
    ON ();

---Duplicate count on station_id
ALTER TABLE DATA_MART.DIM_STATION
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.DUPLICATE_COUNT
   ON (station_id);

--Querying DMF Results

SELECT
  measurement_time,
  scheduled_time,
  table_name,
  table_schema,
  metric_name,
  metric_return_type,
  value
FROM SNOWFLAKE.LOCAL.DATA_QUALITY_MONITORING_RESULTS
WHERE table_name in ('FACT_WEATHER_DAILY','DIM_STATION')
ORDER BY measurement_time DESC;

--Expectations that exist for a specific DMF
SELECT *
  FROM TABLE(
    INFORMATION_SCHEMA.DATA_METRIC_FUNCTION_EXPECTATIONS(
      REF_ENTITY_NAME => 'NOAA_WEATHER_DB.DATA_MART.FACT_WEATHER_DAILY',
      REF_ENTITY_DOMAIN => 'table'));
	  
-- check if expectations were violated
SELECT expectation_name,
       metric_name,
       expectation_expression,
       arguments,
       value,
       expectation_violated
  FROM TABLE(SYSTEM$EVALUATE_DATA_QUALITY_EXPECTATIONS(
      REF_ENTITY_NAME => 'NOAA_WEATHER_DB.DATA_MART.FACT_WEATHER_DAILY')); 


--Validate Setup
--List DMF associations
SELECT *
  FROM TABLE(
    INFORMATION_SCHEMA.DATA_METRIC_FUNCTION_REFERENCES(
      REF_ENTITY_NAME => 'NOAA_WEATHER_DB.DATA_MART.FACT_WEATHER_DAILY',
      REF_ENTITY_DOMAIN => 'table'
    )
  );

SELECT *
  FROM TABLE(
    INFORMATION_SCHEMA.DATA_METRIC_FUNCTION_REFERENCES(
      REF_ENTITY_NAME => 'NOAA_WEATHER_DB.DATA_MART.DIM_STATION',
      REF_ENTITY_DOMAIN => 'table'
    )
  );


-- Manully created DQ validation task using custom table:
USE SCHEMA MONITORING;

CREATE OR REPLACE TABLE DATA_QUALITY_RESULTS (
  check_ts TIMESTAMP,
  layer       STRING,
  object_name STRING,
  issue       STRING,
  issue_count NUMBER
);

CREATE OR REPLACE TASK TASK_DQ_FACT_WEATHER
WAREHOUSE = NOAA_WH
SCHEDULE = 'USING CRON 0 7 * * * UTC'
AS
INSERT INTO DATA_QUALITY_RESULTS
SELECT
  CURRENT_TIMESTAMP,
  'DATA_MART',
  'FACT_WEATHER_DAILY',
  'avg_metric_value IS NULL',
  COUNT(*)
FROM DATA_MART.FACT_WEATHER_DAILY
WHERE avg_metric_value IS NULL;


--Manual execution of the task 
--EXECUTE TASK TASK_DQ_FACT_WEATHER;

--monitor the task execution
SELECT * 
  FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
  where database_name = 'NOAA_WEATHER_DB' and schema_name = 'MONITORING'
  ORDER BY SCHEDULED_TIME;

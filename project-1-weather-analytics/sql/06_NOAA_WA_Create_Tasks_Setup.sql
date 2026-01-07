-- Tasks (Orchestration)
USE WAREHOUSE NOAA_WH;
USE ROLE NOAA_ENGINEER;
USE DATABASE NOAA_WEATHER_DB;
USE SCHEMA DATA_MART;

-- Tasks flow:

-- TASK_LOAD_STAGING_WEATHER
--    ↓ (overwrite)
-- TASK_LOAD_FACT_INPUT
--    ↓ (overwrite)
-- STREAM detects changes
--    ↓
-- TASK_BUILD_FACT_WEATHER_DAILY
--    (runs ONLY if stream has data)



-- create task graph
-- create hourly root task
CREATE OR REPLACE TASK TASK_LOAD_STAGING_WEATHER
WAREHOUSE = NOAA_WH
SCHEDULE = 'USING CRON 0 0 1 */3 * UTC'  -- every 3 months correlated with shared data lag
AS
INSERT OVERWRITE INTO STAGING.STG_WEATHER_METRICS
SELECT
  station_id,
  metric_name,
  observation_date,
  metric_value,
  load_ts
FROM STAGING.V_STG_WEATHER_METRICS;

-- create child task (SNAPSHOT COPY INTO DATA_MART.INPUT)
CREATE OR REPLACE TASK TASK_LOAD_FACT_INPUT
WAREHOUSE = NOAA_WH
AFTER TASK_LOAD_STAGING_WEATHER
AS
INSERT OVERWRITE INTO DATA_MART.FACT_WEATHER_INPUT
SELECT
  station_id,
  metric_name,
  observation_date,
  metric_value,
  load_ts
FROM STAGING.STG_WEATHER_METRICS;

-- create child task for incremental (stream based) processing
CREATE OR REPLACE TASK TASK_BUILD_FACT_WEATHER_DAILY
WAREHOUSE = NOAA_WH
AFTER TASK_LOAD_FACT_INPUT
WHEN SYSTEM$STREAM_HAS_DATA('FACT_WEATHER_INPUT_STREAM')
AS
INSERT INTO DATA_MART.FACT_WEATHER_DAILY
SELECT
  station_id,
  observation_date,
  metric_name,
  AVG(metric_value)              AS avg_metric_value,
  CURRENT_TIMESTAMP              AS processed_ts
FROM FACT_WEATHER_INPUT_STREAM
WHERE METADATA$ACTION = 'INSERT'
GROUP BY
  station_id,
  observation_date,
  metric_name;

--activate the child and root tasks
ALTER TASK TASK_LOAD_FACT_INPUT          RESUME;
ALTER TASK TASK_BUILD_FACT_WEATHER_DAILY RESUME;
ALTER TASK TASK_LOAD_STAGING_WEATHER     RESUME;

--Manual execution of the task graph
--EXECUTE TASK TASK_LOAD_FACT_INPUT;

--monitor the task graph execution
SELECT * 
  FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
  where database_name = 'NOAA_WEATHER_DB' and schema_name = 'DATA_MART'
  ORDER BY SCHEDULED_TIME;

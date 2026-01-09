--DATA MART Layer (Facts & Dimensions)
USE WAREHOUSE NOAA_WH;
USE ROLE NOAA_ENGINEER;
USE DATABASE NOAA_WEATHER_DB;
USE SCHEMA DATA_MART;

--Dimension: Stations
CREATE OR REPLACE TABLE DIM_STATION AS
SELECT DISTINCT
  station_id,
  station_name,
  country,
  state,
  latitude,
  longitude,
  elevation
FROM STAGING.STG_WEATHER_STATIONS;

CREATE OR REPLACE TABLE FACT_WEATHER_DAILY (
  station_id        STRING,
  observation_date  DATE,
  metric_name       STRING,
  avg_metric_value  FLOAT,
  processed_ts      TIMESTAMP
);

--DATA_MART INPUT TABLE (SNAPSHOT BOUNDARY)
CREATE OR REPLACE TABLE FACT_WEATHER_INPUT (
  station_id        STRING,
  metric_name       STRING,
  observation_date  DATE,
  metric_value      FLOAT,
  load_ts           TIMESTAMP
);

-- create STREAM (INCREMENTAL consumption)
CREATE OR REPLACE STREAM FACT_WEATHER_INPUT_STREAM
ON TABLE DATA_MART.FACT_WEATHER_INPUT
APPEND_ONLY = FALSE;

-- governance : 
-- TABLE METADATA
COMMENT ON TABLE FACT_WEATHER_DAILY
IS 'Daily aggregated weather metrics by station and state';

-- STREAM METADATA
COMMENT ON STREAM FACT_WEATHER_INPUT_STREAM
IS 'CDC weather metrics changes for incremantal consumption';

-- COLUMN METADATA
COMMENT ON COLUMN FACT_WEATHER_DAILY.station_id
IS 'NOAA weather station identifier';

COMMENT ON COLUMN FACT_WEATHER_DAILY.metric_name
IS 'Metric name derived from station metadata';

COMMENT ON COLUMN FACT_WEATHER_DAILY.avg_metric_value
IS 'Daily average metric value';

--Data Quality Checks
--DATA_MART – Business Rule Validation
--Fact table integrity
SELECT COUNT(*) AS invalid_rows
FROM FACT_WEATHER_DAILY
WHERE avg_metric_value IS NULL
   OR observation_date IS NULL;

--Freshness Check
SELECT MAX(observation_date) AS latest_available_date
FROM FACT_WEATHER_DAILY; --2025-10-07

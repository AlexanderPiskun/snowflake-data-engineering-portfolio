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

CREATE OR REPLACE TABLE DATA_MART.FACT_WEATHER_DAILY (
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

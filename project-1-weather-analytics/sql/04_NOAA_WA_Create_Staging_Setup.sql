--STAGING Layer (Transform & Normalize)
USE WAREHOUSE NOAA_WH;
USE ROLE NOAA_ENGINEER;
USE DATABASE NOAA_WEATHER_DB;
USE SCHEMA STAGING;

--Stations (Dimension-ready)
CREATE OR REPLACE TABLE STG_WEATHER_STATIONS AS
SELECT
  noaa_weather_station_id   AS station_id,
  noaa_weather_station_name AS station_name,
  country_name              AS country,
  state_name                AS state,
  latitude,
  longitude,
  elevation,
  CURRENT_TIMESTAMP         AS load_ts
FROM RAW.NOAA_WEATHER_STATION_INDEX;

--Weather Metrics (Standardized + type casting)
CREATE OR REPLACE TABLE STG_WEATHER_METRICS AS
SELECT
  noaa_weather_station_id AS station_id,
  variable_name           AS metric_name,
  datetime::DATE          AS observation_date,
  value::FLOAT            AS metric_value,
  CURRENT_TIMESTAMP       AS load_ts
FROM RAW.NOAA_WEATHER_METRICS_TS;

--Create a canonical staging view
CREATE OR REPLACE VIEW V_STG_WEATHER_METRICS AS
SELECT
  noaa_weather_station_id AS station_id,
  variable_name           AS metric_name,
  datetime::DATE          AS observation_date,
  value::FLOAT            AS metric_value,
  CURRENT_TIMESTAMP       AS load_ts
FROM RAW.NOAA_WEATHER_METRICS_TS;

--Data Quality Checks
--STAGING – Type & Range Validation

-- Maual Invalid metric values
SELECT COUNT(*) AS invalid_metrics
FROM STG_WEATHER_METRICS
WHERE metric_value IS NULL
   OR metric_value < -100
   OR metric_value > 200;

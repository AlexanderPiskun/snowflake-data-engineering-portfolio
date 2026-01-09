--Analytics Portfolio
USE WAREHOUSE NOAA_WH;
USE ROLE NOAA_ENGINEER;
USE DATABASE NOAA_WEATHER_DB;
USE SCHEMA ANALYTICS;

-- 1. Avg Temperature by State
CREATE OR REPLACE VIEW AVG_TEMP_BY_STATE AS
SELECT
  s.country,
  s.state ,
  AVG(f.avg_metric_value) AS avg_temperature
FROM DATA_MART.FACT_WEATHER_DAILY f
JOIN DATA_MART.DIM_STATION s
  ON f.station_id = s.station_id
WHERE f.metric_name = 'Temperature at Observation Time'
GROUP BY s.country,s.state;

--2. Temperature Trend Over Time
CREATE OR REPLACE VIEW TEMP_TREND AS
SELECT
  observation_date,
  AVG(avg_metric_value) AS avg_temp
FROM DATA_MART.FACT_WEATHER_DAILY
WHERE metric_name = 'Temperature at Observation Time'
GROUP BY observation_date;

--3. Station with Highest Variability
CREATE OR REPLACE VIEW TEMP_VARIABILITY AS
SELECT
  station_id,
  STDDEV(avg_metric_value) AS variability
FROM DATA_MART.FACT_WEATHER_DAILY
WHERE metric_name = 'Temperature at Observation Time'
GROUP BY station_id;

--4. Extreme Weather Days
CREATE OR REPLACE VIEW EXTREME_TEMP_DAYS AS
SELECT *
FROM DATA_MART.FACT_WEATHER_DAILY
WHERE metric_name = 'Temperature at Observation Time'
  AND avg_metric_value > 40;


--5. Top 10 Warmest Stations
CREATE OR REPLACE VIEW TOP_10_WARMEST_STATIONS AS
SELECT
  station_id,
  AVG(avg_metric_value) AS avg_temp
FROM DATA_MART.FACT_WEATHER_DAILY
WHERE metric_name = 'Temperature at Observation Time'
GROUP BY station_id
ORDER BY avg_temp DESC
LIMIT 10;

--6+7. security boundary views
---Contain no transformations
---Exist solely to attach security policies
---Act as the contract between platform and consumers

CREATE OR REPLACE VIEW ANALYTICS.V_WEATHER_DAILY_SECURED AS
SELECT *
FROM DATA_MART.FACT_WEATHER_DAILY;

CREATE OR REPLACE VIEW ANALYTICS.V_DIM_STATION_SECURED AS
SELECT *
FROM DATA_MART.DIM_STATION;

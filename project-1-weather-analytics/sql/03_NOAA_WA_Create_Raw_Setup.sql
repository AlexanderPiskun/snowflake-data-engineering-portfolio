-- RAW Layer (Marketplace Tables)
USE WAREHOUSE NOAA_WH;
USE DATABASE NOAA_WEATHER_DB;
USE ROLE ACCOUNTADMIN;


--Create a RO shouce database from share
SHOW AVAILABLE LISTINGS LIKE '%Snowflake Public Data%';

--2025-09-05 14:42:32.911 -0700	GZTSZ290BV255	Snowflake Public Data (Free)	GZTSZAS2KCS	2025-09-26 11:30:57.928 -0700	2025-09-17 14:14:28.000 -0700	ALL	false	false	false	false	true	true	false	EXTERNAL			false	

-- 3. Accept the legal terms for the listing (Required for automation)
-- Replace 'GZTSZ290BV255' with the actual Global Name found in step 2 if different
CALL SYSTEM$ACCEPT_LEGAL_TERMS('DATA_EXCHANGE_LISTING', 'GZTSZ290BV255');

-- 4. Create the database from the listing
CREATE DATABASE SNOWFLAKE_PUBLIC_DATA_FREE 
  FROM LISTING 'GZTSZ290BV255';

-- 5. Grant access to other roles in your account
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_PUBLIC_DATA_FREE TO ROLE NOAA_ENGINEER;

USE ROLE NOAA_ENGINEER;
USE SCHEMA RAW;

-- Load marketplace snapshot into local table. 
-- All this to allow data upload tasks (to be created in step 06) to read directly from tables in your account, 
-- no cross-account privileges required.
CREATE OR REPLACE TABLE NOAA_WEATHER_METRICS_TS AS
SELECT *
FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.NOAA_WEATHER_METRICS_TIMESERIES;

CREATE OR REPLACE TABLE NOAA_WEATHER_STATION_INDEX AS
SELECT *
FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.NOAA_WEATHER_STATION_INDEX;

CREATE OR REPLACE TABLE NOAA_WATER_SUPPLY_TS AS
SELECT *
FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.NOAA_NWRFC_WATER_SUPPLY_TIMESERIES;

--Data Quality Checks examples
-- RAW – Volume & Null Checks

-- RAW table completeness
SELECT COUNT(*) AS total_rows
FROM NOAA_WEATHER_METRICS_TS;

-- RAW table Null Checks
SELECT COUNT(*) AS null_station_ids
FROM NOAA_WEATHER_METRICS_TS
WHERE noaa_weather_station_id IS NULL;

{{ config(materialized='view') }}

select
    noaa_weather_station_id   AS station_id,
    noaa_weather_station_name AS station_name,
    country_name              AS country,
    state_name                AS state,
    latitude,
    longitude,
    elevation
from {{ source('noaa_raw', 'noaa_weather_station_index') }}
where station_id is not null

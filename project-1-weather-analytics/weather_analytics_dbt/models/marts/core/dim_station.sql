{{ config(materialized='table') }}

select
    {{ generate_surrogate_key(['station_id']) }} as station_key,
    station_id,
    max(station_name) as station_name,
    max(country)      as country,
    max(state)        as state,
    max(latitude)     as latitude,
    max(longitude)    as longitude,
    max(elevation)    as elevation
from {{ ref('stg_noaa_weather_station_index') }}
group by station_id

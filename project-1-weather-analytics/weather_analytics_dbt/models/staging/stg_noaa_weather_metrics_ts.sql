{{ config(materialized='view') }}

select
    noaa_weather_station_id AS station_id,
    variable_name           AS metric_name,
    datetime::DATE          AS observation_date,
    value::FLOAT            AS metric_value
from {{ source('noaa_raw', 'noaa_weather_metrics_ts') }}
where date is not null

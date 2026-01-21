{{ config(materialized='view') }}

select
    weather_key,
    station_id,
    observation_date,
    avg_metric_value as temperature_value
from {{ ref('fct_weather_daily') }}
where metric_name = 'Temperature at Observation Time'
  and avg_metric_value > 40

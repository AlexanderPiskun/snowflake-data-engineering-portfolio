{{ config(materialized='view') }}

select
    station_id,
    stddev(avg_metric_value) as temperature_variability
from {{ ref('fct_weather_daily') }}
where metric_name = 'Temperature at Observation Time'
group by station_id

{{ config(materialized='view') }}

select
    observation_date,
    avg(avg_metric_value) as avg_temp
from {{ ref('fct_weather_daily') }}
where metric_name = 'Temperature at Observation Time'
group by observation_date
order by observation_date

{{ config(materialized='view') }}

select
    s.country,
    s.state,
    avg(f.avg_metric_value) as avg_temperature
from {{ ref('fct_weather_daily') }} f
join {{ ref('dim_station') }} s
    on f.station_id = s.station_id
where f.metric_name = 'Temperature at Observation Time'
group by
    s.country,
    s.state

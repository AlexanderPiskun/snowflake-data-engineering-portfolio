{{ config(
    materialized='incremental',
    unique_key='weather_key'
) }}

select
    {{ generate_surrogate_key(['station_id', 'metric_name', 'observation_date']) }} as weather_key,
    station_id,
    metric_name,
    observation_date,
    avg(metric_value) as avg_metric_value
from {{ ref('stg_noaa_weather_metrics_ts') }}

{% if is_incremental() %}
where observation_date > (select max(observation_date) from {{ this }})
{% endif %}

group by station_id, metric_name, observation_date

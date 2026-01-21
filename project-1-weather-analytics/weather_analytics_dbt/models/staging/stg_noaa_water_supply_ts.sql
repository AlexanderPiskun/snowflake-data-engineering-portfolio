{{ config(materialized='view') }}

select
    station_id,
	location,
    variable_name      as metric_name,
    value::FLOAT       as metric_value,
    unit               as metric_unit,
    water_year         as water_supply_year,
    fcst_period        as water_supply_period,
    date::DATE         as observation_date,
    measure            as water_supply_value,
    unit               as water_supply_unit,
from {{ source('noaa_raw', 'noaa_water_supply_ts') }}
where date is not null

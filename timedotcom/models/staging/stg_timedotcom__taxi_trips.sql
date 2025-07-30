{{ config(
    materialized='incremental',
    unique_key='unique_key',
	partition_by={"field": "trip_date", "data_type": "date"}
) }}

with source as (
  select
    *,
    cast(trip_start_timestamp as date) as trip_date
  from {{ source('chicago_taxi_trips', 'taxi_trips') }}
  {% if is_incremental() %}
    where trip_start_timestamp >= (select max(trip_start_timestamp) from {{ this }})
  {% endif %}
)


select
	unique_key,
	taxi_id,
	cast(trip_start_timestamp as date) as trip_date,
	trip_start_timestamp,
	trip_end_timestamp,
	trip_seconds,
	trip_miles,
	fare,
	tips,
	tolls,
	extras,
	trip_total,
	payment_type,
	company,
	pickup_latitude,
	pickup_longitude,
	pickup_location,
	dropoff_latitude,
	dropoff_longitude,
	dropoff_location
from source
where trip_start_timestamp >= '2020-01-01'
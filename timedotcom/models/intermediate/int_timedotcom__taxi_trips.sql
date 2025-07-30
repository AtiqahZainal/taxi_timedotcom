with trips as (
	select distinct
	unique_key,
	taxi_id,
	trip_date,
	datetime(trip_start_timestamp) as trip_start_datetime,
	datetime(trip_end_timestamp) as trip_end_datetime,
	trip_seconds,
	round(trip_seconds / 60,2) as trip_minutes,
	trip_miles,
	fare,
	tips,
	tolls,
	extras,
	trip_total,
	trip_total_amount,
	payment_type,
	company,
	pickup_latitude,
	pickup_longitude,
	pickup_location,
	dropoff_latitude,
	dropoff_longitude,
	dropoff_location
from {{ ref('stg_timedotcom__taxi_trips') }}
)

, holiday as (
	select * from {{ ref('us_holiday') }}
)

select distinct tr.*, hol.holiday_name, case when hol.is_holiday is not null then 1 else 0 end as is_holiday,
case when trip_seconds > 0 and (pickup_location = dropoff_location or trip_miles = 0) then 1 else 0 end as trip_idle --since location can be null
from trips tr
left join holiday hol
on tr.trip_date = hol.holiday_date
where not (trip_start_datetime = trip_end_datetime and trip_seconds is null and trip_seconds = 0 and trip_miles = 0 and trip_miles is null) --no actual trips
and trip_end_datetime > trip_start_datetime --end time must be after start
and datetime_diff(trip_end_datetime,trip_start_datetime,hour) <= 2 --city trip maximum will take 2 hours
and fare+tips+tolls+extras > 0 and trip_total > 0 --all trip must have a cost
and trip_miles <= 40 --city trips less than 40 miles

select
	trip_date,
	extract(year from trip_date) as year,
	extract(hour from trip_start_datetime) as hour_trip,
	payment_type,
	is_holiday,
	count(distinct unique_key) as trip_freq,
	sum(trip_total_amount) as trip_total_amount,
	sum(fare) as fare,
	sum(tips) as tips,
	sum(tolls) as tolls,
	sum(extras) as extras
from {{ ref('int_timedotcom__taxi_trips') }}
group by 1,2,3,4,5
-- drivers performances in the last 3 months
with main as (
select distinct
	unique_key,
	taxi_id,
	trip_start_datetime,
	trip_end_datetime,
	trip_seconds,
	case when datetime_diff(trip_start_datetime, lag(trip_end_datetime) over (partition by taxi_id, company order by trip_start_datetime), hour) >= 8 or
	lag(trip_end_datetime) over (partition by taxi_id, company order by trip_start_datetime) is null then 1 else 0 end as is_new_shift,
	trip_total_amount,
	fare,
	tips,
	tolls,
	extras,
	company
from {{ ref('int_timedotcom__taxi_trips') }}
where trip_date >= '2023-10-10'
)

, shifts_num as (
select distinct
	*,
	sum(is_new_shift) over (partition by taxi_id, company order by trip_start_datetime rows between unbounded preceding and current row) as shift_num
from main
)

, shifts as (
select distinct
	taxi_id,
	company,
	shift_num,
	min(trip_start_datetime) as start_shift,
	max(trip_end_datetime) as end_shift,
	datetime_diff(max(trip_end_datetime),
	min(trip_start_datetime), minute) as shift_duration_mins,
	count(*) as num_of_trip,
	sum(trip_total_amount) as trip_total_amount,
	sum(fare) as fare,
	sum(tips) as tip,
	sum(tolls) as tolls,
	sum(extras) as extras
from shifts_num group by 1,2,3
)

select distinct *, case when shifts.shift_duration_mins >= 480 then 1 else 0 end as long_shifts from shifts


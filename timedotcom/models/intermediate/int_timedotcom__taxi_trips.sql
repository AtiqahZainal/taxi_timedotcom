WITH main as (
	SELECT *
FROM {{ ref('stg_timedotcom__taxi_trips') }}
)

SELECT * FROM main
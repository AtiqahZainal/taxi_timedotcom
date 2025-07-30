This is an assignment for TimeDotCom Analytics Engineer role based on the data from Chicago Taxi Trips which consist of data up to 2023.

The tools used for this assignment:
1) Data Warehouse : GCP
2) Data Model : DBT
3) Data Visualization : Looker Studio

Important links:
Repo https://github.com/AtiqahZainal/taxi_timedotcom
GCP https://console.cloud.google.com/bigquery?authuser=1&inv=1&invt=Ab4Khg&project=location-1571108398066&ws=!1m4!1m3!3m2!1slocation-1571108398066!2sdbt_taxi_chicago
Looker Studio https://lookerstudio.google.com/u/1/reporting/d5944765-18c4-4abe-a74e-75b2cae30dfa/page/p_f6kjhtkuud

The raw data are split into 3 types using dbt :
**1) Staging Data**
   - The data is partitioned based on the start trip date
   - A new column called trip_total_amount is being created because the trip_total may not be equal with the sum of the fare, tips, tolls and extras. Hence we'll        be using this column for the correct amount
   - The data used for this table is from the year of 2020
   - There are tests associated with this table such as not null, unique and accepted values. Additionally, these are the custom tests we find it important to           understand any data / system issues
     i) trip_end_timestamp > trip_start_timestamp
     ii) maximum city trips in Chicago should only take up to 2 hours
     iii) maximum city trips in Chicago should only go up to 40 miles
     iv) only consider those with more than 0 trip total
**2) Intermediate Data**
   - For the purpose of understanding the impact of public holiday, a seed table for US Holiday is created (assuming all public holidays are the same for each city)
   - The table from (1) will be joining with US Holiday table
   - Timestamp column is converted into datetime, nonetheless no changes to the timezone as it is stated the timestamp for this data is captured in local time
   - Most of the tests mentioned in (1) is filtered here with additional rule :
     not (trip_start_datetime = trip_end_datetime and trip_seconds is null and trip_seconds = 0 and trip_miles = 0 and trip_miles is null) to remove invalid trips
**3) Marts**
     There are 2 marts created from the reusable data in (2)
     i) Drivers - this data is mainly an aggregation of trips and amount at driver level (or taxi id). The use cases for this include top earners, most
        hardworking, top companies, total trips, total amount etc.
     ii) Trips - this data is mainly an aggregation of trips and amount at daily level (or date). The use cases for this include, the tipping behaviour, effect of           public holiday, weekend vs weekdays etc.

There are 3 questions to this assignments:
1) Who are the top 100 “tip earners”, the taxi IDs that earn more money than the others for the last 3 months.
   - Tip earners is based on the tips column
   - Since the data is only up to 2023, the last 3 months data are Oct - Dec 2023
   - Taxi IDs are representing the drivers
   - There are instances when 1 Taxi IDs has multiple company, hence we'll treat them as different unique ID
   - For answer may refer to table "Top 100 Tip Earners" from https://lookerstudio.google.com/u/1/reporting/d5944765-18c4-4abe-a74e-75b2cae30dfa/page/p_f6kjhtkuud
     
2) Who are the top 100 “overworkers”, taxi IDs that work more hours than others without taking at least 8 hours break and regularly have a long shift.
   - A new shifts meaning it starts if there is a gap of more than 8 hours from previous trips
   - Long hours is considered when the total duration for each shifts is more than 480 minutes
   - There are instances when 1 Taxi IDs has multiple company, hence we'll treat them as different unique ID
   - Top 100 is based on the number of trips made for the last 3 months
   - For answer may refer to table Top 100 Overworked Drivers https://lookerstudio.google.com/u/1/reporting/d5944765-18c4-4abe-a74e-75b2cae30dfa/page/p_f6kjhtkuud
   
3) Do you think the public holidays in US had an impact on the increase/decrease the trips.
   The query:
   select extract(year from trip_date) as year, is_holiday, count(distinct unique_key) as freq,
   count(distinct trip_date) as num_day, round(count(distinct unique_key) / count(distinct trip_date),0) as avg_trip_per_day,
   round(sum(trip_total_amount) / count(distinct unique_key),2) as total_amount
   from `location-1571108398066.dbt_taxi_chicago.int_timedotcom__taxi_trips` 
   group by 1,2
   order by year, is_holiday

   The result:
   <img width="998" height="403" alt="image" src="https://github.com/user-attachments/assets/8d911adc-30cd-4909-a71c-162b633a98e2" />
   Based on the result, there are no significant impact from public holiday to the increase/decrease of trips. However, impact is more apparent coming from the total amount for the trips ($) based on the average
   values. This could mainly contributed to the additional charges from airport as people are heading for holidays. Also, it could be some other charges applicable during public holiday.
   
As for visualization, we use the two datamarts to create reports. However, most of the created visualisation in the report is meant to be for answering the questions given.

Future enhancements include:
- Create more tests especially the datamarts
- Deep dive into invalid data as such do we need to add more filter to exclude more invalid data
- Create more marts if required by others
- Improve the visualization with more insights
- Highlight the invalid data from tests to futher improve the system
- To also validate the data from the dashboard especially on the overworked drivers

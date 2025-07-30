This is an assignment for TimeDotCom Analytics Engineer role based on the data from Chicago Taxi Trips which consist of data up to 2023.

The tools used for this assignment:
1) Data Warehouse : GCP
2) Data Model : DBT
3) Data Visualization : Looker Studio

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
1) Who are the top 100 “tip earners”, the taxi IDs that earn more money than the
others for the last 3 months.
2) Who are the top 100 “overworkers”, taxi IDs that work more hours than others
without taking at least 8 hours break and regularly have a long shift.
3) Do you think the public holidays in US had an impact on the increase/decrease the
trips

As for visualization, we use the two datamarts to create reports. However, most of the created visualisation in the report is meant to be for answering the questions given.

In the future, we should add more tests especially for datamarts. Additionally, to check on the result

-- Creating external table referring to gcs path


CREATE OR REPLACE EXTERNAL TABLE `stellar-cipher-412606.nyc_taxi.green_taxi_2022`
(
  VendorID	 	INTEGER,	
lpep_pickup_datetime	 	INTEGER,	
lpep_dropoff_datetime	 	INTEGER,	
store_and_fwd_flag	 	STRING,
RatecodeID	 	FLOAT64,	
PULocationID	 	INT64,
DOLocationID	 	INT64	,
passenger_count	 	FLOAT64	,
trip_distance	 	FLOAT64	,
fare_amount	 	FLOAT64	,
extra	 	FLOAT64	,
mta_tax	 	FLOAT64	,
tip_amount	 	FLOAT64	,
tolls_amount	 	FLOAT64	,
ehail_fee	 	FLOAT64	,
improvement_surcharge	 	FLOAT64	,
total_amount	 	FLOAT64	,
payment_type	 	FLOAT64	,
trip_type	 	FLOAT64	,
congestion_surcharge	 	FLOAT64	
)
OPTIONS (
  format = 'parquet',
  uris = ['gs://mage-atif-zoomcamp/green/green_tripdata_2022-*.parquet']
);

select * from stellar-cipher-412606.nyc_taxi.green_taxi_2022 limit 10;

-- Q1 What is count of records for the 2022 Green Taxi Data?
select count(1) from stellar-cipher-412606.nyc_taxi.green_taxi_2022;
-- 840402

-- Create a non partitioned table from external table
CREATE OR REPLACE TABLE stellar-cipher-412606.nyc_taxi.green_taxi_2022_nonpartitioned AS
SELECT VendorID, TIMESTAMP_MICROS(CAST(lpep_pickup_datetime/1000 AS INT64)) AS lpep_pickup_datetime, 
TIMESTAMP_MICROS(CAST(lpep_dropoff_datetime/1000 AS INT64)) AS lpep_dropoff_datetime
	,store_and_fwd_flag	,RatecodeID	,PULocationID	,DOLocationID	,passenger_count	,trip_distance	,fare_amount
  ,	extra,	mta_tax	,tip_amount	,tolls_amount,	ehail_fee	,improvement_surcharge,	total_amount
  ,	payment_type	,trip_type	,congestion_surcharge FROM stellar-cipher-412606.nyc_taxi.green_taxi_2022 A;

select count(1) from stellar-cipher-412606.nyc_taxi.green_taxi_2022_nonpartitioned;
-- 840402

select * from stellar-cipher-412606.nyc_taxi.green_taxi_2022_nonpartitioned limit 10;
---------------------------------------------------------------------------------------

--Q2 What is the estimated amount of data in the tables ?
select count(distinct PULocationID) from stellar-cipher-412606.nyc_taxi.green_taxi_2022; 
-- estimated bytes processed by external table will be 0
select count(distinct PULocationID) from stellar-cipher-412606.nyc_taxi.green_taxi_2022_nonpartitioned;
-- estimated bytes processed by materialized table is 6.41 MB

--------------------------------------------------------------------------------------

--Q3 How many records have a fare_amount of 0?

select count(1) from stellar-cipher-412606.nyc_taxi.green_taxi_2022_nonpartitioned 
where fare_amount = 0;
-- 1622

--------------------------------------------------------------------------------------
-- Q4 What is the best strategy to make an optimized table in Big Query if your query 
-- will always order the results by PUlocationID and filter based 
-- on lpep_pickup_datetime? (Create a new table with this strategy)

-- Creating a partition and cluster table
CREATE OR REPLACE TABLE stellar-cipher-412606.nyc_taxi.green_taxi_2022_partitioned_clsutered
PARTITION BY DATE(lpep_pickup_datetime)
CLUSTER BY PUlocationID AS
SELECT * FROM stellar-cipher-412606.nyc_taxi.green_taxi_2022_nonpartitioned;

----------------------------------------------------------------------------------------
--Q5 Write a query to retrieve the distinct PULocationID between 
-- lpep_pickup_datetime 06/01/2022 and 06/30/2022 (inclusive)

SELECT count(distinct PULocationID) from stellar-cipher-412606.nyc_taxi.green_taxi_2022_partitioned_clsutered
where date(lpep_pickup_datetime) between '2022-06-01' and '2022-06-30';

SELECT count(distinct PULocationID) from stellar-cipher-412606.nyc_taxi.green_taxi_2022_nonpartitioned
where date(lpep_pickup_datetime) between '2022-06-01' and '2022-06-30';
-- 12.82 MB for non-partitioned table and 1.12 MB for the partitioned table

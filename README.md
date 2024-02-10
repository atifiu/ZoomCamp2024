# ZoomCamp2024
ZoomCamp 2024 Training

Module 2 Homework answer

Q1. Once the dataset is loaded, what's the shape of the data?

266,855 rows x 20 columns

Q2. Upon filtering the dataset where the passenger count is greater than 0 and the trip distance is greater than zero, how many rows are left?

139,370 rows

Q3. Which of the following creates a new column lpep_pickup_date by converting lpep_pickup_datetime to a date?

data['lpep_pickup_date'] = data['lpep_pickup_datetime'].dt.date

Q4. What are the existing values of VendorID in the dataset?

1 or 2
select distinct vendor_id from magic.green_taxi;

Q5. How many columns need to be renamed to snake case?

4

<p align="center">
  <a href="" rel="noopener">
 <img width=400px height=200px src="./zoomcamp_2024.png" alt="Project logo"></a>
</p>


<h3 align="center">Data Engineering Zoomcamp 2024</h3>

<div align="center">



</div>

---

<p align="center"> End to End Data Engineering course having various modules/topics/workshops and final project </p>
<br> 

### Modules
- [x] Module 1: Containerization and Infrastructure as Code <br>
- [x] Module 2: Workflow Orchestration <br>
- [ ] Workshop 1: Data Ingestion <br>
- [x] Module 3: Data Warehouse <br>
- [ ] Module 4: Analytics Engineering <br>
- [ ] Module 5: Batch processing <br>
- [ ] Module 6: Streaming <br>
- [ ] Workshop 2: Stream Processing with SQL <br>



## 📝 Table of Contents

- [Module 1: Containerization and Infrastructure as Code](#module1)



##  Module 1: Containerization and Infrastructure as Code  <a name = "module1"></a>

### Introduction

In this module we will make use of docker to create a simple data pipeline using PostgreSQL DB.
 Following tools/concepts will be introduced as part of this module:
 - Docker
 - Docker Compose
 - Postgres
 - PGAdmin
 - Terraform
 - SQL
 - GCP

 > Note: Throughtout this course I will be using GitHub CodeSpaces which is a development environment hosted in cloud provided by GitHub and can be integrated with various IDEs(I am using VSCode). To setup GitHub CodeSpaces please refer to this [Video](https://www.youtube.com/watch?v=XOSUt8Ih3zA&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=16)

### Docker
Docker provides a container like platform where you can put all your code, libraries and related dependencies which can be imported to any environment and not depended on OS.

#### Docker Commands
- **docker run**: It will run the command in new container and if the image is not present it will pull the image.It also have various parameters such as `it` which provides iteractive terminal to execute the code in docker. [Details here](https://docs.docker.com/engine/reference/commandline/container_run/)


- **docker ps**: It show currently running containers while -a option also shows both running as well as stopped containers. [Details here](https://docs.docker.com/engine/reference/commandline/container_ls/)

### Steps to Setup Docker container for running Data Pipeline

1. Define a `Dockerfile` with all the required dependencies install inside it. Import required Image with the tag. [Dockerfile](./Dockerfile)

2. Build a docker image using  below line of code<br>
``` docker build -t taxi_ingest:v001 .```

3. We will define our simple data pipeline know as `ingest_data.py`. This will be executed inside the docker and is already used in our `Dockerfile`.

4. Create a docker network `pg-network` so that Postgres and PGAdmin can interact.<br>
``` docker network create pg-network ```

5. Create docker volume for Postgres and PGAdmin so that data can be preserved on local disk otherwise once the docker container is down all data will be lost.<br>
```
docker volume create  --name ny_taxi_postgres_data -d local
docker volume create  --name data_pgadmin -d local
``` 

### 🏁 Docker, Terraform and  SQL 

In this homework we'll prepare the environment and practice with Docker and SQL

#### Question 1. Knowing docker tags
Run the command to get information on Docker

```docker --help```

Now run the command to get help on the "docker build" command:

```docker build --help```

Do the same for "docker run".

Which tag has the following text? - Automatically remove the container when it exits
<p>
--delete<br>
--rc<br>
--rmc<br>
:white_check_mark: --rm<br>
</p>

---

#### Question 2. Understanding docker first run
Run docker with the python:3.9 image in an interactive mode and the entrypoint of bash. Now check the python modules that are installed ( use pip list ).

What is version of the package wheel ?

:white_check_mark: 0.42.0 <br>
1.0.0 <br>
23.0.1 <br>
58.1.0 <br>

---
#### Question 3. Count records
How many taxi trips were totally made on September 18th 2019?

Tip: started and finished on 2019-09-18.

Remember that lpep_pickup_datetime and lpep_dropoff_datetime columns are in the format timestamp (date and hour+min+sec) and not in date.

15767<br>
:white_check_mark: 15612<br>
15859<br>
89009<br>

```
SELECT Count(1)
FROM   green_taxi_data_2019
WHERE  lpep_pickup_datetime BETWEEN
       '2019-09-18 00:00:00' AND '2019-09-18 23:59:59'
       AND lpep_dropoff_datetime BETWEEN
           '2019-09-18 00:00:00' AND '2019-09-18 23:59:59'; 
```

---

#### Question 4. Longest trip for each day
Which was the pick up day with the longest trip distance? Use the pick up time for your calculations.

Tip: For every trip on a single day, we only care about the trip with the longest distance.

2019-09-18
2019-09-16
:white_check_mark: 2019-09-26
2019-09-21

```WITH largest_trip
     AS (SELECT a.lpep_pickup_datetime,
                trip_distance,
                Dense_rank()
                  OVER(
                    ORDER BY trip_distance DESC) ranking
         FROM   green_taxi_data_2019 a)
SELECT *
FROM   largest_trip
WHERE  ranking = 1; 
```

---

#### Question 5. Three biggest pick up Boroughs
Consider lpep_pickup_datetime in '2019-09-18' and ignoring Borough has Unknown

Which were the 3 pick up Boroughs that had a sum of total_amount superior to 50000?

:white_check_mark: "Brooklyn" "Manhattan" "Queens"<br>
"Bronx" "Brooklyn" "Manhattan"<br>
"Bronx" "Manhattan" "Queens"<br>
"Brooklyn" "Queens" "Staten Island"<br>

```
SELECT     Sum(total_amount),
           b."Borough"
FROM       green_taxi_data_2019 a
INNER JOIN zones b
ON         a."PULocationID" = b."Location ID"
AND        b."Borough" <> 'Unknown'
AND        a.lpep_pickup_datetime BETWEEN '2019-09-18 00:00:00' AND        '2019-09-18 23:59:59'
GROUP BY   b."Borough" havi ng sum(a.total_amount) > 50000;
```
---

#### Question 6. Largest tip
For the passengers picked up in September 2019 in the zone name Astoria which was the drop off zone that had the largest tip? We want the name of the zone, not the id.

Note: it's not a typo, it's tip , not trip

Central Park<br>
Jamaica<br>
:white_check_mark: JFK Airport<br>
Long Island City/Queens Plaza<br>

```
SELECT *
FROM   (
                  SELECT     a.tip_amount,
                             (
                                    SELECT c."Zone"
                                    FROM   zones c
                                    WHERE  c."LocationID" = a."DOLocationID") AS zone,
                             de nse_rank() OVER(ORDER BY a.tip_amount DESC)      ranking
                  FROM       green_taxi_data_2019 a
                  INNER JOIN zones b
                  ON         a."PULocationID" = b."LocationID"
                  AND        b ."Zone" = 'Astoria'
                  AND        a.lpep_pickup_datetime BETWEEN '2019-09-01 00:00:00' AND        '2019-09-30 23:59:59') max_tip
WHERE  ranking = 1;
```

---

#### Question 7. Creating Resources
After updating the main.tf and variable.tf files run:

```terraform apply```


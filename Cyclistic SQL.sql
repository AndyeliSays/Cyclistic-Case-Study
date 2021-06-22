/* PREPARATION */

-- Use sp_help (ALT + F1) to get an idea of monthly datasets April 2020 to March 2021 
-- sp_help April_2020, March_2020... 

-- Goal: New table of combined datasets April 2020 to March 2021: March20_April21

SELECT * INTO April_to_November
FROM April_2020
UNION ALL 
SELECT * FROM May_2020
UNION ALL 
SELECT * FROM June_2020
UNION ALL 
SELECT * FROM July_2020
UNION ALL 
SELECT * FROM August_2020
UNION ALL 
SELECT * FROM September_2020
UNION ALL 
SELECT * FROM October_2020
UNION ALL 
SELECT * FROM November_2020

-- December, 2020 to March 2021 have NVARCHAR for [start_station_id] and [end_station_id] instead of FLOAT like other months.
--These two columns are not relevant to task. 

SELECT * INTO December_to_March
FROM December_2020
UNION ALL 
SELECT * FROM January_2021
UNION ALL 
SELECT * FROM February_2021
UNION ALL 
SELECT * FROM March_2021

-- New tables without [start_station_id] and [end_station_id] 

SELECT ride_id,
rideable_type,
started_at,
ended_at,
start_station_name,
end_station_name,
member_casual
INTO April_to_November_v2 
FROM April_to_November

SELECT ride_id,
rideable_type,
started_at,
ended_at,
start_station_name,
end_station_name,
member_casual
INTO December_to_March_v2 
FROM December_to_March

-- Merge to create aggregated table April 2020 to March 2021: March20_April21 

SELECT * INTO March20_April21 
FROM April_to_November_v2
UNION ALL 
SELECT * FROM December_to_March_v2

-- Creating New columns [ride_length_mins] & [day_of_week] and updated aggregated table: March20_April21_v2

SELECT ride_id,
rideable_type,
started_at,
ended_at,
start_station_name,
end_station_name,
member_casual,
DATEDIFF(MINUTE, started_at, ended_at) AS ride_length_mins,
DATENAME(WEEKDAY, started_at) AS day_of_week
INTO March20_April21_v2
FROM March20_April21

---------------------------------------------------------------------------
/* CLEANING */

-- Checking for extra spaces front and back of strings

SELECT rideable_type,
start_station_name,
end_station_name,
member_casual
FROM March20_April21_v2
WHERE rideable_type LIKE ' %' OR rideable_type LIKE '% '
OR start_station_name LIKE ' %' OR rideable_type LIKE '% '
OR end_station_name LIKE ' %' OR rideable_type LIKE '% ';

-- Checking for Mispellings in [rideable_type] & [member_casual]

SELECT rideable_type, member_casual
FROM March20_April21_v2
GROUP BY rideable_type, member_casual;

-- Count of Records & Checking for Duplicates

SELECT COUNT(*)
FROM March20_April21_v2
-- 3,489,748 rows

SELECT COUNT(DISTINCT ride_id)
FROM March20_April21_v2
-- 3,489,537 rows

SELECT COUNT(ride_id)
FROM March20_April21_v2
GROUP BY ride_id HAVING COUNT(ride_id) > 1;
-- 211 records

-- Removing Records with duplicate ride_id

DELETE FROM March20_April21_v2
WHERE ride_id IN (SELECT ride_id
FROM March20_April21_v2
GROUP BY ride_id HAVING COUNT(ride_id) > 1);

-- Count of NULLS

SELECT COUNT(*) AS records_count
FROM March20_April21_v2
WHERE start_station_name IS NULL OR end_station_name IS NULL;

-- Removing NULLs

DELETE FROM March20_April21_v2
WHERE start_station_name IS NULL OR end_station_name IS NULL;

-- Count of records where ended_at is earlier than started_at

SELECT COUNT(ride_length_mins)
FROM March20_April21_v2
WHERE ended_at < started_at;

-- Removing Records where [ended_at] before [started_at]

DELETE FROM March20_April21_v2
WHERE ended_at < started_at;

-- Count of records with "test" in [start_station_name] & [end_station_name]

SELECT COUNT(*) AS records_count
FROM March20_April21_v2
WHERE start_station_name LIKE ('%test%') OR end_station_name LIKE ('%test%')
OR start_station_name LIKE ('%TEST%') OR end_station_name LIKE ('%TEST%');

-- Removing values with TEST or test in them

DELETE FROM March20_April21_v2
WHERE start_station_name LIKE ('%test%') OR end_station_name LIKE ('%test%')
OR start_station_name LIKE ('%TEST%') OR end_station_name LIKE ('%TEST%');

-- Count of Negative Values for [ride_length_mins]

SELECT COUNT(*) AS ride_length_mins_negative
FROM March20_April21_v2
WHERE ride_length_mins < 0

-- Cleaned, aggregated dataset: March20_April21_v2

SELECT *
FROM March20_April21_v2

---------------------------------------------------------------------------

/* ANALYZE */

-- Getting Count of rides for different types of members

SELECT member_casual,
COUNT(member_casual) AS member_casual_count
FROM March20_April21_v2
GROUP BY member_casual;

SELECT 
COUNT(member_casual) as num_casual
FROM March20_April21_v2
WHERE member_casual = 'casual'

SELECT 
COUNT(member_casual) as num_member
FROM March20_April21_v2
WHERE member_casual = 'member'

 -- Preferred bike by Member Type

SELECT member_casual, rideable_type,
COUNT(rideable_type) AS rideable_type_count
FROM March20_April21_v2
GROUP BY member_casual, rideable_type;
 
-- Number of rides by day of the week per member type

SELECT member_casual, day_of_week,
COUNT(ride_id) AS rides_count
FROM March20_April21_v2
GROUP BY member_casual, day_of_week
ORDER BY member_casual;
 
-- Ride duration by day of the week per member type

SELECT member_casual,
day_of_week,
ROUND(AVG(DATEDIFF(MINUTE, started_at, ended_at)),0) AS avg_ride_duration
FROM March20_April21_v2
GROUP BY member_casual, day_of_week
ORDER BY member_casual;
 
 -- Average Ride Length Overall and by Member

SELECT ROUND(AVG(DATEDIFF(MINUTE, Started_at, ended_at)),0) AS avg_ride_length_mins_all
FROM March20_April21_v2

SELECT ROUND(AVG(DATEDIFF(MINUTE, Started_at, ended_at)),0) AS avg_ride_length_mins_member
FROM March20_April21_v2
WHERE member_casual = 'member'

SELECT ROUND(AVG(DATEDIFF(MINUTE, Started_at, ended_at)),0) AS avg_ride_length_mins_casual
FROM March20_April21_v2
WHERE member_casual = 'casual'

SELECT member_casual,
ROUND(AVG(DATEDIFF(MINUTE, started_at, ended_at)),0) AS avg_ride_duration
FROM March20_April21_v2
GROUP BY member_casual;

-- Total Ride Length in Mins by Customer Type in a Year

SELECT member_casual, 
SUM(ride_length_mins) AS Yearly_Duration
FROM March20_April21_v2
WHERE ride_length_mins > 0 
GROUP BY member_casual

  -- Count of over rides over 1000 by station 

SELECT start_station_name,
COUNT(start_station_name) AS num_at_start_station
FROM March20_April21_v2
GROUP BY start_station_name
HAVING COUNT(start_station_name) > 1000
ORDER BY COUNT(start_station_name) DESC ;



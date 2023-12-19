-- Author: Douye Victor O.
-- Dataset Source: Task attachment from Dignity
-- Import Procedure
-- Open SSMS
-- Connect SQL Server
-- Create Database (Dignity)
-- Go to Database (Dignity)
-- Go to Tasks
-- Go to Import Data
-- Go to Data Source (Microsoft Excel)
-- Select file path (C:\Users\douye\Desktop\dignity\excel file)
-- Choose Destination (Microsoft OLE DB Provider for SQL Server)
-- Select Default Server name (VICTOR\SQLEXPRESS)
-- Select Authentification (Windows Authentification) 

-- Initial Data Cleaning
--Overviewing booking data
SELECT *
FROM dignity_booking$
--Checking for missing values in booking table
SELECT *
FROM dignity_booking$
WHERE Revenue is null or ID is null or Volume is null 
--An empty table clarifies that no null values exists for booking data
-- Identify duplicates in the 'ID' column
SELECT ID, COUNT(*)
FROM dignity_booking$
GROUP BY ID
HAVING COUNT(*) > 1;
--An empty result clarifies that there are no repeating IDs in the data, thus all are unique 

--Assumption: Above attempts at cleaning data suggests that the data has been pre-cleaned 
--and is thus save to jump into actual tasks. Cleaning will also be skipped 
--for the remaining two data sets. More detailed cleaning if more time was available.

--Objective 1: Count the number of bookings in a specific date range and the revenue generated.
--This requires inner joining the booking data table with the Day_dwh table on the date code columns
--present in both tables
SELECT
    COUNT(Date_code_booking) AS TotalBookings,
    SUM(Revenue) AS TotalRevenue
FROM dignity_booking$ b
JOIN DAY_DWH$ d ON b.Date_code_attend = d.DAY_DWH_ID
WHERE d.DAY_Date BETWEEN '2000-01-01' AND '2005-06-23';
--Total bookings count is 5142 and Total Revenue is 2794677


--Objective 2: Show the average number of bookings by week in a specific period of time of your choice.
SELECT
    DATEPART(WEEK, d.DAY_Date) AS WeekNumber,
	COUNT(b.Volume) AS AverageVolume
FROM dignity_booking$ b
JOIN DAY_DWH$ d ON b.Date_code_attend = d.DAY_DWH_ID
WHERE d.DAY_Date BETWEEN '2000-01-01' AND '2005-06-23'
GROUP BY DATEPART(WEEK, d.DAY_Date)
ORDER BY WeekNumber;

-- Objective 3: Extract the monthly volume, revenue, and average revenue generated by each region.
SELECT
    o.ORG_Region_Name AS Region,
    DATEPART(MONTH, d.DAY_Date) AS Month,
    COUNT(b.Volume) AS MonthlyVolume,
    SUM(b.Revenue) AS MonthlyRevenue,
    AVG(b.Revenue) AS AvgMonthlyRevenue
FROM dignity_booking$ b
JOIN DAY_DWH$ d ON b.Date_code_attend = d.DAY_DWH_ID
JOIN ORG_DWH$ o ON b.ORG_DWH_ID = o.ORG_DWH_ID
WHERE d.DAY_Date BETWEEN '2000-01-01' AND '2005-06-23'
GROUP BY o.ORG_Region_Name, DATEPART(MONTH, d.DAY_Date)
ORDER BY Region, Month;

--Objective 4a:
--Aggregating Volume and Revenue for each unique booking code
SELECT
    Date_code_booking,
    SUM(Volume) AS TotalVolume,
    SUM(Revenue) AS TotalRevenue
FROM dignity_booking$
WHERE Date_code_booking > 0
GROUP BY Date_code_booking
ORDER BY TotalRevenue DESC;

--Objective 4b:
--Aggregating Volume and Revenue for each unique attended code
SELECT
    Date_code_attend,
    SUM(Volume) AS TotalVolume,
    SUM(Revenue) AS TotalRevenue
FROM dignity_booking$
WHERE Date_code_attend > 0
GROUP BY Date_code_attend
ORDER BY TotalRevenue DESC;

--Objective 4c:
--Average Revenue by week
SELECT
DATEPART(WEEK, d.DAY_Date) AS WeekNumber,
    AVG(b.Revenue) AS AverageRevenue
FROM dignity_booking$ b
JOIN DAY_DWH$ d ON b.Date_code_attend = d.DAY_DWH_ID
WHERE d.DAY_Date BETWEEN '2000-01-01' AND '2005-06-23'
GROUP BY DATEPART(WEEK, d.DAY_Date)
ORDER BY WeekNumber;

--Aggregate by year
 SELECT
    o.ORG_Region_Name AS Region,
    DATEPART(Year, d.DAY_Date) AS Year,
    COUNT(b.Volume) AS YearlyVolume,
    SUM(b.Revenue) AS YearlyRevenue
FROM dignity_booking$ b
JOIN DAY_DWH$ d ON b.Date_code_attend = d.DAY_DWH_ID
JOIN ORG_DWH$ o ON b.ORG_DWH_ID = o.ORG_DWH_ID
WHERE d.DAY_Date BETWEEN '2000-01-01' AND '2005-06-23'
GROUP BY o.ORG_Region_Name, DATEPART(Year, d.DAY_Date)
ORDER BY Region, Year;
-- 1. Upload the CSV data via CLI into the DATABASE
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/UC3.csv'
INTO TABLE device_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 2. Find all the duplicate time entries for respective devices.
SELECT DEVICE, TIME_STAMP, COUNT(TIME_STAMP)
FROM Device_Info
GROUP BY TIME_STAMP, DEVICE
HAVING COUNT(TIME_STAMP) > 1;

-- 3. Find all the missing timestamps for respective devices.
SELECT D1.DEVICE, T.TIME_STAMP
FROM (SELECT DISTINCT DEVICE FROM Device_Info) D1
CROSS JOIN (SELECT DISTINCT TIME_STAMP FROM Device_Info) T
LEFT JOIN Device_Info D2 ON D1.DEVICE = D2.DEVICE AND T.TIME_STAMP = D2.TIME_STAMP
WHERE D2.DEVICE IS NULL
ORDER BY D1.DEVICE, T.TIME_STAMP;

-- 4. Find the hour-wise cumulative consumption of each device.
SELECT HOUR(TIME_STAMP) AS 'DURATION', DEVICE, MAX(Consumption) AS 'PEAK'   -- AVG(Consumption)
FROM Device_Info
GROUP BY DEVICE, DURATION;

-- 5. Find the peak consumption reached in a given time range for all the devices.
SELECT DEVICE, MAX(Consumption) AS 'PEAK'
FROM Device_Info
WHERE HOUR(TIME_STAMP) BETWEEN 1 AND 10 GROUP BY DEVICE;



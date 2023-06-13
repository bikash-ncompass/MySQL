create DATABASE College;
USE College;

CREATE TABLE STUDENT(
  ID CHAR(5) NOT NULL,
  NAME VARCHAR(50) NOT NULL,
  DEPARTMENT CHAR(10), 
  CGPA DECIMAL(4,2),
  PRIMARY KEY (ID));

CREATE TABLE COMPANY(
  ID CHAR(5) NOT NULL,
  NAME VARCHAR(20) NOT NULL,
  LOCATION VARCHAR(30) NOT NULL,
  INTERVIEW_DATE DATE,
  PRIMARY KEY (ID));

CREATE TABLE PLACEMENTS(
  S_ID CHAR(5) NOT NULL,
  C_ID CHAR(5) NOT NULL,
  PACKAGE BIGINT NOT NULL DEFAULT 0,
FOREIGN KEY (S_ID) REFERENCES STUDENT (ID),
FOREIGN KEY (C_ID) REFERENCES COMPANY (ID));

INSERT INTO STUDENT VALUES
  ('S001', 'ARUN', 'CS',  8),
  ('S002', 'GITA', 'CS',  7.5),
  ('S003', 'KUMAR', 'IT',  6),
  ('S004', 'ROHIT', 'IT',  8.5),
  ('S005', 'YAMUNA','ECE', 9),
  ('S006', 'YOGESH','ECE', 9);

INSERT INTO COMPANY VALUES
  ('C001', 'MICROSOFT','BANGALORE','2020-08-01'),
  ('C002', 'AMAZON',  'CHENNAI', '2020-09-10'),
  ('C003', 'FLIPKART', 'BANGALORE','2020-09-15'),
  ('C004', 'HONEYWELL','HYDERABAD','2020-10-30'),
  ('C005', 'ACCENTURE','CHENNAI', '2020-11-30'),
  ('C006', 'WIPRO','NOIDA','2020-12-31');

INSERT INTO PLACEMENTS VALUES
  ('S001', 'C001', 2000000),
  ('S002', 'C001', 2000000),
  ('S003', 'C002', 1200000),
  ('S004', 'C004', 700000),
  ('S004', 'C006', 400000),
  ('S006', 'C004', 700000);

-- 1.Write a SQL query to find student who go placed with highest package, along with the name of the company.
SELECT S.NAME AS 'STUDENT', C.NAME AS 'COMPANY', P.PACKAGE AS 'PACKAGE'
  FROM STUDENT S
  JOIN PLACEMENTS P ON S.ID = P.S_ID
  JOIN COMPANY C ON C.ID = P.C_ID
  WHERE P.PACKAGE = (
  SELECT MAX(PACKAGE) FROM PLACEMENTS
);

-- 2.HOD of ECE department wants to know placement details of all his department students, Write a SQL query for this scenario
SELECT S.NAME AS 'STUDENT',
  S.DEPARTMENT AS 'DEPARTMENT',
CASE
  WHEN P.PACKAGE IS NULL THEN 'NO'
  ELSE 'YES'
END AS PLACED,
  COALESCE(C.NAME, '-') AS COMPANY,
  COALESCE(P.PACKAGE, '-')
FROM STUDENT S
  LEFT JOIN PLACEMENTS P ON S.ID = P.S_ID
  LEFT JOIN COMPANY C ON C.ID = P.C_ID;

-- 3.Write a SQL query to display total number of students each company has hired.
SELECT C.NAME AS 'COMPANY', COUNT(P.S_ID) AS 'NO OF STUDENTS'
FROM COMPANY C
LEFT JOIN PLACEMENTS P ON C.ID = P.C_ID
GROUP BY C.NAME;

-- 4.Write a SQL query which displays list of companies conducted interview in month of september.
SELECT
  DATE_FORMAT(COMPANY.INTERVIEW_DATE, "%M") AS 'INTERVIEW DATE', -- MONTHNAME(INTERVIEW_DATE) AS 'INTERVIEW DATE'
  COMPANY.NAME AS 'COMPANY'
FROM COMPANY
WHERE MONTH(INTERVIEW_DATE) = 9;


-- 5.Write a SQL query which displays list of companies which conducted interview till date.
SELECT COMPANY.NAME AS 'COMPANY', COMPANY.INTERVIEW_DATE AS 'DATE'
FROM COMPANY WHERE COMPANY.INTERVIEW_DATE <= CURDATE();

-- 6.Dean would like to know the students who got more than one placement offer, write a SQL query for this scenario.
SELECT S.NAME, C.NAME AS COMPANY
FROM  STUDENT S
  JOIN PLACEMENTS P ON S.ID = P.S_ID
  JOIN COMPANY C ON C.ID = P.C_ID
WHERE S.ID IN (
SELECT P.S_ID FROM PLACEMENTS P
GROUP BY P.S_ID HAVING COUNT(*) > 1);

-- 7.Accenture would like to shortlist candidates with CGPA > 7 and no need of student who already got placed, write SQL query that statisfies their given criteria.
SELECT
  S.NAME AS 'STUDENT',
  S.DEPARTMENT AS 'DEPARTMENT',
  S.CGPA AS 'CGPA'
FROM STUDENT S
WHERE S.CGPA > 7
  AND S.ID NOT IN (SELECT S_ID FROM PLACEMENTS);

-- 8.Yamuna decided that she will attend the interview of companies who's location name starts with 'B', write a query that gets the list of company she can attend
SELECT C.NAME AS 'NAME', C.LOCATION AS 'LOCATION'
FROM COMPANY C
WHERE LOCATION LIKE "B%";

CREATE DATABASE COMPANY;
USE COMPANY;

-- Create & Insert data
CREATE TABLE DEPARTMENT(
  ID CHAR(5) NOT NULL,
  NAME VARCHAR(30) NOT NULL,
PRIMARY KEY (ID));

CREATE TABLE ROLES(
  ID CHAR(5) NOT NULL,
  NAME VARCHAR(30) NOT NULL,
PRIMARY KEY (ID));

CREATE TABLE EMPLOYEE(
ID CHAR(5),
NAME VARCHAR(50) NOT NULL,
DEPARTMENT CHAR(5),
ACTIVE INT DEFAULT 0,
GENDER CHAR(1) NOT NULL,
ROLE_ID CHAR(5) NOT NULL,
PRIMARY KEY (ID),
FOREIGN KEY (DEPARTMENT) REFERENCES DEPARTMENT (ID),
FOREIGN KEY (ROLE_ID) REFERENCES ROLES (ID));

CREATE TABLE REPORTING(
  ID CHAR(5) NOT NULL,
  L1 CHAR(5),
  L2 CHAR(5),
  FOREIGN KEY (ID) REFERENCES EMPLOYEE (ID),
  FOREIGN KEY (L1) REFERENCES EMPLOYEE (ID),
  FOREIGN KEY (L2) REFERENCES EMPLOYEE (ID));

CREATE TABLE EMP_ACTIVE_DATE(
  ID CHAR(5) NOT NULL,
  ACTIVE_FROM DATE NOT NULL,
  RESIGNED_ON DATE DEFAULT NULL,
  FOREIGN KEY (ID) REFERENCES EMPLOYEE (ID));

INSERT INTO DEPARTMENT VALUES
('D001', 'DEVELOPMENT'),
('D002', 'HR');

INSERT INTO ROLES VALUES
('R001', 'TEAM LEAD'),
('R002', 'SR. DEVELOPER'),
('R003', 'DEVLOPER'),
('R004', 'MANAGER'),
('R005', 'SR. MANAGER'),
('R006', 'EXE. MANAGER');

INSERT INTO EMPLOYEE VALUES
('E001', 'RAJKUMAR', 'D001', 1, 'M', 'R001'),
('E002', 'GANESH', 'D001', 1, 'M', 'R002'),
('E003', 'RAGHU', 'D001', 1, 'M', 'R003'),
('E004', 'CHITRA', 'D001', 1, 'F', 'R001'),
('E005', 'PRIYA', 'D001', 1, 'F', 'R002'),
('E006', 'PREM KUMAR', 'D001', 1, 'M' , 'R003'),
('E007', 'KRISHNA', 'D002', 1, 'M', 'R006'),
('E008', 'PREETHI', 'D002', 1, 'F', 'R005'),
('E009', 'RAVI', 'D002', 0, 'M', 'R004'),
('E010', 'MEENA', 'D002', 1, 'F', 'R004');

INSERT INTO REPORTING VALUES
('E001',	NULL,	NULL),
('E002',	NULL,	'E001'),
('E003',	'E002',	'E001'),
('E004',	NULL,	NULL),
('E005',	NULL,	'E004'),
('E006',	'E005',	'E004'),
('E007',	NULL,	NULL),
('E008',	NULL,	'E007'),
('E009',	'E008',	'E007'),
('E010',	'E008',	'E007');

INSERT INTO EMP_ACTIVE_DATE VALUES
('E001',	'2015-01-02', NULL),
('E002',	'2016-03-01', NULL),
('E003',	'2018-01-02', NULL),
('E004',	'2014-11-01', NULL),
('E005',	'2015-02-01', NULL),
('E006',	'2019-01-02', NULL),
('E007',	'2013-01-02', NULL),
('E008',	'2015-01-02', NULL),
('E009',	'2017-11-05', '2020-10-31'),
('E010',	'2015-01-02', NULL);

-- 1.GET EMPLOYESS STRENGTH IN EACH DEPARTMENT 
SELECT E.DEPARTMENT, D.NAME AS DEPARTMENT, COUNT(E.DEPARTMENT) AS STRENGTH
FROM EMPLOYEE E RIGHT JOIN DEPARTMENT D ON E.DEPARTMENT = D.ID
GROUP BY E.DEPARTMENT, D.NAME;

-- 2.LIST EACH EMPLOYEES L2, L1 REPORTING SENIORS
SELECT E.ID, E.NAME AS EMPLOYEE,
COALESCE((SELECT E.NAME FROM EMPLOYEE E WHERE R.L2 = E.ID), '-') AS L2,
COALESCE((SELECT E.NAME FROM EMPLOYEE E WHERE R.L1 = E.ID), '-') AS L1
FROM REPORTING R JOIN EMPLOYEE E
ON R.ID = E.ID;

--3.PROVIDE DETAILED EMPLOYEE REPORT ALL EMPLOYEES
SELECT E.ID, E.NAME AS EMPLOYEE, D.NAME AS DEPARTMENT, R.NAME AS ROLE,
CASE WHEN EAD.RESIGNED_ON IS NULL THEN 'ACTIVE' ELSE 'RESIGNED'
END AS 'ACTIVE/RESIGNED',
CASE
  WHEN EAD.RESIGNED_ON IS NULL THEN 
  CONCAT(TIMESTAMPDIFF(year, EAD.ACTIVE_FROM, CURRENT_DATE()), ' years ',
	TIMESTAMPDIFF(month, EAD.ACTIVE_FROM, CURRENT_DATE()) - TIMESTAMPDIFF(year, EAD.ACTIVE_FROM, CURRENT_DATE()) * 12, ' months ',
	TIMESTAMPDIFF(DAY, EAD.ACTIVE_FROM, CURRENT_DATE()) - TIMESTAMPDIFF(year, EAD.ACTIVE_FROM, CURRENT_DATE()) * 365 -
  (TIMESTAMPDIFF(month, EAD.ACTIVE_FROM, CURRENT_DATE()) - TIMESTAMPDIFF(year, EAD.ACTIVE_FROM, CURRENT_DATE()) * 12) * 30, ' days'
)
  ELSE CONCAT(TIMESTAMPDIFF(year, EAD.ACTIVE_FROM, CURRENT_DATE()), ' years ',
	TIMESTAMPDIFF(month, EAD.ACTIVE_FROM, CURRENT_DATE()) - TIMESTAMPDIFF(year, EAD.ACTIVE_FROM, CURRENT_DATE()) * 12, ' months ',
	TIMESTAMPDIFF(DAY, EAD.ACTIVE_FROM, CURRENT_DATE()) - TIMESTAMPDIFF(year, EAD.ACTIVE_FROM, CURRENT_DATE()) * 365 -
  (TIMESTAMPDIFF(month, EAD.ACTIVE_FROM, CURRENT_DATE()) - TIMESTAMPDIFF(year, EAD.ACTIVE_FROM, CURRENT_DATE()) * 12) * 30, ' days')
END AS DAYS
FROM EMPLOYEE E LEFT JOIN DEPARTMENT D ON E.DEPARTMENT = D.ID
LEFT JOIN ROLES R ON R.ID = E.ROLE_ID
LEFT JOIN EMP_ACTIVE_DATE EAD ON EAD.ID = E.ID;

-- 4.GET LIST OF ALL EMPLOYEES WHO HAS PART OF OUR TEAM FOR MORE THAN 1500 DAYS			
SELECT E.ID, E.NAME AS EMPLOYEE, D.NAME AS DEPARTMENT,
DATEDIFF(CURDATE(), EAD.ACTIVE_FROM) DAYS
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DEPARTMENT = D.ID
JOIN EMP_ACTIVE_DATE EAD ON EAD.ID = E.ID
WHERE E.ACTIVE = 1
HAVING DAYS > 1500;

-- 5.CALCULATE THE STRENGTH (IN RATIO) OF FEMALE EMPLOYEES IN EACH DEPARTMENT
SELECT D.NAME,
COUNT(CASE WHEN E.GENDER='F' THEN 1 ELSE NULL END)/COUNT(D.ID) * 100 AS PERCENTAGE
FROM DEPARTMENT D
LEFT JOIN EMPLOYEE E ON E.DEPARTMENT = D.ID
WHERE E.ACTIVE = 1
GROUP BY D.NAME;

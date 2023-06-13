-- https://docs.google.com/spreadsheets/d/1sw-IwgpiHuHC6Zuig0iuakwfPzj5mUt1/edit#gid=1769471301
create DATABASE Sales;
USE Sales;

-- 1.Create table Customers,Agent and Orders. Use primary key for each tables and foreign keys for connecting the tables.Use Comments while creating the tables.
CREATE TABLE AGENT (
 AGENT_CODE CHAR(5) NOT NULL COMMENT 'unique code for each agent',
 AGENT_NAME VARCHAR(50) NOT NULL,
 COUNTRY VARCHAR(20),
 PHONE_NO VARCHAR(11),
 STATUS CHAR(1),
 PRIMARY KEY (AGENT_CODE));

CREATE TABLE CUSTOMER (
 CUST_CODE CHAR(5) NOT NULL COMMENT 'unique code for each agent',
 CUST_NAME VARCHAR(50) NOT NULL,
 CUST_CITY VARCHAR(30) NOT NULL,
 PHONE_NO VARCHAR(11),
 AGENT_CODE CHAR(5),
 PRIMARY KEY (CUST_CODE),
 FOREIGN KEY (AGENT_CODE) REFERENCES AGENT(AGENT_CODE));

CREATE TABLE ORDERS (
 ORDER_NUM CHAR(5) NOT NULL COMMENT 'unique number for each order',
 CUST_CODE CHAR(5) NOT NULL COMMENT 'reference to unique customer',
 AGENT_CODE CHAR(5) NOT NULL COMMENT 'reference to unique agent',
 AMOUNT DECIMAL(12,2),
 ORDER_DATE DATE,
 PRIMARY KEY (ORDER_NUM),
 FOREIGN KEY (CUST_CODE) REFERENCES CUSTOMER (CUST_CODE),
 FOREIGN KEY (AGENT_CODE) REFERENCES AGENT (AGENT_CODE));

INSERT INTO AGENT VALUES
('A001', 'Joe', 'Canada', '2345623452', '0'),
('A002', 'Sara', 'India', '1234567890', '1'),
('A003', 'Wiley', 'Bahamas','987654321', '1'),
('A004', 'Katniss','Ireland','3456543698', '1'),
('A005', 'Arjun', 'India', '9844342345', '0');

INSERT INTO CUSTOMER VALUES
('C001', 'Albert','Chennai','9798865876', 'A001'),
('C002', 'Ravi', 'Bangalore', '9876123456', 'A002'),
('C003', 'Archana','Chennai','94523098123','A004'),
('C004', 'Riya', 'Trichy', '9612309876', 'A002'),
('C005', 'Pavithra', 'Kanyakumari','9612309856', 'A005');

INSERT INTO ORDERS VALUES
('O001','C001', 'A001', 50000.5, '2021-05-24'),
('O002', 'C002', 'A002', 3000.35, '2021-03-26'),
('O003', 'C005', 'A004', 25000.1, '2021-01-21'),
('O004', 'C003', 'A003', 6000.5, '2020-04-24'),
('O006', 'C004', 'A005', 100000.4, '2019-09-13');

-- 2.Alter the table agent, Add a new Column called "Commission".
ALTER TABLE AGENT ADD Commission DECIMAL(3,2) AFTER AGENT_NAME;
UPDATE AGENT SET Commission = 0.2 WHERE AGENT_CODE='A001';
UPDATE AGENT SET Commission = 0.96 WHERE AGENT_CODE='A002';
UPDATE AGENT SET Commission = 0.23 WHERE AGENT_CODE='A003';
UPDATE AGENT SET Commission = 0.12 WHERE AGENT_CODE='A004';
UPDATE AGENT SET Commission = 0.76 WHERE AGENT_CODE='A005';

-- 3.Delete the column Phone_No from the agents table.
ALTER TABLE AGENT DROP PHONE_NO;

-- 4.Alter the table agent , Add a new Column called "Commission".
ALTER TABLE AGENT RENAME COLUMN Commission TO Commission_Percentage;

-- 5.Make a copy of agent table with a table name as "AGENT_DETAILS" and delete the old agent table with the name "AGENT"
CREATE TABLE AGENT_DETAILS AS SELECT * FROM AGENT;
ALTER TABLE AGENT_DETAILS ADD PRIMARY KEY (AGENT_CODE);

-- Delete FOREIGN keys before Deleting AGENT Table
ALTER TABLE CUSTOMER DROP FOREIGN KEY customer_ibfk_1;
ALTER TABLE ORDERS DROP FOREIGN KEY orders_ibfk_2;
DROP TABLE AGENT;

-- Add FOREIGN keys
ALTER TABLE CUSTOMER ADD CONSTRAINT customer_fk_1 FOREIGN KEY (AGENT_CODE) REFERENCES AGENT_DETAILS(AGENT_CODE) ON DELETE CASCADE;
ALTER TABLE ORDERS ADD CONSTRAINT orders_fk_2 FOREIGN KEY (AGENT_CODE) REFERENCES AGENT_DETAILS(AGENT_CODE) ON DELETE CASCADE;

-- 6.Delete all the order table records in a single command
TRUNCATE ORDERS;

-- 7.Alter the tables orders and set a default value for the column Amount
ALTER TABLE ORDERS CHANGE COLUMN AMOUNT AMOUNT DECIMAL(12,2) NOT NULL DEFAULT 0.0;

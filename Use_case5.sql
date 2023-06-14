-- CREATE DATABASE LIBRARY;
USE LIBRARY;

-- Create & Insert data
CREATE TABLE BOOK(
  ID INT NOT NULL,
  NAME VARCHAR(30) NOT NULL,
  ISBN BIGINT NOT NULL,
  EDITION INT,
  PRIMARY KEY (ID));

CREATE TABLE AUTHOR(
  ID INT,
  FIRST_NAME VARCHAR(20) NOT NULL,
  LAST_NAME VARCHAR(20),
  PRIMARY KEY (ID));

CREATE TABLE BOOK_DETAILS	(
  BOOK_ID INT NOT NULL,
  AUTHOR_ID INT NOT NULL,
  FOREIGN KEY (BOOK_ID) REFERENCES BOOK (ID),
  FOREIGN KEY (AUTHOR_ID) REFERENCES AUTHOR (ID));

CREATE TABLE CUSTOMER(  	
  ID INT NOT NULL,
  NAME VARCHAR(30) NOT NULL,
  ADDRESS VARCHAR(50),
  PRIMARY KEY (ID));

CREATE TABLE LIBRARIANS(  	
  ID INT NOT NULL,
  NAME VARCHAR(30) NOT NULL,
  PRIMARY KEY (ID));

CREATE TABLE BOOK_REQUEST	(
  DUE_DATE	DATE,
  IS_ACTIVE INT DEFAULT 1,
  CUSTOMER_ID INT NOT NULL,	
  BOOK_ID INT NOT NULL,
  LIBRARIAN_ID INT NOT NULL,
  FOREIGN KEY (BOOK_ID) REFERENCES BOOK (ID),
  FOREIGN KEY (LIBRARIAN_ID) REFERENCES LIBRARIANS (ID),
  FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMER (ID));

INSERT INTO BOOK VALUES
(1, 'piligrim souls', 9876011, 1),
(2, 'piligrim souls', 9876011, 2),
(3, 'python for data science', 9876012, 1),
(4, 'python for data science', 9876012, 1),
(5, 'python for data science', 9876012, 1),
(6, 'c# 7.0 All-in-one', 9876016, 1),
(7, 'c# 7.0 All-in-one', 9876016, 2),
(8, 'c programming All-in-one', 9876017, 3),
(9, 'c programming All-in-one', 9876017, 3),
(10, 'java programming for everyone', 9876018, 1);

INSERT INTO AUTHOR VALUES
(1, 'Hortsman', 'Cay S'),
(2, 'John Paul', 'Mueller'),
(3, 'Mike', 'Chapple'),
(4, 'Barbara', 'Walter' );

INSERT INTO BOOK_DETAILS VALUES
(1, 1),
(2, 1),
(3, 4),
(4, 4),
(5, 4),
(6, 2),
(7, 2),
(8, 3),
(9, 3),
(10, 2);

INSERT INTO CUSTOMER VALUES
(111, 'Kala', '03 Ranjith St'),
(112, 'Amy', '6 Hudson St'),
(113, 'Ajay', '56 Murugappa st'),
(114, 'Basker', '23 Blue St'),
(115, 'Bella', '10 New St'),
(116, 'Cynthia', '107 Park St'),
(117, 'Zara', '34 Lombard St');

INSERT INTO LIBRARIANS VALUES
(20211, 'Julia Roosevelt'),
(20233, 'Tom White');

INSERT INTO BOOK_REQUEST VALUES
('2021-02-01', 1, 113, 1, 20211),
('2021-02-11', 1, 116, 8, 20211),
('2021-01-28', 1, 116, 3, 20233),
('2021-01-15', 0, 111, 7, 20211),
('2021-01-08', 0, 113, 5, 20233),
('2021-02-08', 1, 113, 4, 20233);

-- 1.Write an SQL query to display the book details with the respective author name.
SELECT NAME AS BOOK_NAME,	ISBN, EDITION, FIRST_NAME, LAST_NAME
FROM BOOK JOIN AUTHOR
ON BOOK.ID = AUTHOR.ID;

-- 2.Write an SQL query to find out the books with the word ‘programming’ in their names.
SELECT NAME AS BOOK_NAME, A.ID AS AUTHOR_ID, CONCAT(A.FIRST_NAME, A.LAST_NAME) AS AUTHOR_NAME
FROM BOOK B LEFT JOIN AUTHOR A
ON B.ID = A.ID HAVING BOOK_NAME LIKE "%programming%";

--3 Find the books that are not returned before the due date.		
SELECT B.NAME AS BOOK_NAME, BR.DUE_DATE,	C.NAME AS CUSTOMER_NAME
FROM BOOK_REQUEST BR JOIN CUSTOMER C
ON BR.CUSTOMER_ID = C.ID
JOIN BOOK B
ON BR.BOOK_ID = B.ID WHERE BR.IS_ACTIVE = 0;

-- 4.Find all the unique entries in the book table.
SELECT DISTINCT NAME, ISBN, EDITION
FROM BOOK;

-- 5.Write an SQL query to display the book name, customer name and librarian name (first 50% of the records).
SET @COUNT = (SELECT FLOOR(COUNT(*)/2) FROM (SELECT B.NAME AS BOOK_NAME, C.NAME AS	CUSTOMER_NAME, L.NAME AS LIBRARIAN_NAME
FROM BOOK_REQUEST BR JOIN CUSTOMER C
ON BR.CUSTOMER_ID = C.ID
JOIN BOOK B
ON BR.BOOK_ID = B.ID
JOIN LIBRARIANS L
ON BR.LIBRARIAN_ID = L.ID) AS T);

SET @Q = CONCAT('SELECT B.NAME AS BOOK_NAME, C.NAME AS	CUSTOMER_NAME, L.NAME AS LIBRARIAN_NAME
FROM BOOK_REQUEST BR JOIN CUSTOMER C
ON BR.CUSTOMER_ID = C.ID
JOIN BOOK B
ON BR.BOOK_ID = B.ID
JOIN LIBRARIANS L
ON BR.LIBRARIAN_ID = L.ID LIMIT ', @COUNT);

SELECT @Q;
PREPARE statement FROM @Q;
EXECUTE statement;


-- 6.Calculate the fine amount (Rs.1 per day if it exceeds the due date) for the books borrowed. Display the total fine amount for all the customers.
SELECT C.ID AS	CUSTOMER_ID, C.NAME AS	CUSTOMER_NAME,
CASE
 WHEN '2021-01-20' < BR.DUE_DATE THEN 0
 ELSE	DATEDIFF('2021-01-20', BR.DUE_DATE)
END AS FINE_AMOUNT
FROM CUSTOMER C JOIN BOOK_REQUEST BR
ON C.ID = BR.CUSTOMER_ID
JOIN BOOK B
ON BR.BOOK_ID = B.ID ORDER BY CUSTOMER_ID;

-- 7.Write an SQL query to display the librarian name and number of books they distributed to the customers.
SELECT L.NAME AS LIBRARIAN_NAME,
COUNT(BR.LIBRARIAN_ID) AS NO_OF_BOOKS
FROM LIBRARIANS L
JOIN BOOK_REQUEST BR
ON BR.LIBRARIAN_ID = L.ID
GROUP BY L.ID;

-- 8.Find the customer who has borrowed multiple copies of the same book. 
-- SELECT  AS	CUSTOMER_NAME, B.NAME AS BOOK_NAME, B.EDITION AS BOOK_EDITION, A.FIRST_NAME AS AUTHOR_FIRST_NAME
SELECT C.NAME AS CUSTOMER_NAME, B.NAME AS BOOK_NAME
FROM BOOK_REQUEST BR JOIN CUSTOMER C
ON C.ID = BR.CUSTOMER_ID
JOIN BOOK B
ON BR.BOOK_ID = B.ID
LEFT JOIN AUTHOR A
ON B.ID = A.ID
GROUP BY C.NAME, B.NAME
HAVING count(B.NAME) > 1;

-- 9.Find the customers who haven’t borrowed any books from the library. Display the table as given below. 
SELECT C.ID , C.NAME, C.ADDRESS
FROM CUSTOMER C LEFT JOIN BOOK_REQUEST BR
ON C.ID = BR.CUSTOMER_ID
WHERE C.ID NOT IN (SELECT CUSTOMER_ID FROM BOOK_REQUEST);

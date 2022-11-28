'''
A community college uses the following tables to track each student’s progress:

Class
class_id (p)      class_name
101               Geometry
102               English
103               Physics

Student
student_id(p)     first_name      last_name
500               Robert          Smith
762               Frank           Carter
881               Joseph          Evans
933               Anne            Baker

Enrollment
class_id(p)(f)      student_id(p)(f)      semester(p)     grade
101                 500                   Fall 2019       A
102                 500                   Fall 2019       B
103                 762                   Fall 2019       F
101                 881                   Spring 2020     B
102                 881                   Fall 2020       B
103                 762                   Spring 2021     null

Please note that null is not a string value, i.e., null.  It is a true null and should be inserted into the table without quotes.

Note: (p) = "primary key" and (f) = "foreign key". They are not part of the column names.


Prompt 1 Questions
(There are 12 questions for Prompt 1).
Answer the following questions by constructing a single query without using subqueries, unless otherwise instructed.
'''

'1. Write a query to retrieve all columns from the Enrollment table where the grade of A or B was assigned.'
SELECT *
FROM Enrollment
WHERE grade = 'A' OR grade = 'B';

'2. Write a query to return the first and last names of each student who has taken Geometry.'
SELECT first_name, last_name
FROM Student AS s
  JOIN Enrollment AS e
  ON s.student_id = e.student_id
  JOIN Class AS c
  ON e.class_id = c.class_id
WHERE c.class_name = 'Geometry';

'3. Write a query to return all rows from the Enrollment table where the student has not been given a
failing grade (F). Include any rows where the grade has not yet been assigned.'
SELECT *
FROM Enrollment AS e
WHERE grade <> 'F' OR grade IS null;

'4. Write a query to return the first and last names of every student in the Student table.
If a student has ever enrolled in English, please specify the grade that they received.
You need only include the Enrollment and Student tables and may specify the class_id value of 102
for the English class. The query should return one row for each student (4 rows) with nulls as grades
for students who dont have a grade.'
SELECT s.first_name, s.last_name, e.grade
FROM Enrollment AS e
  JOIN Student AS s
  ON e.student_id = s.student_id
WHERE e.class_id = 102 OR (e.class_id = 102 AND grade IS null);

'5. Write a query to return the class names and the total number of students who have ever been
enrolled in each class. If a student has enrolled in the same class twice, it is OK to count him twice
in your results.'
SELECT c.class_name, count(s.student_id)
FROM Class AS c
  JOIN Enrollment AS e
  ON c.class_id = e.class_id
  JOIN Student AS s
  ON e.student_id = s.student_id
GROUP BY c.class_name;

'6. Write a statement to update Robert Smith’s grade for the English class from a B to a B+.
Specify the student by his student ID, which is 500, and the English class by class ID 102.'
UPDATE Enrollment
SET grade = 'B+'
WHERE student_id = 500 AND class_id = 102;

'7. Create an alternate statement to update Robert Smith’s grade in English to a B+,
but for this version specify the student by first/last name, not by student ID.
This will require the use of a subquery.'
UPDATE Enrollment AS e
SET e.grade = 'B+'
WHERE e.class_id = 102 AND e.student_id =
(
  SELECT s.student_id
  FROM Student AS s
  WHERE s.first_name = 'Robert' AND s.last_name = 'Smith'
);

'8. A new student name Michael Cronin enrolls in the Geometry class. Construct a statement to add the
new student to the Student table. (You can pick any value for the student_id, provided it doesn’t already
exist in the table).'
INSERT INTO Student (student_id, first_name, last_name)
VALUES (640, 'Michael', 'Cronin');

'9. Add Michael Cronin’s enrollment in the Geometry class to the Enrollment table.
You may only specify names (e.g. “Michael”, “Cronin”, “Geometry”) and not numbers (e.g. student_id, class_num)
in your statement.  You may use subqueries if desired, but the statement can also be written without
the use of subqueries. Use ‘Spring 2020’ for the semester value.'
INSERT INTO Enrollment (class_id, student_id, semester, grade)
VALUES
(
  (SELECT c.class_id FROM Class AS c WHERE c.class_name = 'Geometry'),
  (SELECT s.student_id FROM Student AS s WHERE s.first_name = 'Michael' AND s.last_name = 'Cronin'),
  'Spring 2020',
  null
);

'10. Write a query to return the first and last names of all students who have not enrolled in any class.
It is important to use a correlated subquery for this question. Please DO NOT use a JOIN.'
SELECT s.first_name, s.last_name
FROM Student AS s
WHERE NOT EXISTS
(
  SELECT e.student_id # Could also be all columns (star)
  FROM Enrollment AS e
  WHERE s.student_id = e.student_id
);

'11. Return the same results as the previous question (first and last name of all students who have not enrolled
in any class), but formulate your query using a non-correlated subquery. It is important to use a non-correlated
subquery for this question. Please DO NOT use a JOIN.'
SELECT first_name, last_name
FROM Student AS s
WHERE s.student_id NOT IN
(
  SELECT e.student_id
  FROM Enrollment AS e
);

'12. Write a statement to remove any rows from the Student table where the person has not enrolled in any classes.
You may use either a correlated or non-correlated subquery. Please DO NOT use a JOIN.'
DELETE s.student_id, s.first_name, s.last_name
FROM Student AS s
WHERE s.student_id NOT IN
(
  SELECT e.student_id
  FROM Enrollment AS e
);

________________________________
DELETE FROM Student
WHERE first_name =
(
  SELECT first_name
  FROM Student AS s
  WHERE s.student_id NOT IN
  (
    SELECT e.student_id
    FROM Enrollment AS e
  )
);

'''
Prompt 2 Tables
The Customer_Order table, which stores data about customer orders, contains the following data:

Customer_Order
order_num     cust_id       order_date
1             121           2019-01-15
2             234           2019-07-24
3             336           2020-05-02
4             121           2019-01-15
5             336           2020-03-19
6             234           2019-07-24
7             121           2019-01-15
8             336           2020-06-12

Customer
cust_id       cust_name
121           Acme Wholesalers
234           Griffin Electric
336           East Coast Marine Supplies
544           Sanford Automotive

Prompt 2 Questions
(There are 8 questions for Prompt 2).
'''
'1. Write a query to retrieve each unique customer ID (cust_id) from the Customer_Order table.
There are multiple ways to construct the query, but do not use a subquery.'
SELECT DISTINCT(cust_id)
FROM Customer_Order;

'2. Write a query to retrieve each unique customer ID (cust_id) along with the latest order date for
each customer.  Do not use a subquery.'
SELECT DISTINCT(cust_id), MAX(order_date)
FROM Customer_Order
GROUP BY cust_id;

'3. Write a query to retrieve all rows and columns from the Customer_Order table, with the results
sorted by order date descending (latest date first) and then by customer ID ascending.'
SELECT *
FROM Customer_Order
ORDER BY order_date DESC, cust_id ASC;

'4. Write a query to retrieve each unique customer (cust_id) whose lowest order number
(order_num) is at least 3.  Please note that this is referring to the value of the lowest order number and
NOT the order count.  Do not use a subquery.'
SELECT DISTINCT(cust_id)
FROM Customer_Order
WHERE order_num >=3;

'5. Write a query to retrieve only those customers who had 2 or more orders on the same day.
Retrieve the cust_id and order_date values, along with the total number of orders on that date.
Do not use a subquery.'
SELECT cust_id, order_date, COUNT(order_num)
FROM Customer_Order
GROUP BY order_date, cust_id
HAVING COUNT(order_num) >= 2;

'6. Along with the Customer_Order table, there is another Customer table below. Write a query that returns
the name of each customer who has placed exactly 3 orders.  Do not return the same customer name more than once,
and use a correlated subquery (no JOINS please) against Customer_Order to determine the total number of orders
for each customer:'
SELECT DISTINCT(c.cust_name)
FROM Customer AS c
WHERE 3 =
(
  SELECT COUNT(DISTINCT(co.order_num))
  FROM Customer_Order AS co
  WHERE co.cust_id = c.cust_id
);

'7. Construct a different query to return the same data as the previous question (name of each customer who
has placed exactly 3 orders) but use a non-correlated subquery (no JOINS please) against the
Customer_Order table. It is important to code a non-correlated subquery for this question.'
SELECT c.cust_name
FROM Customer AS c
WHERE c.cust_id IN
(
  SELECT co.cust_id
  FROM Customer_Order AS co
  GROUP BY co.cust_id
  HAVING COUNT(order_num) = 3
);

'8. Write a query to return the name of each customer, along with the total number of orders for each customer.
Include all customers, regardless if they have orders or not. Use a scalar, correlated subquery
(no JOINS please) to generate the number of orders.'
SELECT c.cust_name,
       (SELECT COUNT(*)
        FROM Customer_Order AS co
        WHERE c.cust_id = co.cust_id
       ) as total_orders
FROM Customer AS c;

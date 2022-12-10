'''
Prompt: A manufacturing company’s data warehouse contains the following tables.

Region
region_id (p)   region_name     super_region_id (f)
101             North America   null
102             USA             101
103             Canada          101
104             USA-Northeast   102
105             USA-Southeast   102
106             USA-West        102
107             Mexico          101

200             Europe          null

Product
product_id (p)    product_name
1256              Gear - Large
4437              Gear - Small
5567              Crankshaft
7684              Sprocket

Sales_Totals
product_id (p)(f)     region_id (p)(f)      year (p)    month (p)   sales
1256                  104                   2020        1           1000
4437                  105                   2020        2           1200
7684                  106                   2020        3           800
1256                  103                   2020        4           2200
4437                  107                   2020        5           1700
7684                  104                   2020        6           750
1256                  104                   2020        7           1100
4437                  105                   2020        8           1050
7684                  106                   2020        9           600
1256                  103                   2020        10          1900
4437                  107                   2020        11          1500
7684                  104                   2020        12          900

7684                  200                   2020        10          1500'

'1. CREATE DATABASE sales;'
'2. USE sales;'
'3. CREATE TABLE Region (region_id INT PRIMARY KEY, region_name VARCHAR(256), super_region_id INT);'
'4. INSERT INTO Region (region_id, region_name, super_region_id) VALUES (101,'North America',null),
  (102,'USA', 101),(103,'Canada', 101), (104,'USA-Northeast',102), (105,'USA-Southeast',102), (106, 'USA-West', 102),
  (107,'Mexico', 101);'
'5. CREATE TABLE Product (product_id INT PRIMARY KEY, product_name VARCHAR(256));'
'6. INSERT INTO Product (product_id, product_name) VALUES (1256,'Gear - Large'), (4437,'Gear - Small'),
  (5567,'Crankshaft'), (7684,'Sprocket');'
'7. CREATE TABLE Sales_Totals (product_id INT, region_id INT, year INT, month INT, sales INT,
  PRIMARY KEY (product_id, region_id, year, month));'
'8. INSERT INTO Sales_Totals (product_id,region_id,year,month,sales) VALUES
  (1256, 104, 2020, 1, 1000),
  (4437, 105, 2020, 2, 1200),
  (7684, 106, 2020, 3, 800),
  (1256, 103, 2020, 4, 2200),
  (4437, 107, 2020, 5, 1700),
  (7684, 104, 2020, 6, 750),
  (1256, 104, 2020, 7, 1100),
  (4437, 105, 2020, 8, 1050),
  (7684, 106, 2020, 9, 600),
  (1256, 103, 2020, 10, 1900),
  (4437, 107, 2020, 11, 1500),
  (7684, 104, 2020, 12, 900);'

'''
Answer the following questions using the above tables/data:'''

'1. Write a SELECT statement to return the month column, as well as an additional column for the quarter
(1, 2, 3, or 4) that is based on the month. Please use a CASE expression for this and do not alter the table.'
SELECT month,
(
  CASE
    WHEN month IN (1,2,3) THEN 1
    WHEN month IN (4,5,6) THEN 2
    WHEN month IN (7,8,9) THEN 3
    ELSE 4
  END
) AS quarter
FROM Sales_Totals
ORDER BY month, quarter;

'2. Write a query that will pivot the Sales_Totals data so that there is a column for each of the 4
products containing the total sales across all months of 2020.  It is OK to include the product_id values
in your query, and the results should look as follows:

tot_sales_large_gears	      tot_sales_small_gears	      tot_sales_crankshafts	      tot_sales_sprockets
6200                        5450                        0                           3050'
SELECT
  SUM(CASE WHEN product_id = 1256 THEN sales ELSE 0 END) AS tot_sales_large_gears,
  SUM(CASE WHEN product_id = 4437 THEN sales ELSE 0 END) AS tot_sales_small_gears,
  SUM(CASE WHEN product_id = 5567 THEN sales ELSE 0 END) AS tot_sales_crankshafts,
  SUM(CASE WHEN product_id = 7684 THEN sales ELSE 0 END) AS tot_sales_sprockets
FROM Sales_Totals;

'3. Write a query that retrieves all columns from the Sales_Totals table, along with a column called
sales_rank which assigns a ranking to each row based on the value of the Sales column in descending order.
Please use SQL RANK functions shown in the class video.'
SELECT *, DENSE_RANK() OVER(ORDER BY sales DESC) AS sales_rank
FROM Sales_Totals
ORDER BY sales_rank ASC;

'4. Write a query that retrieves all columns from the Sales_Totals table, along with a column called
product_sales_rank which assigns a ranking to each row based on the value of the Sales column in
descending order, with a separate set of rankings for each product. Please use SQL RANK functions shown
in the class video.'
SELECT *, RANK() OVER(PARTITION BY product_id ORDER BY sales DESC) AS product_sales_rank
FROM Sales_Totals;

'5. Expand on the query from question #4 by adding logic to return only those rows with a product_sales_rank
of 1 or 2.'

SELECT *
FROM
(
		SELECT *,
			RANK() OVER(PARTITION BY st.product_id ORDER BY st.sales DESC) AS product_sales_rank
        FROM Sales_Totals AS st
) AS product_rank
WHERE product_rank.product_sales_rank <= 2;

'6. Write a set of SQL statements which will add a row to the Region table for Europe, and then add a row
to the Sales_Total table for the Europe region and the Sprocket product (product_id = 7684) for October 2020,
with a sales total of $1,500. You can assign any value to the region_id column, as long as it is unique
to the Region table. The statements should be executed as a single unit of work. Please note that since
the statements are executed as a single unit of work, additional code is needed.'
START TRANSACTION;

INSERT INTO Region (region_id, region_name, super_region_id)
VALUES (200, 'Europe', null);

SAVEPOINT europe_sale;

INSERT INTO Sales_Totals (product_id, region_id, year, month, sales)
VALUES (7684, 200, 2020, 10, 1500);

COMMIT;

'7. Write a statement to create a view called Product_Sales_Totals which will group sales data by product
and year.  Columns should include product_id, year, product_sales, and gear_sales. The gear_sales column will
contain the total sales for the “Gear - Large” or the total sales for “Gear Small” products,
depending on the product_id.  In the case that the product is neither “Gear - Large” or “Gear Small”,
the value for gear_sales should be 0. (The data should be generated by an expression, and it is OK to
use the product_id values in the expression).  To accomplish this, you need a CASE statement.
The product_sales column should be a sum of sales for the particular product_id and year,
regardless of what kind of product it is (including gears).'
CREATE OR REPLACE VIEW Product_Sales_Totals AS
SELECT product_id, year,
  SUM(CASE WHEN product_id = 1256 OR product_id = 4437 THEN sales ELSE 0 END) AS gear_sales,
  (
    CASE
      WHEN product_id = 1256 THEN (SELECT SUM(sales) FROM Sales_Totals WHERE product_id = 1256)
      WHEN product_id = 4437 THEN (SELECT SUM(sales) FROM Sales_Totals WHERE product_id = 4437)
      WHEN product_id = 5567 THEN (SELECT SUM(sales) FROM Sales_Totals WHERE product_id = 5567)
      ELSE (SELECT SUM(sales) FROM Sales_Totals WHERE product_id = 7684)
    END
  ) AS product_sales
FROM Sales_Totals
GROUP BY product_id, year;

'8. Write a query to return all sales data for 2020, along with a column called “pct_product_sales”
showing the percentage of sales for each product by region_id and month.  Columns should include product_id,
region_id, month, sales, and pct_product_sales. The values in pct_product_sales should add up to 100% for
each product.'
SELECT product_id, region_id, month, sales,
  ROUND((sales / SUM(sales) OVER(PARTITION BY product_id
    ORDER BY product_id)) * 100, 1) AS pct_product_sales
FROM Sales_Totals
WHERE year = 2020
ORDER BY product_id, sales;

'This return 100% in every row as there is only one sale per month
SELECT product_id, region_id, month, sales,
  ROUND((sales / SUM(sales) OVER(PARTITION BY product_id, region_id, month
    ORDER BY product_id)) * 100, 1) AS pct_product_sales
FROM Sales_Totals
WHERE year = 2020;'

'9. Write a query to return the year, month, and sales columns, along with a 4th column named prior_month_sales
showing the sales from the prior month.  There are only 12 rows in the sales_totals table, one for
each month of 2020, so you will not need to group data or filter/partition on region_id or product_id.
Please use a windowing function for this as shown in the class video.'

CREATE OR REPLACE VIEW PriorMonthSale AS
SELECT year, month, sales,
  LAG(sales) OVER(ORDER BY month ASC) AS prior_month_sales
FROM Sales_Totals;

'10. If the tables used in this prompt are in the ‘sales’ database, write a query to retrieve the name and
type of each of the columns in the Product table. Please specify the <sales> schema in your answer.
(You can test with the actual name of your schema and then replace the name with <sales>).'
SELECT column_name, column_type
FROM information_schema.columns
WHERE table_schema = 'sales'
  AND table_name = 'Product';

-- DATABASE CREATION
CREATE DATABASE CASE_STUDY1


-- UNDERSTANDING DATA
SELECT TOP 1 *  FROM Customer
SELECT *  FROM prod_cat_info
SELECT TOP 1 *  FROM Transactions


--DATA PREPARATION AND UNDERSTANDING
--1. What is the total number of rows in each of the 3 tables in the database?
SELECT * FROM (
SELECT 'CUSTOMER' AS TABLE_NAME, COUNT(*) AS ROWS_NO FROM Customer UNION ALL
SELECT 'PROD_CAT_INFO' AS TABLE_NAME,COUNT(*) AS ROWS_NO FROM prod_cat_info UNION ALL
SELECT 'TRANSACTION' AS TABLE_NAME,COUNT(*) AS ROWS_NO FROM Transactions
) AS TBL
 

--2. What is the total number of transactions that has a return?
SELECT COUNT(*) AS TOTAL_RETURNS FROM Transactions
WHERE TOTAL_AMT < 0


--3. As you would have noticed, the dates provided across the datasets are not in the correct format.
--   As first steps, please convert the date variables into valid date formats before proceeding ahead. 
SELECT *,CONVERT(DATE,DOB,105) AS CONVERTED_DATE FROM Customer


--4. What is the time range for transaction date available for analysis? Show the output in number of
--   days, months and years simultaneously in different columns.
SELECT DATEDIFF(DAY,MIN(TRAN_DATE),MAX(TRAN_DATE)) AS DAY_TIME_RANGE FROM Transactions
SELECT DATEDIFF(MONTH,MIN(TRAN_DATE),MAX(TRAN_DATE)) AS MONTH_TIME_RANGE FROM Transactions
SELECT DATEDIFF(YEAR,MIN(TRAN_DATE),MAX(TRAN_DATE)) AS YEAR_TIME_RANGE FROM Transactions

 
--5. Which product category does the sub-category 'DIY' belong to?
SELECT prod_cat FROM prod_cat_info
WHERE prod_subcat = 'DIY'




--DATA ANALYSIS
--1. Which channel is most frequently used for transactions?
SELECT TOP 1 STORE_TYPE,COUNT(*) AS COUNT_CHANNEL FROM Transactions
GROUP BY Store_type
ORDER BY COUNT_CHANNEL DESC 


--2. What is the count of males amd females customers in the database?
SELECT GENDER,COUNT(*) AS GENDER_COUNT FROM Customer
GROUP BY GENDER


--3. From which city do we have the maximum number of customers and how many?
SELECT TOP 1 CITY_CODE,COUNT(*) AS NO_OF_CUST FROM Customer
GROUP BY CITY_CODE
ORDER BY COUNT(*) DESC


--4. How many subcategories are there under books category?
SELECT COUNT(*) AS SUBCAT_BOOKS FROM prod_cat_info
WHERE PROD_CAT = 'BOOKS'


--5. What is the maximum quantity of products ever ordered?
SELECT TOP 1 * FROM Transactions
ORDER BY QTY DESC


--6. What is the net total revenue generated in categories Electronics and Books?
SELECT SUM(TOTAL_REV) AS TOTAL FROM 
(SELECT * FROM (SELECT * , CONCAT(PROD_CAT_CODE,' ',PROD_SUB_CAT_CODE) AS CAT_SUBCAT_CODE 
FROM prod_cat_info
WHERE PROD_CAT IN ('ELECTRONICS','BOOKS')) AS T
LEFT JOIN 
(SELECT  CONCAT(PROD_CAT_CODE,' ',PROD_SUBCAT_CODE) AS CAT_SUBCAT, SUM(TOTAL_AMT) AS TOTAL_REV  
FROM Transactions
GROUP BY CONCAT(PROD_CAT_CODE,' ',PROD_SUBCAT_CODE)) AS TT
ON T.CAT_SUBCAT_CODE = TT.CAT_SUBCAT) AS TTT


--7. How many customers have >10 transactions with us, excluding returns?
SELECT cust_id, COUNT(*) AS NO_OF_TRANS FROM Transactions
WHERE QTY > 0
GROUP BY cust_id
HAVING COUNT(*) > 10
ORDER BY NO_OF_TRANS DESC



--8. What is the combined revenue earned from the "Electronics" and "Clothing" categories, from
--   "Flagship Stores"?
SELECT SUM(TOTAL_REV) AS TOTAL FROM
(SELECT * FROM (SELECT * , CONCAT(PROD_CAT_CODE,' ',PROD_SUB_CAT_CODE) AS CAT_SUBCAT_CODE 
FROM prod_cat_info
WHERE PROD_CAT IN ('ELECTRONICS','CLOTHING')) AS T
JOIN 
(SELECT  CONCAT(PROD_CAT_CODE,' ',PROD_SUBCAT_CODE) AS CAT_SUBCAT, SUM(TOTAL_AMT) AS TOTAL_REV  
FROM Transactions
WHERE Store_type = 'FLAGSHIP STORE'
GROUP BY CONCAT(PROD_CAT_CODE,' ',PROD_SUBCAT_CODE)) AS TT
ON T.CAT_SUBCAT_CODE = TT.CAT_SUBCAT) AS TTT


--9. What is the total revenue generated from Male customers in Electronics category? Output should
--   display the total revenue by prod subcat.
SELECT TOTAL_REV, prod_subcat FROM 
(SELECT CONCAT(PROD_CAT_CODE,' ',PROD_SUBCAT_CODE) AS CAT_SUBCAT, SUM(TOTAL_AMT) AS TOTAL_REV FROM Transactions AS T
LEFT JOIN Customer AS TT
ON T.cust_id = TT.customer_Id
WHERE GENDER = 'M'
GROUP BY CONCAT(PROD_CAT_CODE,' ',PROD_SUBCAT_CODE)) AS A
JOIN
(SELECT PROD_SUBCAT , CONCAT(PROD_CAT_CODE,' ',PROD_SUB_CAT_CODE) AS CAT_SUBCAT_CODE 
FROM prod_cat_info
WHERE PROD_CAT = 'ELECTRONICS') AS B
ON A.CAT_SUBCAT = B.CAT_SUBCAT_CODE


--10. What is the percentage of sales and returns by product subcategory? Display only top5 sub
--    categories in terms of sales.
SELECT TOP 5 A.prod_subcat_code, SALES_PERC, RETURN_PERC FROM
(SELECT PROD_SUBCAT_CODE, 
(SUM(TOTAL_AMT)/(SELECT SUM(TOTAL_AMT) FROM Transactions WHERE total_amt>0))*100 AS SALES_PERC
FROM Transactions
WHERE total_amt > 0
GROUP BY prod_subcat_code) AS A
JOIN
(SELECT PROD_SUBCAT_CODE, 
(SUM(TOTAL_AMT)/(SELECT SUM(TOTAL_AMT) FROM Transactions WHERE total_amt<0))*100 AS RETURN_PERC
FROM Transactions
WHERE total_amt < 0
GROUP BY prod_subcat_code) AS B
ON A.prod_subcat_code = B.prod_subcat_code
ORDER BY SALES_PERC DESC


--11. For all customers aged between 25 to 35 years find what is the net total revenue generated
--    by these consumers in last 30 days of transaction from max transaction date available in data?
SELECT cust_id, CUST_TOTAL_REV FROM((
SELECT *, DATEDIFF(YEAR,DOB,GETDATE()) AS AGE FROM Customer
WHERE DATEDIFF(YEAR,DOB,GETDATE()) BETWEEN 25 AND 35) AS T
JOIN
(SELECT cust_id, SUM(TOTAL_AMT) AS CUST_TOTAL_REV FROM Transactions
WHERE tran_date > DATEADD(DAY,-30,(SELECT MAX(TRAN_DATE) FROM TRANSACTIONS))
GROUP BY cust_id) AS TT
ON T.customer_Id = TT.cust_id)



--12. Which product category has seen the max value of returns in the last 3 months of transactions?
SELECT TOP 1  prod_cat , total_amt FROM (SELECT *, CONCAT(PROD_CAT_CODE,' ',PROD_SUB_CAT_CODE) AS PROD_CODE
FROM prod_cat_info) AS A
RIGHT JOIN
(SELECT *, CONCAT(PROD_CAT_CODE,' ',PROD_SUBCAT_CODE) AS TRANS_CODE
FROM Transactions
WHERE tran_date >= DATEADD(MONTH,-3,(SELECT MAX(TRAN_DATE) FROM TRANSACTIONS)) AND total_amt < 0) AS B
ON A.PROD_CODE = B.TRANS_CODE
ORDER BY total_amt 


--13. Which store-type sells the maximum products by value of sales amount and by quantity sold?
SELECT TOP 1 Store_type, SUM(TOTAL_AMT) AS SALES_AMOUNT FROM Transactions
GROUP BY Store_type
ORDER BY SALES_AMOUNT DESC

SELECT TOP 1 STORE_TYPE, SUM(QTY) AS QUANTITY FROM Transactions
GROUP BY Store_type
ORDER BY QUANTITY DESC


--14. What are the categories for which average revenue is above the overall average?
SELECT * FROM (SELECT prod_cat , total_amt,  AVG(TOTAL_AMT) OVER(PARTITION BY PROD_CAT) AS AVG_REV FROM 
(SELECT *, CONCAT(PROD_CAT_CODE,' ',PROD_SUB_CAT_CODE) AS PROD_CODE
FROM prod_cat_info) AS A
JOIN
(SELECT *, CONCAT(PROD_CAT_CODE,' ',PROD_SUBCAT_CODE) AS TRANS_CODE
FROM Transactions) AS B
ON A.PROD_CODE = B.TRANS_CODE) AS T
WHERE AVG_REV > (SELECT AVG(TOTAL_AMT) FROM Transactions)




--15. Find the average and total revenue by each subcategory for the categories which are among top
--    5 categories in terms of quantity sold.
SELECT PROD_SUBCAT_CODE, AVG(TOTAL_AMT) AS AVG_SUBCAT, SUM(TOTAL_AMT) AS TOTAL_SUBCAT  FROM 
((SELECT *, CONCAT(PROD_CAT_CODE,' ',PROD_SUB_CAT_CODE) AS PROD_CODE
FROM prod_cat_info) AS A
JOIN
(SELECT *, CONCAT(PROD_CAT_CODE,' ',PROD_SUBCAT_CODE) AS TRANS_CODE
FROM Transactions) AS B
ON A.PROD_CODE = B.TRANS_CODE) 
WHERE prod_sub_cat_code IN
(SELECT TOP 5 prod_cat_code FROM Transactions
GROUP BY prod_cat_code
ORDER BY SUM(QTY) DESC)
GROUP BY prod_subcat_code







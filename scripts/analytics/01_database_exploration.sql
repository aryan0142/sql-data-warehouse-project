/*
===============================================================================
DATABASE EXPLORATION
===============================================================================

Purpose:
    Explore the structure of the Gold layer including tables, views,
    columns, and available analytical objects.
===============================================================================
*/

-- Explore all tables and views
SELECT
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'gold';


-- Explore Gold Layer columns
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold'
ORDER BY TABLE_NAME, ORDINAL_POSITION;


-- Check NULLs in Fact Sales

SELECT
    SUM(CASE WHEN order_number IS NULL THEN 1 ELSE 0 END) AS null_order_number,
    SUM(CASE WHEN product_key IS NULL THEN 1 ELSE 0 END) AS null_product_key,
    SUM(CASE WHEN customer_key IS NULL THEN 1 ELSE 0 END) AS null_customer_key,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN sales_amount IS NULL THEN 1 ELSE 0 END) AS null_sales_amount,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price
FROM gold.fact_sales;




-- Check sales calculation consistency
SELECT *
FROM gold.fact_sales
WHERE sales_amount != quantity * price;

-- Data Quality Observation:
-- No inconsistencies found.
-- Sales amount is consistent with quantity * price across all records.




-- Check invalid numerical values
SELECT *
FROM gold.fact_sales
WHERE sales_amount <= 0
   OR quantity <= 0
   OR price <= 0;




-- Check invalid date sequence
SELECT *
FROM gold.fact_sales
WHERE shipping_date < order_date
   OR due_date < order_date;


/*
===============================================================================
DATA QUALITY OBSERVATIONS
===============================================================================

- No critical NULL values found in the fact_sales view.
- Sales amount is consistent with quantity * price across all records.
- No zero or negative values found in sales_amount, quantity, or price.
- No invalid date sequences found.
- The fact_sales view is ready for exploratory data analysis.
===============================================================================
*/

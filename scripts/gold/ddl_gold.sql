/* 
====================================================================================================
DDL Script : Create Gold Views
====================================================================================================\
Script Purpose:
  This script  creates views for the gold layer in the data warehouse. 
  The gold layer represent the final dimension and facts tables (Star Schema)

  Each view performs transformation and combines data from the silver layer to
  produce a clean , and business - ready dataset.

Usage:
  - These views can be qieried directly for abalytics and reporting.
====================================================================================================
*/

====================================================================================================
-- Create Dimension : gold.dim_customers
====================================================================================================
IF OBJECT_ID('gold.dim_customer','V') IS NOT NULL
  DROP VIEW gold.dim_customer;
CREATE VIEW gold.dim_customers AS 
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- crm_cust_info is the master table 
		ELSE COALESCE(ca.gen,'n/a') 
	END AS gender, 
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date

FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON        ci.cst_key = ca.cid 
LEFT JOIN silver.erp_loc_a101 la
ON        ci.cst_key = la.cid;

====================================================================================================
-- Create Dimension : gold.dim_products 
====================================================================================================
IF OBJECT_ID('gold.dim_products','V') IS NOT NULL
  DROP VIEW gold.dim_products;
CREATE VIEW gold.dim_products AS 
SELECT 
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcatogery,
	pc.maintenance,
	pn.prd_cost AS product_cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
	
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON        pn.cat_id = pc.id
WHERE prd_end_dt IS NULL -- Filter out all historical data ;

====================================================================================================
-- Create fact table : gold.fact_sales
====================================================================================================
IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
  DROP VIEW gold.fact_sales;
CREATE VIEW gold.fact_sales as
SELECT
  sd.sls_ord_num as order_number,
  pr.product_key,
  cu.customer_key,
  sd.sls_order_dt as order_date,
  sd.sls_ship_dt as shipping_date,
  sd.sls_due_dt as due_date,
  sd.sls_sales as sales_amount,
  sd.sls_quantity as quantity,
  sd.sls_price as price
FROM silver.crm_sales_details sd 
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id;



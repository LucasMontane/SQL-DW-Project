/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================

*/



-----------------------------------------------------------------------------
-- CREATING CUSTOMERS DIMENTION
-----------------------------------------------------------------------------
DROP VIEW IF EXISTS gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cst_id) as customer_key
    ,ci.cst_id                          as customer_id
    ,ci.cst_key                         as customer_number
    ,ci.cst_firstname                   as first_name
    ,ci.cst_lastname                    as last_name
    ,la.CNTRY                           as country
    ,ci.cst_marital_status              as marital_status
    ,CASE 
        WHEN ci.cst_gndr <> 'Unknown' THEN ci.cst_gndr --CRM is the Master for Gender Info
        ELSE COALESCE(ca.GEN,'Unknown')
     END as gender
    ,ca.BDATE                           as birth_date
    ,ci.cst_create_date                 as create_date
from silver.crm_cust_info ci
LEFT JOIN silver.erp_CUST_AZ12 ca ON ca.CID = ci.cst_key
LEFT JOIN silver.erp_LOC_A101 la on la.CID=ci.cst_key

GO

-----------------------------------------------------------------------------
-- CREATING PRODUCTS DIMENTION
-----------------------------------------------------------------------------

DROP VIEW IF EXISTS gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
ROW_NUMBER() OVER (order by pi.prd_start_dt, pi.prd_key) as product_key,

pi.prd_id as product_id, 
pi.prd_key as product_number,  
pi.prd_nm as product_name ,

pi.cat_id as category_id,
pc.CAT as category,
pc.SUBCAT as subcategory,
pc.maintenance,

pi.prd_cost as cost,
pi.prd_line as product_line,
pi.prd_start_dt as start_date

FROM silver.crm_prd_info pi
LEFT JOIN silver.erp_PX_CAT_G1V2 pc on pi.cat_id=pc.ID
where pi.prd_end_dt is NULL --No historic data of Products, only the current value 

GO

-----------------------------------------------------------------------------
-- CREATING Sales FACT
-----------------------------------------------------------------------------
DROP VIEW IF EXISTS gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS
select 
sd.sls_ord_num as order_number
,dp.product_key
,dc.customer_key

,sd.sls_order_dt as order_date
,sd.sls_ship_dt as shiping_date
,sd.sls_due_dt as due_date

,sd.sls_quantity as quantity
,sd.sls_price as price
,sd.sls_sales as sales_amount

from silver.crm_sales_details sd
LEFT JOIN gold.dim_products dp on dp.product_number = sd.sls_prd_key
LEFT JOIN gold.dim_customers dc on dc.customer_id=sd.sls_cust_id
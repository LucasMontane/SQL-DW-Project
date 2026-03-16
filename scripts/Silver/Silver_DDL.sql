
/*
DDL Script: Create Silver Tables

Purpose:
    This script creates the tables in the silver schema, droping existing tables.
    Run this script to re-define the DDL structure of the silver Tables

*/


USE DataWarehouse

-------------------------------------------
-- CRM System Tables
-------------------------------------------
DROP TABLE IF EXISTS silver.crm_cust_info
CREATE TABLE silver.crm_cust_info(
    cst_id             INT,
    cst_key            NVARCHAR(50),
    cst_firstname      NVARCHAR(50),
    cst_lastname       NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr           NVARCHAR(50),
    cst_create_date    DATE,
    dwh_create_date    DATETIME2 DEFAULT GETDATE()

)

DROP TABLE IF EXISTS silver.crm_prd_info
CREATE TABLE silver.crm_prd_info(
    prd_id          INT,
    cat_id          NVARCHAR(50),
    prd_key         NVARCHAR(50),    
    prd_nm          NVARCHAR(50),
    prd_cost        INT,
    prd_line        NVARCHAR(50),
    prd_start_dt    DATE,
    prd_end_dt      DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
    
)

DROP TABLE IF EXISTS silver.crm_sales_details
CREATE TABLE silver.crm_sales_details(
    sls_ord_num     NVARCHAR(50),
    sls_prd_key     NVARCHAR(50),
    sls_cust_id     INT,
    sls_order_dt    DATE,
    sls_ship_dt     DATE,
    sls_due_dt      DATE,
    sls_sales       INT,
    sls_quantity    INT,
    sls_price       INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
)


-------------------------------------------
-- ERP System Tables
-------------------------------------------
DROP TABLE IF EXISTS silver.erp_CUST_AZ12
CREATE TABLE silver.erp_CUST_AZ12(

    CID             NVARCHAR(50),
    BDATE           DATE,
    GEN             NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
)

DROP TABLE IF EXISTS silver.erp_LOC_A101
CREATE TABLE silver.erp_LOC_A101(

    CID             NVARCHAR(50),
    CNTRY           NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
)

DROP TABLE IF EXISTS silver.erp_PX_CAT_G1V2
CREATE TABLE silver.erp_PX_CAT_G1V2(

    ID              NVARCHAR(50),
    CAT             NVARCHAR(50),
    SUBCAT          NVARCHAR(50),
    MAINTENANCE     NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
)
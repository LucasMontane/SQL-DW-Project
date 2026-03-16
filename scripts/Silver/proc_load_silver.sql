/*
Stored Procedure: Load Silver Layer (Bronze --> Silver)

Purpose:
    This SP perfomrs ETL process to load data into the 'silver' schema from 'bronze' schema tables.
        -First it truncastes the target tables
        -Transforms and cleans the data from Bronze into the Silver Tables

Parameters:
    None.
    This SP does not take any parameters nor it returns any value

Usage: 
    EXCEC silver.load_silver;

*/



CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME2, @end_time DATETIME2, @batch_start_time DATETIME2, @batch_end_time DATETIME2;
    BEGIN TRY
        PRINT '==========================================='
        PRINT 'LOADING SILVER LAYER'
        PRINT '==========================================='
        SET @batch_start_time= GETDATE()
        PRINT 'START TIME: ' + CAST(@batch_start_time as NVARCHAR)

        PRINT '-------------------------------------------'
        PRINT 'Loading CRM Tables'
        PRINT '-------------------------------------------'
        ------------------------------------------------------------
        -- bronze.crm_cust_info --> silver.crm_cust_info
        ------------------------------------------------------------
   
        PRINT '>> Loading silver.crm_cust_info '
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.crm_cust_info;

        WITH latest_ranked_customers as(
        SELECT 
            [cst_id],
            [cst_key],
            [cst_firstname],
            [cst_lastname],
            [cst_marital_status],
            [cst_gndr],
            [cst_create_date],
            ROW_NUMBER() over (PARTITION BY cst_id ORDER BY cst_create_date DESC) as latest_rank
        from bronze.crm_cust_info
        where cst_id is NOT NULL
        )

        INSERT INTO silver.crm_cust_info
        (
            [cst_id],
            [cst_key],
            [cst_firstname],
            [cst_lastname],
            [cst_marital_status],
            [cst_gndr],
            [cst_create_date]
        )
        select
            [cst_id],
            [cst_key],
            TRIM([cst_firstname]) as cst_firstname,
            TRIM([cst_lastname]) as cst_lastname,
            CASE UPPER(TRIM([cst_marital_status])) 
                WHEN 'M' THEN 'Married'
                WHEN 'S' THEN 'Single'
                ELSE 'Unknown' 
            END as cst_marital_status,
            CASE UPPER(TRIM([cst_gndr]))
                WHEN 'M' THEN 'Male'
                WHEN 'F' THEN 'Female'
                ELSE 'Unkown'
            END as cst_gndr,
            [cst_create_date]
        from latest_ranked_customers where latest_rank=1;
        SET @end_time = GETDATE()
        PRINT '>> Total Load time: ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR) + ' miliseconds'
        PRINT '-------------------------------------------'

        ------------------------------------------------------------
        -- bronze.crm_prd_info --> silver.crm_prd_info
        ------------------------------------------------------------
        PRINT '>> Loading silver.crm_prd_info'
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.crm_prd_info
        INSERT INTO silver.crm_prd_info
        (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT 
        [prd_id],
        REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id, --Deriving Product Category
        RIGHT(prd_key,LEN(prd_key)-6) as prd_key, --Derived Clean Product Key
        [prd_nm],
        ISNULL([prd_cost], 0) as prd_cost,
        CASE UPPER(TRIM(prd_line))
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            WHEN 'S' THEN 'Other Sales'
            WHEN 'T' THEN 'Touring'
            ELSE 'Unkown'
        END as prd_line,
        CAST([prd_start_dt]AS DATE) as prd_start_dt,
        CAST(LEAD(prd_start_dt,1,NULL) OVER (PARTITION BY prd_key ORDER BY prd_start_dt ASC) -1 AS DATE)  as prd_end_dt
        FROM [bronze].[crm_prd_info] 

        SET @end_time = GETDATE()
        PRINT '>> Total Load time: ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR) + ' miliseconds'
        PRINT '-------------------------------------------'

        /*

        select * from silver.crm_prd_info

        select * from [bronze].[crm_prd_info] where prd_cost<0 or prd_cost is null
        select * from bronze.crm_prd_info 
        select prd_key,
                COUNT(*) as count_id
            from bronze.crm_prd_info
            GROUP BY prd_key
            HAVING COUNT(*)>1 or prd_key IS NULL
        */


        ------------------------------------------------------------
        -- bronze.crm_sales_details--> silver.crm_sales_details
        ------------------------------------------------------------
        PRINT '>> Loading silver.crm_sales_details'
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.crm_sales_details
        INSERT INTO silver.crm_sales_details(
            sls_ord_num,
            sls_prd_key,
            sls_cust_id ,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            [sls_ord_num]
            ,[sls_prd_key]
            ,[sls_cust_id]

            ,CASE WHEN LEN([sls_order_dt])!=8 or [sls_order_dt]<=0 THEN NULL
                ELSE CONVERT(DATE, CAST( [sls_order_dt] AS VARCHAR(8)), 112)
            END as sls_order_dt

            ,CASE WHEN LEN([sls_ship_dt])!=8 or [sls_ship_dt]<=0 THEN NULL
                ELSE CONVERT(DATE, CAST( [sls_ship_dt] AS VARCHAR(8)), 112)
            END as sls_ship_dt

            ,CASE WHEN LEN([sls_due_dt])!=8 or [sls_due_dt]<=0 THEN NULL
                ELSE CONVERT(DATE, CAST( [sls_due_dt] AS VARCHAR(8)), 112)
            END as sls_due_dt

            ,CASE WHEN sls_sales IS NULL OR sls_sales<=0 or sls_sales != sls_quantity*ABS(sls_price)
                THEN sls_quantity*ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales

            ,CASE WHEN sls_quantity IS NULL THEN 0
                ELSE ABS(sls_quantity)
            END AS sls_quantity    
        
            ,CASE WHEN sls_price IS NULL or sls_price<=0 THEN sls_sales/NULLIF(sls_quantity,0)
                ELSE ABS(sls_price)
            END AS sls_price
        from bronze.crm_sales_details

        SET @end_time = GETDATE()
        PRINT '>> Total Load time: ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR) + ' miliseconds'
        PRINT '-------------------------------------------'

        /*
        select * from silver.crm_sales_details

        */
        PRINT '-------------------------------------------'
        PRINT 'Loading ERP Tables'
        PRINT '-------------------------------------------'
        ------------------------------------------------------------
        -- bronze.erp_cust_AZ12 --> silver.erp_cust_AZ12
        ------------------------------------------------------------
        PRINT '>> Loading silver.erp_CUST_AZ12'
        SET @start_time = GETDATE()
        TRUNCATE TABLE silver.erp_CUST_AZ12
        INSERT INTO silver.erp_CUST_AZ12
        (
            CID,
            BDATE,
            GEN
        )
        SELECT
            CASE WHEN CID LIKE 'NAS%' THEN RIGHT(CID,LEN(CID)-3)
                ELSE CID
            END as CID

            ,CASE WHEN BDATE > GETDATE() THEN NULL
                ELSE BDATE
            END as BDATE

            ,CASE LOWER(TRIM([GEN])) 
                WHEN 'm' then 'Male'
                WHEN 'male' then 'Male'
                WHEN 'female' then 'Female'
                WHEN 'f' then 'Female'
                ELSE 'Unkown'
            END AS GEN 

        FROM bronze.erp_CUST_AZ12

        SET @end_time = GETDATE()
        PRINT '>> Total Load time: ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR) + ' miliseconds'
        PRINT '-------------------------------------------'

        /*
        select * from silver.erp_CUST_AZ12
        */

        ------------------------------------------------------------
        -- bronze.erp_LOC_A101 --> silver.erp_LOC_A101
        ------------------------------------------------------------
        PRINT '>> Loading silver.erp_LOC_A101'
        SET @start_time = GETDATE()

        TRUNCATE TABLE silver.erp_LOC_A101
        INSERT INTO silver.erp_LOC_A101
        (
            CID,
            CNTRY
        )
        select 
            REPLACE(CID,'-','') as CID

            ,CASE WHEN UPPER(TRIM(CNTRY)) IS NULL or CNTRY = '' THEN 'Unkown'
                WHEN UPPER(TRIM(CNTRY)) IN ('USA','US','UNITED STATES') THEN 'United States'
                WHEN UPPER(TRIM(CNTRY)) IN ('DE','GERMANY') THEN 'Germany'
                ELSE TRIM(CNTRY)
            END AS CNTRY

        from bronze.erp_LOC_A101

        SET @end_time = GETDATE()
        PRINT '>> Total Load time: ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR) + ' miliseconds'
        PRINT '-------------------------------------------'

        /*
        select * from silver.erp_LOC_A101
        */

        ------------------------------------------------------------
        -- bronze.erp_PX_CAT_G1V2 --> silver.erp_PX_CAT_G1V2
        ------------------------------------------------------------
        PRINT '>> Loading silver.erp_PX_CAT_G1V2'
        SET @start_time = GETDATE()

        TRUNCATE TABLE silver.erp_PX_CAT_G1V2
        INSERT INTO silver.erp_PX_CAT_G1V2
        (
            ID,
            CAT,
            SUBCAT,
            MAINTENANCE
        )
        select 
            ID
            ,TRIM(CAT) as CAT
            ,TRIM(SUBCAT) as SUBCAT
            ,TRIM(MAINTENANCE) as MAINTENANCE
        from bronze.erp_PX_CAT_G1V2

        SET @end_time = GETDATE()
        PRINT '>> Total Load time: ' + CAST(DATEDIFF(MILLISECOND,@start_time,@end_time) AS NVARCHAR) + ' miliseconds'
        PRINT '-------------------------------------------'

        SET @batch_end_time= GETDATE()
        PRINT '==========================================='
        PRINT 'Load completed, Total Excecution time: ' + CAST(DATEDIFF(millisecond,@batch_start_time,@batch_end_time) AS NVARCHAR)  + ' miliseconds'
        PRINT '==========================================='

    END TRY
    BEGIN CATCH
        PRINT '================================'
        PRINT 'ERROR While Loading Silver Layer'
        PRINT 'Error: ' + CAST(ERROR_NUMBER() as NVARCHAR);
        PRINT 'Message: ' + ERROR_MESSAGE();
        PRINT '================================'
    END CATCH
END
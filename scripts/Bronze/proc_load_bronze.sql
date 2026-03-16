/*
Stored Procedure: Load Bronze Layer (Source --> Bronze)

Purpose:
    This SP loads data into the 'bronze' schema from external CSV files.
        -First it truncastes the target tables
        -Then uses BULK INSEERT to load data from the CSV files into the bronze tables

Parameters:
    None.
    This SP does not take any parameters nor it returns any value

Usage: 
    EXCEC bronze.load_bronze;

*/





--exec bronze.load_bronze;

CREATE OR ALTER PROCEDURE bronze.load_bronze AS

BEGIN
    DECLARE @start_time DATETIME2, @end_time DATETIME2, @batch_start_time DATETIME2, @batch_end_time DATETIME2;
    BEGIN TRY
        
        PRINT '==========================================='
        PRINT 'LOADING BRONZE LAYER'
        PRINT '==========================================='
        ---------------------------------------------------------------------------------
        -- CRM SYSTEM TABLES
        ---------------------------------------------------------------------------------
        PRINT '-------------------------------------------'
        PRINT 'Loading CRM Tables'
        PRINT '-------------------------------------------'
        SET @batch_start_time= GETDATE()
        PRINT '>> Loading bronze.crm_cust_info '
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_cust_info
        BULK INSERT bronze.crm_cust_info
        FROM '/datasets/source_crm/cust_info.csv'
        WITH (
            FIRSTROW=2,
            FIELDTERMINATOR= ',',
            ROWTERMINATOR= '\r\n',
            TABLOCK
        )
        SET @end_time = GETDATE();
        PRINT '>> Total Load time: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
        PRINT '-------------------------------------------'
        -- select * from bronze.crm_cust_info
        --select COUNT(*) from bronze.crm_cust_info


        PRINT '>> Loading bronze.crm_prd_info'
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_prd_info
        BULK INSERT bronze.crm_prd_info
        FROM '/datasets/source_crm/prd_info.csv'
        WITH (
            FIRSTROW=2,
            FIELDTERMINATOR= ',',
            ROWTERMINATOR= '\r\n',
            TABLOCK
        )
        SET @end_time = GETDATE();
        PRINT '>> Total Load time: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
        PRINT '-------------------------------------------'
        --select * from bronze.crm_prd_info
        --select COUNT(*) from bronze.crm_prd_info


        PRINT '>> Loading bronze.crm_sales_details'
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_sales_details
        BULK INSERT bronze.crm_sales_details
        FROM '/datasets/source_crm/sales_details.csv'
        WITH (
            FIRSTROW=2,
            FIELDTERMINATOR= ',',
            ROWTERMINATOR= '\r\n',
            TABLOCK
        )
        SET @end_time = GETDATE();
        PRINT '>> Total Load time: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
        PRINT '-------------------------------------------'
        --select * from bronze.crm_sales_details
        --select COUNT(*) from bronze.crm_sales_details

        ---------------------------------------------------------------------------------
        -- ERP SYSTEM TABLES
        ---------------------------------------------------------------------------------
        PRINT '-------------------------------------------'
        PRINT 'Loading ERP Tables'
        PRINT '-------------------------------------------'

        PRINT '>> Loading bronze.erp_CUST_AZ12'
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_CUST_AZ12
        BULK INSERT bronze.erp_CUST_AZ12
        FROM '/datasets/source_erp/CUST_AZ12.csv'
        WITH (
            FORMAT='CSV',
            FIRSTROW=2,
            FIELDTERMINATOR= ',',
            ROWTERMINATOR= '\r\n',
            TABLOCK
        )
        SET @end_time = GETDATE();
        PRINT '>> Total Load time: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
        PRINT '-------------------------------------------'
        -- select * from bronze.erp_CUST_AZ12
        -- select COUNT(*) from bronze.erp_CUST_AZ12

        PRINT '>> Loading bronze.erp_LOC_A101'
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_LOC_A101
        BULK INSERT bronze.erp_LOC_A101
        FROM '/datasets/source_erp/LOC_A101.csv'
        WITH (
            FIRSTROW=2,
            FIELDTERMINATOR= ',',
            ROWTERMINATOR= '\r\n',
            TABLOCK
        )
        SET @end_time = GETDATE();
        PRINT '>> Total Load time: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
        PRINT '-------------------------------------------'
        -- select * from bronze.erp_LOC_A101
        -- select COUNT(*) from bronze.erp_LOC_A101

        PRINT '>> Loading bronze.erp_PX_CAT_G1V2'
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_PX_CAT_G1V2
        BULK INSERT bronze.erp_PX_CAT_G1V2
        FROM '/datasets/source_erp/PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW=2,
            FIELDTERMINATOR= ',',
            ROWTERMINATOR= '\r\n',
            TABLOCK
        )
        SET @end_time = GETDATE();
        PRINT '>> Total Load time: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
        PRINT '-------------------------------------------'
        -- select * from bronze.erp_PX_CAT_G1V2
        -- select COUNT(*) from bronze.erp_PX_CAT_G1V2
        SET @batch_end_time= GETDATE()
        PRINT '==========================================='
        PRINT 'Load completed, Total Excecution time: ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR) 
        PRINT '==========================================='
    END TRY
    BEGIN CATCH
        PRINT '================================'
        PRINT 'ERROR While Loading Bonze Layer'
        PRINT 'Error: ' + CAST(ERROR_NUMBER() as NVARCHAR);
        PRINT 'Message: ' + ERROR_MESSAGE();
        PRINT '================================'
    END CATCH
END

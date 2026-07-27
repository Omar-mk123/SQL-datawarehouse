USE DATAWAREHOUSE;
GO




CREATE or ALTER PROCEDURE bronze.load_bronze AS 
BEGIN

DECLARE @start_time DATETIME , @end_time DATETIME , @batchstart_time DATETIME , @batchend_time DATETIME 


BEGIN TRY 
SET @batchstart_time = GETDATE();
PRINT '================================================================='
PRINT ' LOADING TIME FOR BRONZE LAYER '
PRINT '================================================================='
print'=========================='
print'loading the bronze layer'
print'=========================='


print'---------------------------'
print'loading the CRM tables'
print'---------------------------'

SET @start_time=GETDATE();
print'truncate'
truncate table bronze.crm_cust_info ;

print'insert element'
BULK INSERT bronze.crm_cust_info 
FROM 'C:\Users\Is Laptop\Desktop\DATA WAREHOUSE\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
with (
    firstrow = 2 , 
    fieldterminator = ',', 
    tablock 
);
SET @end_time=GETDATE();

PRINT'>>LOAD DURATION ' +CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR)+ 'SECOND' ;
PRINT '---------------------------------------'

SET @start_time=GETDATE();
print'truncate'
truncate table BRONZE.crm_sales_details ;

print'insert element'
BULK INSERT BRONZE.crm_sales_details
FROM 'C:\Users\Is Laptop\Desktop\DATA WAREHOUSE\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
with (
    firstrow = 2 , 
    fieldterminator = ',', 
    tablock 
);
SET @end_time=GETDATE();
PRINT'>>LOAD DURATION ' +CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR)+ 'SECOND' ;
PRINT '---------------------------------------'

SET @start_time=GETDATE();
print'truncate'
truncate table BRONZE.crm_prd_info;

print'insert element'
BULK INSERT BRONZE.crm_prd_info
FROM 'C:\Users\Is Laptop\Desktop\DATA WAREHOUSE\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
with (
    firstrow = 2 , 
    fieldterminator = ',', 
    tablock 
);
SET @end_time=GETDATE();
PRINT'>>LOAD DURATION ' +CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR)+ 'SECOND' ;
PRINT '---------------------------------------'

print'---------------------------'
print'loading the ERP tables'
print'---------------------------'

SET @start_time=GETDATE();
print'truncate'
truncate table BRONZE.erp_loc_a101 ;

print'insert element'
BULK INSERT BRONZE.erp_loc_a101
FROM 'C:\Users\Is Laptop\Desktop\DATA WAREHOUSE\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
with (
    firstrow = 2 , 
    fieldterminator = ',', 
    tablock 
);
SET @end_time=GETDATE();

PRINT'>>LOAD DURATION ' +CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR)+ 'SECOND' ;
PRINT '---------------------------------------'

SET @start_time=GETDATE();
print'truncate'
truncate table BRONZE.erp_cust_az12 ;

print'insert element'
BULK INSERT BRONZE.erp_cust_az12
FROM 'C:\Users\Is Laptop\Desktop\DATA WAREHOUSE\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
with (
    firstrow = 2 , 
    fieldterminator = ',', 
    tablock 
);
SET @end_time=GETDATE();

PRINT'>>LOAD DURATION ' +CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR)+ 'SECOND' ;
PRINT '---------------------------------------'

SET @start_time=GETDATE();
print'truncate'
truncate table BRONZE.erp_px_cat_g1v2 ;

print'insert element'
BULK INSERT BRONZE.erp_px_cat_g1v2 
FROM 'C:\Users\Is Laptop\Desktop\DATA WAREHOUSE\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
with (
    firstrow = 2 , 
    fieldterminator = ',', 
    tablock 
);
SET @end_time=GETDATE();

PRINT'>>LOAD DURATION ' +CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR)+ 'SECOND' ;
PRINT '---------------------------------------'


SET @batchend_time= GETDATE();
PRINT '================================================================='
PRINT ' LOADING TIME FOR BRONZE LAYER COMPLETED '
PRINT '>>LOAD DURATION ' +CAST(DATEDIFF(SECOND,@batchstart_time, @batchend_time) AS NVARCHAR)+ 'SECOND' ;
PRINT '================================================================='


END TRY 

BEGIN CATCH 
PRINT '========================='
PRINT ' LOADING OR HANDLE ERRORS'
PRINT'=========================='

END CATCH 

END
GO

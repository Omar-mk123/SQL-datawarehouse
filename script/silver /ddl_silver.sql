USE DataWarehouse;
GO

----------------------------------------------------------
-- Create Silver Schema
----------------------------------------------------------
IF NOT EXISTS (
    SELECT *
    FROM sys.schemas
    WHERE name = 'silver'
)
BEGIN
    EXEC('CREATE SCHEMA silver');
END
GO

----------------------------------------------------------
-- Drop Tables (Optional)
----------------------------------------------------------
DROP TABLE IF EXISTS silver.crm_sales_details;
DROP TABLE IF EXISTS silver.crm_prd_info;
DROP TABLE IF EXISTS silver.crm_cust_info;

DROP TABLE IF EXISTS silver.erp_cust_az12;
DROP TABLE IF EXISTS silver.erp_loc_a101;
DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
GO

----------------------------------------------------------
-- CRM CUSTOMER
----------------------------------------------------------
CREATE TABLE silver.crm_cust_info
(
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(20),
    cst_gndr NVARCHAR(20),
    cst_create_date DATE
);
GO

----------------------------------------------------------
-- CRM PRODUCT
----------------------------------------------------------
CREATE TABLE silver.crm_prd_info
(
    prd_id INT,
    cat_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(100),
    prd_cost DECIMAL(10,2),
    prd_line NVARCHAR(20),
    prd_start_dt DATE,
    prd_end_dt DATE
);
GO

----------------------------------------------------------
-- CRM SALES
----------------------------------------------------------
CREATE TABLE silver.crm_sales_details
(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales DECIMAL(18,2),
    sls_quantity INT,
    sls_price DECIMAL(18,2)
);
GO

----------------------------------------------------------
-- ERP CUSTOMER
----------------------------------------------------------
CREATE TABLE silver.erp_cust_az12
(
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(20)
);
GO

----------------------------------------------------------
-- ERP LOCATION
----------------------------------------------------------
CREATE TABLE silver.erp_loc_a101
(
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);
GO

----------------------------------------------------------
-- ERP PRODUCT CATEGORY
----------------------------------------------------------
CREATE TABLE silver.erp_px_cat_g1v2
(
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
);

USE DataWarehouse;
GO

----------------------------------------------------------
-- Drop Procedure (if exists)
----------------------------------------------------------
IF OBJECT_ID('silver.load_silver', 'P') IS NOT NULL
    DROP PROCEDURE silver.load_silver;
GO

----------------------------------------------------------
-- Create Procedure
----------------------------------------------------------
CREATE PROCEDURE silver.load_silver
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        DECLARE @StartTime DATETIME = GETDATE();

        PRINT '=============================================';
        PRINT 'Loading Silver Layer';
        PRINT 'Start Time : ' + CONVERT(VARCHAR, @StartTime, 120);
        PRINT '=============================================';

        --------------------------------------------------
        -- Truncate Silver Tables
        --------------------------------------------------
        PRINT '';
        PRINT 'Truncating Silver Tables...';

        TRUNCATE TABLE silver.crm_cust_info;
        TRUNCATE TABLE silver.crm_prd_info;
        TRUNCATE TABLE silver.crm_sales_details;

        TRUNCATE TABLE silver.erp_cust_az12;
        TRUNCATE TABLE silver.erp_loc_a101;
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT 'Silver Tables Truncated Successfully.';
        PRINT '';

        /**************************************************
            PART 3
            Load CRM Customer
        **************************************************/

        -- INSERT INTO silver.crm_cust_info
        -- SELECT ...
        -- FROM bronze.crm_cust_info;

        /**************************************************
            PART 4
            Load CRM Product
        **************************************************/

        -- INSERT INTO silver.crm_prd_info
        -- SELECT ...
        -- FROM bronze.crm_prd_info;

        /**************************************************
            PART 5
            Load CRM Sales
        **************************************************/

        -- INSERT INTO silver.crm_sales_details
        -- SELECT ...
        -- FROM bronze.crm_sales_details;

        /**************************************************
            PART 6
            Load ERP Customer
        **************************************************/

        -- INSERT INTO silver.erp_cust_az12
        -- SELECT ...
        -- FROM bronze.erp_cust_az12;

        /**************************************************
            PART 7
            Load ERP Location
        **************************************************/

        -- INSERT INTO silver.erp_loc_a101
        -- SELECT ...
        -- FROM bronze.erp_loc_a101;

        /**************************************************
            PART 8
            Load ERP Category
        **************************************************/

        -- INSERT INTO silver.erp_px_cat_g1v2
        -- SELECT ...
        -- FROM bronze.erp_px_cat_g1v2;

        --------------------------------------------------
        -- Finish
        --------------------------------------------------
        DECLARE @EndTime DATETIME = GETDATE();

        PRINT '';
        PRINT '=============================================';
        PRINT 'Silver Layer Loaded Successfully';
        PRINT 'End Time   : ' + CONVERT(VARCHAR, @EndTime, 120);
        PRINT '=============================================';

    END TRY

    BEGIN CATCH

        PRINT '';
        PRINT '=============================================';
        PRINT 'ERROR LOADING SILVER LAYER';
        PRINT '=============================================';

        PRINT ERROR_MESSAGE();

    END CATCH

END;
GO

          /**************************************************
            PART 3
            Load CRM Customer
        **************************************************/

        PRINT '---------------------------------------------';
        PRINT 'Loading CRM Customers';
        PRINT '---------------------------------------------';

        INSERT INTO silver.crm_cust_info
        (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )

        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,

            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'Unknown'
            END AS cst_marital_status,

            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'Unknown'
            END AS cst_gndr,

            cst_create_date

        FROM
        (
            SELECT *,
                   ROW_NUMBER() OVER
                   (
                       PARTITION BY cst_id
                       ORDER BY cst_create_date DESC
                   ) AS rn
            FROM bronze.crm_cust_info
        ) t

        WHERE rn = 1;

        PRINT 'CRM Customers Loaded.';
        PRINT '';

        /**************************************************
            PART 4
            Load CRM Product
        **************************************************/

        PRINT '---------------------------------------------';
        PRINT 'Loading CRM Products';
        PRINT '---------------------------------------------';

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
            prd_id,

            -- Extract Category ID
            REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,

            -- Product Key
            SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,

            -- Product Name
            TRIM(prd_nm) AS prd_nm,

            -- Product Cost
            ISNULL(prd_cost,0) AS prd_cost,

            -- Product Line
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'Unknown'
            END AS prd_line,

            -- Start Date
            prd_start_dt,

            -- End Date
            DATEADD
            (
                DAY,
                -1,
                LEAD(prd_start_dt)
                OVER
                (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt
                )
            ) AS prd_end_dt

        FROM bronze.crm_prd_info;

        PRINT 'CRM Products Loaded.';
        PRINT '';
GO

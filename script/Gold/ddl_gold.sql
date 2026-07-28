USE DataWarehouse;
GO

----------------------------------------------------------
-- Create Gold Schema
----------------------------------------------------------

IF NOT EXISTS (
    SELECT *
    FROM sys.schemas
    WHERE name = 'gold'
)
BEGIN
    EXEC('CREATE SCHEMA gold');
END
GO


----------------------------------------------------------
-- Drop Existing Gold Tables
----------------------------------------------------------

DROP TABLE IF EXISTS gold.fact_sales;
DROP TABLE IF EXISTS gold.dim_products;
DROP TABLE IF EXISTS gold.dim_customers;
GO


----------------------------------------------------------
-- Dimension Customer Table
----------------------------------------------------------

CREATE TABLE gold.dim_customers
(
    customer_key INT IDENTITY(1,1) PRIMARY KEY,

    customer_id INT,

    customer_number NVARCHAR(50),

    first_name NVARCHAR(50),

    last_name NVARCHAR(50),

    country NVARCHAR(50),

    marital_status NVARCHAR(50),

    gender NVARCHAR(50),

    birth_date DATE,

    create_date DATE
);
GO


----------------------------------------------------------
-- Dimension Product Table
----------------------------------------------------------

CREATE TABLE gold.dim_products
(
    product_key INT IDENTITY(1,1) PRIMARY KEY,

    product_id INT,

    product_number NVARCHAR(50),

    product_name NVARCHAR(100),

    category_id NVARCHAR(50),

    category NVARCHAR(50),

    subcategory NVARCHAR(50),

    maintenance NVARCHAR(50),

    cost DECIMAL(10,2),

    product_line NVARCHAR(50),

    start_date DATE,

    end_date DATE
);
GO


----------------------------------------------------------
-- Fact Sales Table
----------------------------------------------------------

CREATE TABLE gold.fact_sales
(
    order_number NVARCHAR(50),

    product_key INT,

    customer_key INT,

    order_date DATE,

    shipping_date DATE,

    due_date DATE,

    sales_amount DECIMAL(18,2),

    quantity INT,

    price DECIMAL(18,2)

);
GO

USE DataWarehouse;
GO


----------------------------------------------------------
-- Drop Procedure If Exists
----------------------------------------------------------

IF OBJECT_ID('gold.load_gold', 'P') IS NOT NULL
    DROP PROCEDURE gold.load_gold;
GO


----------------------------------------------------------
-- Create Gold Loading Procedure
----------------------------------------------------------

CREATE PROCEDURE gold.load_gold
AS
BEGIN

    SET NOCOUNT ON;


    BEGIN TRY


        DECLARE @StartTime DATETIME = GETDATE();


        PRINT '=============================================';
        PRINT 'Loading Gold Layer';
        PRINT 'Start Time: ' 
              + CONVERT(VARCHAR, @StartTime,120);
        PRINT '=============================================';



        --------------------------------------------------
        -- Clear Gold Tables
        --------------------------------------------------

        PRINT '';
        PRINT 'Truncating Gold Tables...';


        TRUNCATE TABLE gold.fact_sales;

        TRUNCATE TABLE gold.dim_products;

        TRUNCATE TABLE gold.dim_customers;


        PRINT 'Gold Tables Truncated Successfully.';
        PRINT '';



        /**************************************************
            PART 3
            Load Dimension Customers
        **************************************************/

        -- INSERT INTO gold.dim_customers
        -- SELECT ...



        /**************************************************
            PART 4
            Load Dimension Products
        **************************************************/

        -- INSERT INTO gold.dim_products
        -- SELECT ...



        /**************************************************
            PART 5
            Load Fact Sales
        **************************************************/

        -- INSERT INTO gold.fact_sales
        -- SELECT ...



        DECLARE @EndTime DATETIME = GETDATE();



        PRINT '';
        PRINT '=============================================';
        PRINT 'Gold Layer Loaded Successfully';
        PRINT 'End Time: '
              + CONVERT(VARCHAR, @EndTime,120);
        PRINT '=============================================';



    END TRY



    BEGIN CATCH


        PRINT '';
        PRINT '=============================================';
        PRINT 'ERROR LOADING GOLD LAYER';
        PRINT '=============================================';


        PRINT ERROR_MESSAGE();


    END CATCH


END;
GO

        /**************************************************
            PART 3
            Load Dimension Customers
        **************************************************/

        PRINT '---------------------------------------------';
        PRINT 'Loading Gold Customer Dimension';
        PRINT '---------------------------------------------';


        INSERT INTO gold.dim_customers
        (
            customer_id,
            customer_number,
            first_name,
            last_name,
            country,
            marital_status,
            gender,
            birth_date,
            create_date
        )


        SELECT

            c.cst_id AS customer_id,

            c.cst_key AS customer_number,

            c.cst_firstname AS first_name,

            c.cst_lastname AS last_name,


            ------------------------------------------------
            -- Country From ERP Location
            ------------------------------------------------
            ISNULL(
                l.cntry,
                'Unknown'
            ) AS country,


            ------------------------------------------------
            -- Marital Status
            ------------------------------------------------
            c.cst_marital_status AS marital_status,


            ------------------------------------------------
            -- Gender
            -- CRM has priority
            ------------------------------------------------
            CASE

                WHEN c.cst_gndr <> 'Unknown'
                    THEN c.cst_gndr

                WHEN e.gen IS NOT NULL
                    THEN e.gen

                ELSE 'Unknown'

            END AS gender,


            ------------------------------------------------
            -- Birth Date
            ------------------------------------------------
            e.bdate AS birth_date,


            ------------------------------------------------
            -- Customer Create Date
            ------------------------------------------------
            c.cst_create_date AS create_date


        FROM silver.crm_cust_info c


        LEFT JOIN silver.erp_cust_az12 e

            ON c.cst_key = e.cid


        LEFT JOIN silver.erp_loc_a101 l

            ON c.cst_key = l.cid;



        PRINT 'Gold Customer Dimension Loaded.';
        PRINT '';


        /**************************************************
            PART 4
            Load Dimension Products
        **************************************************/

        PRINT '---------------------------------------------';
        PRINT 'Loading Gold Product Dimension';
        PRINT '---------------------------------------------';


        INSERT INTO gold.dim_products
        (
            product_id,
            product_number,
            product_name,
            category_id,
            category,
            subcategory,
            maintenance,
            cost,
            product_line,
            start_date,
            end_date
        )


        SELECT

            p.prd_id AS product_id,


            ------------------------------------------------
            -- Product Number
            ------------------------------------------------
            p.prd_key AS product_number,


            ------------------------------------------------
            -- Product Name
            ------------------------------------------------
            p.prd_nm AS product_name,


            ------------------------------------------------
            -- Category ID
            ------------------------------------------------
            p.cat_id AS category_id,


            ------------------------------------------------
            -- Category
            ------------------------------------------------
            ISNULL(c.cat,'Unknown') AS category,


            ------------------------------------------------
            -- Sub Category
            ------------------------------------------------
            ISNULL(c.subcat,'Unknown') AS subcategory,


            ------------------------------------------------
            -- Maintenance
            ------------------------------------------------
            ISNULL(c.maintenance,'Unknown') AS maintenance,


            ------------------------------------------------
            -- Cost
            ------------------------------------------------
            p.prd_cost AS cost,


            ------------------------------------------------
            -- Product Line
            ------------------------------------------------
            p.prd_line AS product_line,


            ------------------------------------------------
            -- Dates
            ------------------------------------------------
            p.prd_start_dt AS start_date,

            p.prd_end_dt AS end_date



        FROM silver.crm_prd_info p


        LEFT JOIN silver.erp_px_cat_g1v2 c

            ON p.cat_id = c.id;



        PRINT 'Gold Product Dimension Loaded.';
        PRINT '';

        /**************************************************
            PART 5
            Load Fact Sales
        **************************************************/

        PRINT '---------------------------------------------';
        PRINT 'Loading Gold Fact Sales';
        PRINT '---------------------------------------------';


        INSERT INTO gold.fact_sales
        (
            order_number,
            product_key,
            customer_key,
            order_date,
            shipping_date,
            due_date,
            sales_amount,
            quantity,
            price
        )


        SELECT


            s.sls_ord_num AS order_number,


            ------------------------------------------------
            -- Product Surrogate Key
            ------------------------------------------------
            p.product_key,


            ------------------------------------------------
            -- Customer Surrogate Key
            ------------------------------------------------
            c.customer_key,


            ------------------------------------------------
            -- Dates
            ------------------------------------------------
            s.sls_order_dt AS order_date,

            s.sls_ship_dt AS shipping_date,

            s.sls_due_dt AS due_date,


            ------------------------------------------------
            -- Measures
            ------------------------------------------------
            s.sls_sales AS sales_amount,

            s.sls_quantity AS quantity,

            s.sls_price AS price



        FROM silver.crm_sales_details s



        LEFT JOIN gold.dim_products p

            ON s.sls_prd_key = p.product_number



        LEFT JOIN gold.dim_customers c

            ON s.sls_cust_id = c.customer_id;



        PRINT 'Gold Fact Sales Loaded.';
        PRINT '';


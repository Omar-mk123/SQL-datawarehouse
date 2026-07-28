        /**************************************************
            PART 5
            Load CRM Sales Details
        **************************************************/

        PRINT '---------------------------------------------';
        PRINT 'Loading CRM Sales Details';
        PRINT '---------------------------------------------';

        INSERT INTO silver.crm_sales_details
        (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )

        SELECT

            TRIM(sls_ord_num) AS sls_ord_num,

            TRIM(sls_prd_key) AS sls_prd_key,

            sls_cust_id,

            ------------------------------------------------
            -- Order Date
            ------------------------------------------------
            CASE
                WHEN sls_order_dt = 0 THEN NULL
                WHEN LEN(CAST(sls_order_dt AS VARCHAR(8))) <> 8 THEN NULL
                WHEN TRY_CONVERT(DATE, CAST(sls_order_dt AS VARCHAR(8)),112) IS NULL THEN NULL
                ELSE TRY_CONVERT(DATE, CAST(sls_order_dt AS VARCHAR(8)),112)
            END AS sls_order_dt,

            ------------------------------------------------
            -- Ship Date
            ------------------------------------------------
            CASE
                WHEN sls_ship_dt = 0 THEN NULL
                WHEN LEN(CAST(sls_ship_dt AS VARCHAR(8))) <> 8 THEN NULL
                WHEN TRY_CONVERT(DATE, CAST(sls_ship_dt AS VARCHAR(8)),112) IS NULL THEN NULL
                ELSE TRY_CONVERT(DATE, CAST(sls_ship_dt AS VARCHAR(8)),112)
            END AS sls_ship_dt,

            ------------------------------------------------
            -- Due Date
            ------------------------------------------------
            CASE
                WHEN sls_due_dt = 0 THEN NULL
                WHEN LEN(CAST(sls_due_dt AS VARCHAR(8))) <> 8 THEN NULL
                WHEN TRY_CONVERT(DATE, CAST(sls_due_dt AS VARCHAR(8)),112) IS NULL THEN NULL
                ELSE TRY_CONVERT(DATE, CAST(sls_due_dt AS VARCHAR(8)),112)
            END AS sls_due_dt,

            ------------------------------------------------
            -- Sales Amount
            ------------------------------------------------
            CASE
                WHEN sls_sales IS NULL
                     OR sls_sales <= 0
                THEN ABS(ISNULL(sls_quantity,0) * ISNULL(sls_price,0))
                ELSE sls_sales
            END AS sls_sales,

            ------------------------------------------------
            -- Quantity
            ------------------------------------------------
            CASE
                WHEN sls_quantity IS NULL
                     OR sls_quantity < 0
                THEN 0
                ELSE sls_quantity
            END AS sls_quantity,

            ------------------------------------------------
            -- Price
            ------------------------------------------------
            CASE
                WHEN sls_price IS NULL
                     OR sls_price <= 0
                THEN
                    CASE
                        WHEN ISNULL(sls_quantity,0) = 0 THEN 0
                        ELSE ABS(sls_sales) / sls_quantity
                    END
                ELSE sls_price
            END AS sls_price

        FROM bronze.crm_sales_details;

        PRINT 'CRM Sales Details Loaded.';
        PRINT '';

        /**************************************************
            PART 6
            Load ERP Customer
        **************************************************/

        PRINT '---------------------------------------------';
        PRINT 'Loading ERP Customers';
        PRINT '---------------------------------------------';

        INSERT INTO silver.erp_cust_az12
        (
            cid,
            bdate,
            gen
        )

        SELECT

            ------------------------------------------------
            -- Customer ID
            ------------------------------------------------
            CASE
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END AS cid,

            ------------------------------------------------
            -- Birth Date
            ------------------------------------------------
            CASE
                WHEN bdate > GETDATE() THEN NULL
                WHEN bdate < '1924-01-01' THEN NULL
                ELSE bdate
            END AS bdate,

            ------------------------------------------------
            -- Gender
            ------------------------------------------------
            CASE
                WHEN UPPER(TRIM(gen)) IN ('F','FEMALE')
                    THEN 'Female'

                WHEN UPPER(TRIM(gen)) IN ('M','MALE')
                    THEN 'Male'

                ELSE 'Unknown'
            END AS gen

        FROM bronze.erp_cust_az12;

        PRINT 'ERP Customers Loaded.';
        PRINT '';

        /**************************************************
            PART 7
            Load ERP Location
        **************************************************/

        PRINT '---------------------------------------------';
        PRINT 'Loading ERP Locations';
        PRINT '---------------------------------------------';

        INSERT INTO silver.erp_loc_a101
        (
            cid,
            cntry
        )

        SELECT

            ------------------------------------------------
            -- Customer ID
            ------------------------------------------------
            REPLACE(TRIM(cid), '-', '') AS cid,

            ------------------------------------------------
            -- Country
            ------------------------------------------------
            CASE

                WHEN TRIM(cntry) = 'DE'
                    THEN 'Germany'

                WHEN TRIM(cntry) IN ('US','USA')
                    THEN 'United States'

                WHEN TRIM(cntry) = ''
                    OR cntry IS NULL
                    THEN 'Unknown'

                ELSE TRIM(cntry)

            END AS cntry

        FROM bronze.erp_loc_a101;

        PRINT 'ERP Locations Loaded.';
        PRINT '';

        /**************************************************
            PART 8
            Load ERP Product Categories
        **************************************************/

        PRINT '---------------------------------------------';
        PRINT 'Loading ERP Product Categories';
        PRINT '---------------------------------------------';

        INSERT INTO silver.erp_px_cat_g1v2
        (
            id,
            cat,
            subcat,
            maintenance
        )

        SELECT

            ------------------------------------------------
            -- Category ID
            ------------------------------------------------
            TRIM(id) AS id,

            ------------------------------------------------
            -- Category
            ------------------------------------------------
            CASE
                WHEN cat IS NULL
                     OR TRIM(cat) = ''
                THEN 'Unknown'
                ELSE TRIM(cat)
            END AS cat,

            ------------------------------------------------
            -- Subcategory
            ------------------------------------------------
            CASE
                WHEN subcat IS NULL
                     OR TRIM(subcat) = ''
                THEN 'Unknown'
                ELSE TRIM(subcat)
            END AS subcat,

            ------------------------------------------------
            -- Maintenance
            ------------------------------------------------
            CASE
                WHEN maintenance IS NULL
                     OR TRIM(maintenance) = ''
                THEN 'Unknown'
                ELSE TRIM(maintenance)
            END AS maintenance

        FROM bronze.erp_px_cat_g1v2;

        PRINT 'ERP Product Categories Loaded.';
        PRINT '';

USE DataWarehouse;
GO


SELECT 'crm_cust_info' AS Table_Name,
       COUNT(*) AS Row_Count
FROM silver.crm_cust_info

UNION ALL

SELECT 'crm_prd_info',
       COUNT(*)
FROM silver.crm_prd_info

UNION ALL

SELECT 'crm_sales_details',
       COUNT(*)
FROM silver.crm_sales_details

UNION ALL

SELECT 'erp_cust_az12',
       COUNT(*)
FROM silver.erp_cust_az12

UNION ALL

SELECT 'erp_loc_a101',
       COUNT(*)
FROM silver.erp_loc_a101

UNION ALL

SELECT 'erp_px_cat_g1v2',
       COUNT(*)
FROM silver.erp_px_cat_g1v2; 

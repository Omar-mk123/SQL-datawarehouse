USE DataWarehouse;
GO


SELECT 
    'dim_customers' AS Table_Name,
    COUNT(*) AS Row_Count
FROM gold.dim_customers

UNION ALL

SELECT 
    'dim_products',
    COUNT(*)
FROM gold.dim_products

UNION ALL

SELECT 
    'fact_sales',
    COUNT(*)
FROM gold.fact_sales;

SELECT
    customer_id,
    COUNT(*) AS Total
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT *
FROM gold.dim_customers
WHERE customer_id IS NULL;

SELECT DISTINCT
    gender,
    country,
    marital_status
FROM gold.dim_customers;

SELECT
    product_id,
    COUNT(*) AS Total
FROM gold.dim_products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT *
FROM gold.dim_products
WHERE product_id IS NULL;



SELECT *
FROM gold.dim_products
WHERE cost < 0;

SELECT *
FROM gold.dim_products
WHERE start_date > end_date;

SELECT *
FROM gold.fact_sales
WHERE product_key IS NULL;

SELECT *
FROM gold.fact_sales
WHERE sales_amount < 0;

SELECT *
FROM gold.fact_sales
WHERE quantity < 0;

SELECT
    f.*
FROM gold.fact_sales f

LEFT JOIN gold.dim_customers c

ON f.customer_key = c.customer_key

WHERE c.customer_key IS NULL;

SELECT
    f.*
FROM gold.fact_sales f

LEFT JOIN gold.dim_products p

ON f.product_key = p.product_key

WHERE p.product_key IS NULL;

SELECT TOP 10

    c.first_name,
    c.last_name,

    SUM(f.sales_amount) AS Total_Sales

FROM gold.fact_sales f

JOIN gold.dim_customers c

ON f.customer_key = c.customer_key

GROUP BY
    c.first_name,
    c.last_name

ORDER BY Total_Sales DESC;

SELECT TOP 10

    p.product_name,

    SUM(f.sales_amount) AS Total_Sales

FROM gold.fact_sales f

JOIN gold.dim_products p

ON f.product_key = p.product_key

GROUP BY
    p.product_name

ORDER BY Total_Sales DESC;

SELECT

SUM(sales_amount) AS Total_Revenue

FROM gold.fact_sales;

SELECT

COUNT(DISTINCT order_number) AS Total_Orders

FROM gold.fact_sales;

SELECT

COUNT(*) AS Total_Products

FROM gold.dim_products;

SELECT

COUNT(*) AS Total_Products

FROM gold.dim_products;


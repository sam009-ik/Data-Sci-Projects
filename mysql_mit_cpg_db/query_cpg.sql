-- Homework 2
USE mit;

-- Products
SELECT * FROM products LIMIT 10;
describe products;
-- Confirm SKU is unique
SELECT constraint_name, column_name 
FROM information_schema.key_column_usage
WHERE table_name = 'products';

-- Alternatively check via count
SELECT COUNT(DISTINCT SKU_PK) FROM products group by SKU_PK; -- All should have a count of 1

-- DC table
SELECT * FROM distribution_centres;
SELECT constraint_name, column_name 
FROM information_schema.key_column_usage
WHERE table_name = 'distribution_centres';

-- Part D queries
-- Unique Product types
SELECT COUNT(DISTINCT ProductType)
FROM products;
SELECT DISTINCT(ProductType) FROM products;
-- There are 9 unique product type

--  Count of products in each productType
SELECT ProductType, SUM(SKU_PK) AS ProductCount
FROM products GROUP BY ProductType ORDER BY 2 DESC;

-- total revenue by storeID 
SELECT 
	Stores_Store_Fk AS StoreID,
    SUM(UnitSold * UnitPriceAvg) AS TotalRevenue
FROM transactions
GROUP BY 1 ORDER BY 2 DESC;

-- For single largest transaction
SELECT 
    Stores_Store_Fk AS StoreID, 
    Products_SKU_FK AS ProductID,
    UnitSold * UnitPriceAvg AS Revenue
FROM transactions
ORDER BY Revenue DESC
LIMIT 1;

-- More information about the store and product
SELECT 
    transactions.Stores_Store_Fk AS StoreID, 
    stores.StoreVolume,
    stores.Zone,
    transactions.Products_SKU_FK AS ProductID,
    products.ProductCategory,
    products.ProductType,
    products.RetailPrice,
    UnitSold * UnitPriceAvg AS Revenue
FROM transactions
JOIN stores ON transactions.Stores_Store_FK = stores.Store_PK
JOIN products ON transactions.Products_SKU_FK = products.SKU_PK
ORDER BY Revenue DESC
LIMIT 1;
 /*Aggregation vs. Single Record: 
 The first query aggregates data (sums up revenue) across multiple transactions for each
 store, 
 while the second query looks at each transaction individually 
 and finds the one with the highest revenue.*/
 
 -- Check that StoresServed in distribution_centres is correct
 -- check one: that only a single store is served by a DC
 SELECT 
	stores.Store_PK AS StoreID, 
    COUNT(distribution_centres.StoresServed) AS storesServed
FROM stores
JOIN distribution_centres ON stores.Distribution_Centres_DC_FK = distribution_centres.DC_PK
GROUP BY 1
HAVING  COUNT(distribution_centres.StoresServed) > 1;
-- The above query returns 0 rows which means a store is served by a single DC

-- Match stores served with actual stores served
UPDATE distribution_centres dc
JOIN (
    SELECT 
        Distribution_Centres_DC_FK, 
        COUNT(Store_PK) AS ActualStoresServed
    FROM stores
    GROUP BY Distribution_Centres_DC_FK
) AS store_counts
ON dc.DC_PK = store_counts.Distribution_Centres_DC_FK
SET dc.StoresServed = store_counts.ActualStoresServed;


SELECT
	distribution_centres.DC_PK AS DCid,
    distribution_centres.StoresServed AS ExpectedStoresServed,
    COUNT(stores.Store_PK) AS ActualStoresServed
FROM distribution_centres
JOIN stores ON distribution_centres.DC_PK = stores.Distribution_Centres_DC_FK
GROUP BY distribution_centres.DC_PK, ExpectedStoresServed;
-- The above query further validates that the stores served column is correct

-- 3 products with lowet retail price
SELECT * FROM products ORDER BY products.RetailPrice LIMIT 3;
/*# SKU_PK, ProductCategory, ProductType, PcntAlcohol, RetailPrice, Quantity
xri2, Snack, Nuts, , 5.01, 11
l3vb, Beer, Stout, 20.27, 5.05, 43
om2c, Snack, Nuts, , 5.09, 14
*/
-- Determine the total revenue for the 3 products with lowest retail price
SELECT 
    t.SalesDate_PK, 
    (t.UnitSold * t.UnitPriceAvg) AS TotalRevenue,
    lpp.SKU_PK,
    lpp.ProductCategory,
    lpp.ProductType,
    lpp.RetailPrice
FROM transactions t
JOIN (
    SELECT 
        SKU_PK, 
        ProductCategory,
        ProductType,
        RetailPrice
        -- Include the same additional columns here
    FROM products 
    ORDER BY RetailPrice 
    LIMIT 3
) AS lpp ON t.Products_SKU_FK = lpp.SKU_PK;

SELECT DISTINCT p.SKU_PK 
FROM transactions 
JOIN (
SELECT SKU_PK FROM products ORDER BY RetailPrice LIMIT 3
) AS p ON transactions.Products_SKU_FK = p.SKU_PK;
/*The absence of om2c in the second query's results indicates that, while om2c is one of the three products with the lowest retail price, there are no transactions recorded for it in the transactions table. Consequently, when you join the transactions table with the list of the three lowest-priced products, om2c does not appear in the final output because there are no matching rows in transactions.*/

-- List of all transactions related to ProductType: Ale
SELECT 
    p.SKU_PK AS pID,
    p.ProductCategory,
    p.ProductType,
    p.PcntAlcohol,
    t.SalesDate_PK,
    t.UnitSold,
    t.UnitPriceAvg,
    t.InvEndOfDay
FROM
    products p
        JOIN
    transactions t ON p.SKU_PK = t.Products_SKU_FK
WHERE
    p.ProductType = 'Ale';
-- Ale ttansactions where unit sold > 100
SELECT 
	p.SKU_PK AS pID,
    p.ProductCategory,
    p.ProductType,
    p.PcntAlcohol,
    t.SalesDate_PK,
    t.UnitSold,
    t.UnitPriceAvg,
    t.InvEndOfDay
FROM products p 
JOIN transactions t ON p.SKU_PK = t.Products_SKU_FK
WHERE p.ProductType = 'Ale' AND t.UnitSold > 100;
/*Return a list of the total number of each product type sold, further split by distribution
centers from where the product was shipped. Include the ServedByPlant information as
well.*/
SELECT 
    p.ProductType,
    dc.DC_PK,
    dc.ServedByPlant,
    SUM(t.UnitSold) AS ProductSoldInEachType
FROM
    products p
        JOIN
    transactions t ON p.SKU_PK = t.Products_SKU_FK
        JOIN
    stores ON t.Stores_Store_FK = stores.Store_PK
        JOIN
    distribution_centres dc ON stores.Distribution_Centres_DC_FK = dc.DC_PK
GROUP BY p.ProductType , dc.DC_PK , dc.ServedByPlant;

/*Return a list of the store locations (lat and lon) where I can buy something strong (Pcnt
Alcohol > 7.25). Return the product type as well as the percent alcohol. List each
combination of options only once.*/
SELECT 
	p.ProductType, 
    p.PcntAlcohol,
    p.RetailPrice,
    st.LatStore,
    st.LonStore
FROM products p 
JOIN transactions t ON p.SKU_PK = t.Products_SKU_FK
JOIN stores st ON t.Stores_Store_FK = st.Store_PK
WHERE p.PcntAlcohol IS NOT NULL AND p.PcntAlcohol > 7.25
GROUP BY p.ProductType, p.PcntAlcohol, p.RetailPrice, st.LatStore, st.LonStore;
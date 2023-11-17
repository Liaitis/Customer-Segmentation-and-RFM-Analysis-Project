-- DATA EXPLORATION --
-- Head of the DataFrame
SELECT * FROM marketing_campaign LIMIT 5;

-- Shape of the DataFrame
SELECT COUNT(*) AS num_rows
FROM marketing_campaign;

SELECT COUNT(*) AS num_columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'marketing_campaign';

-- Data Types
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'marketing_campaign';

-- Missing Values
SELECT *
FROM marketing_campaign
WHERE COALESCE(ID, Year_Birth, Education, Marital_Status, Income, Kidhome, Teenhome, Dt_Customer, Recency, Complain, MntWines, MntFruits, MntMeatProducts, MntFishProducts, MntSweetProducts, MntGoldProds, NumDealsPurchases, AcceptedCmp1, AcceptedCmp2, AcceptedCmp3, AcceptedCmp4, AcceptedCmp5, Response, NumWebPurchases, NumCatalogPurchases, NumStorePurchases, NumWebVisitsMonth
) IS NULL;

-- Duplicated Values
SELECT COUNT(*) AS Duplicated_Values
FROM marketing_campaign
GROUP BY 
  ID, 
  Year_Birth, 
  Education, 
  Marital_Status, 
  Income, 
  Kidhome, 
  Teenhome, 
  Dt_Customer, 
  Recency, 
  Complain, 
  MntWines, 
  MntFruits, 
  MntMeatProducts, 
  MntFishProducts, 
  MntSweetProducts, 
  MntGoldProds, 
  NumDealsPurchases, 
  AcceptedCmp1, 
  AcceptedCmp2, 
  AcceptedCmp3, 
  AcceptedCmp4, 
  AcceptedCmp5, 
  Response, 
  NumWebPurchases, 
  NumCatalogPurchases, 
  NumStorePurchases, 
  NumWebVisitsMonth
HAVING COUNT(*) > 1
LIMIT 0, 1000;

-- DATA CLEANING AND EXPLORATION --
Select * from marketing_campaign;
-- Rename specific columns using ALTER TABLE
ALTER TABLE marketing_campaign
CHANGE COLUMN MntWines Wines INT,
CHANGE COLUMN MntFruits Fruits INT,
CHANGE COLUMN MntMeatProducts Meat INT,
CHANGE COLUMN MntFishProducts Fish INT,
CHANGE COLUMN MntSweetProducts Sweets INT,
CHANGE COLUMN MntGoldProds Gold INT;
Select * from marketing_campaign;


-- Add the 'Frequency' and 'Monetary' columns
ALTER TABLE marketing_campaign
ADD COLUMN Frequency INT,
ADD COLUMN Monetary INT;

-- Update the values for the new columns based on your calculations
UPDATE marketing_campaign
SET Frequency = NumDealsPurchases + NumWebPurchases + NumCatalogPurchases + NumStorePurchases,
    Monetary = Wines + Fruits + Meat + Fish + Sweets + Gold;
Select * from marketing_campaign;

-- CREATING RFM DATA --
-- Create the 'rfm_data' table with 'ID' as the index
CREATE TABLE rfm_data AS
SELECT
    ID,
    Recency,
    NumDealsPurchases + NumWebPurchases + NumCatalogPurchases + NumStorePurchases AS Frequency,
    Wines + Fruits + Meat + Fish + Sweets + Gold AS Monetary
FROM marketing_campaign;

-- Add an index on the 'ID' column
ALTER TABLE rfm_data
ADD INDEX idx_ID (ID);

-- CALCULATING RFM SCORES --
-- Retrieve the data from the new table
SELECT * FROM rfm_data LIMIT 5;

SELECT
ID
,Recency
,Frequency
,Monetary
,NTILE(5) OVER(ORDER BY Recency DESC) AS Recency_Score
,NTILE(5) OVER(ORDER BY Frequency ASC) AS Frequency_Score
,NTILE(5) OVER(ORDER BY Monetary ASC) AS Monetary_Score
FROM
rfm_data
ORDER BY
ID

-- CREATING RFM VIEW --
-- DropView if exixted
DROP VIEW IF EXISTS RFM_View

CREATE VIEW RFM_View AS
WITH 
-- Calculate RFM Values
RFM_CALC AS (
    SELECT
        ID,
        Recency,
        NumDealsPurchases + NumWebPurchases + NumCatalogPurchases + NumStorePurchases AS Frequency,
        Wines + Fruits + Meat + Fish + Sweets + Gold AS Monetary
    FROM marketing_campaign
    GROUP BY ID  -- Assuming 'ID' is the correct column for grouping
),
-- Calculate RMF Scores
RFM_SCORES AS (
    SELECT
        ID,
        Recency,
        Frequency,
        Monetary,
        NTILE(5) OVER (ORDER BY Recency DESC) AS Recency_Score,
        NTILE(5) OVER (ORDER BY Frequency ASC) AS Frequency_Score,
        NTILE(5) OVER (ORDER BY Monetary ASC) AS Monetary_Score
    FROM RFM_CALC
),
-- Calculate Avg RFM Score
RFM_AVG_SCORE AS (
    SELECT
        ID,
        CONCAT_WS('-', Recency_Score, Frequency_Score, Monetary_Score) AS R_F_M,
        CAST((CAST(Recency_Score AS Float) + Frequency_Score + Monetary_Score) / 3 AS DECIMAL(16, 2)) AS Avg_RFM_Score
    FROM RFM_SCORES
)
SELECT
    T1.ID,
    Recency,
    Frequency,
    Monetary,
    Recency_Score,
    Frequency_Score,
    Monetary_Score,
    R_F_M,
    Avg_RFM_Score
FROM RFM_SCORES T1
JOIN RFM_AVG_SCORE T2 ON T1.ID = T2.ID;

SELECT * FROM RFM_View LIMIT 10; -- Returns the first 10 rows

-- CUSTOMER SEGMENTATION --
-- Drop View if already exists
DROP VIEW IF EXISTS Customer_Segmentaion;
---- Create a View for the Customer Segments & Value Segments using the View "RFM_View"
CREATE VIEW Customer_Segmentation AS
SELECT *,
  CASE
    WHEN Avg_RFM_Score >= 4 THEN 'High Value'
    WHEN Avg_RFM_Score >= 2.5 AND Avg_RFM_Score < 4 THEN 'Mid Value'
    WHEN Avg_RFM_Score > 0 AND Avg_RFM_Score < 2.5 THEN 'Low Value'
  END AS Value_Seg, -- Value Segment
  CASE
    WHEN Frequency_Score >= 4 AND Recency_Score >= 4 AND Monetary_Score >= 4 THEN 'VIP'
    WHEN Frequency_Score >= 3 AND Monetary_Score < 4 THEN 'Regular'
    WHEN Recency_Score <= 3 AND Recency_Score > 1 THEN 'Inactive'
    WHEN Recency_Score = 1 THEN 'Churned'
    WHEN Recency_Score >= 4 AND Frequency_Score <= 4 THEN 'New Customer'
  END AS Cust_Seg -- Customer Segment
FROM RFM_View;

SELECT * FROM Customer_Segmentation ORDER BY Avg_RFM_Score LIMIT 10;

-- ANALYZING CUSTOMER SEGMENTS --
SELECT
Value_Seg,
COUNT(ID) AS Customer_Count
FROM Customer_Segmentation
GROUP BY Value_Seg
ORDER BY Customer_Count

SELECT
Cust_Seg,
COUNT(ID) AS Customer_Count
FROM Customer_Segmentation
GROUP BY Cust_Seg
ORDER BY Customer_Count;

SELECT
Value_Seg,
Cust_Seg,
COUNT(ID) AS Customer_Count
FROM Customer_Segmentation
GROUP BY Cust_Seg,Value_Seg
ORDER BY Value_Seg,Customer_Count DESC;

-- Churned Customers are equally distributed among mid value & low value customers.
-- Dormant Customers are distributed across all the value segments, low value segment have the maximum dormant customers.
-- Regular Customers are also distributed across all the value segments but majorly the Mid Value segment.
-- New Customers are also distributed across all the value segments but majorly low value & mid value segment.
-- 55% of High Value segment customers are the VIP Customer


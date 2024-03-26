CREATE TABLE PropertySales (
    UniqueID int,
    ParcelID text,
    LandUse text,
    PropertyAddress text,
    SaleDate date,
    SalePrice numeric,
    LegalReference text,
    SoldAsVacant boolean,
    OwnerName text,
    OwnerAddress text,
    Acreage numeric,
    TaxDistrict text,
    LandValue numeric,
    BuildingValue numeric,
    TotalValue numeric,
    YearBuilt int,
    Bedrooms int,
    FullBath int,
    HalfBath int
);

/*

Cleaning Data in SQL Queries

*/


Select *
From propertysales

--------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address data

Select *
From propertysales
--Where PropertyAddress is null
order by ParcelID



SELECT 
    a.ParcelID AS ParcelID_a, 
    a.PropertyAddress AS PropertyAddress_a, 
    b.ParcelID AS ParcelID_b, 
    b.PropertyAddress AS PropertyAddress_b, 
    COALESCE(a.PropertyAddress, b.PropertyAddress) AS MergedPropertyAddress
FROM 
    propertysales a
JOIN 
    propertysales b
ON 
    a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE 
    a.PropertyAddress IS NULL;


UPDATE propertysales AS a
SET PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM propertysales AS b
WHERE a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
    AND a.PropertyAddress IS NULL;


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From propertysales
--Where PropertyAddress is null
--order by ParcelID

SELECT 
    SUBSTRING(PropertyAddress FROM 1 FOR POSITION(',' IN PropertyAddress) - 1) AS Address1,
    SUBSTRING(PropertyAddress FROM POSITION(',' IN PropertyAddress) + 1) AS Address2
FROM 
    propertysales;


-- Add the new column
ALTER TABLE propertysales
ADD COLUMN PropertySplitAddress varchar(255);

--Update the values in the new column
UPDATE propertysales
SET PropertySplitAddress = SUBSTRING(PropertyAddress FROM 1 FOR POSITION(',' IN PropertyAddress) - 1);



ALTER TABLE propertysales
Add PropertySplitCity varchar(255);

UPDATE propertysales
SET PropertySplitCity = SUBSTRING(PropertyAddress FROM POSITION(',' IN PropertyAddress) + 1);



Select *
From propertysales;





Select OwnerAddress
From propertysales;


SELECT 
    SPLIT_PART(REPLACE(OwnerAddress, ',', '.'), '.', 3) AS Address1,
    SPLIT_PART(REPLACE(OwnerAddress, ',', '.'), '.', 2) AS Address2,
    SPLIT_PART(REPLACE(OwnerAddress, ',', '.'), '.', 1) AS Address3
FROM 
    propertysales;




-- Step 1: Add columns to split the owner address
ALTER TABLE propertysales
ADD COLUMN OwnerSplitAddress varchar(255),
ADD COLUMN OwnerSplitCity varchar(255),
ADD COLUMN OwnerSplitState varchar(255);

-- Step 2: Update the newly added columns with parsed values
UPDATE propertysales
SET 
    OwnerSplitAddress = SPLIT_PART(REPLACE(OwnerAddress, ',', '.'), '.', 3),
    OwnerSplitCity = SPLIT_PART(REPLACE(OwnerAddress, ',', '.'), '.', 2),
    OwnerSplitState = SPLIT_PART(REPLACE(OwnerAddress, ',', '.'), '.', 1);



Select *
From propertysales;




--------------------------------------------------------------------------------------------------------------------------
--removing duplicates

WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM propertysales
)
DELETE FROM propertysales
WHERE UniqueID IN (
    SELECT UniqueID
    FROM RowNumCTE
    WHERE row_num > 1
);

-- you can select remaining records after removing duplicates
SELECT *
FROM propertysales;




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From propertysales


ALTER TABLE propertysales
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate














/*
Cleaning Data in SQL Queries
*/

-- Quick Overview
SELECT *
FROM [Porfolio Project]..NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM [Porfolio Project]..NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


---------------------------------------------------------------------------------------------------------------------------

-- Population Property Address

SELECT * 
FROM [Porfolio Project]..NashvilleHousing
WHERE PropertyAddress is NULL


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.propertyaddress)
FROM [Porfolio Project]..NashvilleHousing as a
JOIN [Porfolio Project]..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is NULL


UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM [Porfolio Project]..NashvilleHousing as a
JOIN [Porfolio Project]..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is NULL



---------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State) using SUBSTRING

SELECT PropertyAddress
FROM [Porfolio Project]..NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address  -- -1 to get rid of ','
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as City
FROM [Porfolio Project]..NashvilleHousing

-- Adding a column for just the Property Address aftering splitting it
ALTER TABLE NashvilleHousing
ADD PropertySpiltAddress VARCHAR(225);

UPDATE NashvilleHousing
SET PropertySpiltAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

-- Adding a column for just the Property City aftering splitting it
ALTER TABLE NashvilleHousing
ADD PropertySpiltCity VARCHAR(225);

UPDATE NashvilleHousing
SET PropertySpiltCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))



-- Seperating Owner Address into seperate columns using PARSENAME

SELECT OwnerAddress
FROM [Porfolio Project]..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Porfolio Project]..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSpiltAddress VARCHAR(225);

UPDATE NashvilleHousing
SET OwnerSpiltAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSpiltCity VARCHAR(225);

UPDATE NashvilleHousing
SET OwnerSpiltCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSpiltState VARCHAR(225);

UPDATE NashvilleHousing
SET OwnerSpiltState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

---------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" Column using CASE WHEN ...ELSE...END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldasVacant)
FROM [Porfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldasVacant, 
CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
	WHEN SoldasVacant = 'N' THEN 'No'
	ELSE SoldasVacant
	End
From [Porfolio Project]..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
	WHEN SoldasVacant = 'N' THEN 'No'
	ELSE SoldasVacant
	End



---------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicate using PARTITION BY and CTE

WITH RowNumCTE AS (								-- Using CTE to create a template
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,						-- If there are duplicates from all these variables, we will partition it
				PropertyAddress,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) as row_num					-- If row_num is greater than 1, that mean it's a duplicate
FROM [Porfolio Project]..NashvilleHousing
-- ORDER BY ParcelID
)

-- SELECT *
-- FROM RowNumCTE									-- Now we can use this CTE template to select the duplicate rows with our WHERE clause
-- WHERE row_num > 1
-- ORDER BY PropertyAddress



DELETE
FROM RowNumCTE									-- Now we are deleting these duplicate rows
WHERE row_num > 1



---------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns (Just practice, don't normally apply to our raw data)


ALTER TABLE [Porfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE [Porfolio Project]..NashvilleHousing
DROP COLUMN SaleDate

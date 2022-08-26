-- Data Cleaning using SQL


SELECT *
FROM PortfolioProject..NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------


-- 1. Formatting Date Column

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


---------------------------------------------------------------------------------------------------------------------------


-- 2. Clean the address column

-- find the null address rows and find its replacement

SELECT *
FROM PortfolioProject..NashvilleHousing
--where PropertyAddress is NULL
ORDER BY ParcelID


-- here we get a new column which we will replace it using update command in the next section

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


---------------------------------------------------------------------------------------------------------------------------


-- 3. Formatting address column values into individual ones using 'SUBSTRING function' (address, city, state)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) AS City -- '+2' to remove the space
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertyAddressUpdate nvarchar(255);

UPDATE NashvilleHousing
SET PropertyAddressUpdate = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertyAddressCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))


-- lets do the same thing but using 'PARSENAME function' for OwnerAddress

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerAddressUpdate nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerAddressCity nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerAddressState nvarchar(255);


UPDATE NashvilleHousing
SET OwnerAddressUpdate = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


---------------------------------------------------------------------------------------------------------------------------


-- 4. Clean the data from SoldAsVacant

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
				   END


---------------------------------------------------------------------------------------------------------------------------



-- 4. Removing Duplicate values (since we created new columns with standardized data)
-- we use CTE here as it was hard to find row_num > 1 by scrolling, hence we want to use the row_num in where

WITH RowNUM AS (
SELECT *,
	ROW_NUMBER()
		OVER(Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
--order by [UniqueID ]
)


DELETE		-- replace this line with 'select *' to see the result
FROM RowNUM
WHERE row_num > 1
-- order by PropertyAddress


---------------------------------------------------------------------------------------------------------------------------


-- 5. Cleaning unused columns

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress, TaxDistrict

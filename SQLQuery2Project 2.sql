
--CLEANING THE DATA IN SQL QUERIES:
--TEST:
SELECT *
FROM [Portfolio Project].dbo.NashvilleHousing

SELECT SaleDate,CONVERT(Date,SaleDate)
FROM [Portfolio Project].dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDataConverted Date;

UPDATE NashvilleHousing
SET SaleDataConverted = CONVERT(Date,SaleDate)
--TESTING NEW TABLE:
SELECT SaleDataConverted
FROM [Portfolio Project].dbo.NashvilleHousing

--POPULATE PROPERTY ADRESS DATA
--TRYING TO FIND OUT DATA QUALITY USING THE WHERE IS NULL FUNCTION AND 29 ROW has return.
SELECT *
FROM [Portfolio Project].dbo.NashvilleHousing
WHERE PropertyAddress is null


SELECT *
FROM [Portfolio Project].dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID
--I'D Join the two same table together to find out Null Property Adresses

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null

--AND UPDATE THE TABLE

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null

--TEST:
SELECT *
FROM [Portfolio Project].dbo.NashvilleHousing
WHERE PropertyAddress is null

SELECT PropertyAddress
FROM [Portfolio Project].dbo.NashvilleHousing
--WHERE PropertyAddress is null

--BREAKING OUT ADRESS INTO INDIVIDUAL COLUMNS(ADRESS,CITY,STATE) Using Delimited with SUBSTRING & CHARINDEX

SELECT
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) - 1 ) AS Adress,
 SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1  , LEN(PropertyAddress)) as Adress
FROM [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(225);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD  PropertySplitCity Nvarchar(225);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1  , LEN(PropertyAddress))

Select *
From [Portfolio Project].dbo.NashvilleHousing

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns from the project ALTER AND DROP USAGE



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
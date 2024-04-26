USE PortfolioProject
GO 

SELECT *
FROM NashvilleHousing

-------------------------------------------------------
--Standardize Date Format 

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-------------------------------------------------------

--Populate Property Address Data


SELECT a.ParcelID, a.PropertyAddress, 
b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL   

----------------------------------------------------------------------

--Breaking out Address Into Individual Colums (Address, City, State)


SELECT 
SUBSTRING(PropertyAddress, 1,
CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address

FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,
CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity  = SUBSTRING(PropertyAddress, 1,
CHARINDEX(',', PropertyAddress)-1)




SELECT 
PARSENAME (REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME (REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME (REPLACE(OwnerAddress, ',', '.'),1)
FROM NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSpliAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSpliAddress = PARSENAME
(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity  = PARSENAME
(REPLACE(OwnerAddress, ',', '.'),2)



ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState  = PARSENAME
(REPLACE(OwnerAddress, ',', '.'),1)

--------------------------------------------------------------

--Change y And N TO Yes And NO IN "Sold As Vacant" Field

--SELECT DISTINCT (SoldAsVacant), COUNT (SoldAsVacant)
--FROM NashvilleHousing
--GRoup BY SoldAsVacant
--Order BY 2 


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant= 'Y' THEN 'YES'
	WHEN SoldAsVacant= ' N' THEN 'NO'
	ELSE SoldAsVAcant 
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant= 'Y' THEN 'YES'
	WHEN SoldAsVacant= 'N' THEN 'NO'
	ELSE SoldAsVAcant 
END

--------------------------------------------------------

--Remove Duplicate

WITH RowNumCTE AS ( 
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID
) row_num

FROM NashvilleHousing

)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


------------------------------------------------------------------------------------

--Delete Unused Colomns


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress, SaleDate


SELECT *
FROM NashvilleHousing
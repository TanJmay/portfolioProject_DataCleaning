select * 
from ProjectPortfolio..NashvilleHousing
------------------------------------------------------------

-- Standardize data format

select SaleDateConverted, CONVERT(date,SaleDate)
from ProjectPortfolio..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

Alter table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

-------------------------------------------------------

-- populate property Adresss data

select *
from ProjectPortfolio..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISnull(a.PropertyAddress, b.ParcelID)
from ProjectPortfolio..NashvilleHousing a
join ProjectPortfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
SET PropertyAddress = ISnull(a.PropertyAddress, b.ParcelID)
from ProjectPortfolio..NashvilleHousing a
join ProjectPortfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------------------------
--Breaking out Address into Individual Columns (address ,City, State)
select PropertyAddress
from ProjectPortfolio..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1  ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1  , LEN(PropertyAddress)) as Address
from NashvilleHousing

--chatGTP
SELECT 
  LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress + ',') - 1) as Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress + ',') + 1, LEN(PropertyAddress)) as RestOfAddress
FROM NashvilleHousing
--(OR)
SELECT 
   SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress + ',') - 1) as Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress + ',') + 1, LEN(PropertyAddress)) as RestOfAddress
FROM NashvilleHousing
--(OR)
SELECT 
  PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2) as Address,
  PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1) as RestOfAddress
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress =   LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress + ',') - 1)

ALTER TABLE NashvilleHousing
add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress + ',') + 1, LEN(PropertyAddress))

select * 
from ProjectPortfolio..NashvilleHousing


--OWNERS ADDRRESS

select OwnerAddress 
from ProjectPortfolio..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from ProjectPortfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
add OwnerSplitAddress nvarchar(255)
Update NashvilleHousing
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
add OwnerSplitCity nvarchar(255)
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
add OwnerSplitState nvarchar(255)
Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select * 
from ProjectPortfolio..NashvilleHousing

--------------------------------------------------------------

-- Change y and N to Yes and No in "sold as Vacent" field

Select Distinct(SoldAsVacant), count(SoldAsVacant) TotalCount
from ProjectPortfolio..NashvilleHousing
group by SoldAsVacant
order by TotalCount



Select SoldAsVacant,
Case When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
	 END
from ProjectPortfolio..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
	 END
from ProjectPortfolio..NashvilleHousing

------------------------------------------------------------

--Remove Duplicates
WITH  RowNumCTE AS(
Select *,
		ROW_NUMBER() over (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 ORDER by
						UniqueID
						) Row_num

from ProjectPortfolio..NashvilleHousing
--order by ParcelID
)

Select * 
from RowNumCTE
where row_num > 1
Order by PropertyAddress


----------------------------------------------------------------

--Delete unused column

select *
from ProjectPortfolio..NashvilleHousing
order by SalePrice desc

Alter table ProjectPortfolio..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter table ProjectPortfolio..NashvilleHousing
Drop Column saleDate





























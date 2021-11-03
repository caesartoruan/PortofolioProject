/*
Cleaning Data in SQL Queries
*/

select *
from PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDate, (CONVERT(date, saleDate))
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date,saledate)

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,saledate)

select SaleDateConverted, (CONVERT(date, saleDate))
from PortfolioProject.dbo.NashvilleHousing


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, 
	a.PropertyAddress, 
	b.ParcelID, 
	b.PropertyAddress,
	ISNULL (a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2 , LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2 , LEN(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing 



select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing 


select PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing 

 
alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)


select *
from PortfolioProject.dbo.NashvilleHousing 


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing 
group by SoldAsVacant
order by 2


select SoldAsVacant,
	case when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No'
		else SoldAsVacant
		END
from PortfolioProject.dbo.NashvilleHousing 


Update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No'
		else SoldAsVacant
		END





-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as (
select *,
	ROW_NUMBER() over (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				LegalReference
				order by 
					UniqueID
					) row_num
from PortfolioProject.dbo.NashvilleHousing 
--order by ParcelID
)
select * 
from RowNumCTE
where row_num > 1
--order by PropertyAddress



with RowNumCTE as (
select *,
	ROW_NUMBER() over (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				LegalReference
				order by 
					UniqueID
					) row_num
from PortfolioProject.dbo.NashvilleHousing 
--order by ParcelID
)
delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress

select *
from PortfolioProject.dbo.NashvilleHousing 




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from PortfolioProject.dbo.NashvilleHousing 


alter table PortfolioProject.dbo.NashvilleHousing 
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject.dbo.NashvilleHousing 
drop column SaleDate







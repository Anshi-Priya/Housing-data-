select * from Projects.dbo.HousingData

--Standardize date format

select SaleDate,Convert(date,SaleDate)
from Projects.dbo.HousingData

Update Projects.dbo.HousingData
set SaleDate=Convert(date,SaleDate)

Alter Table Projects.dbo.HousingData
Add ConvertedSaleDate Date;

Update Projects.dbo.HousingData
set ConvertedSaleDate = Convert(date,SaleDate)

select ConvertedSaleDate
from Projects.dbo.HousingData

select * from Projects.dbo.HousingData

--Populate property address column

select PropertyAddress
from Projects.dbo.HousingData
where PropertyAddress is null

select *
from Projects.dbo.HousingData
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from Projects.dbo.HousingData a
join Projects.dbo.HousingData b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from Projects.dbo.HousingData a
join Projects.dbo.HousingData b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from Projects.dbo.HousingData a
join Projects.dbo.HousingData b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null



--Breaking out the Address into individual column(address,city,state)

select PropertyAddress
from Projects.dbo.HousingData
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City

from Projects.dbo.HousingData

Alter Table Projects.dbo.HousingData
Add PropertySplitAddress nvarchar(255);

Update Projects.dbo.HousingData
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter Table Projects.dbo.HousingData
Add PropertySplitCity nvarchar(255);

Update Projects.dbo.HousingData
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select*
from Projects.dbo.HousingData

select OwnerAddress
from Projects.dbo.HousingData
--where OwnerAddress is null
--order by ParcelID

select
parsename(replace(OwnerAddress,',','.'),3) as Address,
parsename(replace(OwnerAddress,',','.'),2) as City,
parsename(replace(OwnerAddress,',','.'),1) as State

from Projects.dbo.HousingData

Alter Table Projects.dbo.HousingData
Add OwnerSplitAddress nvarchar(255);

Update Projects.dbo.HousingData
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3)

Alter Table Projects.dbo.HousingData
Add OwnerSplitCity nvarchar(255);

Update Projects.dbo.HousingData
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2)

Alter Table Projects.dbo.HousingData
Add OwnerSplitState nvarchar(255);

Update Projects.dbo.HousingData
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1)

select*
from Projects.dbo.HousingData

--Change Y and N to Yes and No in 'Sold as Vacant' Field

select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from Projects.dbo.HousingData
group by SoldAsVacant
order by 2


select SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant 
	 END
from Projects.dbo.HousingData


Update Projects.dbo.HousingData
set SoldAsVacant=CASE when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant 
	 END

select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from Projects.dbo.HousingData
group by SoldAsVacant
order by 2

--Remove Duplicates

WITH RownumCTE as(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,PropertyAddress,SaleDate,LegalReference,SalePrice
order by UniqueID) row_num
            
from Projects.dbo.HousingData
--order by ParcelID
)
select*
from RownumCTE
where row_num >1
order by PropertyAddress

WITH RownumCTE as(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,PropertyAddress,SaleDate,LegalReference,SalePrice
order by UniqueID) row_num
            
from Projects.dbo.HousingData
--order by ParcelID
)
DELETE
from RownumCTE
where row_num >1
--order by PropertyAddress

--Delete Unused Columns


Select *
from Projects.dbo.HousingData

ALTER TABLE  Projects.dbo.HousingData
Drop column PropertyAddress,OwnerAddress,TaxDistrict,SaleDate

Select *
from Projects.dbo.HousingData

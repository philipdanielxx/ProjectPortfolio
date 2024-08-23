-- Cleaning of data using SQL queries

SELECT * FROM nashville_housing.nashvilehousingdata;

-- Standardizing the date format

SELECT STR_TO_DATE(SaleDate, '%M %d, %Y') AS StandardizedSaleDate
FROM nashville_housing.nashvilehousingdata;

Alter table nashville_housing.nashvilehousingdata
Add SalesDate date;

UPDATE nashville_housing.nashvilehousingdata
SET SalesDate = STR_TO_DATE(SaleDate, '%M %d, %Y');

-- Populate the property address

UPDATE nashville_housing.nashvilehousingdata -- just because they were empty
SET PropertyAddress = NULL
WHERE PropertyAddress = '';

SELECT *
FROM nashville_housing.nashvilehousingdata
Where PropertyAddress is null
order by ParcelID;

SELECT pr.parcelid, pr.PropertyAddress, pa.ParcelID, pa.PropertyAddress, coalesce(pr.PropertyAddress, pa.PropertyAddress) as PropertyAddresss-- performs a join to examine the data and find out which needs populating, then use ISNULL
FROM nashville_housing.nashvilehousingdata Pr
JOIN nashville_housing.nashvilehousingdata Pa
ON pr.parcelid = pa.parcelid
AND pr.ï»¿UniqueID <> pa.ï»¿UniqueID
Where pr.propertyaddress is null;

UPDATE nashville_housing.nashvilehousingdata pr
JOIN nashville_housing.nashvilehousingdata pa
ON pr.parcelid = pa.parcelid
AND pr.ï»¿UniqueID <> pa.ï»¿UniqueID
SET pr.PropertyAddress = COALESCE(pr.PropertyAddress, pa.PropertyAddress)
WHERE pr.PropertyAddress IS NULL;

-- Spliting the PropertyAddress into 3 indivitual columns -address and city

SELECT 
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 2) AS City
FROM nashville_housing.nashvilehousingdata;

-- next step involves altering & updating the table
-- Address Column
Alter table nashville_housing.nashvilehousingdata
Add Address varchar(255);
Update nashville_housing.nashvilehousingdata
Set Address = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);
-- City Column
Alter table nashville_housing.nashvilehousingdata
Add City varchar(255);
Update nashville_housing.nashvilehousingdata
Set City = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 2);

-- Spliting the PropertyAddress into 3 indivitual columns -address, city & State

SELECT 
SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Part1,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS Part2,
SUBSTRING_INDEX(OwnerAddress, ',', -1) AS Part3
FROM nashville_housing.nashvilehousingdata;
-- next step involves altering & updating the table
-- Address Column
Alter table nashville_housing.nashvilehousingdata
Add OwnersAddress varchar(255);
Update nashville_housing.nashvilehousingdata
Set OwnersAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);
-- City Column
Alter table nashville_housing.nashvilehousingdata
Add OwnerCity varchar(255);
Update nashville_housing.nashvilehousingdata
Set OwnerCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);
-- State Column
Alter table nashville_housing.nashvilehousingdata
Add OwnerState varchar(255);
Update nashville_housing.nashvilehousingdata
Set OwnerState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

-- Change Y and N to Yes and No
-- the syntax below shows you if both of them are being used
SELECT distinct(SoldAsVacant)
FROM nashville_housing.nashvilehousingdata;

-- Utilize Case-When
SELECT SoldAsVacant,
Case when SoldAsVacant = "Y" then "YES"
when SoldAsVacant = "N" then "No"
Else SoldAsVacant
End
FROM nashville_housing.nashvilehousingdata;
Update nashville_housing.nashvilehousingdata
Set SoldAsVacant = Case when SoldAsVacant = "Y" then "YES"
when SoldAsVacant = "N" then "No"
Else SoldAsVacant
End;

-- Removal of duplicates - but first a CTE had to be created

With Row_numbers as
(SELECT *, row_number()
Over(Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
Order by ï»¿UniqueID) row_numbers
FROM nashville_housing.nashvilehousingdata)
Delete From nashville_housing.nashvilehousingdata
WHERE ï»¿UniqueID IN (
SELECT ï»¿UniqueID
FROM Row_numbers
WHERE row_numbers > 1
);

-- Delete unwanted columns

SELECT * FROM nashville_housing.nashvilehousingdata;

Alter table nashville_housing.nashvilehousingdata
drop column OwnerAddress,
drop column PropertyAddress,
Drop column SaleDate;








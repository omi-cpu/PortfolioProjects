/*
 
 Cleaning data with PostgreSQL
 
 */



------------------------------------------------------------------------------------------------------



select * from nashville_housing_data_for_data_cleaning  


------------------------------------------------------------------------------------------------------



-- standardize date format

select saledate, cast(saledate as date)
from nashville_housing_data_for_data_cleaning nhdfdc 

update nashville_housing_data_for_data_cleaning 
set saledate = cast(saledate as date)

alter table nashville_housing_data_for_data_cleaning 
add saledate_converted date;

update nashville_housing_data_for_data_cleaning 
set saledate_converted = cast(saledate as date)

select saledate_converted
from nashville_housing_data_for_data_cleaning nhdfdc 



------------------------------------------------------------------------------------------------------



-- populate property adress data

select propertyaddress 
from nashville_housing_data_for_data_cleaning nhdfdc 
-- where propertyaddress is null
order by parcelid 

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, coalesce(a.propertyaddress, b.propertyaddress) 
from nashville_housing_data_for_data_cleaning a 
join nashville_housing_data_for_data_cleaning b 
	on a.parcelid = b.parcelid 
	and a."UniqueID " <> b."UniqueID "  -- not equal to
where a.propertyaddress is null

update a
set propertyaddress = coalesce(a.propertyaddress, b.propertyaddress) 
from nashville_housing_data_for_data_cleaning a 
join nashville_housing_data_for_data_cleaning b 
	on a.parcelid = b.parcelid 
	and a."UniqueID " <> b."UniqueID "  -- not equal to
where a.propertyaddress is null



------------------------------------------------------------------------------------------------------



-- breaking out address into columns(address, city, state)

select propertyaddress 
from nashville_housing_data_for_data_cleaning nhdfdc 
-- where propertyaddress is null
order by parcelid 

select 
substr(propertyaddress, 1, strpos(',', propertyaddress) - 1) as address,
substr(propertyaddress, 1, strpos(',', propertyaddress) + 1 , LENGTH(propertyaddress)) as address
from nashville_housing_data_for_data_cleaning nhdfdc 


alter table nashville_housing_data_for_data_cleaning 
add property_split_address varchar(255);

update nashville_housing_data_for_data_cleaning 
set property_split_address = substr(propertyaddress, 1, strpos(',', propertyaddress) - 1)

alter table nashville_housing_data_for_data_cleaning 
add property_split_city varchar(255);

update nashville_housing_data_for_data_cleaning 
set property_split_city = substr(propertyaddress, 1, strpos(',', propertyaddress) + 1 , LENGTH(propertyaddress)) 

select * from nashville_housing_data_for_data_cleaning nhdfdc 

            -- OR --

select owneraddress 
from nashville_housing_data_for_data_cleaning nhdfdc 

select split_part(owneraddress, ',', 1), 
split_part(owneraddress, ',', 2), 
split_part(owneraddress, ',', 3)
from nashville_housing_data_for_data_cleaning nhdfdc 

alter table nashville_housing_data_for_data_cleaning 
add owner_split_address varchar(255);

update nashville_housing_data_for_data_cleaning 
set owner_split_address = split_part(owneraddress, ',', 1)

alter table nashville_housing_data_for_data_cleaning 
add owner_split_city varchar(255);

update nashville_housing_data_for_data_cleaning 
set owner_split_city = split_part(owneraddress, ',', 2)

alter table nashville_housing_data_for_data_cleaning 
add owner_split_state varchar(255);

update nashville_housing_data_for_data_cleaning 
set owner_split_state = split_part(owneraddress, ',', 3)

select * from nashville_housing_data_for_data_cleaning nhdfdc 



------------------------------------------------------------------------------------------------------



-- change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(soldasvacant), count(soldasvacant)
from nashville_housing_data_for_data_cleaning nhdfdc 
group by soldasvacant 
order by 2

select soldasvacant ,
	case when soldasvacant = 'N' then 'No'
		 when soldasvacant = 'Y' then 'Yes'
	else soldasvacant 
	end
from nashville_housing_data_for_data_cleaning nhdfdc 

update nashville_housing_data_for_data_cleaning 
set soldasvacant = case when soldasvacant = 'N' then 'No'
		 				when soldasvacant = 'Y' then 'Yes'
					else soldasvacant 
					end

					
					
------------------------------------------------------------------------------------------------------

					
					
-- remove duplicates , it's normally better to create a temp table for duplicates rather than deleting
					
with row_num_cte as(
select *,
	row_number() over (
	partition by parcelid , 
				 propertyaddress , 
				 saleprice , 
				 saledate ,
				 legalreference 
				 --order by 
				 	--UniqueID
					)row_num
from nashville_housing_data_for_data_cleaning nhdfdc 
--order by parcelid  
)
select *
--delete
from row_num_cte
where row_num > 1
--order by propertyaddress 



------------------------------------------------------------------------------------------------------



-- delete unused columns

select * from nashville_housing_data_for_data_cleaning nhdfdc 

alter table nashville_housing_data_for_data_cleaning 
--drop column owneraddress
drop column saledate
--drop column taxdistrict


					
					

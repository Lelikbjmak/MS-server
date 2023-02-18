-- Option 2

-- #a
-- Создайте представление VIEW, отображающее данные из таблиц Production.Location и
-- Production.ProductInventory, а также Name из таблицы Production.Product. Сделайте невозможным
-- просмотр исходного кода представления. Создайте уникальный кластерный индекс в представлении
-- по полям LocationID,ProductID.

create view ProductLocationAndInventoryView with schemabinding
as
	select 
		L.LocationID,
		L.Name as LocationName,
		L.CostRate,
		L.Availability,
		L.ModifiedDate as LocationModifiedDate,
			PI.ProductID,
				P.Name as ProductName,
			PI.Shelf,
			PI.Bin,
			PI.Quantity,
			PI.rowguid,
			PI.ModifiedDate as ProductMOdifiedDate
	from Production.Location L
	inner join Production.ProductInventory PI
		on PI.LocationID = L.LocationID
	inner join Production.Product as P
		on P.ProductID = PI.ProductID;
go

select * from ProductLocationAndInventoryView;

create unique clustered index uq_clust_index_product_inv_loc_view
	on [dbo].[ProductLocationAndInventoryView]
	(
		LocationId asc,
		ProductId asc
	);
go

-- ------------------------------------------------------------------------------------------------

-- #b
-- Создайте три INSTEAD OF триггера для представления на операции INSERT, UPDATE, DELETE.
-- Каждый триггер должен выполнять соответствующие операции в таблицах Production.Location и
-- Production.ProductInventory для указанного Product Name. Обновление и удаление строк производите
-- только в таблицах Production.Location и Production.ProductInventory, но не в Production.Product.
--select * from ProductLocationAndInventoryView;
--select * from Production.ProductInventory;
--select * from Production.Location;

-- insert trigger
create trigger insteadOFOperationInsertViewTrigger
on ProductLocationAndInventoryView
	instead of insert
	as 
		begin
		
			declare @ProductName nvarchar(50);
			declare @LocationName nvarchar(50);
			declare @ProductExists bit;
			declare @LocationExists bit;

			set @ProductName = ( select
						ProductName
					from inserted);

			begin try
				if (select
						P.Name
					from Production.Product P
						where P.Name = @ProductName) is not null
				set @ProductExists = 1
				else 
					throw 51000, 'Product doesn''t exist', @ProductName;
			end try
			begin catch
				throw;
			end catch

			set @LocationName = ( select
						LocationName
					from inserted);
				
			if (select
					L.Name
				from Production.Location L
					where L.Name = @LocationName) is not null
			set @LocationExists = 1
			else 
				begin
					set @LocationExists = 0;
					print 'Location doesn''t exists';
				end

			if @LocationExists = 0
			begin
				print 'Creating location: ' + @LocationName;
				insert into Production.Location
					select
						I.LocationName,
						I.CostRate,
						I.Availability,
						I.LocationModifiedDate
					from inserted I;

				set @LocationExists = 1;
			end


			if @LocationExists = 1 and @ProductExists = 1
			begin
				insert into Production.ProductInventory
					select
						I.ProductID,
						(select LocationID 
						from Production.Location
							where Name = @LocationName),
						I.Shelf,
						I.Bin,
						I.Quantity,
						NEWID(),
						GETDATE() as ModifiedDate
					from inserted I;
			end
				else 
				print 'Location or product afk';

		end
go

--drop trigger insteadOFOperationInsertViewTrigger;

select * from Production.ProductInventory order by LocationID desc;  -- 868
select * from Production.Location order by LocationID desc;

--delete from Production.Location where LocationID = 68;

declare @productName nvarchar(256);
set @productName = 'Adjustable Race';

insert into ProductLocationAndInventoryView
values(	
	3,  -- LocationId
	'New trigger Location',  --LocationName
	11.11,  -- CostRate
	11.11,  -- Availibility
	GETDATE(),  -- LocationModifiedDate
	(select ProductID
	from Production.Product
		where Name = @productName),  --ProductId
	@productName,  -- ProductName
	'A',  -- Shelf
	2,  -- Bin
	333,  -- Quantity
	NEWID(),  -- rowguid
	(select ModifiedDate
	from Production.Product
		where Name = @productName)  -- productModifiedDate
);
go 
-- update trigger
create trigger insteadOFOperationUpdateViewTrigger
on ProductLocationAndInventoryView
	instead of update
	as
		begin
		
			declare @ProductId int;
			declare @LocationId int;
			declare @IsLocationUpdated bit;
			declare @IsProductUpdated bit;

			begin try
			set @ProductId = ( select
						ProductID
					from inserted);

			set @LocationId = ( select
						LocationID
					from inserted);

			if (select
					count(*)
				from Production.Product
					where ProductID = @ProductId) = 0
				throw 51000, 'Product u trying to update doesn''t exist.', @ProductId; 
			end try
			begin catch
				throw;
			end catch

			begin try
			if (select
					count(*)
				from Production.Location
					where LocationID = @LocationId) = 0
				throw 51000, 'Location u trying to update doesn''t exist.', @ProductId; 
			end try
			begin catch
				throw;
			end catch


			if (select
					count(*)
				from Production.Location L
					where
						L.LocationID = @LocationId and
						L.CostRate = (select CostRate from inserted) and
						L.Availability = (select Availability from inserted)) = 0
					set @IsLocationUpdated = 1
			else 
				set @IsLocationUpdated = 0;


			if (select
					count(*)
				from Production.ProductInventory PI
					where
						PI.LocationID = @LocationId and
						PI.ProductID = @ProductId and
						PI.Bin = (select Bin from inserted) and
						PI.Quantity = (select Quantity from inserted) and
						PI.rowguid = (select rowguid from inserted) and
						PI.Shelf = (select Shelf from inserted)) = 0
					set @IsProductUpdated = 1
			else 
				set @IsProductUpdated = 0;

			if @IsProductUpdated = 1
				update Production.ProductInventory
					set
						Shelf = (select Shelf from inserted),
						Bin = (select Bin from inserted),
						Quantity = (select Quantity from inserted),
						rowguid = (select rowguid from inserted),
						ModifiedDate = GETDATE()
					where LocationID = @LocationId
						and
							ProductID = @ProductId;

			if @IsLocationUpdated = 1
				update Production.Location
					set
						Availability = (select Availability from inserted),
						CostRate = (select CostRate from inserted),
						ModifiedDate = GETDATE()
					where LocationID = @LocationId;

		end
go


-- test update trigger
declare @productName nvarchar(256);
declare @locationName nvarchar(256);
set @productName = 'Adjustable Race';
set @locationName = 'New trigger Location';

select * from Production.ProductInventory
	where
		ProductID = (select ProductID from Production.Product where Name = @productName) and
		LocationID = (select LocationID from Production.Location where Name = @locationName);

select * from Production.Location
	where LocationID = (select LocationID from Production.Location where Name = @locationName);

update ProductLocationAndInventoryView
set
	Quantity = 10,
	Bin = 10,
	CostRate = 100.00
where
	ProductID = (select ProductID from Production.Product where Name = @productName) and
	LocationID = (select LocationID from Production.Location where Name = @locationName);
go

-- delete trigger
create trigger insteadOFOperationDeleteViewTrigger
on ProductLocationAndInventoryView
	instead of delete
	as
		begin
		
			declare @ProductId int;
			declare @LocationId int;

			set @ProductId = ( select
						ProductID
					from deleted);

			set @LocationId = ( select
						LocationID
					from deleted);

			delete from Production.ProductInventory
				where
					ProductID = @ProductId and
					LocationID = @LocationId;
			if (select
					count(*)
				from Production.ProductInventory
					where LocationID = @LocationId) = 0
			delete from Production.Location
				where LocationID = @LocationId;

		end
go

-- test delete trigger
declare @productName nvarchar(256);
declare @locationName nvarchar(256);
set @productName = 'Adjustable Race';
set @locationName = 'New trigger Location';

delete from ProductLocationAndInventoryView
	where
		ProductID = (select ProductID from Production.Product where Name = @productName) and
		LocationID = (select LocationID from Production.Location where Name = @locationName); 

select * from Production.ProductInventory
	where 
		ProductID = (select ProductID from Production.Product where Name = @productName) and
		LocationID = (select LocationID from Production.Location where Name = @locationName); 
go
-- ------------------------------------------------------------------------------------------------

-- #c
-- Вставьте новую строку в представление, указав новые данные для Location и ProductInventory, но
-- для существующего Product (например для ‘Adjustable Race’). Триггер должен добавить новые строки
-- в таблицы Production.Location и Production.ProductInventory для указанного Product Name. Обновите
-- вставленные строки через представление. Удалите строки.

select * from Production.Location
	where LocationID = 6;

select * from Production.Location where LocationID not in(select LocationID from ProductLocationAndInventoryView)

declare @productName nvarchar(256);
declare @locationName nvarchar(256);
set @productName = 'Bearing Ball';
set @locationName = 'Miscellaneous Storage';

insert into ProductLocationAndInventoryView
values(	
	(select LocationID from Production.Location
		where Name = @locationName),  -- LocationId
	@locationName,  --LocationName
	11.11,  -- CostRate
	11.11,  -- Availibility
	GETDATE(),  -- LocationModifiedDate
	(select ProductID
	from Production.Product
		where Name = @productName),  --ProductId
	@productName,  -- ProductName
	'A',  -- Shelf
	1,  -- Bin
	1,  -- Quantity
	NEWID(),  -- rowguid
	GETDATE()  -- productModifiedDate
);
go 

-- ... look before
-- ------------------------------------------------------------------------------------------------
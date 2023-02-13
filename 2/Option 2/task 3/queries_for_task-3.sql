-- Option 2

-- #a
-- —оздайте таблицу Production.LocationHst, котора€ будет хранить информацию об изменени€х в
-- таблице Production.Location.
-- ќб€зательные пол€, которые должны присутствовать в таблице: ID Ч первичный ключ
-- IDENTITY(1,1); Action Ч совершенное действие (insert, update или delete); ModifiedDate Ч дата и
-- врем€, когда была совершена операци€; SourceID Ч первичный ключ исходной таблицы; UserName
-- им€ пользовател€, совершившего операцию. —оздайте другие пол€, если считаете их нужными.create table [Production].LocationHst(ID bigint primary key Identity(1,1),Action nvarchar(70) not null,ModifiedDate datetime,SourceId smallint,UserName nvarchar(256) not null,constraint action_emun_cnsrt check(Action in ('insert', 'update', 'delete', 'unknown')));-- ------------------------------------------------------------------------------------------

---- #b
-- —оздайте один AFTER триггер дл€ трех операций INSERT, UPDATE, DELETE дл€ таблицы
-- Production.Location. “риггер должен заполн€ть таблицу Production.LocationHst с указанием типа
-- операции в поле Action в зависимости от оператора, вызвавшего триггер

go
create trigger afterOnLocationHoiston [Production].Location after insert, update, deleteas	declare @event_type nvarchar(70)	declare @source_id smallint	IF EXISTS(SELECT * FROM inserted)
	IF EXISTS(SELECT * FROM deleted)
		begin
			SELECT @event_type = 'update'
			select @source_id = (select LocationID from inserted)
		end
	ELSE
		begin
			SELECT @event_type = 'insert'
			select @source_id = (select LocationID from inserted)
		end
	ELSE
	IF EXISTS(SELECT * FROM deleted)
		begin
			SELECT @event_type = 'delete'
			select @source_id = (select LocationID from deleted)
		end
	ELSE
		begin
	--no rows affected - cannot determine event
			SELECT @event_type = 'unknown'			select @source_id = -1		end	insert into [Production].LocationHst	values (		@event_type,		GETDATE(),		@source_id,		(select SUSER_NAME())		)
select * from Production.Location;select * from Production.LocationHst;select * from Production.ProductInventory;update Production.Location	set CostRate = 10.00	where LocationID = 1;insert into Production.Location	values(		'Test trigger',		11.11,		0.00,		GETDATE()		);delete from Production.Location where LocationID = 61;-- -------------------------------------------------------------------------------------------- #c-- —оздайте представление VIEW, отображающее все пол€ таблицы Production.Location.gocreate view ProductLocationView(	LocationId,	Name,	CostRate,	Availibility,	ModifiedDate)as 	select * from Production.Location;select * from ProductLocationView;-- -------------------------------------------------------------------------------------------- #d-- ¬ставьте новую строку в Production.Location через представление. ќбновите вставленную строку.
-- ”далите вставленную строку. ”бедитесь, что все три операции отображены в Production.LocationHst.insert into ProductLocationView	values(		'Test trigger2',		12.12,		0.00,		GETDATE()		);update ProductLocationView	set CostRate = 10.10	where LocationId = 64;delete from ProductLocationView where LocationID = 64;select * from Production.LocationHst;
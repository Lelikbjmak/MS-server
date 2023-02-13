-- Option 2

-- #a
-- �������� ������� Production.LocationHst, ������� ����� ������� ���������� �� ���������� �
-- ������� Production.Location.
-- ������������ ����, ������� ������ �������������� � �������: ID � ��������� ����
-- IDENTITY(1,1); Action � ����������� �������� (insert, update ��� delete); ModifiedDate � ���� �
-- �����, ����� ���� ��������� ��������; SourceID � ��������� ���� �������� �������; UserName
-- ��� ������������, ������������ ��������. �������� ������ ����, ���� �������� �� �������.create table [Production].LocationHst(ID bigint primary key Identity(1,1),Action nvarchar(70) not null,ModifiedDate datetime,SourceId smallint,UserName nvarchar(256) not null,constraint action_emun_cnsrt check(Action in ('insert', 'update', 'delete', 'unknown')));-- ------------------------------------------------------------------------------------------

---- #b
-- �������� ���� AFTER ������� ��� ���� �������� INSERT, UPDATE, DELETE ��� �������
-- Production.Location. ������� ������ ��������� ������� Production.LocationHst � ��������� ����
-- �������� � ���� Action � ����������� �� ���������, ���������� �������

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
select * from Production.Location;select * from Production.LocationHst;select * from Production.ProductInventory;update Production.Location	set CostRate = 10.00	where LocationID = 1;insert into Production.Location	values(		'Test trigger',		11.11,		0.00,		GETDATE()		);delete from Production.Location where LocationID = 61;-- -------------------------------------------------------------------------------------------- #c-- �������� ������������� VIEW, ������������ ��� ���� ������� Production.Location.gocreate view ProductLocationView(	LocationId,	Name,	CostRate,	Availibility,	ModifiedDate)as 	select * from Production.Location;select * from ProductLocationView;-- -------------------------------------------------------------------------------------------- #d-- �������� ����� ������ � Production.Location ����� �������������. �������� ����������� ������.
-- ������� ����������� ������. ���������, ��� ��� ��� �������� ���������� � Production.LocationHst.insert into ProductLocationView	values(		'Test trigger2',		12.12,		0.00,		GETDATE()		);update ProductLocationView	set CostRate = 10.10	where LocationId = 64;delete from ProductLocationView where LocationID = 64;select * from Production.LocationHst;
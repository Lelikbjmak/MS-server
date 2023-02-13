-- Option 2

-- #a
-- �������� ������� Production.LocationHst, ������� ����� ������� ���������� �� ���������� �
-- ������� Production.Location.
-- ������������ ����, ������� ������ �������������� � �������: ID � ��������� ����
-- IDENTITY(1,1); Action � ����������� �������� (insert, update ��� delete); ModifiedDate � ���� �
-- �����, ����� ���� ��������� ��������; SourceID � ��������� ���� �������� �������; UserName
-- ��� ������������, ������������ ��������. �������� ������ ����, ���� �������� �� �������.

---- #b
-- �������� ���� AFTER ������� ��� ���� �������� INSERT, UPDATE, DELETE ��� �������
-- Production.Location. ������� ������ ��������� ������� Production.LocationHst � ��������� ����
-- �������� � ���� Action � ����������� �� ���������, ���������� �������

go
create trigger afterOnLocationHoist
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
			SELECT @event_type = 'unknown'

-- ������� ����������� ������. ���������, ��� ��� ��� �������� ���������� � Production.LocationHst.
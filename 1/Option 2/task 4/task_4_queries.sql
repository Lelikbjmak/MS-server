-- #a
-- �������� ������� dbo.PersonPhone � ����� �� ���������� ��� Person.PersonPhone, �� �������
-- �������, ����������� � ��������

GO
CREATE TABLE PersonPhone(
	[BusinessEntityID] [int] NOT NULL,
	[PhoneNumber] [dbo].[Phone] NOT NULL,
	[PhoneNumberTypeID] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
)
go
-- -------------------------------------------------------------------------------------------

-- #b
-- ��������� ���������� ALTER TABLE, �������� � ������� dbo.PersonPhone ����� ���� ID, �������
--�������� ���������� ������������ UNIQUE ���� bigint � ����� �������� identity. ���������
--�������� ��� ���� identity ������� 2 � ���������� ������� 2

alter table PersonPhone
add ID bigint unique identity(2,2);
-- -------------------------------------------------------------------------------------------

-- #c
-- ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.PersonPhone ����������� ���
-- ���� PhoneNumber, ����������� ���������� ����� ���� �������;

alter table PersonPhone with nocheck
add check (PhoneNumber not like '%[^a-zA-Z]%');

insert into PersonPhone values(1, '1ad2', 1, '2003-02-08 00:00:00.000');
-- -------------------------------------------------------------------------------------------

-- #d
-- ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.PersonPhone �����������
-- DEFAULT ��� ���� PhoneNumberTypeID, ������� �������� �� ��������� 1;

alter table PersonPhone
add default 1 for PhoneNumber;
-- -------------------------------------------------------------------------------------------

-- #e
-- ��������� ����� ������� ������� �� Person.PersonPhone, ��� ���� PhoneNumber �� ��������
-- �������� �(� � �)� � ������ ��� ��� �����������, ������� ���������� � �������
-- HumanResources.Employee, � �� ���� �������� �� ������ ��������� � ����� ������ ������ � ������
insert into PersonPhone 
	select
		E.BusinessEntityID,
		PP.PhoneNumber,
		PP.PhoneNumberTypeID,
		PP.ModifiedDate
	from Person.PersonPhone as PP
		right join HumanResources.Employee as E
			on E.BusinessEntityID = PP.BusinessEntityID
		inner join HumanResources.EmployeeDepartmentHistory as EDH
			on EDH.BusinessEntityID = E.BusinessEntityID
		inner join HumanResources.Department as D
			on D.DepartmentID = EDH.DepartmentID
	where E.HireDate = EDH.StartDate and 
		PP.PhoneNumber not like '%[()]%';

select * from PersonPhone;
-- -------------------------------------------------------------------------------------------

-- #f
-- �������� ���� PhoneNumber, �������� ���������� null ��������.alter table PersonPhone alter column PhoneNumber [dbo].[Phone] NULL;-- -------------------------------------------------------------------------------------------

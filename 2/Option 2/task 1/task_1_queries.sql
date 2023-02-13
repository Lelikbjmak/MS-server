-- Option 2

-- #a
-- добавьте в таблицу dbo.PersonPhone поле HireDate типа date

alter table PersonPhone
	add HireDate date;
-- --------------------------------------------------------------------

-- #b
-- объявите табличную переменную с такой же структурой как dbo.PersonPhone и заполните ее
-- данными из dbo.PersonPhone. Заполните поле HireDate значениями из поля HireDate таблицы
-- HumanResources.Employeego
declare @PersonPhoneVar table(
	BusinessEntityId int,
	PhoneNumber nvarchar(30),
	PhoneNumberTypeID int,
	ModifiedDate datetime,
	HiredDate date
);


insert into @PersonPhoneVar 
select
	P.BusinessEntityID,
	P.PhoneNumber,
	P.PhoneNumberTypeID,
	P.ModifiedDate,
	E.HireDate
from PersonPhone as P
inner join HumanResources.Employee as E
	on E.BusinessEntityID = P.BusinessEntityID;


select HiredDate from @PersonPhoneVar;
-- --------------------------------------------------------------------

-- #c
-- обновите HireDate в dbo.PersonPhone данными из табличной переменной, добавив к HireDate один
-- день;

update dbo.PersonPhone
set HireDate = K.HiredDate
		from @PersonPhoneVar as K;

select * from PersonPhone;
-- --------------------------------------------------------------------

-- #d
-- удалите данные из dbo.PersonPhone, для тех сотрудников, у которых почасовая ставка в таблице
-- HumanResources.EmployeePayHistory больше 50;
delete from PersonPhone
where BusinessEntityID in
	(select E.BusinessEntityID
		from HumanResources.Employee as E
		inner join HumanResources.EmployeePayHistory as EPH
			on EPH.BusinessEntityID = E.BusinessEntityID
			where EPH.Rate > 50);
-- --------------------------------------------------------------------

-- #e
-- удалите все созданные ограничения и значения по умолчанию. После этого, удалите поле ID.
-- Имена ограничений вы можете найти в метаданных. Например:
-- SELECT *
-- FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
-- WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'PersonPhone';
-- Имена значений по умолчанию найдите самостоятельно, приведите код, которым пользовались для
-- поиска;

SELECT CONSTRAINT_NAME
FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'PersonPhone';

--DECLARE @database NVARCHAR(50)
--DECLARE @table NVARCHAR(50)
--DECLARE @sql NVARCHAR(255)

--SET @database = 'AdventureWorks2012'
--SET @table = 'PersonPhone'

--WHILE EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
--WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'PersonPhone')
--	BEGIN
--		SELECT @sql = 'ALTER TABLE ' + @table + ' DROP CONSTRAINT ' + CONSTRAINT_NAME
--			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
--		WHERE constraint_catalog=@database AND table_name=@table
--			EXEC sp_executesql @sql
--	END

--ALTER TABLE PersonPhone DROP CONSTRAINT 
--(SELECT CONSTRAINT_NAME
--FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
--WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'PersonPhone')
--GO

ALTER TABLE [dbo].[PersonPhone] DROP CONSTRAINT [CK__PersonPho__Phone__5090EFD7]
GO

ALTER TABLE [dbo].[PersonPhone] DROP CONSTRAINT [DF__PersonPho__Phone__4DB4832C]
GO

ALTER TABLE [dbo].[PersonPhone] DROP CONSTRAINT [UQ__PersonPh__3214EC26E443D4A4]
GO

alter table PersonPhone
drop column ID;
-- --------------------------------------------------------------------

-- #f
-- удалите таблицу dbo.PersonPhone.

drop table PersonPhone;
-- #a
-- создайте таблицу dbo.PersonPhone с такой же структурой как Person.PersonPhone, не включая
-- индексы, ограничения и триггеры

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
-- используя инструкцию ALTER TABLE, добавьте в таблицу dbo.PersonPhone новое поле ID, которое
--является уникальным ограничением UNIQUE типа bigint и имеет свойство identity. Начальное
--значение для поля identity задайте 2 и приращение задайте 2

alter table PersonPhone
add ID bigint unique identity(2,2);
-- -------------------------------------------------------------------------------------------

-- #c
-- используя инструкцию ALTER TABLE, создайте для таблицы dbo.PersonPhone ограничение для
-- поля PhoneNumber, запрещающее заполнение этого поля буквами;

alter table PersonPhone with nocheck
add check (PhoneNumber not like '%[^a-zA-Z]%');

insert into PersonPhone values(1, '1ad2', 1, '2003-02-08 00:00:00.000');
-- -------------------------------------------------------------------------------------------

-- #d
-- используя инструкцию ALTER TABLE, создайте для таблицы dbo.PersonPhone ограничение
-- DEFAULT для поля PhoneNumberTypeID, задайте значение по умолчанию 1;

alter table PersonPhone
add default 1 for PhoneNumber;
-- -------------------------------------------------------------------------------------------

-- #e
-- заполните новую таблицу данными из Person.PersonPhone, где поле PhoneNumber не содержит
-- символов ‘(‘ и ‘)’ и только для тех сотрудников, которые существуют в таблице
-- HumanResources.Employee, а их дата принятия на работу совпадает с датой начала работы в отделе
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
-- измените поле PhoneNumber, разрешив добавление null значений.alter table PersonPhone alter column PhoneNumber [dbo].[Phone] NULL;-- -------------------------------------------------------------------------------------------

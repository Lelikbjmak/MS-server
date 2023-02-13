-- task 2

-- #a
-- выполните код, созданный во втором задании второй лабораторной работы. Добавьте в таблицу
-- dbo.PersonPhone поля JobTitle NVARCHAR(50), BirthDate DATE и HireDate DATE. Также создайте в
-- таблице вычисляемое поле HireAge, считающее количество лет, прошедших между BirthDate и
-- HireDate.select * from PersonPhone;alter table PersonPhoneadd	Jobtitle nvarchar(50),	BirthDate date,	HireDate date,	HireAge as year(HireDate) - year(BirthDate);-- ------------------------------------------------------------------------------------------------ #b-- создайте временную таблицу #PersonPhone, с первичным ключом по полю BusinessEntityID.
-- Временная таблица должна включать все поля таблицы dbo.PersonPhone за исключением поля
-- HireAge.

CREATE TABLE #PersonPhone(
	[BusinessEntityID] [int] primary key,
	[PhoneNumber] [nvarchar](25),
	[PhoneNumberTypeID] [int],
	[ModifiedDate] [datetime],
	[HireDate] [date],
	[Jobtitle] [nvarchar](50),
	[BirthDate] [date],
)
GO

select * from #PersonPhone;
-- ----------------------------------------------------------------------------------------------

-- #c
-- заполните временную таблицу данными из dbo.PersonPhone. Поля JobTitle, BirthDate и HireDate
-- заполните значениями из таблицы HumanResources.Employee. Выберите только сотрудников с JobTitle
-- = ‘Sales Representative’. Выборку данных для вставки в табличную переменную осуществите в
-- Common Table Expression (CTE).

with pp_cte as (
select
	PP.BusinessEntityID,
	PP.PhoneNumber,
	PP.PhoneNumberTypeID,
	PP.ModifiedDate,
	E.HireDate,
	E.JobTitle,
	E.BirthDate
from PersonPhone as PP
inner join HumanResources.Employee as E
	on E.BusinessEntityID = PP.BusinessEntityID
	)
	insert into #PersonPhone
		select 
			*
		from pp_cte
			where pp_cte.JobTitle = 'Sales Representative';

select * from #PersonPhone;
-- ----------------------------------------------------------------------------------------------

-- №d
-- удалите из таблицы dbo.PersonPhone одну строку (где BusinessEntityID = 275)

delete from PersonPhone where BusinessEntityID = 275;
-- ----------------------------------------------------------------------------------------------

-- #e
-- напишите Merge выражение, использующее dbo.PersonPhone как target, а временную таблицу как
-- source. Для связи target и source используйте BusinessEntityID. Обновите поля JobTitle, BirthDate и
-- HireDate, если запись присутствует и в source и в target. Если строка присутствует во временной
-- таблице, но не существует в target, добавьте строку в dbo.PersonPhone. Если в dbo.PersonPhone
-- присутствует такая строка, которой не существует во временной таблице, удалите строку из
-- dbo.PersonPhone

select BusinessEntityID from #PersonPhone  -- Al notes from #PersonPhone, we can't find in PersonPhone
	except 
	select BusinessEntityID from PersonPhone;

select BusinessEntityID from PersonPhone  -- Al notes from PersonPhone, we can't find in #PersonPhone
	except 
	select BusinessEntityID from #PersonPhone;

select BusinessEntityID from PersonPhone  -- common notes in both select
	intersect
	select BusinessEntityID from #PersonPhone;


-- update common notes
update PersonPhone
	set JobTitle = 'Common', BirthDate = GETDATE(), HireDate = GETDATE()
	from PersonPhone P1  -- common notes in both select
	inner join #PersonPhone P2
		on P2.BusinessEntityID = P1.BusinessEntityID;
		
select * from PersonPhone where BusinessEntityID > 274;

 -- insert in PersonPhone notes, that are not represented in PersonPhone, but exist in #PersonPhone
insert into PersonPhone( 
	BusinessEntityID,
	PhoneNumber,
	PhoneNumberTypeID,
	ModifiedDate,
	HireDate,
	Jobtitle,
	BirthDate
)
select
	P1.BusinessEntityID,
	P1.PhoneNumber,
	P1.PhoneNumberTypeID,
	P1.ModifiedDate,
	P1.HireDate,
	P1.Jobtitle,
	P1.BirthDate
from #PersonPhone P1
left outer join PersonPhone P2
	on P2.BusinessEntityID = P1.BusinessEntityID
	where P2.BusinessEntityID is null;

select * from PersonPhone;

-- delete fileds represented in PersonPhone, that we can't observ in #PersonPhone

delete from PersonPhone
	where BusinessEntityID in (
		select
			P1.BusinessEntityID
		from PersonPhone P1
		left join #PersonPhone P2
			on P2.BusinessEntityID = P1.BusinessEntityID
			where P2.BusinessEntityID is null
			);
			
select * from PersonPhone as P1
inner join #PersonPhone P2
	on P2.BusinessEntityID = P1.BusinessEntityID;
-- ----------------------------------------------------------------------------------------------


-- task 2

-- #a
-- ��������� ���, ��������� �� ������ ������� ������ ������������ ������. �������� � �������
-- dbo.PersonPhone ���� JobTitle NVARCHAR(50), BirthDate DATE � HireDate DATE. ����� �������� �
-- ������� ����������� ���� HireAge, ��������� ���������� ���, ��������� ����� BirthDate �
-- HireDate.select * from PersonPhone;alter table PersonPhoneadd	Jobtitle nvarchar(50),	BirthDate date,	HireDate date,	HireAge as year(HireDate) - year(BirthDate);-- ------------------------------------------------------------------------------------------------ #b-- �������� ��������� ������� #PersonPhone, � ��������� ������ �� ���� BusinessEntityID.
-- ��������� ������� ������ �������� ��� ���� ������� dbo.PersonPhone �� ����������� ����
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
-- ��������� ��������� ������� ������� �� dbo.PersonPhone. ���� JobTitle, BirthDate � HireDate
-- ��������� ���������� �� ������� HumanResources.Employee. �������� ������ ����������� � JobTitle
-- = �Sales Representative�. ������� ������ ��� ������� � ��������� ���������� ����������� �
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

-- �d
-- ������� �� ������� dbo.PersonPhone ���� ������ (��� BusinessEntityID = 275)

delete from PersonPhone where BusinessEntityID = 275;
-- ----------------------------------------------------------------------------------------------

-- #e
-- �������� Merge ���������, ������������ dbo.PersonPhone ��� target, � ��������� ������� ���
-- source. ��� ����� target � source ����������� BusinessEntityID. �������� ���� JobTitle, BirthDate �
-- HireDate, ���� ������ ������������ � � source � � target. ���� ������ ������������ �� ���������
-- �������, �� �� ���������� � target, �������� ������ � dbo.PersonPhone. ���� � dbo.PersonPhone
-- ������������ ����� ������, ������� �� ���������� �� ��������� �������, ������� ������ ��
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


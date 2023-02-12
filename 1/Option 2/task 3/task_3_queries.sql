-- #OPTION 2#

-- #1
-- ������� �� ����� ������� ����������, ������� �������� �� ������� �Purchasing Manager�. � �����
-- ������� �������� �� �������, � ��������� �������� ������ � ������ ������.

select
	E.BusinessEntityID,
	E.JobTitle,
	D.Name,
	EDP.StartDate,
	EDP.EndDate
from HumanResources.Employee as E
	inner join HumanResources.EmployeeDepartmentHistory as EDP
		on EDP.BusinessEntityID = E.BusinessEntityID
	inner join HumanResources.Department as D
		on D.DepartmentID = EDP.DepartmentID
where JobTitle = 'Purchasing Manager';
-- ----------------------------------------------------------------------------------------------

-- #2
-- ������� �� ����� ������ �����������, � ������� ��������� ������ ���������� ���� �� ���� ���.

select
	E.BusinessEntityID,
	E.JobTitle,
	count(Ep.RateChangeDate) as rateChangedCount
from HumanResources.Employee as E
	inner join HumanResources.EmployeePayHistory as EP
		on EP.BusinessEntityID = E.BusinessEntityID
	group by E.BusinessEntityID, E.JobTitle
having count(*) > 1;
-- ----------------------------------------------------------------------------------------------

-- #3
-- ������� �� ����� ������������ ��������� ������ � ������ ������. ������� ������ ����������
-- ����������. ���� ��������� ������ �� �������� � ������ � �� ��������� ����� ������.

-- tha same wityh min, avg instead of max(EPH.Rate) -> max(EPH.Rate) etc.
select
	D.DepartmentID,
	D.Name,
	max(EPH.Rate) as avgRate
from HumanResources.Employee as E
	inner join (
		select distinct
			EPH.BusinessEntityID,
			EPH.Rate,
			EPH.RateChangeDate
		from HumanResources.EmployeePayHistory as EPH
			where EPH.RateChangeDate = (
				select
					max(RateChangeDate)
				from HumanResources.EmployeePayHistory
					where BusinessEntityID = EPH.BusinessEntityID
					)
	) as EPH
		on EPH.BusinessEntityID = E.BusinessEntityID
	inner join (
		select
			E.BusinessEntityID,
			EDP.DepartmentID
		from HumanResources.Employee as E
			inner join HumanResources.EmployeeDepartmentHistory as EDP
				on EDP.BusinessEntityID = E.BusinessEntityID
		where EDP.EndDate is null
	) as EDH
		on EDH.BusinessEntityID = E.BusinessEntityID
	inner join HumanResources.Department as D
		on D.DepartmentID = EDH.DepartmentID
group by D.DepartmentID, D.Name;
-- ----------------------------------------------------------------------------------------------

-- Additional queries to implement current task #3

-- 1. all current rate for Employers
select distinct
	EPH.BusinessEntityID,
	EPH.Rate,
	EPH.RateChangeDate
from HumanResources.EmployeePayHistory as EPH
where EPH.RateChangeDate = (select max(RateChangeDate) from HumanResources.EmployeePayHistory where BusinessEntityID = EPH.BusinessEntityID)

-- 2. current department for each Employer
select
	E.BusinessEntityID,
	EDP.DepartmentID
from HumanResources.Employee as E
	inner join HumanResources.EmployeeDepartmentHistory as EDP
		on EDP.BusinessEntityID = E.BusinessEntityID
where EDP.EndDate is null;
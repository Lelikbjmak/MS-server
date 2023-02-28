-- Option 5

-- #3
-- Вывести на экран почасовые ставки сотрудников, с указанием максимальной ставки для каждого
-- отдела в столбце [MaxInDepartment]. В рамках каждого отдела разбейте все ставки на группы, таким
-- образом, чтобы ставки с одинаковыми значениями входили в состав одной группы.

select
	D.Name,
	EPH.BusinessEntityID,
	EPH.Rate,
	(select max(E.Rate) from HumanResources.EmployeePayHistory E
		inner join HumanResources.EmployeeDepartmentHistory ED
		on ED.BusinessEntityID = E.BusinessEntityID
			where ED.DepartmentID = D.DepartmentID) as maxRate,
	DENSE_RANK () over (
		partition by D.Name
		order by EPH.Rate asc
	) RateGroup
from HumanResources.EmployeePayHistory EPH
inner join HumanResources.EmployeeDepartmentHistory EDH
	on EDH.BusinessEntityID = EPH.BusinessEntityID
inner join HumanResources.Department D
	on D.DepartmentID = EDH.DepartmentID
where EDH.EndDate is null;
-- ------------------------------------------------------------------------------------------------------
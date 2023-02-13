-- #OPTION 2#

-- #1 
-- Вывести на экран список отделов, отсортированных по названию отдела в порядке Z-A. Вывести на
-- экран только 5 строк, начиная с 3-ей строки.

select DepartmentID, Name
	from HumanResources.Department
	order by (Name) desc
		offset 2 rows
		fetch next 5 rows only;
-- ----------------------------------------------------------------------------------------------

-- #2
-- Вывести на экран список неповторяющихся позиций, которые соответствуют первому уровню
-- позиций в организации (OrganizationLevel).

select distinct JobTitle from HumanResources.Employee
	where OrganizationLevel = 1;
-- ----------------------------------------------------------------------------------------------

-- #3
-- Вывести на экран сотрудников, которым исполнилось 18 лет в тот год, когда их приняли на работу.

select
	BusinessEntityID,
	JobTitle,
	Gender,
	BirthDate,
	HireDate
from HumanResources.Employee
	where DATEDIFF(YEAR, BirthDate, HireDate) = 18;
-- ----------------------------------------------------------------------------------------------

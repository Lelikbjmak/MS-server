-- #OPTION 2#

-- #1 
-- ������� �� ����� ������ �������, ��������������� �� �������� ������ � ������� Z-A. ������� ��
-- ����� ������ 5 �����, ������� � 3-�� ������.

select DepartmentID, Name
	from HumanResources.Department
	order by (Name) desc
		offset 2 rows
		fetch next 5 rows only;
-- ----------------------------------------------------------------------------------------------

-- #2
-- ������� �� ����� ������ ��������������� �������, ������� ������������� ������� ������
-- ������� � ����������� (OrganizationLevel).

select distinct JobTitle from HumanResources.Employee
	where OrganizationLevel = 1;
-- ----------------------------------------------------------------------------------------------

-- #3
-- ������� �� ����� �����������, ������� ����������� 18 ��� � ��� ���, ����� �� ������� �� ������.

select
	BusinessEntityID,
	JobTitle,
	Gender,
	BirthDate,
	HireDate
from HumanResources.Employee
	where DATEDIFF(YEAR, BirthDate, HireDate) = 18;
-- ----------------------------------------------------------------------------------------------

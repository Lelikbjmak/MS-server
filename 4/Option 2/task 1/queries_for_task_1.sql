-- Option 2

-- task 1
-- �������� �������� ���������, ������� ����� ���������� ������� ������� (�������� PIVOT),
-- ������������ ������ � ������������ ���� (Production.Product.Weight) �������� � ������
-- ������������ (Production.ProductSubcategory) ��� ������������� �����. ������ ������ ��������� �
-- ��������� ����� ������� ��������.
-- ����� �������, ����� ��������� ����� ��������� ��������� �������:
-- EXECUTE dbo.SubCategoriesByColor �[Black],[Silver],[Yellow]�

--create type colorList as table (color nvarchar(15));
--go

ALTER DATABASE [AdventureWorks2012]
SET COMPATIBILITY_LEVEL = 150;
go

declare @colorList nvarchar(max),
		@query nvarchar(max),
		@maxColorList nvarchar(max);

set @colorList = STUFF((SELECT distinct ',' + QUOTENAME(P.Color) 
            FROM Production.Product P
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'');
		
set @maxColorList = Stuff((SELECT ', max(' + value + ') ' + value
            FROM string_split(@colorList, ',')
			FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'');

set @query = 'select
	Name,
	' + @maxColorList + '
from (select PS.Name, P.Weight, P.Color from Production.Product P
	inner join Production.ProductSubcategory PS
	on PS.ProductSubcategoryID = P.ProductSubcategoryID) as PS
	pivot (
		max(Weight)
			for Color in (' + @colorList + ')
			) PP
group by Name;'

execute(@query);
go

create proc maxVeightForProduction(
					@colorList nvarchar(max))
as
	begin
		declare @query nvarchar(max),
		@maxColorList nvarchar(max);

		set @maxColorList = Stuff((SELECT ', max(' + value + ') ' + value
            FROM string_split(@colorList, ',')
			FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'');

		set @query = 'select
			Name,
			' + @maxColorList + '
		from (select PS.Name, P.Weight, P.Color from Production.Product P
			inner join Production.ProductSubcategory PS
			on PS.ProductSubcategoryID = P.ProductSubcategoryID) as PS
			pivot (
				max(Weight)
					for Color in (' + @colorList + ')
					) PP
		group by Name';

		execute(@query);

	end
go

execute maxVeightForProduction '[Black],[Silver],[Yellow]';
-- ---------------------------------------------------------------------------------------------------
-- Option 2

-- task 2
-- ������� �������� ����� [ProductID], [Name], [ProductNumber] �� ������� [Production].[Product] �
-- ���� xml, ������������ � ����������. ������ xml ������ ��������������� �������:
-- <Products>
-- <Product ID="1">
-- <Name>Adjustable Race</Name>
-- <ProductNumber>AR-5381</ProductNumber>
-- </Product>
-- <Product ID="2">
-- <Name>Bearing Ball</Name>
-- <ProductNumber>BA-8327</ProductNumber>
-- </Product>
-- </Products>
-- ������� �������� ���������, ������������ �������, ����������� �� xml ����������
-- ��������������� ����. ������� ��� ��������� ��� ����������� �� ������ ���� ����������.
declare @ProductsXML XML
set @ProductsXML = (select
			ProductID as '@ID',
			Name,
			ProductNumber
	from Production.Product
		for xml
			path('Product'),
			root('Products'),
			ELEMENTS XSINIL)

select @ProductsXML;
go

create proc getTableFromXmlVar(@XML XML)
as
	begin
		
		declare @xmlTable Table(
		ProductID int,
		Name nvarchar(50),
		ProductionNumber nvarchar(25)
		);
		insert into @xmlTable
		SELECT
			T.c.value('@ID[1]', 'int') ProductId,
			T.c.value('Name[1]', 'nvarchar(50)') Name,
			T.c.value('ProductNumber[1]', 'nvarchar(25)') ProductNumber
		FROM  @XML.nodes('/Products/Product') T(c)

		select * from @xmlTable X;
	end
go

declare @ProductsXML XML
set @ProductsXML = (select
			ProductID as '@ID',
			Name,
			ProductNumber
	from Production.Product
		for xml
			path('Product'),
			root('Products'),
			ELEMENTS XSINIL)

execute getTableFromXmlVar @ProductsXML;
go


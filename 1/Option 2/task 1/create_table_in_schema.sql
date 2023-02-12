use l1;

create table persons(
Id int identity(1,1),
name nvarchar(50)
);

insert into persons values('Tom'),('Bob');

select * from persons;


create table l1schema.test(
Id int identity(1,1)
);

USE [master];
GO

BACKUP DATABASE [l1]
TO DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\l1DB.bak' 
WITH NOFORMAT, NOINIT,
NAME = N'l1DB-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10;
GO

drop database l1;
declare @ID int = 
(
	select max(id)+1
	from typecontent
)
declare @Desc varchar(50) = 'IP Adress'
insert into TypeContent 
values (@ID, @Desc)

select * from TypeContent
select * from PersonalInfo

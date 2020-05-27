/*Time In Data*/
declare @TimeIn TABLE (RowNum int, EventDate datetime);
insert into @TimeIn
select ROW_NUMBER() over(order by id) RowNum,tic.EventDate
from Calendar tic 
where tic.TypeContentID = (select id from TypeContent where ExternalID = 'TimeStampIn')
and (CONVERT(VARCHAR(10), tic.EventDate, 101) = CONVERT(VARCHAR(10), GETDATE(), 101))/*Make sure to only data from today*/
order by tic.EventDate asc /*Ordering so that I number the rows correctly*/

/*Time Out Data*/
declare @TimeOut TABLE (RowNum int, EventDate datetime);
insert into @TimeOut
select ROW_NUMBER() over(order by id) RowNum,toc.EventDate
from Calendar toc 
where toc.TypeContentID = (select id from TypeContent where ExternalID = 'TimeStampOut')
and (CONVERT(VARCHAR(10), toc.EventDate, 101) = CONVERT(VARCHAR(10), GETDATE(), 101))
order by toc.EventDate asc

/*s=second;m=minute;h=hour*/
Declare @s int;
declare @m int;
declare @h int;

/*Get Seconds*/
SET @s=
(
	select 
	sum
	(
        /*Converting to seconds*/
		(DATEPART(hour, CONVERT(time,isnull(TimeOut.EventDate,GETDATE())-isnull(Timein.EventDate,0)))*3600)+
		(DATEPART(minute, CONVERT(time,isnull(TimeOut.EventDate,GETDATE())-isnull(Timein.EventDate,0)))*60)+
		DATEPART(second, CONVERT(time,isnull(TimeOut.EventDate,GETDATE())-isnull(Timein.EventDate,0)))
	)
    /*Outer join to take into out for timing in*/
	from @TimeIn TimeIn full outer join @TimeOut TimeOut on TimeIn.RowNum = TimeOut.RowNum
)

/*Get Hours*/
if (@s >= 3600)
begin
	set @h = @s/3600;
	set @s = @s%3600;
end
else
begin
	set @h = 0;
end

/*Get Minutes*/
if (@s >= 60)
begin
	set @m = @s/60;
	set @s = @s%60;
end
else
begin
	set @m = 0;
end

/*Get Time*/
select concat(convert(varchar(10),@h),':',convert(varchar(10),@m),':',convert(varchar(10),@s)) [Time]
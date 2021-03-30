select COUNT(case when is_online = 1 then 1 end) as active, COUNT(case when is_online = 0 then 1 end) as offline
from sys.dm_os_schedulers where status NOT LIKE ('%DAC%');
select * from sys.dm_os_schedulers where status NOT LIKE ('%HIDDEN%') and status NOT LIKE ('%DAC%')
order by is_online;
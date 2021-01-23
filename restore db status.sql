SELECT percent_complete,* 
FROM sys.dm_exec_requests 
where command = 'restore database'

--kill 70
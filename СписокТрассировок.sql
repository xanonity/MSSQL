SELECT * FROM sys.fn_trace_getinfo(0) -- �������� ��� ������

SELECT * FROM sys.fn_trace_getinfo(3) -- �������� ������ � ID = 3

exec sp_trace_setstatus 3, 1 -- �������� ������ � ID = 3
exec sp_trace_setstatus 3, 0 -- ��������� ������ � ID = 3



select * from sys.dm_xe_sessions -- ���������� ����������� Extended events

ALTER EVENT SESSION [session_name] ON SERVER  STATE = START -- ��������� ������ Extended events 
ALTER EVENT SESSION [session_name] ON SERVER  STATE = STOP -- ���������� ������ Extended events
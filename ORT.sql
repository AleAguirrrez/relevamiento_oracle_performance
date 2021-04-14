select round(avg("ORT/Tx(s)"),2), round(avg("Ex/s"),2),  round(avg("SQL_RT"),4) from (
	select  snap_time,inst_id,
	"Ex/s", "Tx/s", "ORT/Tx(s)", "SQL_RT", "%DbT/s", "%Wait/DbT",
	"%Cpu/DbT","PhysicalReads/s" ,"PhysicalWrites/s", "CpuUsage per seg(cs/s)","CpuUsage per Tx(Tx/s) ","IOPS(read)","IOPS(write)"--,"NetworkB/S"
	from
	(select end_time snap_time,instance_number inst_id,
	round(max(decode(metric_id,2121,average,null)),2) "Ex/s",
	round(max(decode(metric_id,2003,average,null)),2) "Tx/s",
	round(max(decode(metric_id,2109,average/100,null)),2) "ORT/Tx(s)",
	round(max(decode(metric_id,2106,average/100,null)),5) "SQL_RT",
	round(max(decode(metric_id,2123,average,null)),2) "%DbT/s",
	round(max(decode(metric_id,2107,average,null)),2) "%Wait/DbT",
	round(max(decode(metric_id,2108,average,null)),2) "%Cpu/DbT" ,
	round(max(decode(metric_id,2004,average,null)),2) "PhysicalReads/s" ,
	round(max(decode(metric_id,2006,average,null)),2) "PhysicalWrites/s",
	round(max(decode(metric_id,2075,average,null)),2) "CpuUsage per seg(cs/s)",
	round(max(decode(metric_id,2076,average,null)),2) "CpuUsage per Tx(Tx/s) ",
	round(max(decode(metric_id,2092,average,null)),2) "IOPS(read)",
	round(max(decode(metric_id,2100,average,null)),2) "IOPS(write)",
	round(max(decode(metric_id,2036,average,null)),2) "LongTS/s",
    round(max(decode(metric_id,2040,average,null)),2) "FullIdxScan/s",
     round(max(decode(metric_id,2053,average,null)),2) "RowsXsort",
     round(max(decode(metric_id,2057,average,null)),2) "HostCPU%"
	from dba_hist_sysmetric_summary
	group by end_time,instance_number
	order by 1)
	where (snap_time >= to_date('19-01-2021 14:55','dd-mm-yyyy hh24:mi')
	 and  snap_time <= to_date('29-03-2021 15:01','dd-mm-yyyy hh24:mi')  )
--     or 
--     ( snap_time >= to_date('05-03-2021 17:13','dd-mm-yyyy hh24:mi')
--     and  snap_time <= to_date('05-03-2021 17:34','dd-mm-yyyy hh24:mi') ) 
--     order by snap_time;
 and  to_number(to_char(snap_time,'HH24')) >= 8  and to_number(to_char(snap_time,'HH24')) < 19--Horario Online;
-- and ( to_number(to_char(snap_time,'HH24')) < 8 or  to_number(to_char(snap_time,'HH24')) >=19); --Horario Batch
);
-- _
select * from V$sysmetric;
and to_number(to_char(snap_time,'HH24')) between 8 and 19);--HORARIO ONLINE
and to_number(to_char(snap_time,'HH24')) between 19 and 8);--HORARIO BATCH
--select avg("ORT/Tx(s)"), avg("Tx/s"),  avg("SQL_RT") from (
;
select * from dba_hist_parameter where parameter_name='db_writer_processes' order by snap_id desc;
select  snap_time,
"Uc/s", "Tx/s", "ORT/Tx(s)", "SQL_RT", "%DbT/s", "%Wait/DbT",
"%Cpu/DbT","PhysicalReads/s" ,"PhysicalWrites/s", "CpuUsage per seg(cs/s)","CpuUsage per Tx(Tx/s) "
from
(select begin_time snap_time,
round(max(decode(metric_id,2026,value,null)),2) "Uc/s",
round(max(decode(metric_id,2003,value,null)),2) "Tx/s",
round(max(decode(metric_id,2109,value/100,null)),2) "ORT/Tx(s)",
round(max(decode(metric_id,2106,value,null)),2) "SQL_RT",
round(max(decode(metric_id,2123,value,null)),2) "%DbT/s",
round(max(decode(metric_id,2107,value,null)),2) "%Wait/DbT",
round(max(decode(metric_id,2108,value,null)),2) "%Cpu/DbT" ,
round(max(decode(metric_id,2004,value,null)),2) "PhysicalReads/s" ,
round(max(decode(metric_id,2006,value,null)),2) "PhysicalWrites/s",
round(max(decode(metric_id,2075,value,null)),2) "CpuUsage per seg(cs/s)",
round(max(decode(metric_id,2076,value,null)),2) "CpuUsage per Tx(Tx/s) "
from dba_hist_sysmetric_history
group by begin_time
order by 1)
where snap_time >= to_date('27-08-2015 14','dd-mm-yyyy hh24')
 and  snap_time <= to_date('27-08-2015 17','dd-mm-yyyy hh24')
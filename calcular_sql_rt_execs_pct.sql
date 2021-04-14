select parsing_schema_name
--,sum(ELAPSED_TIME)/sum(execs),sum(sum(ELAPSED_TIME)/sum(execs)) over () tot
,round((sum(ELAPSED_TIME)/sum(execs))*100 / (sum(sum(ELAPSED_TIME)/sum(execs)) over ()),4) pct_sql_rt
--,sum(sum(execs)) over () tot_execs
,round(sum(execs)*100 /(sum(sum(execs)) over ()),4) pct_execs from  (select  ss.sql_id,
round(sum(ss.elapsed_time_delta)/1000000) elapsed_time,
--round(sum(ss.elapsed_time_delta)/1000000/avg(db_time)*100,2) db_time,
ss.parsing_schema_name,
round(sum(ss.cpu_time_delta)/1000000) cpu_time,
sum(ss.executions_delta) execs,
rtrim(round(sum(ss.elapsed_time_delta)/sum(decode(ss.executions_delta,0,1,ss.executions_delta))/1000000,3),'0') elap_x_exec,
sum(ss.buffer_gets_delta) buffer_gets,
round(sum(ss.buffer_gets_delta)/decode(sum(ss.executions_delta),0,1,sum(ss.executions_delta)),2) get_x_exec,
sum(ss.rows_processed_delta) rows_processed,
sum(ss.disk_reads_delta) disk_reads,
sum(ss.iowait_delta) iowait,
rtrim(round(sum(ss.iowait_delta)/sum(decode(ss.executions_delta,0,1,ss.executions_delta))/1000000,3),'0') io_x_exec,
sum(ss.ccwait_delta) ccwait,
sum(ss.clwait_delta) clwait,
sum(ss.apwait_delta) apwait,
sum(ss.px_servers_execs_delta) px_servers,
sum(ss.direct_writes_delta) direct_writes,
count(1) snap_ref_cnt
from dba_hist_sqlstat ss,
     dba_hist_sqltext st,
     dba_hist_snapshot s
where s.snap_id = ss.snap_id
  and ss.sql_id = st.sql_id
  and  s.end_interval_time >= to_date('01-01-2021 00:45','dd-mm-yyyy hh24:mi')
and  s.end_interval_time <= to_date('30-03-2021 00:50','dd-mm-yyyy hh24:mi')
 and  to_number(to_char(s.end_interval_time,'HH24')) >= 8  and to_number(to_char(s.end_interval_time,'HH24')) < 19--Horario Online;
-- and ( to_number(to_char(s.end_interval_time,'HH24')) < 8 or  to_number(to_char(s.end_interval_time,'HH24')) >=19); --Horario Batch
group by ss.sql_id,parsing_schema_name
order by elapsed_time desc) 
--where  sql_id in (select distinct sql_id from dba_hist_sql_plan where object_owner like 'ACE01')
group by parsing_schema_name order by 1 ;
--EMERDBCPER
--ACE01_USER1
--ACE01--

66.1004051107715480206616546076950823518
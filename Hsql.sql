select  snap_time, instance_number inst,
       sql_text,
       elapsed_time,
       cpu_time,
       executions,
       elap_x_exec,
       buffer_gets,
       get_x_exec,
       disk_reads,
       px_servers,
       direct_writes,
       iowait,
       rows_processed,
       ccwait,
       clwait,
       apwait,
       plan_hash_value,
       optimizer_cost,
       opt_env_hash_value
from
(select  unique
s.end_interval_time snap_time,s.instance_number,
to_char(substr(st.sql_text,1,50)) sql_text,
round(ss.elapsed_time_delta/1000000) elapsed_time,
round(ss.cpu_time_delta/1000000) cpu_time,
ss.executions_delta executions,
round(ss.elapsed_time_delta/decode(ss.executions_delta,0,1,ss.executions_delta)/1000000,4) elap_x_exec,
ss.buffer_gets_delta buffer_gets,
round(ss.buffer_gets_delta/decode(ss.executions_delta,0,1,ss.executions_delta),1) get_x_exec,
ss.disk_reads_delta disk_reads,
ss.rows_processed_delta rows_processed,
ss.direct_writes_delta direct_writes,
ss.iowait_delta iowait,
ss.ccwait_delta ccwait,
ss.clwait_delta clwait,
ss.apwait_delta apwait,
ss.px_servers_execs_delta px_servers,
to_char(ss.plan_hash_value) plan_hash_value,
ss.optimizer_cost optimizer_cost,
to_char(ss.optimizer_env_hash_value) opt_env_hash_value
from dba_hist_sqlstat ss,
     dba_hist_sqltext st,
     dba_hist_snapshot s
where s.snap_id = ss.snap_id
  and ss.sql_id = st.sql_id(+)
  and ss.instance_number=s.instance_number
  and ss.elapsed_time_delta >0
  and ss.sql_id = '9ycz27wc8x4sx'
order by snap_time desc);

select * from dba_hist_sqltext where sql_id='2j7pfb2qgn5c4';

SELECT DBMS_SQLTUNE.report_sql_monitor(
  sql_id       => 'crwc6m8j9gkdk',
  type         => 'TEXT',
  report_level => 'ALL') AS report
FROM dual;
select * from V$version;
select * from table(dbms_xplan.display_awr('crwc6m8j9gkdk',null,null,'Advanced'));
create index SICCCR.IX_PARID_ADDTID_ADDID on SICCCR.TBL_ADDRESSES(PARTY_ID,ADDRESS_TYPE_ID,ADDRESS_ID) NOLOGGING INVISIBLE;
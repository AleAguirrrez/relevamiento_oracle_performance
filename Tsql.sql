 select ss.sql_id,s.instance_number inst,ss.parsing_schema_name,
      to_char(substr(st.sql_text,1,50)) sql_text,
round(sum(ss.elapsed_time_delta)/1000000) elapsed_time,
--round(sum(ss.elapsed_time_delta)/1000000/avg(db_time)*100,2) db_time,
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
  and ss.sql_id = st.sql_id(+)
  and s.instance_number=ss.instance_number
  and ss.elapsed_time_delta >0
  and  s.end_interval_time >= to_date('03-08-2020 11:45','dd-mm-yyyy hh24:mi')
and  s.end_interval_time <= to_date('08-07-2020 18:10','dd-mm-yyyy hh24:mi')
group by ss.sql_id,to_char(substr(st.sql_text,1,50)),s.instance_number,ss.parsing_schema_name
order by elapsed_time desc;




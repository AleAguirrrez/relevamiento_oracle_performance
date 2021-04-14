		--BLOQUEOS
		select o.inst_id,ob.object_name,locked_mode,os_user_name,o.process,sid,serial#,sql_id,prev_sql_id,username,s.status,event,blocking_session,ROW_WAIT_OBJ#,machine,program,last_call_et,logon_time from gV$locked_object o, gV$session s ,dba_objects ob
		where s.sid=o.session_id and ob.object_id=o.object_id  and o.inst_id=s.inst_id and object_name='AGENDA'  order by logon_time desc;
		set linesize 600
		set pagesize 4000
		col maxt format a26
		col mint format a26
		col event format a35
		select max(sample_time) maxt,min(sample_time) mint,sql_id,event,blocking_session,count(1)*10 cnt from
		dba_hist_active_sess_history where sample_time > sysdate -10 and event like 'enq: TX%' group by sql_id,event,blocking_session order by cnt desc;
		
		select max(sample_time) maxt,min(sample_time) mint,sql_id,event,blocking_session,count(1)*10 cnt 
		from dba_hist_active_sess_history
		where sample_time > to_date('10/04/2020 03:40:00','DD/MM/YYYY HH24:MI:SS') 
		and sample_time < to_date('10/04/2020 06:50:00','DD/MM/YYYY HH24:MI:SS')and session_id=3560
		group by sql_id,event,blocking_session order by cnt desc;
		
			
select username,sql_id,prev_sql_id,status,event,machine,last_call_et,logon_time from gV$session where
  username like 'QLIK%' order by last_call_et  desc;
        select 'alter system kill session '''||sid||','||serial#||',@'||inst_id||''' immediate;'inst_id,sid,serial#,sql_id,prev_sql_id,username,status,event,blocking_session,ROW_WAIT_OBJ#,machine,program,last_call_et,logon_time from gV$session where username is not null and sql_id='dhvrnwr5j6cdd' order by last_call_et desc;
		select inst_id,sid,serial#,sql_id,prev_sql_id,username,status,event,blocking_session,blocking_instance,ROW_WAIT_OBJ#,ROW_WAIT_BLOCK#,machine,program,last_call_et from gV$session where username is not null and
        (  event like 'enq: TX%')order by last_call_et desc;
		
select inst_id,sid,serial#,sql_id,prev_sql_id,username,status,event,blocking_session,ROW_WAIT_OBJ#,machine,program,last_call_et,logon_time from gV$session where  
username=user and sid=2616;
			SELECT distinct w.tx, l.inst_id, l.sid, l.lmode, l.request,w.SECONDS_IN_WAIT
	 FROM  ( SELECT p2,p3,
		 'TX-'||lpad(ltrim(p2raw,'0'),8,'0')||'-'||lpad(ltrim(p3raw,'0'),8,'0') TX,SECONDS_IN_WAIT
		  FROM gv$session_wait 
		 WHERE event='enq: TX - row lock contention'
		   and state='WAITING'
	  ) W, 
	  gv$lock L WHERE l.type(+)='TX'    and l.id1(+)=w.p2    and l.id2(+)=w.p3  ORDER BY SECONDS_IN_WAIT desc, tx, lmode desc, request desc
;
select * from GV$SQL_BIND_CAPTURE where sql_id='g1zzpvvc6wjhy' ;


select b.*,s.sid,s.serial#,last_call_et from gV$SQL_BIND_CAPTURE b, gv$session s where b.address=s.SQL_ADDRESS and s.inst_id=b.inst_id and s.sql_id='g1zzpvvc6wjhy' 
and b.child_number=s.SQL_CHILD_NUMBER and s.event like   'enq%' and b.name in (':PARAMETER10X',':PARAMETER3X') and value_string is not null and last_call_et >10 order by last_captured desc;
select b.sql_text, a.bind_vars, c.datatype, c.value
    from gv$sql_cursor a, gv$sql b, gv$sql_bind_data c
    where b.address = a.parent_handle
      and a.curno = c.cursor_num --and b.sql_id='g1zzpvvc6wjhy'
      ;
  
select * from dict where table_name like '%BIND%';
SELECT l1.inst_id,s1.status,s1.username || '@' || s1.machine
    || ' ( SID=' || s1.sid || ' )  is blocking '
    || s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS blocking_status,l2.inst_id,s2.status
    FROM gv$lock l1, gv$session s1, gv$lock l2, gv$session s2
    WHERE s1.sid=l1.sid AND s2.sid=l2.sid and l1.inst_id=s1.inst_id and s2.inst_id=l2.inst_id
    AND l1.BLOCK=1 AND l2.request > 0
    AND l1.id1 = l2.id1
    AND l1.id2 = l2.id2;
		select inst_id,sid,serial#,sql_id,prev_sql_id,username,status,event,blocking_session,ROW_WAIT_OBJ#,machine,program,last_call_et,logon_time from gV$session where (serial# in (9603) ) or (serial# in (51325) ) ;
		select sid,serial#,sql_id,prev_sql_id,username,status,event,blocking_session,ROW_WAIT_OBJ#,machine,program from gV$session where username is not null and event='Backup: MML restore backup piece';
		--Monitoreo de ASH
        alter system kill session '977,45026,@2' immediate;
        select * from dba_hist_sqltext where sql_id='dwq77f1gwbrnp';
select SQL_ID,SQL_PROFILE,SQL_PLAN_BASELINE,PLAN_HASH_VALUE,EXECUTIONS,ELAPSED_TIME,round(ELAPSED_TIME/1000000/decode(EXECUTIONS,0,1,executions),4) elap,DISK_READS,OPTIMIZER_COST,buffer_gets,last_active_time,sql_text
 from V$sql where sql_id in ('9zg9qd9bm4spu','9ugbqsmzak521','1hagytpxgb6jx','gtctma5ss9rdb','4601ggwbuy3hn','2upffnamx89xq','7qg3bqsq6bpda');
select * from dba_objects where object_id in (144851,109690,93905);
        select inst_id,nvl(event,'ON CPU'),sql_id,current_obj#,blocking_session, count(*) total_wait_time,round((count(*))/(sum(count(*)) over() ) *100,2) pct
        from gV$active_session_history a
--        where a.sample_time >= to_date('07/05/2018 11:19','DD/MM/YYYY HH24:MI') and a.sample_time <= to_date('07/05/2018 11:25','DD/MM/YYYY HH24:MI')  and user_id in (select user_id from dba_users where username='CRM_AMX_CENAM_CR_FU')  --and sql_id='dhvrnwr5j6cdd'
       where a.sample_time >= sysdate -60/60/24 --and user_id in (select user_id from dba_users where username='OGGUSER')
   and sql_id='9ugbqsmzak521'
        group by event,sql_id,inst_id,current_obj#,blocking_session
        order by total_wait_time desc;
        
        
               select nvl(event,'ON CPU'),sql_id,sql_exec_id,session_id,session_serial#,blocking_session,BLOCKING_SESSION_SERIAL#,BLOCKING_INST_ID,BLOCKING_SESSION_STATUS, count(*)*10 total_wait_time,round((count(*))/(sum(count(*)) over() ) *100,2) pct,max(sample_time),min(sample_time) mini
        from V$active_session_history a
        where a.sample_time >= to_date('07/05/2018 7:00','DD/MM/YYYY HH24:MI')
        and a.sample_time <= to_date('07/05/2018 07:21','DD/MM/YYYY HH24:MI') and sql_id='g1zzpvvc6wjhy'
        group by event,sql_id,sql_exec_id,session_id,session_serial#,blocking_session,BLOCKING_SESSION_SERIAL#,BLOCKING_INST_ID,BLOCKING_SESSION_STATUS--,sql_plan_hash_value
        order by total_wait_time desc;
		select inst_id,sql_id,sql_exec_id,session_id, count(*) total_wait_time,round((count(*))/(sum(count(*)) over() ) *100,2) pct,max(sample_time),min(sample_time) mini
		from gV$active_session_history a
		where a.sample_time >= to_date('29/12/2016 20:16','DD/MM/YYYY HH24:MI') --and sql_id='dhvrnwr5j6cdd'
		     and (session_id=1382 and session_serial#=31739 and inst_id=2)
       -- or (session_id=411 and session_serial#=24229 and inst_id=1)
		group by sql_id,inst_id,session_id,sql_exec_id
		order by mini desc;
        
        select inst_id,sql_id, count(*) total_wait_time,round((count(*))/(sum(count(*)) over() ) *100,2) pct,max(sample_time),min(sample_time) mini
        from gV$active_session_history a
        where a.sample_time >= to_date('29/12/2015 20:10','DD/MM/YYYY HH24:MI')  and event like 'enq: TX%'
        group by event,inst_id,sql_id
        order by pct desc;
select * from dba_objects where object_id=64467;
		select nvl(event,'ON CPU'),sql_id,object_name,object_type, count(*) total_wait_time,round((count(*))/(sum(count(*)) over() ) *100,2) pct,sql_plan_hash_value
		from V$active_session_history a,dba_objects o
		where a.sample_time >= to_date('10/06/2015 07:30','DD/MM/YYYY HH24:MI')
		--where a.sample_time >= sysdate - 10/60/24
        and top_level_sql_id='99nu1n9usfzsf'
		and o.object_id=a.current_obj#
		group by event,sql_id,sql_plan_hash_value,object_name,object_type
		order by total_wait_time desc;
        
        
        -------------------------------------------------------------------
        ---HISTORICO ---------------------------------------------------
        --------------------------------------------------------------------
                select nvl(event,'ON CPU'),sql_id,object_name,object_type, count(*) total_wait_time,round((count(*))/(sum(count(*)) over() ) *100,2) pct,sql_plan_hash_value
        from DBA_HIST_active_sess_history a,dba_objects o
        where a.sample_time >= to_date('12/06/2015 07:30','DD/MM/YYYY HH24:MI')
        and a.sample_time <= to_date('12/06/2016 18:30','DD/MM/YYYY HH24:MI')
        and sql_id='fmkgk0spjnwjq'
        and o.object_id=a.current_obj#
        group by event,sql_id,sql_plan_hash_value,object_name,object_type
        order by total_wait_time desc;
        
            select sql_id,sql_exec_id, count(*)*10 total_wait_time,round((count(*))/(sum(count(*)) over() ) *100,2) pct,max(sample_time),min(sample_time) mini
        from dba_hist_active_sess_history a
        where a.sample_time >= to_date('01/05/2018 00:00','DD/MM/YYYY HH24:MI')
        and a.sample_time <= to_date('07/05/2018 07:00','DD/MM/YYYY HH24:MI') and sql_id='SQL_ID'
        group by sql_id,sql_exec_id--,sql_plan_hash_value
        order by total_wait_time desc;

set colsep ';'
set linesize 600;
set pagesize 40000;
select io.instance_number inst,end_interval_time snap_time, round(max(decode(readtim,0,1,readtim)/decode(phyrds,0,1,phyrds))*10,2)  PROM_READ_TIME,
round(avg(decode(writetim,0,1,writetim)/decode(phywrts,0,1,phywrts))*10,2) "PROM_WRITE_TIME(ms)",
round(avg(phyrds),2) PROM_PHYSICAL_READ,
round(avg(phywrts),2) PROM_PHYSICAL_WRITES from (select snap_id,instance_number,file#,filename,tsname,block_size,
(phyrds-lead(phyrds) over (partition by file#,instance_number order by snap_id desc)) phyrds,
(phywrts-lead(phywrts) over (partition by file#,instance_number order by snap_id desc)) phywrts,
(readtim-lead(readtim) over (partition by file#,instance_number order by snap_id desc)) readtim,
(writetim-lead(writetim) over (partition by file#,instance_number order by snap_id desc)) writetim from DBA_HIST_FILESTATXS ) io, dba_hist_snapshot s
where io.snap_id=s.snap_id  
and io.instance_number=s.instance_number
group by end_interval_time,io.instance_number
order by end_interval_time desc;



select  b.inst_id,MAX(b.AVERAGE_READ_TIME)*10 PROM_READ_TIME, AVG(b.AVERAGE_WRITE_TIME)*10 PROM_WRITE_TIME, AVG(b.PHYSICAL_READS)*10 PROM_PHYSICAL_READ, AVG(b.PHYSICAL_WRITES)*10 PROM_PHYSICAL_WRITES from gV$dbfile a, gv$filemetric b where a.file#=b.file_id
and a.inst_id=b.inst_id group by b.inst_id;

select username,a.sql_id,SQL_EXEC_START, count(*)*10 total_wait_time--,round((count(*))/(sum(count(*)) over() ) *100,2) pct,max(sample_time) end_time,min(sample_time) start_time
,(round((cast(max(sample_time) as date) - date '1970-01-01')*24*60*60) - round((cast(min(sample_time) as date) - date '1970-01-01')*24*60*60) ) as Duration_seconds
,( select sql_text from dba_hist_sqltext s where a.sql_id=s.sql_id ) sql_txt
        from dba_hist_active_sess_history a, dba_users u ,dba_hist_sqltext s
        where a.sample_time >= to_date('01/04/2021 00:00','DD/MM/YYYY HH24:MI') -- Fecha inicio del periodo
        and a.sample_time <= to_date('17/04/2021 07:00','DD/MM/YYYY HH24:MI') -- Fecha Fin del periodo
        and u.user_id=a.user_id 
        and u.username in ( 'SRVCBI','SRVC_TABLEAU') -- SRVCBI(DISCOVERER)   SRVC_TABLEAU(TABLEAU)
        group by a.sql_id,sql_exec_id,u.username,SQL_EXEC_START--,sql_plan_hash_value
        order by total_wait_time desc;-- hola
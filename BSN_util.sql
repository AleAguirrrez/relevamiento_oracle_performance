***************************************************************************************************
-- Cargar baseline desde AWR
***************************************************************************************************
begin
   dbms_sqltune.drop_sqlset(sqlset_name => 'XXXXXXX');
    dbms_sqltune.create_sqlset(sqlset_name => 'XXXXXXXXXXX', description =>'11g workload'); 
end;
/
select user from dual;
declare 
   mycur dbms_sqltune.sqlset_cursor; 
begin 
  open mycur for 
  select value (P) 
  from table(DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY(begin_snap=> 16770, end_snap => 16812 ,basic_filter => 'parsing_schema_name = ''COLLECTIONSCLAROFIJACO'' and sql_id = ''6c2ugbpkrbjby'' ')) P;
  dbms_sqltune.load_sqlset(sqlset_name => '6c2ugbpkrbjby' , populate_cursor => mycur); 
end; 
/

select * from user_sqlset_statements where sqlset_name = '6c2ugbpkrbjby' ;

DECLARE
  l_plans_altered  PLS_INTEGER;
  Begin
l_plans_altered:=DBMS_SPM.LOAD_PLANS_FROM_SQLSET (sqlset_name => '6c2ugbpkrbjby', fixed=> 'NO',enabled => 'YES');
   DBMS_OUTPUT.put_line('Plans Altered: ' || l_plans_altered);
END;
/
SELECT * FROM dba_sql_plan_baselines WHERE signature IN (SELECT force_matching_signature FROM dba_hist_sqlstat WHERE sql_id='g4sdyfcx7hn7c') order by created desc ;
SELECT * FROM dba_sql_profiles WHERE signature IN (SELECT force_matching_signature FROM dba_hist_sqlstat WHERE sql_id='g4sdyfcx7hn7c') order by created desc ;
select  SQL_ID,SQL_PROFILE,SQL_PLAN_BASELINE,PLAN_HASH_VALUE,EXECUTIONS,ELAPSED_TIME,round(ELAPSED_TIME/1000000/decode(EXECUTIONS,0,1,executions),4) elap,DISK_READS,OPTIMIZER_COST,buffer_gets,last_active_time,sql_text  from gV$sql 
where sql_id in ('g4sdyfcx7hn7c') order by last_active_time desc;
select * from table(dbms_xplan.display_awr('g4sdyfcx7hn7c',2403578997));
select  SQL_ID,SQL_PROFILE,SQL_PLAN_BASELINE,PLAN_HASH_VALUE,EXECUTIONS,ELAPSED_TIME,DISK_READS,OPTIMIZER_COST,buffer_gets,last_active_time  from gV$sql order by buffer_gets desc,last_active_time desc;--
SELECT *
FROM   TABLE(DBMS_XPLAN.display_sql_plan_baseline(plan_name=>'SQL_PLAN_cufsbh6bsv1zj06fe2d6b'));

DECLARE
  l_plans_altered  PLS_INTEGER;
BEGIN
  l_plans_altered := DBMS_SPM.alter_sql_plan_baseline(
    sql_handle      => 'SQL_a718cd482422b978',
    plan_name       => 'SQL_PLAN_af66d90k25fbs56022e11',
    attribute_name  => 'fixed',
    attribute_value => 'YES');

  DBMS_OUTPUT.put_line('Plans Altered: ' || l_plans_altered);
END;
/

SET SERVEROUTPUT ON
DECLARE
  l_plans_dropped  PLS_INTEGER;
BEGIN
  l_plans_dropped := DBMS_SPM.drop_sql_plan_baseline (
    sql_handle => NULL,
    plan_name  => 'SQL_PLAN_af66d90k25fbs56022e11');
    
    l_plans_dropped := DBMS_SPM.drop_sql_plan_baseline (
    sql_handle => NULL,
    plan_name  => 'SQL_PLAN_af66d90k25fbs67a4fd1b');
  DBMS_OUTPUT.put_line(l_plans_dropped);
END;
/

--UNPINNED sql_id from cursor cache
DECLARE
  name varchar2(50);
  version varchar2(3);
BEGIN
  select regexp_replace(version,'\..*') into version from v$instance;

  if version = '10' then
    execute immediate 
      q'[alter session set events '5614566 trace name context forever']'; -- bug fix for 10.2.0.4 backport
  end if;

  select address||','||hash_value into name
  from v$sqlarea 
  where sql_id like 'cdx3wx5n926g3';

  sys.dbms_shared_pool.purge(name,'C',1);

END;
/


ALTER session SET "_plan_verify_improvement_margin"=200;
SELECT DBMS_SPM.evolve_sql_plan_baseline(sql_handle => 'SQL_b9f6b5a880681b31') FROM   dual;

select * frpom 


--select * from dba_indexes where index_name in ('IDX$$_34390001','FK_163_167','FK_163_168','FK_163_165','IDX_UK_INBOX_SECURITY'   )--
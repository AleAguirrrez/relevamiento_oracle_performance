	--Para borrar la tarea
	execute DBMS_SQLTUNE.drop_tuning_task ('Useless_Task');

	DECLARE
	my_task_tuning_prod
	varchar2(100);
	sql_txt
	clob;
	BEGIN
	sql_txt:= 'Select * from PROD.VW_ETIQUETA where etiqueta = 156649466';
	my_task_tuning_prod:= DBMS_SQLTUNE.CREATE_TUNING_TASK(sql_text=> sql_txt,user_name => 'PROD', 
	scope => 'COMPREHENSIVE',time_limit=> 600,task_name => 'Useless_Task',description=> 'Tune Useless Query Task');
	END;
	/

	--Una vez ejecutado, El ‘Useless Task’ Se creara. Ahora debemos ejecutar la tarea recien creada.

	execute dbms_sqltune.execute_tuning_task (task_name => 'Useless_Task');

	--Para ver el reporte

	/*SET SERVEROUTPUT ON SIZE 1000000

	set long 10000

	set pagesize 0*/

	select dbms_sqltune.report_tuning_task('Useless_Task') from dual;
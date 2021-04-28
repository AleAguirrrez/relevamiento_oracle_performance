--PEPEEPEE
SET SERVEROUT ON
DECLARE
    l_id_formulario_di JUZGADO.FORMULARIO_DI.id_formulario_di%TYPE;
    l_id_usuario_alta JUZGADO.REL_ESTADO_FORMULARIO_DI.id_usuario_alta%TYPE;
    L_NRO_CAUSA VARCHAR2(1000);
        type array_t is table of varchar2(20);
    array array_t := array_t('02-089-00020375-1-00','02-089-00030245-9-00','02-089-00037923-4-00','02-089-00044868-7-00','02-119-00395363-7-00','02-089-00067469-8-00','02-089-00078953-8-00',
'02-089-00090033-0-00','02-089-00104119-0-00','02-089-00134149-3-00','02-105-00347890-8-00','02-030-00615623-4-00','02-089-00245871-6-00','02-112-00885540-7-00');
BEGIN
  for i in 1..array.count loop
    L_NRO_CAUSA:=array(i);
    select max(di.id_formulario_di) INTO l_id_formulario_di from juzgado.formulario_di di where di.nro_causa = L_NRO_CAUSA;
    select edi.id_usuario_alta INTO l_id_usuario_alta from juzgado.rel_estado_formulario_di edi where edi.id_rel_estado_formulario_di = (SELECT MAX (edi.id_rel_estado_formulario_di) from juzgado.rel_estado_formulario_di edi WHERE edi.id_formulario_di = l_id_formulario_di);    
    
    UPDATE juzgado.rel_estado_formulario_di edi
    SET edi.fh_vigencia_hasta = (select localtimestamp from dual)
    WHERE edi.id_rel_estado_formulario_di = (select max(rr.id_rel_estado_formulario_di) from juzgado.rel_estado_formulario_di rr where rr.id_formulario_di = l_id_formulario_di);
    
    INSERT INTO juzgado.rel_estado_formulario_di edi
    (edi.id_rel_estado_formulario_di, edi.id_formulario_di, edi.id_estado_formulario_di, edi.id_usuario_alta, edi.fh_vigencia_desde)
    VALUES
    (juzgado.sq_id_rel_estado_fdi.NEXTVAL,
    l_id_formulario_di,
    7,
    l_id_usuario_alta,
    (select localtimestamp from dual));
    
    commit; 
  END LOOP;
END;
/
--validaciones
--OBTENGO EL ID_FORMULARIO_DI CON EL NÚMERO DE LA CAUSA
select * from juzgado.formulario_di di where di.nro_causa in ( '02-089-00020375-1-00','02-089-00030245-9-00','02-089-00037923-4-00','02-089-00044868-7-00','02-119-00395363-7-00','02-089-00067469-8-00','02-089-00078953-8-00',
'02-089-00090033-0-00','02-089-00104119-0-00','02-089-00134149-3-00','02-105-00347890-8-00','02-030-00615623-4-00','02-089-00245871-6-00','02-112-00885540-7-00') order by nro_causa;
--id_formulario_di: 67270

select * from juzgado.formulario_di di where di.id_formulario_di = 67283;

--OBTENER EL ESTADO CON EL QUE VA A ACTUALIZAR EL DI
select * from juzgado.estado_formulario_di;
--id_estado_formulario_di:7-->Eliminada


--==========================================================================================
/*====================PASO 0 => ESTA PARTE ES SOLO SI HAY MAS DE UN ID_PERSONA DESTINO =======
===========================================================================================*/
-- activar el dbms_output y poner los nro_doc que no matacheron en el not in del cursor ( cambiar el cuit!!!! )
-- este bloque se ejecuta dos veces
-- La primera : para sacar los nro_doc_destino que no estan en general.personas 
-- La segunda : ya con el not in en el cursor con los nro_doc_destino que no estan en general.personas para extraer los id_persona a cargar en tmp_descargos_img
declare 
l_id_persona_destino integer;
l_nro_doc_destino integer;
l_ID_TIPO_DOC_DESTINO integer;
begin 
for reg in (select id_persona_destino,nro_doc_destino,id_tipo_doc_destinofrom juzgado.formulario_di
			where cuit_fuente= 30575170125 and id_estado_formulario_di = '1' 
			--and nro_doc_destino not in (20120520,23248191,24742747,25384881,29953449,32952244,34518164,36740772)  -- descomentar y poner los nro_doc_destino que no mathean en general.personas
			and sexo_destino IN ('M','F') group by  id_persona_destino,nro_doc_destino,id_tipo_doc_destino order by nro_doc_destino )
loop
 l_nro_doc_destino:=reg.nro_doc_destino;
 l_ID_TIPO_DOC_DESTINO := reg.ID_TIPO_DOC_DESTINO ;
 begin
 select id_persona into l_id_persona_destino from  (select id_persona from  general.personas where id_persona =reg.id_persona_destino
         union all
         select id_persona from  general.personas where pf_nro_doc=reg.nro_doc_destino and PF_ID_TIPO_DOC_PERSONA=reg.ID_TIPO_DOC_DESTINO) where rownum=1;
         exception when NO_DATA_FOUND then dbms_output.put_line(l_nro_doc_destino||' nro_doc no encontrado ======');
  END;
--  if ( reg.id_persona_destino is null)
--  then
  dbms_output.put_line('id_perdona_destino:'||l_id_persona_destino);
--      null;
--  end if;
end loop;
end;
/
/*================================================================================================*/
/* ======================= PASO 1 ================================================================*/
--crear la tabla temporal con las imagenes el id es de ejemplo  select * from juzgado.causas_personas where id_causa=15934930 and id_persona=4648895 ;
drop table aaguirrez.tmp_descargos_img ;
-- usar in id_persona que extrajimos en el paso anterior 
create table aaguirrez.tmp_descargos_img as select 6011264 id_persona,DESCRIPCION
,empty_BLOB() IMAGEN_DESCARGO,B_ESTA_PROCESADO,B_PARA_PROCESAR from JUZGADO.DESCARGOS_DET_IMAGENES where ID_DESCARGO_DOC_ASOCIADA=494802 and rownum <=3; -- sacar el rownum o ampliarselo
-- cargo las imagenes
select rowid,dti.* from aaguirrez.tmp_descargos_img dti order by 1 desc;
/*===================================================================================================
===================== PASO 2 ========================================================================
=====================================================================================================*/
-- la salida del bloque anterior ponerla en el array_t del bloque plsql 
-- IMPORTANTE sacar el id_persona que usamos en el paso 1 para cargar las primeras imagenes
--SELECT *FROM GENERAL.PERSONAS WHERE pf_nro_doc IN (21424211,22053685,23424235,24422799,25225730,26788656,31535358,31826986,37006448);

DECLARE
    L_FEC_ACTUAL DATE:=SYSDATE;
    L_ID_PERSONA NUMBER ;
    L_ID_PERSONA_MUESTRA NUMBER :=6011264 ;
    L_ID_ESTADO_CAUSA NUMBER :=40; -- VER ESTADO 40 CERRADO --> 66 ANULADA    
    type array_t is table of integer;
    array array_t := array_t(6221969,3309673,6551441,4766267,6349692,4648895,4892670,4401043,4197110,5809985,1174290,6147879,5270749,3026978);
    BEGIN
    for i in 1..array.count loop
    L_ID_PERSONA:=array(i);
      insert into aaguirrez.tmp_descargos_img select L_ID_PERSONA ,DESCRIPCION,IMAGEN_DESCARGO,B_ESTA_PROCESADO,B_PARA_PROCESAR from aaguirrez.tmp_descargos_img where id_persona=L_ID_PERSONA_MUESTRA ;
    end loop;
    END;
    /
/* ===============================================================================================================================*/
-- la salida del bloque anterior ponerla en el array_t del bloque plsql ( importante 
--SELECT *FROM GENERAL.PERSONAS WHERE pf_nro_doc IN (21424211,22053685,23424235,24422799,25225730,26788656,31535358,31826986,37006448);

DECLARE
    L_FEC_ACTUAL DATE:=SYSDATE;
    L_ID_PERSONA NUMBER ;
    L_ID_PERSONA_MUESTRA NUMBER :=6011264 ;
    L_ID_ESTADO_CAUSA NUMBER :=40; -- VER ESTADO 40 CERRADO --> 66 ANULADA    
    type array_t is table of integer;
    array array_t := array_t(6221969,3309673,6551441,4766267,6349692,4648895,4892670,4401043,4197110,5809985,1174290,6147879,5270749,3026978);
    BEGIN
    for i in 1..array.count loop
    L_ID_PERSONA:=array(i);
      insert into aaguirrez.tmp_descargos_img select L_ID_PERSONA ,DESCRIPCION,IMAGEN_DESCARGO,B_ESTA_PROCESADO,B_PARA_PROCESAR from aaguirrez.tmp_descargos_img where id_persona=L_ID_PERSONA_MUESTRA ;
    end loop;
    END;
    /
	--validar que deberia devolver (cantidad de l_id_persona) X ( numeros de imagenes del descargo)
	select rowid,dti.* from aaguirrez.tmp_descargos_img dti order by 1 desc;
	COMMIT;
/*=====================================================================================================
======================================== PASO 3 =======================================================
======== Este es el bloque que todo pero deben estar todas las imagenes  cargadas en las ==============
========  tabla tmp_descargos_img dti por cada id_persona !!!! IMPORTANTE =============================
=======================================================================================================
--- usar el nro_doc_destino not in que usamos en el PASO 0 si no fallara 
-- Activar el dbsm_output -- eso nos dara los id_descargo para validar antes de hacer el commit
*/
set serveroutput on;
declare 
l_cuit integer := 30630402073;  -- CUIT de la empresa
l_nro_causa varchar2(100) ; -- esto no va
l_usuario_alta number := 9387; -- Usuario de sacit con el cual se redireecciona el DI
l_id_persona_destino number;
l_id_causa_persona number;
L_ID_ESTADO_CAUSA integer := 44; -- Estado final de la causa 
L_FEC_ACTUAL DATE:=SYSDATE;
L_REL_CAUSA_ESTADO_ANTERIOR NUMBER;
l_id_descargo integer;
--l_id_causa integer := 19338858;
l_ID_DESACRGO_DOC_ASOCIADA integer;
l_ID_DESCARGO_DET_IMAGEN integer;
l_id_causa integer;
begin
for reg in (select id_persona_destino,nro_doc_destino,ID_TIPO_DOC_DESTINO  from juzgado.formulario_di where cuit_fuente= l_cuit  and id_estado_formulario_di=1   and ( id_persona_destino is not null or ID_TIPO_DOC_DESTINO is not null) and sexo_destino IN ('M','F') 
               --and nro_doc_destino not in (20120520,23248191,24742747,25384881,29953449,32952244,34518164,36740772)  
               group by 
               id_persona_destino,nro_doc_destino,ID_TIPO_DOC_DESTINO  )
LOOP
    select id_persona into l_id_persona_destino from  (select id_persona from  general.personas where id_persona =reg.id_persona_destino
         union all
         select id_persona from  general.personas where pf_nro_doc=reg.nro_doc_destino and PF_ID_TIPO_DOC_PERSONA=reg.ID_TIPO_DOC_DESTINO) where rownum=1;
         --dbms_output.put_line('id_perdona_destino:'||l_id_persona_destino);
    select JUZGADO.SQ_ID_DESCARGO.nextval into l_id_descargo from dual;
    -- insert descargo 
    dbms_output.put_line('id_descargo:'||l_id_descargo);
    insert into juzgado.descargos (ID_DESCARGO,FECHA_RECEPCION,DESCRIPCION,FECHA_ENVIO,FECHA_CREACION,F_APLICACION_DESDE,CUMPLIMENTADA,ORIGEN_DESCARGO
    ,ESTADO_DESCARGO,ID_TIPO_DESCARGO,DENUNC_ID_TIPO_DOC_PERSONA,ID_USUARIO_CREACION) values (l_id_descargo,sysdate, 'Desc. presentado',sysdate , sysdate,sysdate ,'F' , 'E', 'N',7 ,null,9387 );
    -- JUZGADO.DESCARGOS_DOC_ASOCIADA
--    dbms_output.put_line(l_id_descargo);
    select JUZGADO.SQ_ID_DESACRGO_DOC_ASOCIADA.nextval into l_ID_DESACRGO_DOC_ASOCIADA from dual;
    insert into JUZGADO.DESCARGOS_DOC_ASOCIADA (ID_DESCARGO_DOC_ASOCIADA,ID_DESCARGO,CUMPLIMENTADA,ID_DOCUMENTO) 
    values (l_ID_DESACRGO_DOC_ASOCIADA,l_id_descargo,'F',0);
    --  juzgado.SQ_ID_CAUSA_DET_IMAGEN

    --select JUZGADO.SQ_ID_DESCARGO_IMAGEN.nextval into  l_ID_DESCARGO_DET_IMAGEN from dual; -- 666084
    insert into JUZGADO.DESCARGOS_DET_IMAGENES (ID_DESCARGO_DOC_ASOCIADA,ID_DESCARGO_DET_IMAGEN,FECHA_CARGA,DESCRIPCION
    ,IMAGEN_DESCARGO,B_ESTA_PROCESADO,B_PARA_PROCESAR) select l_ID_DESACRGO_DOC_ASOCIADA,JUZGADO.SQ_ID_DESCARGO_IMAGEN.nextval,sysdate,DESCRIPCION,IMAGEN_DESCARGO,B_ESTA_PROCESADO,B_PARA_PROCESAR from aaguirrez.tmp_descargos_img where id_persona=l_id_persona_destino;
END LOOP;
-- insert en relacion select * from juzgado.descargos
    for  reg in (  select *
                from juzgado.formulario_di
                where cuit_fuente= l_cuit
                 and id_estado_formulario_di=1 
                 --and nro_doc_destino not in  (20120520,23248191,24742747,25384881,29953449,32952244,34518164,36740772) --and id_persona_destino=4648895
                 and ( id_persona_destino is not null or ID_TIPO_DOC_DESTINO is not null)
                   and sexo_destino IN ('M','F') --and id_causa not in (15934930)
--                   and nro_causa=l_nro_causa
                   --and rownum<=5 --SACAR SI 
                   )
    loop
        dbms_output.put_line('id_formulario_di:'||reg.id_formulario_di ||' doc: '||reg.nro_doc_destino||' id_person_dest: '||reg.id_persona_destino||' id_persona_orig:'||reg.id_persona_fuente||' id_causa:'||reg.id_causa);
--         select to_number(id_persona) into l_id_persona_destino from general.personas where id_persona =reg.id_persona_destino,'%%') or pf_nro_doc like nvl(reg.nro_doc_destino,'%%') ) and PF_ID_TIPO_DOC_PERSONA=reg.ID_TIPO_DOC_DESTINO;
         select id_persona into l_id_persona_destino from  (select id_persona from  general.personas where id_persona =reg.id_persona_destino
         union all
         select id_persona from  general.personas where pf_nro_doc=reg.nro_doc_destino and PF_ID_TIPO_DOC_PERSONA=reg.ID_TIPO_DOC_DESTINO) where rownum=1;
         dbms_output.put_line('id_perdona_destino:'||l_id_persona_destino);
        -- actualizo el estado di
--         dbms_output.put_line('update juzgado.formulario_di set id_estado_formulario_di= 2 where id_formulario_di='|| reg.id_formulario_di);
         update juzgado.formulario_di set id_estado_formulario_di= 2 where id_formulario_di=reg.id_formulario_di;
         -- cambiar el estado en la rel_
         /*Insert into juzgado.rel_estado_formulario_di (ID_REL_ESTADO_FORMULARIO_DI,ID_FORMULARIO_DI,ID_ESTADO_FORMULARIO_DI,ID_USUARIO_ALTA,FH_VIGENCIA_DESDE)
            values (JUZGADO.SQ_ID_ESTADO_FORMULARIO_DI.nextval,reg.id_formulario_di,2,l_usuario_alta,trunc(sysdate)) */
--            dbms_output.put_line('update juzgado.rel_estado_formulario_di set fh_vigencia_hasta=trunc(sysdate) where id_formulario_di='||reg.id_formulario_di||' and fh_vigencia_hasta is null');
            update juzgado.rel_estado_formulario_di set fh_vigencia_hasta=trunc(sysdate) where id_formulario_di=reg.id_formulario_di and fh_vigencia_hasta is null;
--            dbms_output.put_line('insert into juzgado.rel_estado_formulario_di (ID_REL_ESTADO_FORMULARIO_DI,ID_FORMULARIO_DI,ID_ESTADO_FORMULARIO_DI,ID_USUARIO_ALTA,FH_VIGENCIA_DESDE) values (JUZGADO.SQ_ID_ESTADO_FORMULARIO_DI.nextval,'||reg.id_formulario_di||',2,'||l_usuario_alta||',trunc(sysdate))'  );
            insert into juzgado.rel_estado_formulario_di (ID_REL_ESTADO_FORMULARIO_DI,ID_FORMULARIO_DI,ID_ESTADO_FORMULARIO_DI,ID_USUARIO_ALTA,FH_VIGENCIA_DESDE) values (JUZGADO.SQ_ID_REL_ESTADO_FDI.nextval,reg.id_formulario_di,2,l_usuario_alta,trunc(sysdate));
            --select * from juzgado.rel_estado_formulario_di where id_formulario_di=34137 and fh_vigencia_hasta is null;
            -- causas personas
            -- si esta en estado 1 no insertas
--           dbms_output.put_line('insert into  juzgado.causas_personas  (ID_CAUSA_PERSONA,ID_PERSONA,ID_CAUSA,F_VIGENCIA_DESDE,CONTACTADO) values ( JUZGADO.SQ_ID_CAUSA_PERSONA.nextval,'||l_id_persona_destino||','||reg.ID_CAUSA||',trunc(sysdate),''F'')');
           insert into  juzgado.causas_personas  (ID_CAUSA_PERSONA,ID_PERSONA,ID_CAUSA,F_VIGENCIA_DESDE,CONTACTADO) values ( JUZGADO.SQ_ID_CAUSA_PERSONA.nextval,l_id_persona_destino,reg.ID_CAUSA,trunc(sysdate),'F');
           /* insert into  juzgado.causas_personas  (ID_CAUSA_PERSONA,ID_PERSONA,ID_CAUSA,F_VIGENCIA_DESDE,CONTACTADO)
          values ( JUZGADO.SQ_ID_CAUSA_PERSONA.nextval,l_id_persona_destino,ID_CAUSA,trunc(sysdate),'F'); */
--           dbms_output.put_line('update juzgado.causas_personas set f_vigencia_hasta=sysdate, motivo_reconduccion=''Informe de Persona Juridica'' where id_causa='||reg.id_causa||' and id_persona='||reg.id_persona_fuente||' and f_vigencia_hasta is null');
           update juzgado.causas_personas set f_vigencia_hasta=sysdate, motivo_reconduccion='Informe de Persona Juridica' where id_causa=reg.id_causa and id_persona=reg.id_persona_fuente and f_vigencia_hasta is null;
           select id_causa_persona into l_id_causa_persona from juzgado.causas_personas where id_causa=reg.id_causa and id_persona=reg.id_persona_fuente ;
--           dbms_output.put_line('update  juzgado.CAUSAS_PERSONA_DEBER_INFORMAR set f_vigencia_hasta=trunc(sysdate) where id_causa='||reg.id_causa||' and ID_CAUSA_PERSONA='||l_id_causa_persona||' and f_vigencia_hasta is null');
           update  juzgado.CAUSAS_PERSONA_DEBER_INFORMAR set f_vigencia_hasta=trunc(sysdate) where  ID_CAUSA_PERSONA=l_id_causa_persona and f_vigencia_hasta is null;
           select id_causa_persona into l_id_causa_persona from juzgado.causas_personas where id_causa=reg.id_causa and id_persona=l_id_persona_destino ;
          dbms_output.put_line('insert into juzgado.CAUSAS_PERSONA_DEBER_INFORMAR (ID_CAUSA_PERSONA_DEBER,ID_CAUSA_PERSONA,ID_ESTADO_DEBER_INFORMAR,F_VIGENCIA_DESDE) values (JUZGADO.SQ_ID_CAUSA_PERSONA_DEBER.nextval,'||l_id_causa_persona||',14,trunc(sysdate) )');
           insert into juzgado.CAUSAS_PERSONA_DEBER_INFORMAR (ID_CAUSA_PERSONA_DEBER,ID_CAUSA_PERSONA,ID_ESTADO_DEBER_INFORMAR,F_VIGENCIA_DESDE) values (JUZGADO.SQ_ID_CAUSA_PERSONA_DEBER.nextval,l_id_causa_persona,14,trunc(sysdate) );
           --
          select id_causa_persona into l_id_causa_persona from juzgado.causas_personas where id_causa=reg.id_causa and id_persona=l_id_persona_destino ;
--           dbms_output.put_line( 'insert into general.DOMICILIOS_CAUSAS_PERSONAS (ID_DOMICILIO_CAUSA_PERSONA,ID_CAUSA_PERSONA,PER_CALLE,PER_CALLE_NRO,PER_PISO,PER_DPTO,PER_CPOSTAL,F_VIGENCIA_DESDE,MOTIVO_CAMBIO,PER_ID_PROVINCIA,PER_ID_PARTIDO,PER_ID_LOCALIDAD,ORIGEN,PER_CALLE_A,PER_CALLE_B)
--            values ( GENERAL.SQ_ID_DOMICILIO_CAUSA_PERSONA.nextval,l_id_causa_persona,reg.CALLE_DESTINO,reg.CALLE_NRO_DESTINO,reg.PISO_DESTINO,reg.DPTO_DESTINO,reg.CPOSTAL_DESTINO,trunc(sysdate),''Informe de Persona Juridica''
--            ,reg.ID_PROVINCIA_DESTINO,reg.ID_PARTIDO_DESTINO,reg.ID_LOCALIDAD_DESTINO,''S'',reg.CALLE_A_DESTINO,reg.CALLE_B_DESTINO)' );
            
            insert into general.DOMICILIOS_CAUSAS_PERSONAS (ID_DOMICILIO_CAUSA_PERSONA,ID_CAUSA_PERSONA,PER_CALLE,PER_CALLE_NRO,PER_PISO,PER_DPTO,PER_CPOSTAL,F_VIGENCIA_DESDE,MOTIVO_CAMBIO,PER_ID_PROVINCIA,PER_ID_PARTIDO,PER_ID_LOCALIDAD,ORIGEN,PER_CALLE_A,PER_CALLE_B
            ,per_localidad,per_partido)
            values ( GENERAL.SQ_ID_DOMICILIO_CAUSA_PERSONA.nextval,l_id_causa_persona,reg.CALLE_DESTINO,reg.CALLE_NRO_DESTINO,reg.PISO_DESTINO,reg.DPTO_DESTINO,reg.CPOSTAL_DESTINO,trunc(sysdate),'Informe de Persona Juridica'
            ,reg.ID_PROVINCIA_DESTINO,reg.ID_PARTIDO_DESTINO,reg.ID_LOCALIDAD_DESTINO,'S',reg.CALLE_A_DESTINO,reg.CALLE_B_DESTINO
            ,(select localidad from general.localidades l where l.id_localidad=reg.ID_LOCALIDAD_DESTINO) ,(select partido from general.partidos p where p.id_partido=reg.ID_PARTIDO_DESTINO));
        
           --==============cambio el estado CAUSA 
         --select ID_CAUSA INTO L_ID_CAUSA from juzgado.causas where nro_causa=L_NRO_CAUSA;
       -- ACTUALIZO
--       dbms_output.put_line('update  juzgado.causas set id_estado_causa=L_ID_ESTADO_CAUSA,pendiente_notificar_ni = ''S'' where id_causa=reg.id_causa');
         update  juzgado.causas set id_estado_causa=L_ID_ESTADO_CAUSA,pendiente_notificar_ni = 'S' where id_causa=reg.id_causa;
       --OBTENGO EL ID_REL_ESTADO_CAUSA
--      dbms_output.put_line('INSERT INTO JUZGADO.REL_CAUSAS_ESTADOS (ID_REL_CAUSA_ESTADO,ID_CAUSA,ID_ESTADO_CAUSA,F_VIGENCIA_DESDE,ID_REL_CAUSA_ESTADO_ANTERIOR)
--         VALUES (JUZGADO.SQ_ID_REL_CAUSA_ESTADO.NEXTVAL,reg.id_causa,L_ID_ESTADO_CAUSA,L_FEC_ACTUAL,L_REL_CAUSA_ESTADO_ANTERIOR)');
         SELECT ID_REL_CAUSA_ESTADO  INTO L_REL_CAUSA_ESTADO_ANTERIOR FROM JUZGADO.REL_CAUSAS_ESTADOS WHERE ID_CAUSA=reg.id_causa AND F_VIGENCIA_HASTA IS NULL;
         INSERT INTO JUZGADO.REL_CAUSAS_ESTADOS (ID_REL_CAUSA_ESTADO,ID_CAUSA,ID_ESTADO_CAUSA,F_VIGENCIA_DESDE,ID_REL_CAUSA_ESTADO_ANTERIOR)
         VALUES (JUZGADO.SQ_ID_REL_CAUSA_ESTADO.NEXTVAL,reg.id_causa,L_ID_ESTADO_CAUSA,L_FEC_ACTUAL,L_REL_CAUSA_ESTADO_ANTERIOR);
         dbms_output.put_line('UPDATE JUZGADO.REL_CAUSAS_ESTADOS SET F_VIGENCIA_HASTA=L_FEC_ACTUAL WHERE ID_REL_CAUSA_ESTADO=L_REL_CAUSA_ESTADO_ANTERIOR');
         UPDATE JUZGADO.REL_CAUSAS_ESTADOS SET F_VIGENCIA_HASTA=L_FEC_ACTUAL WHERE ID_REL_CAUSA_ESTADO=L_REL_CAUSA_ESTADO_ANTERIOR;
         
         -- agregado relacion descargo casusa
         select id_causa into l_id_causa from juzgado.causas where nro_causa=reg.nro_causa;
         insert into JUZGADO.REL_DESCARGOS_CAUSA (ID_CAUSA,ID_DESCARGO) values (l_id_causa,l_id_descargo); 
    end loop;     
end;
/
/*===================================================================================================================
======================== FIN BLOQUE PLSQ ============================================================================*/
/*===================================================================================================================
============================== PASO 3 : Validaciones ================================================================
/*===================================================================================================================*/
--validacion 1 : deberia devolver vacio excepto por los nro_doc_destino que excluimos 
select *
from juzgado.formulario_di
where cuit_fuente= 30630402073
and id_estado_formulario_di = '1' --and id_causa = 15934930
and sexo_destino IN ('M','F')
--and nro_causa ='02-007-00050773-3-00' -- id_causa=10066091
--or nro_causa = '02-030-00275007-3-00' -- id_causa=9419964
order by id_estado_formulario_di desc;
-- aca reemplazar el in por todos los id_descargo que generamos ene l paso dos 
-- deberia devolver el mismo numero que el total de causas
select * from JUZGADO.REL_DESCARGOS_CAUSA rrc where id_descargo in (522063,522064,522065,522066,522067,522068,522069,522070,522071,522072,522073,522074,522075,522076,522077);
-- deberia devolver la misma cantidad de id_persona_destino s
select * from juzgado.descargos where id_descargo in (522079);
-- deberia devolver la misma cantidad de id_persona_destino s
select * from JUZGADO.DESCARGOS_DOC_ASOCIADA where id_descargo in (522079);
-- deberia devolver la misma cantidad de id_persona_destino s X la cantidade de imagenes del descargo . En nuestro eejemplo eran 3
select * from JUZGADO.DESCARGOS_DET_IMAGENES where ID_DESCARGO_DOC_ASOCIADA in
(select ID_DESCARGO_DOC_ASOCIADA from JUZGADO.DESCARGOS_DOC_ASOCIADA where id_descargo in (522079));

/* =====================================================================================================
======================================== PASO 4 commit ================================================
=======================================================================================================*/
COMMIT;

set serveroutput on;
declare 
l_cuit integer := 33500005179;  -- CUIT de la empresa
l_nro_causa varchar2(100) :='02-007-00050773-3-00'; -- esto no va
l_usuario_alta number := 9387; -- Usuario de sacit con el cual se redireecciona el DI
l_id_persona_destino number;
l_id_causa_persona number;
L_ID_ESTADO_CAUSA integer := 62; -- Estado final de la causa 
L_FEC_ACTUAL DATE:=SYSDATE;
L_REL_CAUSA_ESTADO_ANTERIOR NUMBER;
begin
    for  reg in (  select *
                from juzgado.formulario_di
                where cuit_fuente= l_cuit
                 and id_estado_formulario_di=1 
                 and ( id_persona_destino is not null or ID_TIPO_DOC_DESTINO is not null)
                   and sexo_destino IN ('M','F') 
                   and nro_causa in ('NRO_CAUSA_1','NRO_CAUSA_2','NRO_CAUSA_3'..etc) -- cargar las causas ACA!!!!!!!
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
         --dbms_output.put_line('update juzgado.formulario_di set id_estado_formulario_di= 2 where id_formulario_di='|| reg.id_formulario_di);
         update juzgado.formulario_di set id_estado_formulario_di= 2 where id_formulario_di=reg.id_formulario_di;
         -- cambiar el estado en la rel_
         /*Insert into juzgado.rel_estado_formulario_di (ID_REL_ESTADO_FORMULARIO_DI,ID_FORMULARIO_DI,ID_ESTADO_FORMULARIO_DI,ID_USUARIO_ALTA,FH_VIGENCIA_DESDE)
            values (JUZGADO.SQ_ID_ESTADO_FORMULARIO_DI.nextval,reg.id_formulario_di,2,l_usuario_alta,trunc(sysdate)) */
            --dbms_output.put_line('update juzgado.rel_estado_formulario_di set fh_vigencia_hasta=trunc(sysdate) where id_formulario_di='||reg.id_formulario_di||' and fh_vigencia_hasta is null');
            update juzgado.rel_estado_formulario_di set fh_vigencia_hasta=trunc(sysdate) where id_formulario_di=reg.id_formulario_di and fh_vigencia_hasta is null;
            --dbms_output.put_line('insert into juzgado.rel_estado_formulario_di (ID_REL_ESTADO_FORMULARIO_DI,ID_FORMULARIO_DI,ID_ESTADO_FORMULARIO_DI,ID_USUARIO_ALTA,FH_VIGENCIA_DESDE) values (JUZGADO.SQ_ID_ESTADO_FORMULARIO_DI.nextval,'||reg.id_formulario_di||',2,'||l_usuario_alta||',trunc(sysdate))'  );
            insert into juzgado.rel_estado_formulario_di (ID_REL_ESTADO_FORMULARIO_DI,ID_FORMULARIO_DI,ID_ESTADO_FORMULARIO_DI,ID_USUARIO_ALTA,FH_VIGENCIA_DESDE) values (JUZGADO.SQ_ID_REL_ESTADO_FDI.nextval,reg.id_formulario_di,2,l_usuario_alta,trunc(sysdate));
            --select * from juzgado.rel_estado_formulario_di where id_formulario_di=34137 and fh_vigencia_hasta is null;
            -- causas personas
            -- si esta en estado 1 no insertas
           --dbms_output.put_line('insert into  juzgado.causas_personas  (ID_CAUSA_PERSONA,ID_PERSONA,ID_CAUSA,F_VIGENCIA_DESDE,CONTACTADO) values ( JUZGADO.SQ_ID_CAUSA_PERSONA.nextval,'||l_id_persona_destino||','||reg.ID_CAUSA||',trunc(sysdate),''F'')');
           insert into  juzgado.causas_personas  (ID_CAUSA_PERSONA,ID_PERSONA,ID_CAUSA,F_VIGENCIA_DESDE,CONTACTADO) values ( JUZGADO.SQ_ID_CAUSA_PERSONA.nextval,l_id_persona_destino,reg.ID_CAUSA,trunc(sysdate),'F');
           /* insert into  juzgado.causas_personas  (ID_CAUSA_PERSONA,ID_PERSONA,ID_CAUSA,F_VIGENCIA_DESDE,CONTACTADO)
          values ( JUZGADO.SQ_ID_CAUSA_PERSONA.nextval,l_id_persona_destino,ID_CAUSA,trunc(sysdate),'F'); */
           --dbms_output.put_line('update juzgado.causas_personas set f_vigencia_hasta=sysdate, motivo_reconduccion=''Informe de Persona Juridica'' where id_causa='||reg.id_causa||' and id_persona='||reg.id_persona_fuente||' and f_vigencia_hasta is null');
           update juzgado.causas_personas set f_vigencia_hasta=sysdate, motivo_reconduccion='Informe de Persona Juridica' where id_causa=reg.id_causa and id_persona=reg.id_persona_fuente and f_vigencia_hasta is null;
           select id_causa_persona into l_id_causa_persona from juzgado.causas_personas where id_causa=reg.id_causa and id_persona=reg.id_persona_fuente ;
           --dbms_output.put_line('update  juzgado.CAUSAS_PERSONA_DEBER_INFORMAR set f_vigencia_hasta=trunc(sysdate) where id_causa='||reg.id_causa||' and ID_CAUSA_PERSONA='||l_id_causa_persona||' and f_vigencia_hasta is null');
           update  juzgado.CAUSAS_PERSONA_DEBER_INFORMAR set f_vigencia_hasta=trunc(sysdate) where  ID_CAUSA_PERSONA=l_id_causa_persona and f_vigencia_hasta is null;
           select id_causa_persona into l_id_causa_persona from juzgado.causas_personas where id_causa=reg.id_causa and id_persona=l_id_persona_destino ;
          -- dbms_output.put_line('insert into juzgado.CAUSAS_PERSONA_DEBER_INFORMAR (ID_CAUSA_PERSONA_DEBER,ID_CAUSA_PERSONA,ID_ESTADO_DEBER_INFORMAR,F_VIGENCIA_DESDE) values (JUZGADO.SQ_ID_CAUSA_PERSONA_DEBER.nextval,'||l_id_causa_persona||',14,trunc(sysdate) )');
           insert into juzgado.CAUSAS_PERSONA_DEBER_INFORMAR (ID_CAUSA_PERSONA_DEBER,ID_CAUSA_PERSONA,ID_ESTADO_DEBER_INFORMAR,F_VIGENCIA_DESDE) values (JUZGADO.SQ_ID_CAUSA_PERSONA_DEBER.nextval,l_id_causa_persona,14,trunc(sysdate) );
           --
          select id_causa_persona into l_id_causa_persona from juzgado.causas_personas where id_causa=reg.id_causa and id_persona=l_id_persona_destino ;
           dbms_output.put_line( 'insert into general.DOMICILIOS_CAUSAS_PERSONAS (ID_DOMICILIO_CAUSA_PERSONA,ID_CAUSA_PERSONA,PER_CALLE,PER_CALLE_NRO,PER_PISO,PER_DPTO,PER_CPOSTAL,F_VIGENCIA_DESDE,MOTIVO_CAMBIO,PER_ID_PROVINCIA,PER_ID_PARTIDO,PER_ID_LOCALIDAD,ORIGEN,PER_CALLE_A,PER_CALLE_B)
            values ( GENERAL.SQ_ID_DOMICILIO_CAUSA_PERSONA.nextval,l_id_causa_persona,reg.CALLE_DESTINO,reg.CALLE_NRO_DESTINO,reg.PISO_DESTINO,reg.DPTO_DESTINO,reg.CPOSTAL_DESTINO,trunc(sysdate),''Informe de Persona Juridica''
            ,reg.ID_PROVINCIA_DESTINO,reg.ID_PARTIDO_DESTINO,reg.ID_LOCALIDAD_DESTINO,''S'',reg.CALLE_A_DESTINO,reg.CALLE_B_DESTINO)' );
            
            insert into general.DOMICILIOS_CAUSAS_PERSONAS (ID_DOMICILIO_CAUSA_PERSONA,ID_CAUSA_PERSONA,PER_CALLE,PER_CALLE_NRO,PER_PISO,PER_DPTO,PER_CPOSTAL,F_VIGENCIA_DESDE,MOTIVO_CAMBIO,PER_ID_PROVINCIA,PER_ID_PARTIDO,PER_ID_LOCALIDAD,ORIGEN,PER_CALLE_A,PER_CALLE_B
            ,per_localidad,per_partido)
            values ( GENERAL.SQ_ID_DOMICILIO_CAUSA_PERSONA.nextval,l_id_causa_persona,reg.CALLE_DESTINO,reg.CALLE_NRO_DESTINO,reg.PISO_DESTINO,reg.DPTO_DESTINO,reg.CPOSTAL_DESTINO,trunc(sysdate),'Informe de Persona Juridica'
            ,reg.ID_PROVINCIA_DESTINO,reg.ID_PARTIDO_DESTINO,reg.ID_LOCALIDAD_DESTINO,'S',reg.CALLE_A_DESTINO,reg.CALLE_B_DESTINO
            ,(select localidad from general.localidades l where l.id_localidad=reg.ID_LOCALIDAD_DESTINO) ,(select partido from general.partidos p where p.id_partido=reg.ID_PARTIDO_DESTINO));
        
           --==============cambio el estado CAUSA 
         --select ID_CAUSA INTO L_ID_CAUSA from juzgado.causas where nro_causa=L_NRO_CAUSA;
       -- ACTUALIZO
       dbms_output.put_line('update  juzgado.causas set id_estado_causa=L_ID_ESTADO_CAUSA,pendiente_notificar_ni = ''S'' where id_causa=reg.id_causa');
         update  juzgado.causas set id_estado_causa=L_ID_ESTADO_CAUSA,pendiente_notificar_ni = 'S' where id_causa=reg.id_causa;
       --OBTENGO EL ID_REL_ESTADO_CAUSA
       dbms_output.put_line('INSERT INTO JUZGADO.REL_CAUSAS_ESTADOS (ID_REL_CAUSA_ESTADO,ID_CAUSA,ID_ESTADO_CAUSA,F_VIGENCIA_DESDE,ID_REL_CAUSA_ESTADO_ANTERIOR)
         VALUES (JUZGADO.SQ_ID_REL_CAUSA_ESTADO.NEXTVAL,reg.id_causa,L_ID_ESTADO_CAUSA,L_FEC_ACTUAL,L_REL_CAUSA_ESTADO_ANTERIOR)');
         SELECT max(ID_REL_CAUSA_ESTADO)  INTO L_REL_CAUSA_ESTADO_ANTERIOR FROM JUZGADO.REL_CAUSAS_ESTADOS WHERE ID_CAUSA=reg.id_causa AND F_VIGENCIA_HASTA IS NULL;
		 UPDATE JUZGADO.REL_CAUSAS_ESTADOS SET F_VIGENCIA_HASTA=L_FEC_ACTUAL WHERE ID_CAUSA=reg.id_causa AND F_VIGENCIA_HASTA IS NULL;
         INSERT INTO JUZGADO.REL_CAUSAS_ESTADOS (ID_REL_CAUSA_ESTADO,ID_CAUSA,ID_ESTADO_CAUSA,F_VIGENCIA_DESDE,ID_REL_CAUSA_ESTADO_ANTERIOR)
         VALUES (JUZGADO.SQ_ID_REL_CAUSA_ESTADO.NEXTVAL,reg.id_causa,L_ID_ESTADO_CAUSA,L_FEC_ACTUAL,L_REL_CAUSA_ESTADO_ANTERIOR);
         dbms_output.put_line('UPDATE JUZGADO.REL_CAUSAS_ESTADOS SET F_VIGENCIA_HASTA=L_FEC_ACTUAL WHERE ID_REL_CAUSA_ESTADO=L_REL_CAUSA_ESTADO_ANTERIOR');
         --UPDATE JUZGADO.REL_CAUSAS_ESTADOS SET F_VIGENCIA_HASTA=L_FEC_ACTUAL WHERE ID_REL_CAUSA_ESTADO=L_REL_CAUSA_ESTADO_ANTERIOR;
    end loop;     
end;
/

select * from juzgado.causas_personas where  id_persona in (SELECT id_persona FROM general.personas p WHERE p.pf_nro_doc = 33500005179) ;
select * from juzgado.formulario_di where id_formulario_di=121062;
select * from juzgado.rel_estado_formulario_di where id_formulario_di=121062;
select * from juzgado.causas_personas where id_causa=14805835;
select * from general.DOMICILIOS_CAUSAS_PERSONAS where id_causa_persona=18683673;
select * from  juzgado.CAUSAS_PERSONA_DEBER_INFORMAR  where  ID_CAUSA_PERSONA=18683673 and f_vigencia_hasta is null;
    select T2.ESTADO_CAUSA,T1.* from juzgado.causas T1,JUZGADO.ESTADOS_CAUSAS T2  where T1.ID_ESTADO_CAUSA=T2.ID_ESTADO_CAUSA AND  id_causa=14805835;
    SELECT * FROM JUZGADO.REL_CAUSAS_ESTADOS WHERE id_causa=14805835 order by ID_REL_CAUSA_ESTADO;
select * from general.DOMICILIOS_CAUSAS_PERSONAS;
select * from juzgado.CAUSAS_PERSONA_DEBER_INFORMAR where id_causa_persona;
--update juzgado.causas_personas set f_vigencia_hasta=sysdate, motivo_reconduccion='Informe de Persona Juridica' where id_causa=reg.id_causa and id_persona=reg.id_persona_fuente and f_vigencia_hasta is null
select * from general.personas where pf_nro_doc=18591335; --PEDRO    DAGUERRE
select *
from juzgado.formulario_di
where cuit_fuente= 33500005179
and id_estado_formulario_di = '1'
and sexo_destino IN ('M','F')
--and nro_causa ='02-007-00050773-3-00' -- id_causa=10066091
--or nro_causa = '02-030-00275007-3-00' -- id_causa=9419964
order by id_estado_formulario_di desc;
select rowid,p.* from  juzgado.CAUSAS_PERSONA_DEBER_INFORMAR p order by f_vigencia_desde desc;
select * from  juzgado.CAUSAS_PERSONA_DEBER_INFORMAR  where  ID_CAUSA_PERSONA=18683673 and f_vigencia_hasta is null;
select * from juzgado.causas_personas where id_causa=14805835 and id_persona=283843 ;


            
            

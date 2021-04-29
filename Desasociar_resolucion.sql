set serveroutput on;
DECLARE
L_FEC_ACTUAL DATE:=SYSDATE;
L_ID_CAUSA NUMBER ;
L_ID_RESOLUCION NUMBER ;
L_REL_CAUSA_ESTADO_ANTERIOR NUMBER;
L_ID_ESTADO_CAUSA NUMBER :=12; -- 12 CITADA -- 44 CON DESCARGO INVALIDO
L_NRO_CAUSA varchar2(30)  :='02-061-00427562-5-00';
L_ID_NOTIFICACION INTEGER  ;
L_ID_MOVIMIENTO_DE_CUENTA INTEGER;
L_ID_ESTADO_MOVIMIENTO_CUENTA integer;
L_ID_DESCARGO integer;
BEGIN
--1.- Busco notificaciones y movimientos de cuenta posteriores a la citación y anulo uno por uno
--FINANZAS.ESTADOS_MOVIMIENTOS_CUENTAS T3
--notificaciones.TIPOS_CEDULAS T4  notificaciones.ESTADOS_NOTIFICACIONES
-- pongo estado en 15(ANULADA)
--DBMS_OUTPUT.PUT_LINE(lpad('#',100,'#')||chr(13)||'Pongo estado en 15(ANULADA) los mov cuentas '||chr(13)||lpad('#',100,'#') );
  for i in ( SELECT T1.id_notificacion,t1.ID_ESTADO_NOTIFICACION  FROM notificaciones.notificaciones T1,notificaciones.rel_causas_notificaciones T2,juzgado.causas T3
                                                       WHERE T1.ID_NOTIFICACION=T2.ID_NOTIFICACION AND T2.ID_CAUSA=T3.ID_CAUSA  AND T3.nro_causa=L_NRO_CAUSA AND T1.ID_TIPO_CEDULA IN (2,5) )  -- QUE NO TENGA ESTADO 15 ANULADA  -- NOTIFICACIONES DE SENTIENCIA 2 -Notif. Sentencia 5 - Extensión de Pago Sanción
  LOOP
      BEGIN
          select ID_MOVIMIENTO_DE_CUENTA,ID_ESTADO_MOVIMIENTO_CUENTA INTO L_ID_MOVIMIENTO_DE_CUENTA,L_ID_ESTADO_MOVIMIENTO_CUENTA
          from finanzas.movimientos_de_cuentas mc
          where mc.id_notificacion = I.ID_NOTIFICACION;
          exception 
            when NO_DATA_FOUND then
                L_ID_ESTADO_MOVIMIENTO_CUENTA :=15;
                dbms_output.put_line('Notificacion '||I.ID_NOTIFICACION||'  no tiene mov de cuentas asociados');
      END;
      IF L_ID_ESTADO_MOVIMIENTO_CUENTA not  in (15) -- que no este anulada ya 
      then
           DBMS_OUTPUT.PUT_LINE(lpad('#',50,'#')||chr(13)||'El ID_MOVIMIENTO_DE_CUENTA  es : '||L_ID_MOVIMIENTO_DE_CUENTA||' y su estado es :'||L_ID_ESTADO_MOVIMIENTO_CUENTA||chr(13)||lpad('#',50,'#') );
           DBMS_OUTPUT.PUT_LINE('update finanzas.movimientos_de_cuentas mc set L_ID_ESTADO_MOVIMIENTO_CUENTA=15 where ID_MOVIMIENTO_DE_CUENTA='||L_ID_MOVIMIENTO_DE_CUENTA||';');
           update finanzas.movimientos_de_cuentas mc set ID_ESTADO_MOVIMIENTO_CUENTA=15 where ID_MOVIMIENTO_DE_CUENTA=L_ID_MOVIMIENTO_DE_CUENTA;
      END IF;
      -- pongo estado en 12(ANULADA)
      DBMS_OUTPUT.PUT_LINE(lpad('#',50,'#')||chr(13)||'El ID_NOTIFICACION  es : '||I.ID_NOTIFICACION||' y su estado es :'||I.ID_ESTADO_NOTIFICACION||chr(13)||lpad('#',50,'#') );
      DBMS_OUTPUT.PUT_LINE('update notificaciones.notificaciones n set ID_ESTADO_NOTIFICACION=12 where id_notificacion='||I.ID_NOTIFICACION||';');
      update notificaciones.notificaciones n set ID_ESTADO_NOTIFICACION=12 where id_notificacion=I.ID_NOTIFICACION;
  END LOOP;
  --3.- Pongo el último estado vigente de la causa en citada(12)
           --OBTENGO EL ID_CAUSA 
       select ID_CAUSA,ID_RESOLUCION INTO L_ID_CAUSA,L_ID_RESOLUCION from juzgado.causas where nro_causa=L_NRO_CAUSA;
       -- ACTUALIZO
       update  juzgado.causas set id_estado_causa=L_ID_ESTADO_CAUSA where id_causa=L_ID_CAUSA;
       --OBTENGO EL ID_REL_ESTADO_CAUSA
       SELECT max(ID_REL_CAUSA_ESTADO)  INTO L_REL_CAUSA_ESTADO_ANTERIOR FROM JUZGADO.REL_CAUSAS_ESTADOS WHERE ID_CAUSA=L_ID_CAUSA AND F_VIGENCIA_HASTA IS NULL;
	    -- pongo vencidas las rel_causas estados con f_vigencia_hasta null
	   UPDATE JUZGADO.REL_CAUSAS_ESTADOS SET F_VIGENCIA_HASTA=L_FEC_ACTUAL WHERE ID_CAUSA=L_ID_CAUSA AND F_VIGENCIA_HASTA IS NULL;
        INSERT INTO JUZGADO.REL_CAUSAS_ESTADOS (ID_REL_CAUSA_ESTADO,ID_CAUSA,ID_ESTADO_CAUSA,F_VIGENCIA_DESDE,ID_REL_CAUSA_ESTADO_ANTERIOR)
        VALUES (JUZGADO.SQ_ID_REL_CAUSA_ESTADO.NEXTVAL,L_ID_CAUSA,L_ID_ESTADO_CAUSA,L_FEC_ACTUAL,L_REL_CAUSA_ESTADO_ANTERIOR);
       -- UPDATE JUZGADO.REL_CAUSAS_ESTADOS SET F_VIGENCIA_HASTA=L_FEC_ACTUAL WHERE ID_REL_CAUSA_ESTADO=L_REL_CAUSA_ESTADO_ANTERIOR;
        IF L_ID_ESTADO_CAUSA = 40
        then
            for reg in (SELECT T3.ESTADO_MOVIMIENTO_CUENTA,t2.ID_MOVIMIENTO_DE_CUENTA FROM juzgado.causas T1 ,FINANZAS.MOVIMIENTOS_DE_CUENTAS T2 ,FINANZAS.ESTADOS_MOVIMIENTOS_CUENTAS T3 WHERE T1.ID_CAUSA=T2.ID_CAUSA
            AND T3.ID_ESTADO_MOVIMIENTO_CUENTA=T2.ID_ESTADO_MOVIMIENTO_CUENTA and t2.id_estado_movimiento_cuenta in (12) AND T1.nro_causa=L_NRO_CAUSA )
            loop
                update FINANZAS.MOVIMIENTOS_DE_CUENTAS set id_estado_movimiento_cuenta=14 where id_movimiento_de_cuenta=reg.ID_MOVIMIENTO_DE_CUENTA;
            end loop;
        end if;
        IF L_ID_ESTADO_CAUSA = 44
        then 
             for reg3 in (select id_descargo from JUZGADO.REL_DESCARGOS_CAUSA rrc where id_causa in (select id_causa from juzgado.causas where nro_causa=L_NRO_CAUSA) )
             LOOP
               L_ID_DESCARGO:= reg3.id_descargo;
--             select id_descargo into L_ID_DESCARGO from JUZGADO.REL_DESCARGOS_CAUSA rrc where id_causa in (select id_causa from juzgado.causas where nro_causa=L_NRO_CAUSA);
             -- invalido el descargo 
             update  juzgado.descargos set  estado_descargo='N' where id_descargo in (L_ID_DESCARGO);  
             END LOOP;
        end if;
   -- 4.- Anulo la Resolucion asociada a la causa
   DBMS_OUTPUT.PUT_LINE(lpad('#',50,'#')||chr(13)||'El ID_RESOLUCION  es : '||L_ID_RESOLUCION||chr(13)||lpad('#',50,'#') );
   DBMS_OUTPUT.PUT_LINE('update juzgado.REL_RESOLUCIONES_ESTADOSRESOL rel set ID_ESTADO_RESOLUCION=4 where ID_RESOLUCION='||L_ID_RESOLUCION||';');
   update juzgado.REL_RESOLUCIONES_ESTADOSRESOL rel set ID_ESTADO_RESOLUCION=4 where ID_RESOLUCION=L_ID_RESOLUCION;
end;
/
---- pongo estado en 12(ANULADA)
--
     select * from notificaciones.notificaciones n where n.id_notificacion = 56903541;  -- notificaciones.tipos_cedulas
--
----2.- Chequeo estados de notif
--
select n.id_notificacion, n.id_estado_notificacion
from notificaciones.notificaciones n
inner join notificaciones.rel_causas_notificaciones rel on rel.id_notificacion = n.id_notificacion
inner join juzgado.causas c on c.id_causa = rel.id_causa
where c.nro_causa = '02-061-00427562-5-00';
--
--3.- Pongo el último estado vigente de la causa en citada(12)
--
  select * from juzgado.rel_causas_estados rel where rel.id_causa = (select id_causa from juzgado.causas where nro_causa='02-061-00427562-5-00') ;
--
--4.- Anulo la Resolucion asociada a la causa
--
----Estado 4(ANULADA)
--
 select er.estado_resolucion,rel.* from juzgado.REL_RESOLUCIONES_ESTADOSRESOL rel, juzgado.estados_resoluciones er  where  er.id_estado_resolucion=rel.id_estado_resolucion
 and rel.id_resolucion = (select id_resolucion from juzgado.causas where nro_causa='02-061-00427562-5-00')  ;
juzgado.estados_resoluciones
select * from juzgado.rel_causas_estados rel where rel.id_causa = (select id_causa from juzgado.causas where nro_causa='02-061-00427562-5-00') ;
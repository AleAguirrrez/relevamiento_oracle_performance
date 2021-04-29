-- validas que estado tiene la causa actualmente 
select T2.ESTADO_CAUSA,T1.* from juzgado.causas T1,JUZGADO.ESTADOS_CAUSAS T2  where T1.ID_ESTADO_CAUSA=T2.ID_ESTADO_CAUSA AND  nro_causa in ('02-061-00427562-5-00');
-- ver los estados posibles 
    SELECT * FROM JUZGADO.ESTADOS_CAUSAS;
--    
--    SELECT * FROM JUZGADO.REL_CAUSAS_ESTADOS WHERE ID_CAUSA IN (select ID_CAUSA from juzgado.causas where nro_causa in ('01-999-01568397-4-00')) order by ID_REL_CAUSA_ESTADO;
    DECLARE
    L_FEC_ACTUAL DATE:=SYSDATE;
    L_ID_CAUSA NUMBER ;
    L_NRO_CAUSA VARCHAR2(1000):= '02-061-00427562-5-00';
    L_REL_CAUSA_ESTADO_ANTERIOR NUMBER;
    L_ID_ESTADO_CAUSA NUMBER :=44; -- VER ESTADO 40 CERRADO --> 66 ANULADA    
    L_ID_DESCARGO integer;
    BEGIN
       --OBTENGO EL ID_CAUSA 
       select ID_CAUSA INTO L_ID_CAUSA from juzgado.causas where nro_causa=L_NRO_CAUSA;
       -- ACTUALIZO
       update  juzgado.causas set id_estado_causa=L_ID_ESTADO_CAUSA where id_causa=L_ID_CAUSA;
       --OBTENGO EL ID_REL_ESTADO_CAUSA
       SELECT max(ID_REL_CAUSA_ESTADO)  INTO L_REL_CAUSA_ESTADO_ANTERIOR FROM JUZGADO.REL_CAUSAS_ESTADOS WHERE ID_CAUSA=L_ID_CAUSA AND F_VIGENCIA_HASTA IS NULL;
	   -- pongo vencidas las rel_causas estados con f_vigencia_hasta null
	   UPDATE JUZGADO.REL_CAUSAS_ESTADOS SET F_VIGENCIA_HASTA=L_FEC_ACTUAL WHERE ID_CAUSA=L_ID_CAUSA AND F_VIGENCIA_HASTA IS NULL;
        INSERT INTO JUZGADO.REL_CAUSAS_ESTADOS (ID_REL_CAUSA_ESTADO,ID_CAUSA,ID_ESTADO_CAUSA,F_VIGENCIA_DESDE,ID_REL_CAUSA_ESTADO_ANTERIOR)
        VALUES (JUZGADO.SQ_ID_REL_CAUSA_ESTADO.NEXTVAL,L_ID_CAUSA,L_ID_ESTADO_CAUSA,L_FEC_ACTUAL,L_REL_CAUSA_ESTADO_ANTERIOR);
        --UPDATE JUZGADO.REL_CAUSAS_ESTADOS SET F_VIGENCIA_HASTA=L_FEC_ACTUAL WHERE ID_REL_CAUSA_ESTADO=L_REL_CAUSA_ESTADO_ANTERIOR;
        -- SI se pasa a estado CERRADO 40 , desactivo los movimientos de cuenas activos
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
    END;
    /
    --Si el estado de la causa quedo como quriamos 
    select T2.ESTADO_CAUSA,T1.* from juzgado.causas T1,JUZGADO.ESTADOS_CAUSAS T2  where T1.ID_ESTADO_CAUSA=T2.ID_ESTADO_CAUSA AND  nro_causa in ('02-074-00274067-5-00');
    -- Comitear los cambios
    COMMIT;
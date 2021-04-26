select T2.ESTADO_CAUSA,T1.* from juzgado.causas T1,JUZGADO.ESTADOS_CAUSAS T2  where T1.ID_ESTADO_CAUSA=T2.ID_ESTADO_CAUSA 
AND  nro_causa in ('02-144-00006886-6-00','02-144-00003704-9-00','02-144-00017414-1-00','02-144-00010077-0-00','02-144-00011175-0-00','02-144-00014102-6-00','02-144-00005278-3-00',
    '02-144-00009921-3-00','02-144-00001627-0-00','02-144-00017414-1-00','02-144-00011089-2-00','02-144-00006886-6-00','02-144-00018931-3-00','02-144-00002340-7-00','02-144-00004712-9-00','02-144-00005631-0-00','02-144-00015517-2-00','02-144-00014102-6-00',
    '02-144-00005278-3-00','02-144-00009921-3-00','02-144-00004837-3-00','02-144-00011687-4-00','02-144-00014474-2-00','02-144-00006935-4-00','02-144-00017936-5-00','02-144-00013771-2-00','02-144-00007832-2-00','02-144-00017549-5-00','02-144-00002994-4-00',
    '02-144-00006443-1-00','02-144-00017653-3-00','02-144-00002538-1-00','02-144-00004918-3-00','02-144-00007383-3-00','02-144-00008690-4-00','02-144-00012368-2-00','02-144-00011687-4-00','02-144-00017814-3-00','02-144-00003507-0-00','02-144-00010418-9-00',
    '02-144-00013132-7-00','02-144-00015453-1-00','02-144-00011089-2-00','02-144-00011735-1-00','02-144-00000447-0-00','02-144-00000676-2-00','02-144-00000661-9-00','02-144-00018919-6-00','02-144-00015545-2-00','02-144-00000728-1-00','02-144-00001570-9-00','02-144-00009345-3-00','02-144-00002165-9-00','02-144-00016302-8-00','02-144-00002144-8-00','02-144-00003493-2-00','02-144-00008323-0-00','02-144-00015893-5-00','02-144-00011798-5-00','02-144-00011595-3-00','02-144-00002248-0-00');

DECLARE
    L_FEC_ACTUAL DATE:=SYSDATE;
    L_ID_CAUSA NUMBER ;
    L_NRO_CAUSA VARCHAR2(1000):= '02-039-00000789-4-00';
    L_REL_CAUSA_ESTADO_ANTERIOR NUMBER;
    L_ID_ESTADO_CAUSA NUMBER :=44; -- VER ESTADO 40 CERRADO --> 66 ANULADA  
    L_ID_DESCARGO number;	
    type array_t is table of varchar2(20);
    array array_t := array_t('02-003-00164035-2-00','02-074-00482045-4-00','02-003-00139357-6-00','02-074-00487603-6-00','02-119-00436637-7-00','02-003-00169121-2-00','02-003-00175382-5-00','02-003-00152446-3-00',
'02-132-00254679-9-00','02-121-00352952-5-00','02-016-00412705-2-00','02-007-00161977-8-00','02-007-00165449-7-00','02-056-00003659-4-00','02-034-00056953-6-00','02-059-00238126-3-00',
'02-082-00040294-2-00','02-003-00082919-7-00','02-089-00120555-1-00','02-099-00148787-0-00','02-082-00036207-1-00','02-029-00118811-2-00','02-016-00416977-9-00','02-089-00107579-7-00',
'02-029-00115393-3-00','02-003-00113459-4-00','02-119-00428253-4-00','02-999-04608669-2-00','02-104-00446876-0-00','02-112-00953589-2-00','02-030-00658586-1-00','02-029-00154768-8-00',
'02-029-00159529-8-00','02-007-00227886-9-00','02-016-00506924-5-00','02-074-00687349-1-00','02-132-00406325-2-00','02-132-00398817-0-00','02-112-00953563-8-00','02-034-00099323-5-00',
'02-089-00336674-7-00','02-119-00643820-4-00','02-049-00131557-3-00','02-059-00275906-7-00','02-059-00275695-9-00','02-061-00282841-5-00','02-021-00093060-1-00','02-134-00244239-4-00',
'02-049-00141088-3-00','02-135-00511400-8-00','02-089-00343592-5-00','02-059-00277578-0-00','02-029-00154780-5-00','02-104-00441082-2-00','02-112-00936863-0-00','02-059-00275572-6-00',
'02-030-00673067-7-00','02-089-00335855-7-00','02-074-00679060-6-00','02-143-00026703-1-00','02-105-00430458-4-00','02-059-00275291-5-00','02-093-00028710-1-00','02-139-00152221-9-00',
'02-089-00348572-7-00','02-135-00506291-4-00','02-135-00500129-1-00','02-135-00513061-0-00','02-034-00098465-8-00','02-021-00092938-8-00','02-003-00147907-6-00','02-139-00053386-5-00',
'02-074-00473325-4-00','02-132-00256263-4-00','02-021-00060606-1-00','02-059-00241519-3-00','02-059-00239692-8-00','02-099-00150155-1-00','02-029-00116096-4-00','02-059-00238258-6-00',
'02-029-00116510-9-00','02-059-00242465-4-00','02-016-00410552-1-00','02-121-00354877-9-00','02-016-00407919-7-00','02-016-00408275-5-00','02-099-00145579-8-00','02-082-00035505-1-00',
'02-089-00096685-9-00','02-099-00149027-4-00','02-029-00114676-5-00','02-089-00109802-2-00','02-059-00240081-0-00','02-016-00402651-1-00','02-132-00262228-3-00','02-023-00265811-4-00',
'02-029-00116318-2-00','02-082-00036974-7-00','02-029-00119440-2-00','02-059-00243898-9-00','02-059-00236738-7-00','02-059-00239567-8-00','02-139-00022446-1-00','02-077-00084446-5-00',
'02-067-00038611-2-00','02-119-00424433-2-00');
    BEGIN
    for i in 1..array.count loop
    L_NRO_CAUSA:=array(i);
    --dbms_output.put_line(array(i));
               BEGIN
       --OBTENGO EL ID_CAUSA 
       select ID_CAUSA INTO L_ID_CAUSA from juzgado.causas where nro_causa=L_NRO_CAUSA;
       -- ACTUALIZO
       update  juzgado.causas set id_estado_causa=L_ID_ESTADO_CAUSA where id_causa=L_ID_CAUSA;
       --OBTENGO EL ID_REL_ESTADO_CAUSA
       SELECT ID_REL_CAUSA_ESTADO  INTO L_REL_CAUSA_ESTADO_ANTERIOR FROM JUZGADO.REL_CAUSAS_ESTADOS WHERE ID_CAUSA=L_ID_CAUSA AND F_VIGENCIA_HASTA IS NULL;
        INSERT INTO JUZGADO.REL_CAUSAS_ESTADOS (ID_REL_CAUSA_ESTADO,ID_CAUSA,ID_ESTADO_CAUSA,F_VIGENCIA_DESDE,ID_REL_CAUSA_ESTADO_ANTERIOR)
        VALUES (JUZGADO.SQ_ID_REL_CAUSA_ESTADO.NEXTVAL,L_ID_CAUSA,L_ID_ESTADO_CAUSA,L_FEC_ACTUAL,L_REL_CAUSA_ESTADO_ANTERIOR);
        UPDATE JUZGADO.REL_CAUSAS_ESTADOS SET F_VIGENCIA_HASTA=L_FEC_ACTUAL WHERE ID_REL_CAUSA_ESTADO=L_REL_CAUSA_ESTADO_ANTERIOR;
		IF L_ID_ESTADO_CAUSA = 40
        then
            for reg in (SELECT T3.ESTADO_MOVIMIENTO_CUENTA,t2.ID_MOVIMIENTO_DE_CUENTA FROM juzgado.causas T1 ,FINANZAS.MOVIMIENTOS_DE_CUENTAS T2 ,FINANZAS.ESTADOS_MOVIMIENTOS_CUENTAS T3 WHERE T1.ID_CAUSA=T2.ID_CAUSA
            AND T3.ID_ESTADO_MOVIMIENTO_CUENTA=T2.ID_ESTADO_MOVIMIENTO_CUENTA and t2.id_estado_movimiento_cuenta in (12) AND T1.nro_causa=L_NRO_CAUSA )
            loop
                update FINANZAS.MOVIMIENTOS_DE_CUENTAS set id_estado_movimiento_cuenta=14 where id_movimiento_de_cuenta=reg.ID_MOVIMIENTO_DE_CUENTA;
            end loop;
        end if;
        DBMS_OUTPUT.PUT_LINE(lpad('#',50,'#')||chr(13)||'Se modifico la  causa  : '||L_NRO_CAUSA||' pasandola al estado :'||L_ID_ESTADO_CAUSA||chr(13)||lpad('#',50,'#') );
		IF L_ID_ESTADO_CAUSA = 44
        then 
             select id_descargo into L_ID_DESCARGO from JUZGADO.REL_DESCARGOS_CAUSA rrc where id_causa in (select id_causa from juzgado.causas where nro_causa=L_NRO_CAUSA);
             -- invalido el descargo 
             update  juzgado.descargos set  estado_descargo='N' where id_descargo in (L_ID_DESCARGO);  
        end if;
        exception
        WHEN NO_DATA_FOUND then
           DBMS_OUTPUT.PUT_LINE(lpad('#',50,'#')||chr(13)||'El la causa  : '||L_NRO_CAUSA||' NO SE ENCONTRO EN LA BASE  '||chr(13)||lpad('#',50,'#') );
        END;
   end loop;
    END;
    /	
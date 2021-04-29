SET SERVEROUT ON
DECLARE
    l_id_causa JUZGADO.CAUSAS.id_causa%TYPE;
    l_id_notificacion FINANZAS.MOVIMIENTOS_DE_CUENTAS.id_notificacion%TYPE;
    l_cod_red_link NOTIFICACIONES.NOTIFICACIONES.cod_red_link%TYPE;
    l_id_id_notificacion number;
    L_BARCODE_GENERADO  varchar2(100);
    L_BARCODE_FINAL VARCHAR2(100);
    L_COD_BARRA VARCHAR2(100);
    L_MONTO NUMBER := 53478.07;
    L_FECHA_VENCIMIENTO DATE := TO_DATE('2021-02-15 00:00:00', 'YYYY-MM-DD HH24:MI:SS');
    L_FECHA_EMISION DATE := SYSDATE;
    L_COUNT NUMBER;
    L_NRO_CAUSA VARCHAR2(80)  :='01-999-10275824-0-00' ;
    L_ID_ACTA NUMBER;
    l_id_persona NUMBER;
  --  L_ID_CAUSA NUMBER;
    L_ID_MOVIMIENTO_DE_CUENTA NUMBER;
    L_ID_MOVIMIENTO_DE_CUENTA_CH NUMBER;
    L_ID_MOVIMIENTO_DE_CUENTA_GN NUMBER;
    
    PROCEDURE GET_BARCODE (L_BARCODE_GENERADO IN VARCHAR2, L_BARCODE_FINAL OUT VARCHAR2) 
    IS
      L_BARCODE_ORIGINAL VARCHAR2(100) :=L_BARCODE_GENERADO;
      L_BARCODE_MODIFICADO VARCHAR2(100);
      TYPE POSICION IS TABLE OF NUMBER;
      L_POSICION_1ER_DIGITO POSICION :=POSICION(5,6,7,11,12,13,14,15,16,17,20,21,22,23,24,25,26,27,28); -- posiciones para calcluar el primer digito
      L_PONDERACION_1ER_DIGITO POSICION :=POSICION(3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3); -- numeros para pomderar y  para calcluar el primer digito
      L_POSICION_DIG_VERIF POSICION :=POSICION(29,46); -- POSICION DEL CODIGO VERIFICADOR
        L_POSICION_2DO_DIGITO POSICION :=POSICION(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45); -- posiciones para calcluar el primer digito
      L_PONDERACION_2DO_DIGITO POSICION :=POSICION(3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3); -- numeros para pomderar y  para calcluar el primer digito
      L_SUMA number :=0;
      L_DIGITO NUMBER;
      L_PONDERAROR number;
      L_DIGITO_VERIFICADOR NUMBER;
      L_COMODIN NUMBER;
      
    BEGIN
       --DBMS_OUTPUT.PUT_LINE(L_BARCODE_ORIGINAL);
      --Abro al tabla con las posiciones para calcular el digito intermendio
      FOR i IN L_POSICION_1ER_DIGITO.FIRST .. L_POSICION_1ER_DIGITO.LAST LOOP
          -- EXTRAIGO EL NUMERO DEL CODIGO DE BARRAS
          L_DIGITO:=SUBSTR(L_BARCODE_ORIGINAL,L_POSICION_1ER_DIGITO(i),1);
          -- EXTRAIGO EL PONDERADOS CORRESPONDIENTE
          L_PONDERAROR:=L_PONDERACION_1ER_DIGITO(i);
          --  REALIZO LA SUMA POST MULTIPLICACION DE DEL DIGITO PONDERADOR X DIGITO DEL BARCODE
          L_SUMA := L_SUMA + (L_DIGITO*L_PONDERAROR);
          --DBMS_OUTPUT.put_line(L_SUMA);
      END LOOP;
      --DBMS_OUTPUT.put_line(L_SUMA);
      L_DIGITO_VERIFICADOR :=   L_SUMA - (TRUNC(L_SUMA/10)*10);
      IF L_DIGITO_VERIFICADOR = 0 THEN
          L_DIGITO_VERIFICADOR:=L_DIGITO_VERIFICADOR;
      ELSE
          L_DIGITO_VERIFICADOR:=10 - L_DIGITO_VERIFICADOR;
      END IF;
      --DBMS_OUTPUT.put_line(L_DIGITO_VERIFICADOR);--
      -- ahora actuallizo el BARCODE ORIGINAL
      --DBMS_OUTPUT.PUT_LINE(L_BARCODE_ORIGINAL);
      -- Modifico la posicion 29 del barcode
      L_BARCODE_MODIFICADO:=REGEXP_REPLACE( L_BARCODE_ORIGINAL, '[0-9]', L_DIGITO_VERIFICADOR, 1,L_POSICION_DIG_VERIF(1) ) ;
     -- DBMS_OUTPUT.PUT_LINE(L_BARCODE_MODIFICADO);
     -- DBMS_OUTPUT.PUT_LINE(L_BARCODE_ORIGINAL);
      --###############################################################---
      --###  ARRANCO LA GENERACION DEL SEGUNDO DIGITO DE VERIFICACION ###############---
      --###############################################################---
      --Abro al tabla con las posiciones para calcular el digito intermendio
      --INICIALIZO L_SUMA
      L_SUMA:=0;
      FOR i IN L_POSICION_2DO_DIGITO.FIRST .. L_POSICION_2DO_DIGITO.LAST LOOP
          -- EXTRAIGO EL NUMERO DEL CODIGO DE BARRAS
          L_DIGITO:=SUBSTR(L_BARCODE_MODIFICADO,L_POSICION_2DO_DIGITO(i),1);
          -- EXTRAIGO EL PONDERADOS CORRESPONDIENTE
          L_PONDERAROR:=L_PONDERACION_2DO_DIGITO(i);
          --DBMS_OUTPUT.put_line(L_DIGITO||'-->'||L_PONDERAROR);
          --  REALIZO LA SUMA POST MULTIPLICACION DE DEL DIGITO PONDERADOR X DIGITO DEL BARCODE
          L_SUMA := L_SUMA + (L_DIGITO*L_PONDERAROR);
          --DBMS_OUTPUT.put_line(L_SUMA);
      END LOOP;
      --DBMS_OUTPUT.put_line(L_SUMA);
      L_DIGITO_VERIFICADOR :=   L_SUMA - (TRUNC(L_SUMA/10)*10);
      IF L_DIGITO_VERIFICADOR = 0 THEN
          L_DIGITO_VERIFICADOR:=L_DIGITO_VERIFICADOR;
      ELSE
           L_DIGITO_VERIFICADOR:=10 - L_DIGITO_VERIFICADOR;
      END IF;
      --DBMS_OUTPUT.put_line(L_DIGITO_VERIFICADOR);--
      -- Modifico la posicion 46 del barcode
      L_BARCODE_MODIFICADO:=REGEXP_REPLACE( L_BARCODE_MODIFICADO, '[0-9]', L_DIGITO_VERIFICADOR, 1,L_POSICION_DIG_VERIF(2) ) ;
     -- DBMS_OUTPUT.PUT_LINE(L_BARCODE_MODIFICADO);
      --DBMS_OUTPUT.PUT_LINE(L_BARCODE_ORIGINAL);
      L_BARCODE_FINAL:=L_BARCODE_MODIFICADO;
    END;
BEGIN
    select notificaciones.sq_id_notificacion.nextval into  l_id_id_notificacion from dual;
    select c.id_causa INTO l_id_causa from juzgado.causas c where c.nro_causa =L_NRO_CAUSA;
    -- busco la ultima sentencia que no este ANULADA NI OBSERVADA
    select mc.id_notificacion,mc.cod_barra INTO l_id_notificacion,L_COD_BARRA from finanzas.movimientos_de_cuentas mc where mc.id_notificacion = (select MAX (mc.id_notificacion) from finanzas.movimientos_de_cuentas mc where mc.id_causa = l_id_causa  and id_estado_movimiento_cuenta not in (15,41));
    select n.cod_red_link INTO l_cod_red_link from notificaciones.notificaciones n where n.id_notificacion = l_id_notificacion;
    
      select mc.id_persona, mc.id_acta INTO l_id_persona, l_id_acta from finanzas.movimientos_de_cuentas mc where mc.id_notificacion = (select MAX (mc.id_notificacion) from finanzas.movimientos_de_cuentas mc where mc.id_causa = l_id_causa);


    --DBMS_OUTPUT.PUT_LINE(l_id_notificacion);
    --PARA PRUEBAS!!!!!  COOMENTAR
    --l_id_id_notificacion:=50979399;
    ---------------------------------------
    --L_BARCODE_GENERADO:='66600001320713899090'||l_id_id_notificacion||'2'||TO_CHAR(L_FECHA_VENCIMIENTO,'YYYYMMDD')||LPAD(TO_CHAR(L_MONTO*100),8,'0'  )||'2';
    L_BARCODE_GENERADO:=substr(L_COD_BARRA,1,20)||l_id_id_notificacion||'2'||TO_CHAR(L_FECHA_VENCIMIENTO,'YYYYMMDD')||LPAD(TO_CHAR(L_MONTO*100),8,'0'  )||'2';
--    DBMS_OUTPUT.PUT_LINE(L_BARCODE_GENERADO);
    
    --DESCOMENTAR LA SIGUEINTE LINEA PARA PROD
    --commit; 
    ---------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE(lpad('#',50,'#')||chr(13)||'El la causa  es : '||L_NRO_CAUSA||chr(13)||lpad('#',50,'#') );
    DBMS_OUTPUT.PUT_LINE(lpad('#',50,'#')||chr(13)||'El codigo redlink  es : '||l_cod_red_link||chr(13)||lpad('#',50,'#') );
    DBMS_OUTPUT.PUT_LINE(lpad('#',50,'#')||chr(13)||'El barcode anterior es : '||L_COD_BARRA||chr(13)||lpad('#',50,'#') );
    GET_BARCODE (L_BARCODE_GENERADO, L_BARCODE_FINAL) ;
  DBMS_OUTPUT.PUT_LINE(lpad('#',50,'#')||chr(13)||'El barcode final es : '||L_BARCODE_FINAL||chr(13)||lpad('#',50,'#') );
  DBMS_OUTPUT.PUT_LINE(lpad('#',50,'#')||chr(13)||'El ID_NOTIFICACION final es : '||l_id_id_notificacion||chr(13)||lpad('#',50,'#') );
  
  --DESCOMENTAR LA SIGUEINTE LINEA PARA PROD
    INSERT INTO notificaciones.notificaciones (ID_NOTIFICACION,F_EMISION,DIGITO_VERIF,NRO_COMPROBANTE,LOTE,ORDEN,NRO_PIEZA_EMITIDO,RECIBO_IMPOSICION,IMPORTE,PORCENTAJE,IMPORTE_PORCENTAJE,ID_TIPO_CEDULA,CODIGO_BARRAS,F_VENCIMIENTO,ID_ESTADO_LINK,ID_ESTADO_BAPRO_ELEC,F_ENTREGA,ID_FIRMANTE_NOTIF,CANT_IMPRESION,LUGAR_IMPRESION,IMAGEN_NOTIFICACION,TIPO_EMISION,ID_LOTE_NOT,COD_RED_LINK,F_IMPOSICION,OBS,ID_CAUSA,ES_REBELDIA,ES_FEHACIENTE,ID_ESTADO_NOTIFICACION,ES_PRORROGA,C_NEGOCIO,I_DEUDA_RECLAMADA,FH_AUTORIZACION,M_AUTORIZACION,ID_USUARIO_ANULACION,FH_ANULACION,ID_MOTIVO_OPERACION,X_ANULACION_DESCRIPCION,UF_IMPORTE_ORIGINAL,M_ESTADO_EXPORTACION,ID_INFORME_INFRACCION,X_PATH_MIGRACION,B_ESTA_PROCESADO,B_PARA_PROCESAR,CANTIDAD_UF_NEW,FECHA_FIRMA,NI_ELECTRONICA) 
    VALUES(l_id_id_notificacion,SYSDATE,NULL,NULL,NULL,NULL,NULL,NULL,L_MONTO,NULL,NULL,4,'1234',L_FECHA_VENCIMIENTO,1,1,SYSDATE,8,NULL,NULL,EMPTY_BLOB(),'M',NULL,l_cod_red_link,NULL,NULL,NULL,'N','N',8,'N',NULL,NULL,NULL,'N',NULL,NULL,NULL,NULL,NULL,'M',NULL,NULL,'N','N',300,NULL,NULL);
  
  UPDATE notificaciones.notificaciones n SET n.codigo_barras = L_BARCODE_FINAL WHERE n.id_notificacion = l_id_id_notificacion;
  
      --VALIDACION DE CORRECTA INSERCCION 
    SELECT COUNT(1) INTO L_COUNT FROM notificaciones.notificaciones WHERE ID_NOTIFICACION=l_id_id_notificacion;
    --DESCOMENTAR LA SIGUEINTE LINEA PARA PROD
    L_COUNT:=1; 
    ---------------------------------------------------------
    IF L_COUNT =0 THEN
       rollback;
        RAISE_APPLICATION_ERROR(-20020,'ERROR: NO SE DETECTO EL REGISTRO CON ID_NOTIFICACION='||l_id_id_notificacion||' EN LA TABLA notificaciones.notificaciones' );
    END IF;

    INSERT INTO finanzas.movimientos_de_cuentas (ID_MOVIMIENTO_DE_CUENTA,ID_MOVIMIENTO_DE_CUENTA_GENERA,ID_TIPO_COMPROBANTE_FINANZA,VALOR_ORIGINAL,F_EMISION,ID_PERSONA,ID_ESTADO_MOVIMIENTO_CUENTA,SALDO,CANTIDAD_UF,F_VENCIMIENTO,COD_BARRA,ID_NOTIFICACION,ID_ACTA,VALOR_COBRADO,ID_CAUSA,ID_PLAN_DE_PAGO,DESCRIPCION,UF_INTERES,UF_INTERES_OLD,M_ERROR) 
    VALUES(finanzas.sq_id_movimiento_de_cuenta.NEXTVAL,NULL,20,L_MONTO,L_FECHA_EMISION,l_id_persona,12,L_MONTO,0,L_FECHA_VENCIMIENTO,L_BARCODE_GENERADO,l_id_id_notificacion,l_id_acta,0,l_id_causa,NULL,NULL,NULL,NULL,NULL);
   L_ID_MOVIMIENTO_DE_CUENTA := finanzas.sq_id_movimiento_de_cuenta.CURRVAL ;
   --DBMS_OUTPUT.PUT_LINE(lpad('#',50,'#')||chr(13)||'El ID_MOVIMIENTO_DE_CUENTA final es : '||finanzas.sq_id_movimiento_de_cuenta.CURRVAL||chr(13)||lpad('#',50,'#') );
   DBMS_OUTPUT.PUT_LINE(lpad('#',50,'#')||chr(13)||'El ID_MOVIMIENTO_DE_CUENTA final es : '||L_ID_MOVIMIENTO_DE_CUENTA||chr(13)||lpad('#',50,'#') );
   
    INSERT INTO notificaciones.rel_notificaciones_estados (ID_REL_NOTIFICACION_ESTADO,ID_NOTIFICACION,ID_ESTADO_NOTIFICACION,F_VIGENCIA_DESDE,F_VIGENCIA_HASTA,ID_MOTIVO_CAMBIO_ESTADO_NOTIF,OBSERVACION,NRO_TICKET) 
    VALUES(notificaciones.sq_id_rel_notificacion_estado.NEXTVAL,l_id_id_notificacion,8,L_FECHA_EMISION,NULL,NULL,NULL,NULL);
    
    DBMS_OUTPUT.PUT_LINE(lpad('#',50,'#')||chr(13)||'El ID_REL_NOTIFICACION_ESTADO final es : '||notificaciones.sq_id_rel_notificacion_estado.CURRVAL||chr(13)||lpad('#',50,'#') );

    INSERT INTO notificaciones.rel_causas_notificaciones (ID_NOTIFICACION,ID_CAUSA) 
    VALUES(l_id_id_notificacion,l_id_causa);
    
    -- Agregado : Se debe pasar a DEUDA_INACTIVA la sentencia anterior al apremio
    -- SACO EL ID_CAUSA
    --SELECT ID_CAUSA INTO L_ID_CAUSA FROM juzgado.causas WHERE nro_causa=L_NRO_CAUSA;
    --Extraigo el ultimo movimiento de cuanta con estado DEUDA_INACTIVA
    select max(ID_MOVIMIENTO_DE_CUENTA) into L_ID_MOVIMIENTO_DE_CUENTA_GN from FINANZAS.MOVIMIENTOS_DE_CUENTAS where id_causa= l_id_causa and ID_ESTADO_MOVIMIENTO_CUENTA=14;
    -- grabo los movimientos de cuenta a cambiar de estado 12 a 14
    for rec in (select ID_MOVIMIENTO_DE_CUENTA as ID_MOVIMIENTO_DE_CUENTA_CH from FINANZAS.MOVIMIENTOS_DE_CUENTAS where id_causa=l_id_causa and ID_MOVIMIENTO_DE_CUENTA!=L_ID_MOVIMIENTO_DE_CUENTA AND ID_ESTADO_MOVIMIENTO_CUENTA=12 order by ID_MOVIMIENTO_DE_CUENTA)
    loop
    UPDATE FINANZAS.MOVIMIENTOS_DE_CUENTAS SET ID_ESTADO_MOVIMIENTO_CUENTA=14,ID_MOVIMIENTO_DE_CUENTA_GENERA=L_ID_MOVIMIENTO_DE_CUENTA_GN WHERE ID_MOVIMIENTO_DE_CUENTA=rec.ID_MOVIMIENTO_DE_CUENTA_CH;
    DBMS_OUTPUT.PUT_LINE(lpad('#',50,'#')||chr(13)||'El ID_MOVIMIENTO_DE_CUENTA  '||rec.ID_MOVIMIENTO_DE_CUENTA_CH||' paso de estado DEUDA_ACTIVA(12) a estado DEUDA_INACTIVA(14)'||chr(13)||lpad('#',50,'#') );
    -- Seteo el L_ID_MOVIMIENTO_DE_CUENTA_GN para el proximo registro
    L_ID_MOVIMIENTO_DE_CUENTA_GN:=rec.ID_MOVIMIENTO_DE_CUENTA_CH;
    end loop;
END;
/
--SELECT rowid,a.*  FROM notificaciones.notificaciones a WHERE ID_NOTIFICACION=51021845; 
--SELECT * FROM finanzas.movimientos_de_cuentas WHERE ID_MOVIMIENTO_DE_CUENTA=41834243;
--SELECT * FROM notificaciones.rel_notificaciones_estados WHERE ID_REL_NOTIFICACION_ESTADO=94332478;
--SELECT * FROM notificaciones.rel_causas_notificaciones WHERE ID_NOTIFICACION=50979781;
--rollback
--delete from notificaciones.rel_causas_notificaciones WHERE ID_NOTIFICACION=50979760;
--delete FROM notificaciones.rel_notificaciones_estados WHERE ID_REL_NOTIFICACION_ESTADO=94332452;
--delete  FROM finanzas.movimientos_de_cuentas WHERE ID_MOVIMIENTO_DE_CUENTA=41834222;
--delete  FROM notificaciones.notificaciones a WHERE ID_NOTIFICACION=50979760; 
-- verifico que los movimientos de cuenta pasen a inactivo
--select * from FINANZAS.MOVIMIENTOS_DE_CUENTAS T2 where id_causa=15400800 order by id_movimiento_de_cuenta;

--SELECT ID_CAUSA FROM juzgado.causas WHERE nro_causa='01-999-10277106-0-00';



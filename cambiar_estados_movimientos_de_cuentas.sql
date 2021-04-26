SELECT T3.ESTADO_MOVIMIENTO_CUENTA,t2.ID_MOVIMIENTO_DE_CUENTA ,T2.*
FROM juzgado.causas T1 ,FINANZAS.MOVIMIENTOS_DE_CUENTAS T2 ,FINANZAS.ESTADOS_MOVIMIENTOS_CUENTAS T3
WHERE T1.ID_CAUSA=T2.ID_CAUSA
AND T3.ID_ESTADO_MOVIMIENTO_CUENTA=T2.ID_ESTADO_MOVIMIENTO_CUENTA
--and t2.id_estado_movimiento_cuenta in (12,7,14)
AND T1.nro_causa='01-999-10373391-0-00'  -- AND T2.VALOR_ORIGINAL=1598 
--     and T2.F_EMISION < to_date('18/01/2021 08:32','DD/MM/YYYY HH24:MI')-- 
--      and T2.F_VENCIMIENTO >= L_FECHA_PAGO
order by t2.id_movimiento_de_cuenta desc;
--            select rowid,a.* from FINANZAS.MOVIMIENTOS_DE_CUENTAS a where id_movimiento_de_cuenta=42559010;
--            update FINANZAS.MOVIMIENTOS_DE_CUENTAS a set id_estado_movimiento_cuenta=7 where id_movimiento_de_cuenta=29007949;
DECLARE 
    L_FEC_ACTUAL DATE:=SYSDATE;
    L_ID_CAUSA NUMBER ;
    L_ID_ESTADO_MOV_CUENTA NUMBER :=7; -- VER ESTADO 7 PENDIENTE ACREDITACION --> 15 ANULADA   --> 14 DEUDA_INACTIVA
    L_NRO_CAUSA VARCHAR2(40); 
    L_FECHA_PAGO DATE;
    L_VALOR_ORIGINAL number;
    L_ID_MOVIMIENTO_DE_CUENTA INTEGER;
    type array_t is table of varchar2(100);
    -- el siguiente es un array donde se cargan por fila NRO_CUASA "espacio" importe . Si el valor es redondo no poner la parte decimal por ejemplo 6325.0 -->  6325
    array array_t := array_t('01-999-10373391-0-00 4550 11/03/2021-15:50');
BEGIN
   -- Parseo el contenido
   execute immediate 'Alter session set nls_date_format=''DD/MM/YYYY HH24:MI''';
    for i in 1..array.count loop
      L_NRO_CAUSA:=trim(REGEXP_SUBSTR(array(i),'^[0-9]+(-)[0-9]+(-)[0-9]+(-)[0-9]+(-)[0-9]+(\s)+',1,1));
      L_VALOR_ORIGINAL := trim(REGEXP_SUBSTR(array(i),'(\s)+[0-9]+(\.)*[0-9]*'));
      L_FECHA_PAGO := to_date(replace(trim(REGEXP_SUBSTR(array(i),'(\s)[0-9]+(/)[0-9]+(/)[0-9][0-9][0-9][0-9](-)*.*$')),'-',' '),'DD/MM/YYYY HH24:MI');
      dbms_output.put_line('El nro_causa es : '||L_NRO_CAUSA);
      dbms_output.put_line('El MONTO  es : '||L_VALOR_ORIGINAL);
      dbms_output.put_line('La FECHA_PAGO  es : '||L_FECHA_PAGO);
      
      SELECT t2.ID_MOVIMIENTO_DE_CUENTA INTO L_ID_MOVIMIENTO_DE_CUENTA
      FROM juzgado.causas T1 ,FINANZAS.MOVIMIENTOS_DE_CUENTAS T2 ,FINANZAS.ESTADOS_MOVIMIENTOS_CUENTAS T3
      WHERE T1.ID_CAUSA=T2.ID_CAUSA
      AND T3.ID_ESTADO_MOVIMIENTO_CUENTA=T2.ID_ESTADO_MOVIMIENTO_CUENTA
      and t2.id_estado_movimiento_cuenta in (12,7,14)
      AND T1.nro_causa=L_NRO_CAUSA AND (T2.VALOR_ORIGINAL=L_VALOR_ORIGINAL  OR T2.SALDO=L_VALOR_ORIGINAL)
      and T2.F_EMISION < L_FECHA_PAGO-- 
      and T2.F_VENCIMIENTO >= L_FECHA_PAGO
--      and L_FECHA_PAGO between T2.F_EMISION and T2.F_VENCIMIENTO
      ;
       dbms_output.put_line(lpad('#',80,'#')||chr(13)||'El mov de cuenta es :  '||L_ID_MOVIMIENTO_DE_CUENTA||chr(13)||lpad('#',80,'#') );
       -- le pongo el estado correspondiente
        update FINANZAS.MOVIMIENTOS_DE_CUENTAS a set id_estado_movimiento_cuenta=L_ID_ESTADO_MOV_CUENTA where id_movimiento_de_cuenta=L_ID_MOVIMIENTO_DE_CUENTA; 
        -- Verifico que si se le puso estado 7 no haya otros mov acitvos y los anulo
        IF ( L_ID_ESTADO_MOV_CUENTA = 7 )
        THEN
          for reg in (SELECT t2.ID_MOVIMIENTO_DE_CUENTA 
                     FROM juzgado.causas T1 ,FINANZAS.MOVIMIENTOS_DE_CUENTAS T2 ,FINANZAS.ESTADOS_MOVIMIENTOS_CUENTAS T3
                     WHERE T1.ID_CAUSA=T2.ID_CAUSA AND T3.ID_ESTADO_MOVIMIENTO_CUENTA=T2.ID_ESTADO_MOVIMIENTO_CUENTA and t2.id_estado_movimiento_cuenta in (12)  AND T1.nro_causa=L_NRO_CAUSA)
          loop
            update FINANZAS.MOVIMIENTOS_DE_CUENTAS a set id_estado_movimiento_cuenta=15 where id_movimiento_de_cuenta=reg.ID_MOVIMIENTO_DE_CUENTA; 
          end loop;
        END IF;
    end loop;
END;
/    
-- 1 -Ver las causas Activas para la causa (id_estado_movimiento_cuenta = 12) 
SELECT T3.ESTADO_MOVIMIENTO_CUENTA,t2.ID_MOVIMIENTO_DE_CUENTA,T1.* ,T2.*
FROM juzgado.causas T1 ,FINANZAS.MOVIMIENTOS_DE_CUENTAS T2 ,FINANZAS.ESTADOS_MOVIMIENTOS_CUENTAS T3
WHERE T1.ID_CAUSA=T2.ID_CAUSA
AND T3.ID_ESTADO_MOVIMIENTO_CUENTA=T2.ID_ESTADO_MOVIMIENTO_CUENTA
and t2.id_estado_movimiento_cuenta in (12,7)
AND T1.nro_causa='02-069-00023768-5-00' order by t2.id_movimiento_de_cuenta desc;

-- 2 - Con el id_movimiento_de_cuenta del paso 1 actualizar el estado a 7 ( PENDIENTE DE ACREDITACION  ) 
-- Si fuese otro estado ver en ( select * from FINANZAS.ESTADOS_MOVIMIENTOS_CUENTAS)
--select rowid,a.* from FINANZAS.MOVIMIENTOS_DE_CUENTAS a where id_movimiento_de_cuenta=42559010;
update FINANZAS.MOVIMIENTOS_DE_CUENTAS a set id_estado_movimiento_cuenta=7 where id_movimiento_de_cuenta=29007949; -- Poner el id_movimiento_de_cuenta del paso 1

-- 3 - volver a ejecutar la consulta del paso 1 y verificar que haya quedado el cambio
-- 4 - Confirmar rl cambio
COMMIT;
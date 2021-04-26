--VERIFICAR QUE EL USUARIO NO TENGA MOVIMIENTOS DE CUENTA DUPLICADOS CON ESTADO = 12

-- 1 - Sacar el ID_VEHICULO o ID_PERSONA a analizar
--BUSCAR EL ID_VEHICULO DESDE DOMINIO
select id_vehiculo from general.VEHICULOS  where dominio='AB604XH';
--BUSCAR EL ID_PERSONA DESDE EL DNI O CUIT
SELECT * FROM general.personas p WHERE p.pf_nro_doc = 5539559;
 
--id_persona: 3470

-- 2 - BUSCAR CAUSAS QUE TENGAN MOVIMIENTOS DE CUENTA DUPLICADOS con lo extraido en el punto 1  ( ID_VEHICULO o ID_PERSONA)

  SELECT mc.id_causa, COUNT (mc.id_causa) cant
    FROM     finanzas.movimientos_de_cuentas mc
         inner join juzgado.causas c on c.id_causa = mc.id_causa
         INNER JOIN
             juzgado.causas_personas p
         ON p.id_causa = mc.id_causa
   WHERE    
   --c.id_vehiculo in (select id_vehiculo from general.VEHICULOS  where dominio='AB604XH') -- Descomentar si es por ID_VEHICULO ( lo sacas con el DOMINIO)
     p.id_persona in ( 4547404)  -- Descomentar si es por ID_PERSONA ( lo sacas con el DNI)
         AND mc.id_estado_movimiento_cuenta = 12
         AND p.f_vigencia_hasta IS NULL
GROUP BY mc.id_causa
  HAVING COUNT (mc.id_causa) > 1
ORDER BY 2 DESC;

-- 3 - CON LOS ID_CAUSA, BUSCAR Y ACTUALIZAR LOS MOVIMIENTO DE CUENTA PARA QUE SÓLO UN REGISTRO (ÚLTIMO) TENGA ID_ESTADO = 12 (AL ANTEULTIMO PONERLE 14)

select 'update finanzas.movimientos_de_cuentas set id_estado_movimiento_cuenta=14 where id_movimiento_de_cuenta='|| min(id_movimiento_de_cuenta)||';',min(F_EMISION) from finanzas.movimientos_de_cuentas a where
 a.id_causa in  (7659028 )  -- Aca poner los ID_CAUSA que salieron en el paso 2
  and id_estado_movimiento_cuenta in (12)  group by id_causa having count(1)>1 order by id_causa desc;
-- Ejecutar los updates que devuelve la consulta 

-- 4 - VERIFICAR repitienod la consulta del punto 2 que no haya duplicados

-- 5 - Confirmar cambios
COMMIT;  
  
  
--select * from  finanzas.movimientos_de_cuentas a where a.id_causa in  
--(14138660,12347478,16779797,12647431,14097294,12556837,16995352,14857955,16544855,15395302,13337146,11886654,11392381,11934120,14372900 ) and id_estado_movimiento_cuenta in (12,14) order by id_causa,id_movimiento_de_cuenta desc;
--select * from finanzas.movimientos_de_cuentas a where a.id_causa = 11128757;
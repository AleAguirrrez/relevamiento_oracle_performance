-- Sentencia para buscar presunciones , instancias y convenios X varios criterios 
SELECT 
c.id_convenio,ca.nro_causa,a.nro_serie,b.*  -- ver id_convenio e instancias
  FROM presuntas.cinemometros a,presuntas.instancias_cinemometros b,presuntas.tipos_cinemometros t,presuntas.convenios c,presuntas.presunciones p,actas.actas ac, juzgado.causas ca
 WHERE 
 a.id_cinemometro=b.id_cinemometro and a.ID_TIPO_CINEMOMETRO=t.ID_TIPO_CINEMOMETRO and p.id_instancia_cinemometro=b.id_instancia_cinemometro and ac.id_presuncion=p.id_presuncion  and ac.id_causa=ca.id_causa 
and  b.id_jurisdiccion_aplicacion = c.id_jurisdiccion_aplicacion
and  b.ejido_urbano = c.ejido_urbano
and  b.id_jurisdiccion_constatacion = c.id_jurisdiccion_constatacion
and  b.id_aut_constatacion = c.id_aut_constatacion
and c.cod_formulario='02'
--and p.CINEM_FH_CAPTURA<=to_date('01/01/2021','DD/MM/YYYY')  -- Si se desea buscar por fecha de capura de la presuncion
--and  c.id_convenio in (8373,8374,8375,8376) and ca.id_estado_causa not in (1) -- ver causas/presunciones/actas con determinados convenios
and ca.nro_causa in ('02-079-00002074-9-00')
and rownum <1000;

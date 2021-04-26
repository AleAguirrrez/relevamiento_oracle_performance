/*======================================================================
====================== ver instancias de un cinemometro ===========================
======================================================================*/
-- ver que las instancias no se superpongan si tienen los mismos datos ( id_jurisdiccion_aplicacion,ejido_urbano,id_jurisdiccion_constatacion, id_aut_constatacion )
-- En caso de superposicion ajustar las fechas segun primer y ultima presuncion de cada instancia
alter session set nls_date_format='DD/MM/YYYY HH24:MI:SS';
SELECT a.id_cinemometro,a.NRO_SERIE,t.tipo_cinemometro,a.f_vigencia_desde,a.f_vigencia_hasta,a.id_proveedor_cinemometro,b.id_instancia_cinemometro,b.f_vigencia_desde ins_f_vigencia_desde ,b.f_vigencia_hasta ins_f_vigencia_hasta,ejido_urbano
,b.CALLE_RUTA,b.NRO_KILOMETRO,b.sentido,b.mano,b.velocidad_permitida,b.id_aut_constatacion,b.id_localidad,b.id_jurisdiccion_aplicacion
,(select jurisdiccion from presuntas.jurisdicciones where id_jurisdiccion=b.id_jurisdiccion_aplicacion)  jurisdiccion_apli--select * from presuntas.jurisdicciones where id_jurisdiccion=124
,b.id_jurisdiccion_constatacion,(select jurisdiccion from presuntas.jurisdicciones where id_jurisdiccion=b.id_jurisdiccion_constatacion)  jurisdiccion_const
,(select COUNT (*)  FROM presuntas.presunciones c  WHERE c.id_instancia_cinemometro=b.id_instancia_cinemometro ) as Cantidad_presunciones
,(SELECT to_char(MAX (c.cinem_fh_captura),'DD/MM/YYYY HH24:MI') FROM presuntas.presunciones c WHERE c.id_instancia_cinemometro = b.id_instancia_cinemometro)  as F_ultima_presuncion
,(SELECT to_char(min (c.cinem_fh_captura),'DD/MM/YYYY HH24:MI') FROM presuntas.presunciones c WHERE c.id_instancia_cinemometro = b.id_instancia_cinemometro)  as F_primera_presuncion
  FROM presuntas.cinemometros a,presuntas.instancias_cinemometros b,presuntas.tipos_cinemometros t
 WHERE a.id_cinemometro=b.id_cinemometro and a.ID_TIPO_CINEMOMETRO=t.ID_TIPO_CINEMOMETRO
 --and b.f_vigencia_desde<=to_date('15/11/2019 23:59:59','DD/MM/YYYY HH24:MI:SS') 
--and b.f_vigencia_hasta >to_date('06/10/2020','DD/MM/YYYY') and b.f_vigencia_hasta <=to_date('07/10/2020','DD/MM/YYYY') 
 and upper(a.nro_serie) = 'K4000_0100' order by b.f_vigencia_desde desc,b.f_vigencia_hasta desc;



 -- Para modificar la instancia cinemometro 
 UPDATE presuntas.instancias_cinemometros a
   SET --a.f_vigencia_hasta = TO_DATE ('18/05/2018 11:59:59', 'dd/mm/yyyy hh24:mi:ss')
--  ,
 a.f_vigencia_desde = TO_DATE ('01/01/2021', 'dd/mm/yyyy')
 WHERE a.id_instancia_cinemometro = 1422510;


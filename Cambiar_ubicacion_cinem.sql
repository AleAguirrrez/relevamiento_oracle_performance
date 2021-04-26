/*
*************************************************************************************************************************
************ EL SIGUIENTE PROC ES PARA HACERLO MANUAL EN CASO DE TENER ALGUN FALLO EN EL PLSQL DE MAS ABAJO ****************************
*************************************************************************************************************************
-- verifico donde esta el cinemometro
select * from presuntas.vw_cinemometro where nro_serie=upper('DTV2_027');

SELECT rowid,a.*
  FROM presuntas.cinemometros a
 WHERE upper(a.nro_serie) like  'DTV2_027';
 
--VERIFICAR JURISDICCION DE LA FIRMA
SELECT *
  FROM presuntas.imagenes_firmas_cinem a
 WHERE a.id_imagen_firma_cinem in (SELECT id_imagen_firma_cinem
  FROM presuntas.rel_cinemometros_firmas a
 WHERE a.id_cinemometro = 11981);  --    SELECT *   FROM presuntas.rel_cinemometros_firmas a WHERE a.id_cinemometro = 11981
 
 --OBTENER EL id_imagen_firma_cinem DE LA JURISDICCIÓN NUEVA SI NO ESTA EN LA SENTENCIA ANTERIOR
SELECT *
  FROM presuntas.imagenes_firmas_cinem a
 WHERE a.id_jurisdiccion = 23;
 
--INSERTAR UN NUEVO REGISTRO PARA RELACIONAR CON LA JURISDICCIÓN NUEVA
--NO PRESTA ATENCIÓN A LA FECHA FIN, SOLO AL ID_REL_CINEM_FIRMA MAS ALTO
INSERT INTO presuntas.rel_cinemometros_firmas
     VALUES (presuntas.sq_id_rel_cinem_firma.NEXTVAL,
             11981,   --ID_CINEMOMETRO
             401,  --ID_IMAGEN_FIRMA_CINEM CORRESPONDIENTE A LA JURISDICCION
             TO_DATE('01/3/2021','DD/MM/YYYY'),
             NULL);
*/
-- verifico donde esta el cinemometro
select * from presuntas.vw_cinemometro where nro_serie=upper('DTV2_027');
set serveroutput on;
declare 
   l_id_jurisdiccion integer := 23; -- jurisdiccion a donde se quiere mover el cinemometro
   l_nro_serie varchar2(40) := 'DTV2_027' ; -- Nro de serie del cinemometro a pasar de juris
   l_f_vigencia_desde date := to_date('01/03/2021','DD/MM/YYYY') ; -- fecha que  desde 
   l_id_jurisdiccion_actual integer; -- jurisdiccion a donde se encuentra el cinemometro
   l_id_cinemometro integer; 
   l_x_modelo varchar2(40);
   l_x_marca varchar2(40);
   l_x_tipo varchar2(40);
  l_X_proveedor varchar2(40);
  l_jurisdiccion varchar2(40);
  l_ID_IMAGEN_FIRMA_CINEM integer;
begin
  -- Fuerzo el Upper Case
  l_nro_serie := upper(l_nro_serie);
  -- verifico donde esta el cinemometro + datos
  select id_cinemometro,x_tipo,X_proveedor,X_marca,x_modelo ,X_jurisdiccion,id_jurisdiccion into l_id_cinemometro,l_x_tipo,l_X_proveedor,l_x_marca,l_x_modelo,l_jurisdiccion ,l_id_jurisdiccion_actual  from presuntas.vw_cinemometro where upper(nro_serie)=l_nro_serie;
  dbms_output.put_line(lpad('#',80,'#')||chr(13)||'El cinemometro :  '|| l_nro_serie ||' tipo: '||l_x_tipo||' proveedor: '||l_X_proveedor||' marca: '||l_X_marca||' modelo: '||l_x_modelo||' ubicacion actual: '||l_jurisdiccion||chr(13)||lpad('#',80,'#') );
  
  IF ( l_id_jurisdiccion_actual = l_id_jurisdiccion )
  THEN
    dbms_output.put_line('El cinemometro '||l_nro_serie ||' ya se encuentra en '||l_jurisdiccion);
    raise_application_error(-20001,'El cinemometro '||l_nro_serie ||' ya se encuentra en '||l_jurisdiccion);
  ELSE 
     dbms_output.put_line('El cinemometro '||l_nro_serie ||' NO se encuentra en '||l_jurisdiccion);
      --OBTENER EL id_imagen_firma_cinem DE LA JURISDICCIÓN NUEVA 
      SELECT  ID_IMAGEN_FIRMA_CINEM into  l_ID_IMAGEN_FIRMA_CINEM  FROM presuntas.imagenes_firmas_cinem a WHERE a.id_jurisdiccion = l_id_jurisdiccion;
      -- Con los datos obtenidos muevo el cinemometro
      --NO PRESTA ATENCIÓN A LA FECHA FIN, SOLO AL ID_REL_CINEM_FIRMA MAS ALTO
      INSERT INTO presuntas.rel_cinemometros_firmas VALUES (presuntas.sq_id_rel_cinem_firma.NEXTVAL, l_id_cinemometro, l_ID_IMAGEN_FIRMA_CINEM,l_f_vigencia_desde,NULL);
     
  END IF;
  -- obtengo el id_cinemometro
--  SELECT a.id_cinemometro into l_id_cinemometro   FROM presuntas.cinemometros a WHERE upper(a.nro_serie) = l_nro_serie;
END;
/  
   
--valIDAR Y COMITEAR
select * from presuntas.vw_cinemometro where nro_serie=upper('DTV2_027');-- PONER EL NRO_SERIE CORRESPONDIENTE
commit;
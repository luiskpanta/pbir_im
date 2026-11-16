CREATE OR ALTER VIEW [dbo].[v_indice_ocupacion_meta]
AS

SELECT
	id_usuario
	,desde_fh as fecha
	,month(desde_fh) AS mes
	,year(desde_fh) AS anio
	,(1370.0/12.0) AS total_horas
	,FORMAT(ort_programacion.desde_fh, 'yyyyMM') + '_' + cast(id_usuario as varchar(10)) AS llave_mes
FROM ort_programacion
WHERE id_tipoProgramacion = 1
	AND ort_programacion.active = 1
GROUP BY id_usuario
	, month(desde_fh), year(desde_fh),FORMAT(ort_programacion.desde_fh, 'yyyyMM')
	,desde_fh

GO
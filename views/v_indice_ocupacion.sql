CREATE OR ALTER VIEW [dbo].[v_indice_ocupacion]
AS
-- Subconsulta de Cumplimiento como CTE reescrita como subconsulta derivada
SELECT     
	CONVERT(varchar, OTT.fecha_fh, 103) AS fecha_DOC,
	FORMAT(ort_programacion.desde_fh, 'yyyyMM') + '_' + cast(ort_programacion.id_usuario as varchar(10)) AS llave_mes,
	OTT.prefijo + ' ' + CONVERT(varchar, OTT.documento_numero) AS num_OTT,
	CONVERT(varchar, ort_programacion.desde_fh, 103) AS fecha_OT,
	CONVERT(varchar, ort_programacion.desde_fh, 103) AS fecha_ort, -- se deja por estructura del PBI
	seg_usuario.nombre AS Tecnico,
	FORMAT(ort_programacion.desde_fh, 'HH:mm') AS hora_inicio,
	FORMAT(DATEADD(MINUTE, ort_programacion.duracion * 60, ort_programacion.desde_fh), 'HH:mm') AS hora_fin,
	ort_programacion.duracion,
	ort_programacion.id_usuario,
	cat_catalogo.catalogo AS Actividad,
	[cat_catalogo.actividad].esProductiva AS productiva,
	ort_reporteTecnico.trabajos AS Trabajos_realizados,
	null AS cumple_meta,
	CASE WHEN zona_sucursal.id = ZONA_USUARIO.id THEN 0 ELSE 1 END AS Desplazamiento,
	gen_tipoServicio.tipoServicio_codigo tiposervicio,
	gen_tipoServicio.tipoServicio tipoServicioDetallado,
	null AS meta,
	ter_tercero.tercero AS cliente,
	'' + gen_tipoServicio.tipoServicio + char(10) +
	'' + cat_catalogo.catalogo + ' ('+format(duracion , '#.##') + ' hrs)'+ char(10) +
	'' + OTT.prefijo + ' ' + CONVERT(varchar, OTT.documento_numero)+ ' ('+ CONVERT(varchar, ort_programacion.desde_fh, 103) +')'+  char(10) +  
	'' + isnull(modelo.[catalogo.equipo],' ')+ char(10)
		AS descripcion,
	zona_sucursal.zona as zona
	,cat_marca.marca as marca
	,seg_cargo.cargo_codigo as cargo
	,est.estadotipodocumento as estadoOT
	,case when est.estadotipodocumento_codigo in ('CER','CAN') then 0
	else 1 end as abierta
	,OTT.id AS id
FROM doc_documento OTT
INNER JOIN [doc_documento.ot] ON OTT.id = [doc_documento.ot].id AND id_subtipoDocumento = 2
INNER JOIN gen_tipoServicio ON gen_tipoServicio.id = [doc_documento.ot].id_tipoServicio
INNER JOIN ter_sucursal ON ter_sucursal.id = [doc_documento.ot].id_sucursal
INNER JOIN ter_tercero ON ter_tercero.id = OTT.id_tercero_cliente
INNER JOIN ort_programacion ON ort_programacion.[id_documento.ot] = OTT.id
INNER JOIN seg_usuario ON seg_usuario.id = ort_programacion.id_usuario
INNER JOIN seg_cargo ON seg_cargo.id = seg_usuario.id_cargo
INNER JOIN equ_equipo ON equ_equipo.id = [doc_documento.ot].id_equipo
INNER JOIN [cat_catalogo.equipo] modelo ON modelo.id = equ_equipo.[id_catalogo.equipo]
inner join cat_marca on cat_marca.id=modelo.id_marca 
inner join doc_estadotipodocumento est on est.id=OTT.id_estadotipodocumento
LEFT JOIN cat_catalogo ON cat_catalogo.id = ort_programacion.[id_catalogo.actividad]
LEFT JOIN [cat_catalogo.actividad] ON [cat_catalogo.actividad].id = cat_catalogo.id
LEFT JOIN ort_reporteTecnico ON ort_reporteTecnico.id = ort_programacion.id_reporteTecnico
outer apply (select ciudad.id, ciudad.zona as ciudad, zona.zona
	from gen_zona ciudad
		inner join gen_zona dpto on dpto.id=ciudad.id_zona
		inner join gen_zona zona on zona.id=dpto.id_zona
	where ciudad.id=ter_sucursal.id_zona) zona_sucursal
OUTER APPLY (SELECT id FROM gen_zona WHERE id = seg_usuario.id_zona) ZONA_USUARIO
WHERE id_tipoProgramacion = 6
	and ort_programacion.active=1
GO



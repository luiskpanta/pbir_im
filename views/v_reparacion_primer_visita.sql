CREATE OR ALTER VIEW [dbo].[v_reparacion_primer_visita]
AS
SELECT     
	case when SOL.id is not null then CONVERT(varchar, SOL.doc_documento_solicitud_fecha_fh, 103) else CONVERT(varchar, OTT.fecha_fh, 103) end AS fecha_OT,
	case when SOL.id is not null then cast(SOL.doc_documento_solicitud_documento_numero as varchar) else OTT.prefijo + ' ' + CONVERT(varchar, OTT.documento_numero) end AS num_SOL,
	OTT.prefijo + ' ' + CONVERT(varchar, OTT.documento_numero) AS num_OTT,
	ING.tercero AS Tecnico,
	[doc_documento.ot].trabajos AS Trabajos_realizados,
	cum.cumple_meta AS cumple_meta,
	gen_tipoServicio.tipoServicio_codigo tiposervicio,
	gen_tipoServicio.tipoServicio tipoServicioDetallado,
	CLI.tercero as cliente,
	ter_sucursal.sucursal as sucursal,
	zona_sucursal.zona,
	zona_sucursal.ciudad,
	marca,
	OTT.id AS id
FROM doc_documento OTT
	INNER JOIN [doc_documento.ot] ON OTT.id = [doc_documento.ot].id AND id_subtipoDocumento = 2
	inner join equ_equipo eq on eq.id=[doc_documento.ot].id_equipo
	inner join [cat_catalogo.equipo] mod on mod.id=eq.[id_catalogo.equipo]
	inner join cat_marca on mod.id_marca = cat_marca.id
	INNER JOIN gen_tipoServicio ON gen_tipoServicio.id = [doc_documento.ot].id_tipoServicio
	INNER JOIN ter_sucursal ON ter_sucursal.id = [doc_documento.ot].id_sucursal
	INNER JOIN ter_tercero ING ON ING.id = OTT.id_tercero_proveedor
	INNER JOIN ter_tercero CLI ON CLI.id = OTT.id_tercero_cliente
	OUTER APPLY (
		SELECT ort_programacion.[id_documento.ot] , CASE WHEN COUNT(DISTINCT ort_programacion.id_reporteTecnico)>1 then 0 else 1 end AS cumple_meta
		FROM ort_programacion
		WHERE ort_programacion.[id_documento.ot] = OTT.id
			AND id_tipoProgramacion = 6
			AND ort_programacion.active = 1
		GROUP BY ort_programacion.[id_documento.ot] 
	) CUM
	outer apply (
            select ciudad.id, ciudad.zona as ciudad, zona.zona
                from gen_zona ciudad
                inner join gen_zona dpto on dpto.id=ciudad.id_zona
                inner join gen_zona zona on zona.id=dpto.id_zona
            where ciudad.id=ter_sucursal.id_zona) zona_sucursal
	LEFT OUTER JOIN view_doc_documento_solicitud SOL ON SOL.id = OTT.id_documento
WHERE tiposervicio_codigo like '%CORRECTIVO'
	AND CUM.cumple_meta IS NOT NULL
GO

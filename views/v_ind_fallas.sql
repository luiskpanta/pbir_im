CREATE OR ALTER   view [dbo].[v_ind_fallas]
as

select 
	OT.id as idOT
	,case when OT.doc_documento_ot_id_documento=0 then OT.doc_documento_ot_documento_numero else OT.doc_documento_ot_doc_documento_padre_documento_numero  end as numDoc
	,OT.doc_documento_ot_id_documento as idPadre
	,OT.doc_documento_ot_doc_documento_padre_documento_numero as numSOL
	,OT.doc_documento_ot_documento_numero as numOTT
	,equ_equipo_equipo as equipo
	,equ_equipo_equipo_serial as serial
	,OT.doc_documento_ot_ter_tercero_cliente_tercero as cliente
	,motivoservicio
	,case when doc_documento_ot_id_documento>0 then doc_documento_ot_doc_documento_padre_fecha_fh else doc_documento_ot_fecha_fh end as Fechafalla	
	,doc_documento_ot_fecha_fh as FechaParada	
	,REP.fecha as FechaReparacion
	,case when doc_documento_ot_fechaCierre_ff>doc_documento_ot_fecha_fh then 
		datediff(MINUTE
		,case when doc_documento_ot_id_documento>0 then doc_documento_ot_doc_documento_padre_fecha_fh else doc_documento_ot_fecha_fh end
		,REP.fecha)/60.0 else null end as HorasParada
	,case when doc_documento_ot_fechaCierre_ff>doc_documento_ot_fecha_fh then 
		datediff(HOUR
		,case when doc_documento_ot_id_documento>0 then doc_documento_ot_doc_documento_padre_fecha_fh else doc_documento_ot_fecha_fh end
		,REP.fecha)/24.0 else null end as DiasFueraServicio
	,MODELO.cat_marca_marca as marca
	,MODELO.cat_catalogo_equipo_gen_familia_familia as subfamilia
	,FAM.familia as familia
	,REP.horasIngeniero as horasIngeniero
	,case when RQ.numRqs>0 then 1 else 0 end as tieneRequisicion
	,case when doc_documento_ot_fecha_fh < dateadd(day,90,OT.equ_equipo_fechaPuestaMarcha_fh) then 1 else 0 end as fallaPostInstalacion 
from view_doc_documento_ot OT
	inner join view_cat_catalogo_equipo MODELO on OT.[equ_equipo_id_catalogo.equipo]=MODELO.id
	inner join view_gen_familia FAM on MODELO.cat_catalogo_equipo_gen_familia_id_familia=FAM.id
	cross apply(
		select max( hasta_fh) as fecha
			,sum(case when [id_catalogo.actividad]=477 then null else duracion end) as horasIngeniero
		from view_ort_programacion
		where [id_documento.ot]=OT.id
			and active=1
			and id_reportetecnico > 0
		group by [id_documento.ot] 
	) REP
	outer apply(
		select count(id) as numRqs
		from view_doc_documento_requisicion rq
		where rq.doc_documento_requisicion_id_documento=OT.id
	) RQ
where OT.gen_tiposervicio_tiposervicio_codigo ='02 CORRECTIVO'
	and OT.equ_equipo_id_estadoEquipo != 12 --PARTNER
GO



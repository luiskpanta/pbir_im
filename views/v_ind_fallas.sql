create or alter view v_ind_fallas
as

select equ_equipo_equipo as equipo
	,equ_equipo_equipo_serial as serial
	,motivoservicio
	,doc_documento_ot_fecha_fh as Fechafalla	
	,doc_documento_ot_fechaCierre_ff as FechaParada	
	,OT.fechamodificacion as FechaReparacion
	,datediff(day,OT.fechamodificacion,doc_documento_ot_fechaCierre_ff) DiasParada
	,MODELO.cat_marca_marca as marca
from view_doc_documento_ot OT
	inner join view_cat_catalogo_equipo MODELO on OT.[equ_equipo_id_catalogo.equipo]=MODELO.id
CREATE OR ALTER VIEW v_efds
AS

select sol.id
    ,sol.doc_documento_solicitud_fecha_fh as fecha
    ,sol.doc_documento_solicitud_prefijo + '-'+ cast(sol.doc_documento_solicitud_documento_numero as varchar(10)) as solicitud
    ,sol.equ_equipo_equipo_serial serial
    ,sol.doc_documento_solicitud_ter_tercero_cliente_tercero cliente
    ,modelo.cat_marca_marca marca
    ,modelo.[catalogo.equipo] modelo
    ,datediff (day,doc_documento_solicitud_fecha_fh,getdate()) as dias_fds
from view_doc_documento_solicitud sol
    inner join view_cat_catalogo_equipo modelo on modelo.id=sol.[equ_equipo_id_catalogo.equipo]
where doc_documento_solicitud_doc_estadotipodocumento_estadotipodocumento_codigo not in ('CER','CAN')
    and doc_documento_solicitud_doc_prioridaddocumento_prioridaddocumento_codigo = 'EMER' --fuera de servicio
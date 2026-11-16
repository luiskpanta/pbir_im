CREATE OR ALTER VIEW [dbo].[v_ind_cumplimientoPMs]
AS

    select cnt_visitaFija.id
        , cnt_visitaFija.fecha_ff
        , equ_equipo.equipo
        , equ_equipo.equipo_serial
        , cnt_contrato.contrato
        , cnt_contrato.id as id_contrato
        , cnt_contrato.numero
        , cnt_contrato.fechaInicio_ff
        , cnt_contrato.fechaFin_ff
        , cnt_contrato.totalContrato
        , cnt_periodocontrato.periodocontrato
        , doc_documento.documento_numero
        , doc_documento.prefijo
        , ter_tercero.tercero
        , ter_tercero.tercero_nit
        , ter_tercero.direccion as direccion_tercero
        , ter_sucursal.sucursal
        , ter_sucursal.direccion as direccion_sucursal
        , cnt_contrato.active
        , zona_sucursal.zona
        , zona_sucursal.ciudad
        , cat_marca.marca
        , doc_documento.id as idOT
        , [cat_catalogo.tempario].[catalogo.tempario] as tempario
        , doc_estadoTipoDocumento.estadoTipoDocumento as estado
        , case when doc_estadoTipoDocumento.estadoTipoDocumento_codigo in ('CER') and cnt_visitaFija.[id_documento.ot]>0 then 1
            else 0 end as cumplida
        ,ULT_REP.hasta_fh as fecha_reporte
        ,asig.tercero as tecnico
    from cnt_visitaFija inner join
        cnt_contratoEquipo on cnt_contratoEquipo.id=cnt_visitaFija.id_contratoEquipo inner join
        equ_equipo on equ_equipo.id=cnt_contratoEquipo.id_equipo inner join
        ter_tercero asig on asig.id=equ_equipo.id_tercero_servicio inner join
        [cat_catalogo.equipo] on [cat_catalogo.equipo].id=equ_equipo.[id_catalogo.equipo] inner join
        cat_marca on cat_marca.id=[cat_catalogo.equipo].id_marca inner join
        cnt_contrato on cnt_contrato.id=cnt_contratoEquipo.id_contrato inner join
        doc_documento on doc_documento.id=cnt_visitaFija.[id_documento.ot] inner join
        [doc_documento.ot] on [doc_documento.ot].id=doc_documento.id inner join
        doc_estadoTipoDocumento on doc_estadoTipoDocumento.id=doc_documento.id_estadoTipoDocumento inner join
        ter_tercero on ter_tercero.id=cnt_contrato.id_tercero inner join
        ter_sucursal on equ_equipo.id_sucursal=ter_sucursal.id inner join
        [cat_catalogo.tempario] on [cat_catalogo.tempario].id=cnt_visitaFija.[id_catalogo.tempario]inner join
        cnt_periodocontrato on cnt_contrato.id_periodocontrato=cnt_periodocontrato.id
        outer apply (
            select ciudad.id, ciudad.zona as ciudad, zona.zona
                from gen_zona ciudad
                inner join gen_zona dpto on dpto.id=ciudad.id_zona
                inner join gen_zona zona on zona.id=dpto.id_zona
            where ciudad.id=ter_sucursal.id_zona) zona_sucursal
        outer apply (
				select top 1 id_usuario, seg_usuario_nombre nombre, desde_fh, hasta_fh
				from view_ort_programacion PROG
				where PROG.[id_documento.ot]=[doc_documento.ot].id
					and id_tipoProgramacion in (6,3)
					and PROG.active=1
				order by id_tipoProgramacion desc,desde_fh desc
			) as ULT_REP
    WHERE   cnt_visitaFija.active=1



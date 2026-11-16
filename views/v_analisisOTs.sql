CREATE OR ALTER VIEW [v_analisisOTs]
AS 

    select 
		cliente.tercero as cliente
		-- ,cliente.id as cliente_id
		-- ,cliente.tercero_nit as Nit
		-- ,cliente.direccion as direccion
		-- ,cliente.telefono as telefono
		-- ,cliente.email as email
		-- ,contacto.contacto as contacto
		-- ,contacto.email as Contac_Email
		-- ,[doc_documento.ot].id_zona
		-- ,[doc_documento.ot].id_equipo
		,(convert(varchar(max),doc_documento.prefijo)+'-'+ convert(varchar(max),doc_documento.documento_numero))as num_OTT
		,case when padre.id >0 then padre.prefijo + ' ' + cast(padre.documento_numero as varchar) else doc_documento.prefijo + ' ' + CONVERT(varchar, doc_documento.documento_numero) end AS num_SOL
		-- ,doc_documento.documento_codigo as codigo
		,gen_tipoServicio.tipoServicio as tipoServicioDetallado
		,gen_tipoServicio.tipoServicio_codigo as tipoServicio
		-- ,Proveedor.tercero as Proveedor
		,doc_estadoTipoDocumento.estadoTipoDocumento as estadoOT
		,CONVERT(varchar, case when padre.id > 0 then [padre].fechaCreacion else [doc_documento.ot].fechaCreacion end, 103) as fecha_DOC
		,doc_documento.fecha_fh as fecha_fh
		,CONVERT(varchar, doc_documento.fecha_fh, 103) as fecha_OT
		,CONVERT(varchar, doc_documento.fecha_fh, 103) + ' ' + CONVERT(varchar, PRI_REP.desde_fh, 108)  as fecha_ort
		-- ,CONVERT(varchar, doc_documento.fechaCierre_ff, 103) as fecha_atencion
		,CONVERT(varchar, PRI_REP.desde_fh, 103) + ' ' + CONVERT(varchar, PRI_REP.desde_fh, 108)  as fecha_atencion
		,case when padre.id > 0 then CONVERT(varchar, padre.fechaCierre_ff, 103) else CONVERT(varchar, doc_documento.fechaCierre_ff, 103)  end as fecha_solucion
		-- ,[doc_documento.ot].motivoServicio as [Motivo Servicio]
		-- ,[doc_documento.ot].diagnosticoInicial as Diagnostico
		,doc_documento.id as id
		-- ,cnt_contrato.contrato as contrato
		-- ,cnt_contrato.fechaInicio_ff as fechaini
		-- ,cnt_contrato.fechaFin_ff as fechafin
		-- ,[doc_documento.ot].id_sucursal as sucursal
		-- ,doc_documento.fecha_fh
		-- ,doc_prioridadDocumento.prioridadDocumento  
		,case when doc_estadoTipoDocumento.estadotipodocumento_codigo in ('CER','CAN') then 0 else 1 end as abierta
        ,zona_sucursal.zona as zona
	    ,cat_marca.marca as marca
	    ,null as cargo
		,case when ULT_REP.nombre is null then Proveedor.tercero_nombreCorto else ULT_REP.nombre end as Tecnico
		, 0 AS hora_inicio
		, 0 AS hora_fin
		, 0 as duracion
		, ULT_REP.id_usuario
		, null AS Actividad
		, null AS productiva
		, '' AS Trabajos_realizados
		, null AS cumple_meta
		, null AS Desplazamiento
		, null AS meta
		, null AS descripcion
		, COUNT_REP.cntReportes as numReportes
		from doc_documento
            inner join [doc_documento.ot] on doc_documento.id=[doc_documento.ot].id and [doc_documento.ot].active =1
            inner join doc_prioridadDocumento on doc_prioridadDocumento.id=doc_documento.id_prioridadDocumento
            inner join doc_estadoTipoDocumento on doc_documento.id_estadoTipoDocumento=doc_estadoTipoDocumento.id --and doc_estadoTipoDocumento.active=1
            inner join gen_tipoServicio on [doc_documento.ot].id_tipoServicio=gen_tipoServicio.id --and gen_tipoServicio.active=1
            outer apply (
                select ciudad.id, ciudad.zona as ciudad, zona.zona
                from gen_zona ciudad
                    inner join gen_zona dpto on dpto.id=ciudad.id_zona
                    inner join gen_zona zona on zona.id=dpto.id_zona
                where ciudad.id=[doc_documento.ot].id_zona) zona_sucursal
			outer apply (
				select top 1 id_usuario, seg_usuario_nombre nombre, desde_fh, hasta_fh
				from view_ort_programacion PROG
				where PROG.[id_documento.ot]=[doc_documento.ot].id
					and id_tipoProgramacion in (6,3)
					and PROG.active=1
				order by id_tipoProgramacion desc,desde_fh desc
			) as ULT_REP
			outer apply (
				select top 1 id_usuario, seg_usuario_nombre nombre, desde_fh, hasta_fh
				from view_ort_programacion PROG
				where PROG.[id_documento.ot]=[doc_documento.ot].id
					and id_tipoProgramacion = 6
					and PROG.active=1
				order by id_tipoProgramacion desc,desde_fh
			) as PRI_REP
			outer apply (
				select count(distinct id_reporteTecnico)as cntReportes
				from view_ort_programacion PROG
				where PROG.[id_documento.ot]=[doc_documento.ot].id
					and id_tipoProgramacion in (6,3)
					and PROG.active=1
			) as COUNT_REP
            INNER JOIN equ_equipo ON equ_equipo.id = [doc_documento.ot].id_equipo
            INNER JOIN [cat_catalogo.equipo] modelo ON modelo.id = equ_equipo.[id_catalogo.equipo]
            inner join cat_marca on cat_marca.id=modelo.id_marca 
            inner join ter_tercero as Proveedor on doc_documento.id_tercero_proveedor=Proveedor.id
            inner join ter_tercero as cliente on doc_documento.id_tercero_cliente=cliente.id --and cliente.active=1
			left outer join doc_documento padre on padre.id=doc_documento.id_documento
            -- left join ter_contacto as contacto on cliente.id=contacto.id_tercero and contacto.active=1
            -- left join cnt_contrato on [doc_documento.ot].id_contrato=cnt_contrato.id and cnt_contrato.active=1
		where 
            doc_documento.active=1
            and doc_documento.id>0
	
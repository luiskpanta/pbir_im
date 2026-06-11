CREATE OR ALTER   VIEW [dbo].[v_ind_equipos]
AS

    select equ_equipo.id
        , equ_equipo.equipo
        , equ_equipo.equipo_serial
        , ter_tercero.tercero
        , ter_tercero.tercero_nit
        , ter_sucursal.sucursal
        , zona_sucursal.zona
        , zona_sucursal.ciudad
        , cat_marca.marca
        , [cat_catalogo.equipo].[catalogo.equipo] as modelo
        , gen_familia.familia
        , left(gen_familia.familia,2) CodigoFamilia
        , equ_estadoEquipo.estadoEquipo
        , equ_estadoEquipo.estadoEquipo_codigo grupo
        , case when (equ_equipo.fechaPuestaMarcha_fh is null or equ_equipo.fechaPuestaMarcha_fh=0) 
            then equ_equipo.fechaCreacion 
            else equ_equipo.fechaPuestaMarcha_fh end as fechaInicio
        , inactivacion.fecha_ff as fechaFin
    from equ_equipo inner join
        [cat_catalogo.equipo] on [cat_catalogo.equipo].id=equ_equipo.[id_catalogo.equipo] inner join
        cat_marca on cat_marca.id=[cat_catalogo.equipo].id_marca inner join
        [cat_catalogo] on [cat_catalogo.equipo].id=cat_catalogo.id inner join
        gen_familia on gen_familia.id=[cat_catalogo].id_familia inner join
        ter_tercero on ter_tercero.id=equ_equipo.id_tercero inner join
        ter_sucursal on equ_equipo.id_sucursal=ter_sucursal.id inner join
        equ_estadoEquipo on equ_estadoequipo.id=equ_equipo.id_estadoEquipo
        outer apply (
            select ciudad.id, ciudad.zona as ciudad, zona.zona
                from gen_zona ciudad
                inner join gen_zona dpto on dpto.id=ciudad.id_zona
                inner join gen_zona zona on zona.id=dpto.id_zona
            where ciudad.id=ter_sucursal.id_zona) zona_sucursal
        outer apply (
            select top 1 fecha_ff
            from equ_trazabilidad
            where equ_trazabilidad.id_equipo=equ_equipo.id
                and equ_trazabilidad.id_estadoequipo in(2, 13) --inactivo
                and equ_trazabilidad.active=1
            order by fecha_ff desc
        ) inactivacion
    WHERE   equ_equipo.active=1


GO



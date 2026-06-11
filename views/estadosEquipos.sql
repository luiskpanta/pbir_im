IF EXISTS (SELECT 1 FROM sys.types WHERE name = 'TipoEstados' AND is_user_defined = 1)
BEGIN
	DROP FUNCTION estadoEquipo
	DROP TYPE dbo.TipoEstados
END
IF NOT EXISTS (SELECT 1 FROM sys.types WHERE name = 'TipoEstados' AND is_user_defined = 1)
    CREATE TYPE dbo.TipoEstados AS TABLE (int_id int, id_equipo int, fecha smalldatetime, estado varchar(20));
GO

CREATE OR ALTER FUNCTION dbo.estadoEquipo (@DATE DATETIME, @STATES dbo.TipoEstados READONLY, @id_equipo int)
	RETURNS VARCHAR(1)
AS
BEGIN
    DECLARE @estado VARCHAR(20)='Operativo';

	SELECT @estado=estado
	FROM @STATES
	WHERE id_equipo=@id_equipo
		AND fecha<DATEADD(MONTH,1,@DATE)
    
    RETURN @estado;
END
GO
--select * from v_ind_equipos
-- asegurar que fecha_ff tenga el valor correcto
update equ_equipoAtributo
set fecha_ff=T0.fechaReporte
from equ_equipoAtributo
	inner join (
		select EA.id,fecha_ff,id_equipo,EA.id_reporteTecnico,PRG.[doc_documento.ot_id_equipo]
			,min(desde_fh) as fechaReporte
		from view_equ_equipoAtributo EA
		inner join view_ort_programacion PRG on PRG.id_reporteTecnico=EA.id_reporteTecnico
		where id_atributo=50
			and EA.id_reporteTecnico > 0
			and EA.id_equipo > 0
			and EA.fecha_ff=0
		group by EA.id,fecha_ff,id_equipo,EA.id_reporteTecnico,PRG.[doc_documento.ot_id_equipo]
	)T0 on T0.id=equ_equipoAtributo.id
GO

CREATE OR ALTER PROCEDURE dbo.sp_estadoEquipos
AS
BEGIN
    SET NOCOUNT ON

    -- 1. Generar fechas
    DECLARE @Fechas AS TABLE (Fecha SMALLDATETIME)
    DECLARE @FechaActual SMALLDATETIME = DATEFROMPARTS(2020, 1, 1)

    WHILE @FechaActual <= GETDATE()
    BEGIN
        INSERT INTO @Fechas VALUES (@FechaActual)
        SET @FechaActual = DATEADD(MONTH, 1, @FechaActual)
    END

    -- 2. Cargar estados una sola vez
    DECLARE @estados AS dbo.TipoEstados
    INSERT INTO @estados
        SELECT 
            ROW_NUMBER() OVER(ORDER BY id_equipo, fecha_ff) AS new_id,
            id_equipo,
            fecha_ff,
            equ_opcionAtributo_opcionAtributo
        FROM view_equ_equipoAtributo EA
        WHERE id_atributo = 50
            AND id_equipo > 0
            AND fecha_ff > 0
            AND id_opcionAtributo > 0

    -- 3. Resultado final
    SELECT 
        EQ.id,
        F.Fecha,
        dbo.estadoEquipo(F.Fecha, @estados, EQ.id) AS Estado
    FROM @Fechas F
    CROSS JOIN equ_equipo EQ
    WHERE EQ.active = 1
        AND F.Fecha >= EQ.fechaPuestaMarcha_fh
    ORDER BY EQ.id, F.Fecha

END
GO

GRANT EXECUTE ON dbo.sp_estadoEquipos TO conImpulmedicos;




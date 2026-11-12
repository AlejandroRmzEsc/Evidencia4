/* =====================================================================
   DBTORNEO - Evidencia 4
   Reglas principales: PDF de la Evidencia 4 (login sensible a mayúsculas,
   usuarios ACTIVO, Jugador/Entrenador con datos únicos, bajas lógicas,
   auditoría, sin Ids en pantalla, roles ADMINISTRADOR / OBSERVADOR).
   Reglas de negocio (guía): marcadas como [REGLA n] en el script.
   ===================================================================== */

USE MASTER
GO

-- [CAMBIO] Si la base ya existe se borra para poder volver a ejecutar el script completo
IF DB_ID('DBTORNEO') IS NOT NULL
BEGIN
	ALTER DATABASE DBTORNEO SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE DBTORNEO
END
GO

CREATE DATABASE DBTORNEO
GO

USE DBTORNEO
GO

-- [CAMBIO] Necesario para el índice filtrado de la REGLA 3 (SSMS ya lo trae activo, sqlcmd no)
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO


-- CREACION DE TABLAS

--Creacion  de la tabla Estatus
IF OBJECT_ID ('ESTATUS' , 'U') IS NOT NULL
BEGIN
	DROP TABLE ESTATUS
END
GO
CREATE TABLE ESTATUS
(
	IdEstatus		INT IDENTITY(1,1)	NOT NULL,
	Descripcion		NVARCHAR(50)		NOT NULL
	CONSTRAINT PK_IdEstatus PRIMARY KEY (IdEstatus)
)
GO

-- Crear tabla ROL
IF OBJECT_ID ('ROL', 'U') IS NOT NULL
BEGIN
	DROP TABLE ROL
END
GO
CREATE TABLE ROL
(
	IdRol				INT IDENTITY (1,1)	NOT NULL,
	Descripcion			NVARCHAR(30)		NOT NULL,
	CONSTRAINT PK_IdRol PRIMARY KEY (IdRol)
);

--Crear tabla Categoria
IF OBJECT_ID ('CATEGORIA', 'U') IS NOT NULL
BEGIN
	DROP TABLE CATEGORIA
END
GO
CREATE TABLE CATEGORIA
(
	IdCategoria			INT IDENTITY (1,1)	NOT NULL,
	Descripcion			NVARCHAR(30)		NOT NULL,
	CONSTRAINT PK_IdCategoria PRIMARY KEY (IdCategoria)
);

-- Crear tabla Tipo_Equipo
IF OBJECT_ID ('TIPO_EQUIPO', 'U') IS NOT NULL
BEGIN
	DROP TABLE TIPO_EQUIPO
END
GO
CREATE TABLE TIPO_EQUIPO
(
	IdTipoEquipo		INT IDENTITY (1,1)	NOT NULL,
	Descripcion			NVARCHAR(30)		NOT NULL,
	CONSTRAINT PK_IdTipoEquipo PRIMARY KEY (IdTipoEquipo)
);

--Crear tabla Estadio
IF OBJECT_ID ('ESTADIO', 'U') IS NOT NULL
BEGIN
	DROP TABLE ESTADIO
END
GO
CREATE TABLE ESTADIO
(
	IdEstadio			INT IDENTITY (1,1)	NOT NULL,
	Descripcion			NVARCHAR(30)		NOT NULL,
	CONSTRAINT PK_IdEstadio PRIMARY KEY (IdEstadio)
);

-- Crear tabla Usuario
IF OBJECT_ID ('USUARIO', 'U') IS NOT NULL
BEGIN
	DROP TABLE USUARIO
END
GO
CREATE TABLE USUARIO
(
	IdUsuario			INT IDENTITY (1,1)	NOT NULL,
	IdRol				INT					NOT NULL,
	IdEstatus			INT					NOT NULL,
	Cuenta				NVARCHAR(30)		NOT NULL,
	Contrasenia			NVARCHAR(30)		NOT NULL,
	FechaRegistro		DATETIME				NULL,
	UsuarioRegistro		INT						NULL,
	FechaModificacion	DATETIME				NULL,
	UsuarioModificacion	INT						NULL,
	FechaBaja			DATETIME				NULL,
	UsuarioBaja			INT						NULL,
	CONSTRAINT	PK_IdUsuario		 PRIMARY KEY (IdUsuario),
	CONSTRAINT	FK_IdEstatus_Usuario FOREIGN KEY (IdEstatus)	REFERENCES ESTATUS	(IdEstatus),
	CONSTRAINT	FK_IdRol_Usuario	 FOREIGN KEY (IdRol)		REFERENCES ROL		(IdRol)
);

-- Crear tabla Equipo
IF OBJECT_ID ('EQUIPO', 'U') IS NOT NULL
BEGIN
	DROP TABLE	EQUIPO
END
GO
CREATE TABLE EQUIPO
(
	IdEquipo			INT IDENTITY (1,1)	NOT NULL,
	IdEstatus			INT					NOT NULL,
	IdCategoria			INT					NOT NULL,
	Nombre				NVARCHAR (50)		NOT NULL,
	FechaRegistro		DATETIME			NOT NULL,
	UsuarioRegistro		INT					NOT NULL,
	FechaModificacion	DATETIME				NULL,
	UsuarioModificacion	INT						NULL,
	FechaBaja			DATETIME				NULL,
	UsuarioBaja			INT						NULL,
	CONSTRAINT PK_IdEquipo						PRIMARY KEY	(IdEquipo),
	CONSTRAINT FK_IdEstatus_Equipo				FOREIGN KEY (IdEstatus)				REFERENCES ESTATUS	 (IdEstatus),
	CONSTRAINT FK_IdCategoria_Equipo			FOREIGN KEY (IdCategoria)			REFERENCES CATEGORIA (IdCategoria),
	CONSTRAINT FK_UsuarioRegistro_Equipo		FOREIGN KEY (UsuarioRegistro)		REFERENCES USUARIO	 (IdUsuario),
	CONSTRAINT FK_UsuarioModificacion_Equipo	FOREIGN KEY (UsuarioModificacion)	REFERENCES USUARIO	 (IdUsuario),
	CONSTRAINT FK_UsuarioBaja_Equipo			FOREIGN KEY (UsuarioBaja)			REFERENCES USUARIO	 (IdUsuario)
);

-- Crear tabla Partido
IF OBJECT_ID ('PARTIDO', 'U') IS NOT NULL
BEGIN
	DROP TABLE	PARTIDO
END
GO
CREATE TABLE PARTIDO
(
	IdPartido			INT IDENTITY (1,1)	NOT NULL,
	IdEstatus			INT					NOT NULL,
	IdEstadio			INT					NOT NULL,
	Nombre				NVARCHAR (50)		NOT NULL,
	FechaInicio			DATETIME			NOT NULL,
	FechaFin			DATETIME				NULL,
	Resultado			NVARCHAR (30)			NULL,
	FechaRegistro		DATETIME			NOT NULL,
	UsuarioRegistro		INT					NOT NULL,
	FechaModificacion	DATETIME				NULL,
	UsuarioModificacion	INT						NULL,
	FechaBaja			DATETIME				NULL,
	UsuarioBaja			INT						NULL,
	CONSTRAINT PK_IdPartido						PRIMARY KEY	(IdPartido),
	CONSTRAINT FK_IdEstatus_Partido				FOREIGN KEY (IdEstatus)				REFERENCES ESTATUS	(IdEstatus),
	CONSTRAINT FK_IdEstadio_Partido				FOREIGN KEY (IdEstadio)				REFERENCES ESTADIO	(IdEstadio),
	CONSTRAINT FK_UsuarioRegistro_Partido		FOREIGN KEY (UsuarioRegistro)		REFERENCES USUARIO	(IdUsuario),
	CONSTRAINT FK_UsuarioModificacion_Partido	FOREIGN KEY (UsuarioModificacion)	REFERENCES USUARIO	(IdUsuario),
	CONSTRAINT FK_UsuarioBaja_Partido			FOREIGN KEY (UsuarioBaja)			REFERENCES USUARIO	(IdUsuario),
);

-- Crear tabla Jugador
IF OBJECT_ID ('JUGADOR', 'U') IS NOT NULL
BEGIN
	DROP TABLE	JUGADOR
END
GO
CREATE TABLE JUGADOR
(
	IdJugador			INT IDENTITY (1,1)	NOT NULL,
	IdEstatus			INT					NOT NULL,
	IdEquipo			INT					NOT NULL,
	IdUsuario			INT						NULL,	-- [CAMBIO] Antes NOT NULL: la app no captura una cuenta por jugador
	Nombre				NVARCHAR (80)		NOT NULL,
	PrimerApellido		NVARCHAR (80)		NOT NULL,
	SegundoApellido		NVARCHAR (80)			NULL,
	FechaNacimiento		DATE				NOT NULL,
	Correo				NVARCHAR (50)		NOT NULL,
	Telefono			NVARCHAR (15)		NOT NULL,
	FechaRegistro		DATETIME			NOT NULL,
	UsuarioRegistro		INT					NOT NULL,
	FechaModificacion	DATETIME				NULL,
	UsuarioModificacion	INT						NULL,
	FechaBaja			DATETIME				NULL,
	UsuarioBaja			INT						NULL,

	CONSTRAINT PK_IdJugador						PRIMARY KEY (IdJugador),
	CONSTRAINT FK_IdEstatus_Jugador				FOREIGN KEY (IdEstatus)				REFERENCES ESTATUS	(IdEstatus),
	CONSTRAINT FK_IdEquipo_Jugador				FOREIGN KEY (IdEquipo)				REFERENCES EQUIPO	(IdEquipo),
	CONSTRAINT FK_IdUsuario_Jugador				FOREIGN KEY (IdUsuario)				REFERENCES USUARIO	(IdUsuario),
	CONSTRAINT FK_UsuarioRegistro_Jugador		FOREIGN KEY (UsuarioRegistro)		REFERENCES USUARIO	(IdUsuario),
	CONSTRAINT FK_UsuarioModificacion_Jugador	FOREIGN KEY (UsuarioModificacion)	REFERENCES USUARIO	(IdUsuario),
	CONSTRAINT FK_UsuarioBaja_Jugador			FOREIGN KEY (UsuarioBaja)			REFERENCES USUARIO	(IdUsuario),
);


-- Crear tabla Entrenador
IF OBJECT_ID ('ENTRENADOR', 'U') IS NOT NULL
BEGIN
	DROP TABLE	ENTRENADOR
END
GO
CREATE TABLE ENTRENADOR
(
	IdEntrenador		INT IDENTITY (1,1)	NOT NULL,
	IdEstatus			INT					NOT NULL,
	IdEquipo			INT					NOT NULL,
	IdUsuario			INT						NULL,	-- [CAMBIO] Antes NOT NULL: la app no captura una cuenta por entrenador
	Nombre				NVARCHAR (80)		NOT NULL,
	PrimerApellido		NVARCHAR (80)		NOT NULL,
	SegundoApellido		NVARCHAR (80)			NULL,
	FechaNacimiento		DATE				NOT NULL,
	Cedula				NVARCHAR (50)		NOT NULL,
	Telefono			NVARCHAR (15)		NOT NULL,
	FechaRegistro		DATETIME			NOT NULL,
	UsuarioRegistro		INT					NOT NULL,
	FechaModificacion	DATETIME				NULL,
	UsuarioModificacion	INT						NULL,
	FechaBaja			DATETIME				NULL,
	UsuarioBaja			INT						NULL,

	CONSTRAINT PK_IdEntrenador						PRIMARY KEY (IdEntrenador),
	CONSTRAINT FK_IdEstatus_Entrenador				FOREIGN KEY (IdEstatus)				REFERENCES ESTATUS	(IdEstatus),
	CONSTRAINT FK_IdEquipo_Entrenador				FOREIGN KEY (IdEquipo)				REFERENCES EQUIPO	(IdEquipo),
	CONSTRAINT FK_IdUsuario_Entrenador				FOREIGN KEY (IdUsuario)				REFERENCES USUARIO	(IdUsuario),
	CONSTRAINT FK_UsuarioRegistro_Entrenador		FOREIGN KEY (UsuarioRegistro)		REFERENCES USUARIO	(IdUsuario),
	CONSTRAINT FK_UsuarioModificacion_Entrenador	FOREIGN KEY (UsuarioModificacion)	REFERENCES USUARIO	(IdUsuario),
	CONSTRAINT FK_UsuarioBaja_Entrenador			FOREIGN KEY (UsuarioBaja)			REFERENCES USUARIO	(IdUsuario),
)

-- Crear tabla Estadistica_Jugador
IF OBJECT_ID ('ESTADISTICA_JUGADOR', 'U') IS NOT NULL
BEGIN
	DROP TABLE	ESTADISTICA_JUGADOR
END
GO
CREATE TABLE ESTADISTICA_JUGADOR
(
	IdEstadisticaJugador	INT IDENTITY (1,1)	NOT NULL,
	IdPartido				INT					NOT NULL,
	IdJugador				INT					NOT NULL,
	TarjetasAmarillas		INT						NULL,
	TarjetasRojas			INT						NULL,
	Asistencias				INT						NULL,
	GolesAnotados			INT						NULL,
	GolesAtajados			INT						NULL,
	MinutosJugados			INT						NULL,
	CONSTRAINT PK_IdEstadisticaJugador			PRIMARY KEY (IdEstadisticaJugador),
	CONSTRAINT FK_IdPartido_EstadisticaJugador	FOREIGN KEY (IdPartido)				REFERENCES PARTIDO	(IdPartido),
	CONSTRAINT FK_IdJugador_EstadisticaJugador	FOREIGN KEY (IdJugador)				REFERENCES JUGADOR	(IdJugador)
);

-- Crear tabla Equipo_Partido
IF OBJECT_ID ('EQUIPO_PARTIDO', 'U') IS NOT NULL
BEGIN
	DROP TABLE	EQUIPO_PARTIDO
END
GO
CREATE TABLE EQUIPO_PARTIDO
(
	IdEquipoPartido			INT IDENTITY (1,1)	NOT NULL,
	IdPartido				INT					NOT NULL,
	IdEquipo				INT					NOT NULL,
	IdTipoEquipo			INT					NOT NULL,
	Goles					INT						NULL,
	CONSTRAINT PK_IdEquipoPartido				PRIMARY KEY (IdEquipoPartido),
	CONSTRAINT FK_IdPartido_EquipoPartido		FOREIGN KEY (IdPartido)				REFERENCES PARTIDO		(IdPartido),
	CONSTRAINT FK_IdEquipo_EquipoPartido		FOREIGN KEY (IdEquipo)				REFERENCES EQUIPO		(IdEquipo),
	CONSTRAINT FK_IdTipoEquipo_EquipoPartido	FOREIGN KEY (IdTipoEquipo)			REFERENCES TIPO_EQUIPO	(IdTipoEquipo)
);
GO

-- [CAMBIO] RESTRICCIONES DE LAS REGLAS DE NEGOCIO
-- Respaldan en la base lo que los SP validan con mensajes

-- [REGLA 2 y 3] Cada equipo tiene un solo entrenador activo y cada entrenador representa a un solo equipo
-- (el entrenador tiene una sola columna IdEquipo y este índice evita dos entrenadores activos en el mismo equipo)
CREATE UNIQUE INDEX UX_Entrenador_EquipoActivo ON ENTRENADOR (IdEquipo) WHERE IdEstatus = 1;
GO

-- [REGLA 4] La fecha de fin del partido no puede ser anterior a la de inicio
ALTER TABLE PARTIDO ADD CONSTRAINT CK_Partido_Fechas CHECK (FechaFin IS NULL OR FechaFin >= FechaInicio);
GO

-- [REGLA 5] En cada partido participan dos equipos: uno LOCAL y uno VISITANTE, y no el mismo equipo dos veces
ALTER TABLE EQUIPO_PARTIDO ADD CONSTRAINT UQ_EquipoPartido_Equipo UNIQUE (IdPartido, IdEquipo);
ALTER TABLE EQUIPO_PARTIDO ADD CONSTRAINT UQ_EquipoPartido_Tipo   UNIQUE (IdPartido, IdTipoEquipo);
ALTER TABLE EQUIPO_PARTIDO ADD CONSTRAINT CK_EquipoPartido_Goles  CHECK (Goles IS NULL OR Goles >= 0);
GO

-- [REGLA 6] Una sola estadística por jugador en cada partido y valores válidos
ALTER TABLE ESTADISTICA_JUGADOR ADD CONSTRAINT UQ_Estadistica_PartidoJugador UNIQUE (IdPartido, IdJugador);
ALTER TABLE ESTADISTICA_JUGADOR ADD CONSTRAINT CK_Estadistica_Valores CHECK
(
	ISNULL(MinutosJugados, 0)    BETWEEN 0 AND 120 AND
	ISNULL(GolesAnotados, 0)     >= 0 AND
	ISNULL(GolesAtajados, 0)     >= 0 AND
	ISNULL(Asistencias, 0)       >= 0 AND
	ISNULL(TarjetasAmarillas, 0) BETWEEN 0 AND 2 AND
	ISNULL(TarjetasRojas, 0)     BETWEEN 0 AND 1
);
GO

--INSERTS INICIALES

-- Inserts tabla ROL
-- [CAMBIO] El PDF pide dos roles: ADMINISTRADOR (todo) y OBSERVADOR (sólo consulta).
--          La app valida el texto "ADMINISTRADOR" para permitir guardar, editar y eliminar.
-- [REGLA 7] Las reglas de negocio hablan de "entrenador" y "jugador"; se respetan los nombres del PDF:
--          ADMINISTRADOR = permisos del entrenador (registrar, gestionar y administrar todo)
--          OBSERVADOR    = permisos del jugador (sólo consulta de partidos y estadísticas)
INSERT INTO ROL (Descripcion)
VALUES	('ADMINISTRADOR'),
		('OBSERVADOR');
GO

-- Inserts tabla ESTATUS

INSERT INTO ESTATUS (Descripcion)
VALUES	('ACTIVO'),
		('INACTIVO');
GO

-- Inserts tabla USUARIO
-- [CAMBIO] OBSERVADOR ahora usa el IdRol 2 (antes 3)
--          El login distingue mayúsculas: se entra con ADMIN / admin123 y OBSERVADOR / obs123
INSERT INTO USUARIO (IdRol, IdEstatus, Cuenta, Contrasenia, FechaRegistro)
VALUES	(1, 1, 'ADMIN', 'admin123', GETDATE()),
		(2, 1, 'OBSERVADOR', 'obs123' , GETDATE());
GO

--Inserts tabla CATEGORIA

INSERT INTO CATEGORIA (Descripcion)
VALUES	('JUVENIL'),
		('AMATEUR'),
		('PROFESIONAL');
GO

-- Inserts tabla TIPO_EQUIPO

INSERT INTO	TIPO_EQUIPO (Descripcion)
VALUES	('LOCAL'),
		('VISITANTE');
GO

-- Inserts tabla ESTADIO

INSERT INTO ESTADIO	(Descripcion)
VALUES	('ESTADIO 1'),
		('ESTADIO 2'),
		('ESTADIO 3'),
		('ESTADIO 4'),
		('ESTADIO 5'),
		('ESTADIO 6');
GO

-- [CAMBIO] Inserts tabla EQUIPO
-- Sin equipos el combo de Jugador/Entrenador sale vacío y no se puede registrar nada
INSERT INTO EQUIPO (IdEstatus, IdCategoria, Nombre, FechaRegistro, UsuarioRegistro)
VALUES	(1, 3, 'HALCONES FC',		GETDATE(), 1),
		(1, 3, 'LOBOS UNIDOS',		GETDATE(), 1),
		(1, 2, 'DEPORTIVO SIERRA',	GETDATE(), 1),
		(1, 1, 'JAGUARES JUVENIL',	GETDATE(), 1);
GO

-- STORED PROCEDURES

-- spUsuario
CREATE OR ALTER PROCEDURE spUsuario (
    @Accion             INT          = NULL,
    @IdUsuario          INT          = NULL,
    @IdRol              INT          = NULL,
    @Cuenta             NVARCHAR(30) = NULL,
    @Contrasenia        NVARCHAR(30) = NULL,
    @TipoCuenta         NVARCHAR(20) = NULL,    -- [CAMBIO] Crear cuenta: 'JUGADOR' o 'ENTRENADOR'
    @Dato               NVARCHAR(50) = NULL,    -- [CAMBIO] Crear cuenta: correo (jugador) o cédula (entrenador)
    @Telefono           NVARCHAR(15) = NULL,    -- [CAMBIO] Crear cuenta: teléfono registrado de la persona
    @IdUsuarioAuditor   INT          = NULL
)
AS
BEGIN
    -- 1. Crear un nuevo registro
    IF @Accion = 1
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE UPPER(TRIM(Cuenta)) = UPPER(TRIM(@Cuenta)))
        BEGIN
            INSERT INTO USUARIO (
                IdRol,
                IdEstatus,
                Cuenta,
                Contrasenia,
                FechaRegistro,
                UsuarioRegistro
            )
            VALUES (
                @IdRol,
                1,
                TRIM(@Cuenta),      -- [CAMBIO] Sin UPPER: el login distingue mayúsculas y minúsculas
                TRIM(@Contrasenia),
                GETDATE(),
                @IdUsuarioAuditor
            )
            SELECT 'Usuario creado correctamente.' AS Mensaje, 'success' AS TipoMensaje         -- [CAMBIO] + TipoMensaje
        END
        ELSE
        BEGIN
            SELECT 'La cuenta ya existe.' AS Mensaje, 'warning' AS TipoMensaje                  -- [CAMBIO] + TipoMensaje
        END
    END

    -- 2. Leer un registro
    IF @Accion = 2
    BEGIN
        SELECT IdUsuario, IdRol, IdEstatus, Cuenta, Contrasenia     -- [CAMBIO] Cuenta sin UPPER
        FROM USUARIO
        WHERE IdUsuario = @IdUsuario
    END

    -- 3. Consulta general
    -- [CAMBIO] Sólo usuarios ACTIVO y con la descripción del rol (JOIN) en lugar de Ids
    IF @Accion = 3
    BEGIN
        SELECT U.IdUsuario AS Id, U.Cuenta, R.Descripcion AS Rol
        FROM USUARIO U
        INNER JOIN ROL R ON R.IdRol = U.IdRol
        WHERE U.IdEstatus = 1
        AND (UPPER(U.Cuenta) LIKE '%' + UPPER(TRIM(@Cuenta)) + '%' OR @Cuenta IS NULL)
        ORDER BY U.Cuenta
    END

    -- 4. Modificar
    IF @Accion = 4
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE UPPER(TRIM(Cuenta)) = UPPER(TRIM(@Cuenta)) AND IdUsuario != @IdUsuario)
        BEGIN
            UPDATE USUARIO
            SET IdRol               = @IdRol,
                Cuenta              = TRIM(@Cuenta),        -- [CAMBIO] Sin UPPER
                Contrasenia         = TRIM(@Contrasenia),
                FechaModificacion   = GETDATE(),
                UsuarioModificacion = @IdUsuarioAuditor
            WHERE IdUsuario = @IdUsuario

            SELECT 'Registro modificado correctamente.' AS Mensaje, 'success' AS TipoMensaje
        END
        ELSE
        BEGIN
            SELECT 'La cuenta ya está ocupada por otro usuario.' AS Mensaje, 'warning' AS TipoMensaje
        END
    END

    -- 5. Eliminar (Baja lógica)
    IF @Accion = 5
    BEGIN
        UPDATE USUARIO
        SET IdEstatus   = 2,
            FechaBaja   = GETDATE(),
            UsuarioBaja = @IdUsuarioAuditor
        WHERE IdUsuario = @IdUsuario

        SELECT 'Registro eliminado correctamente.' AS Mensaje, 'success' AS TipoMensaje         -- [CAMBIO] + TipoMensaje
    END

    -- [CAMBIO] 6. Iniciar sesión (nueva)
    -- COLLATE ..._CS_AS hace que "admin" y "ADMIN" sean distintos (sensible a mayúsculas)
    IF @Accion = 6
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM USUARIO
                       WHERE Cuenta      COLLATE Latin1_General_CS_AS = @Cuenta
                       AND   Contrasenia COLLATE Latin1_General_CS_AS = @Contrasenia)
        BEGIN
            SELECT 'Usuario o contraseña incorrectos.' AS Mensaje, 'danger' AS TipoMensaje
        END
        -- Validar que el usuario esté en estatus ACTIVO
        ELSE IF EXISTS (SELECT 1 FROM USUARIO
                        WHERE Cuenta      COLLATE Latin1_General_CS_AS = @Cuenta
                        AND   Contrasenia COLLATE Latin1_General_CS_AS = @Contrasenia
                        AND   IdEstatus != 1)
        BEGIN
            SELECT 'El usuario está inactivo.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE
        BEGIN
            SELECT 'Bienvenido.' AS Mensaje, 'success' AS TipoMensaje,
                   U.IdUsuario, U.Cuenta, R.Descripcion AS Rol
            FROM USUARIO U
            INNER JOIN ROL R ON R.IdRol = U.IdRol
            WHERE U.Cuenta      COLLATE Latin1_General_CS_AS = @Cuenta
            AND   U.Contrasenia COLLATE Latin1_General_CS_AS = @Contrasenia
        END
    END

    -- [CAMBIO] 7. Crear cuenta desde el login (nueva)
    -- [REGLA 7] Entrenador -> rol ADMINISTRADOR (registra y gestiona todo)
    --           Jugador    -> rol OBSERVADOR    (sólo consulta)
    -- Para que nadie se dé permisos por su cuenta, la persona ya debe estar registrada y ACTIVA:
    -- el entrenador se identifica con su cédula y teléfono, el jugador con su correo y teléfono.
    -- La cuenta queda vinculada a su registro (IdUsuario) y cada persona sólo puede tener una.
    IF @Accion = 7
    BEGIN
        DECLARE @IdPersona INT, @IdUsuarioPersona INT, @IdRolCuenta INT, @IdNuevo INT

        IF @TipoCuenta = 'ENTRENADOR'
            SELECT @IdPersona = IdEntrenador, @IdUsuarioPersona = IdUsuario
            FROM ENTRENADOR
            WHERE UPPER(TRIM(Cedula)) = UPPER(TRIM(@Dato))
            AND   TRIM(Telefono)      = TRIM(@Telefono)
            AND   IdEstatus           = 1
        ELSE IF @TipoCuenta = 'JUGADOR'
            SELECT @IdPersona = IdJugador, @IdUsuarioPersona = IdUsuario
            FROM JUGADOR
            WHERE UPPER(TRIM(Correo)) = UPPER(TRIM(@Dato))
            AND   TRIM(Telefono)      = TRIM(@Telefono)
            AND   IdEstatus           = 1

        SET @IdRolCuenta = (SELECT IdRol FROM ROL
                            WHERE Descripcion = CASE @TipoCuenta WHEN 'ENTRENADOR' THEN 'ADMINISTRADOR' ELSE 'OBSERVADOR' END)

        IF @TipoCuenta IS NULL OR @TipoCuenta NOT IN ('JUGADOR', 'ENTRENADOR')
        BEGIN
            SELECT 'Selecciona si la cuenta es de jugador o de entrenador.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE IF NULLIF(TRIM(@Cuenta), '') IS NULL OR LEN(ISNULL(@Contrasenia, '')) < 6
        BEGIN
            SELECT 'Captura una cuenta y una contraseña de al menos 6 caracteres.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE IF @IdPersona IS NULL
        BEGIN
            SELECT CASE @TipoCuenta
                       WHEN 'ENTRENADOR' THEN 'No hay un entrenador activo con esa cédula y teléfono.'
                       ELSE 'No hay un jugador activo con ese correo y teléfono.'
                   END AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE IF @IdUsuarioPersona IS NOT NULL
        BEGIN
            SELECT 'Esta persona ya tiene una cuenta.' AS Mensaje, 'warning' AS TipoMensaje
        END
        -- No puede existir más de un usuario con la misma cuenta (sin importar mayúsculas)
        ELSE IF EXISTS (SELECT 1 FROM USUARIO WHERE UPPER(TRIM(Cuenta)) = UPPER(TRIM(@Cuenta)))
        BEGIN
            SELECT 'La cuenta ya existe, elige otra.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE
        BEGIN
            SET XACT_ABORT ON
            BEGIN TRANSACTION
                INSERT INTO USUARIO (IdRol, IdEstatus, Cuenta, Contrasenia, FechaRegistro)
                VALUES (@IdRolCuenta, 1, TRIM(@Cuenta), @Contrasenia, GETDATE())

                SET @IdNuevo = SCOPE_IDENTITY()

                -- Auditoría: la cuenta se registró a sí misma desde el login
                UPDATE USUARIO SET UsuarioRegistro = @IdNuevo WHERE IdUsuario = @IdNuevo

                -- Vincular la cuenta con su registro de entrenador o jugador
                IF @TipoCuenta = 'ENTRENADOR'
                    UPDATE ENTRENADOR
                    SET IdUsuario = @IdNuevo, FechaModificacion = GETDATE(), UsuarioModificacion = @IdNuevo
                    WHERE IdEntrenador = @IdPersona
                ELSE
                    UPDATE JUGADOR
                    SET IdUsuario = @IdNuevo, FechaModificacion = GETDATE(), UsuarioModificacion = @IdNuevo
                    WHERE IdJugador = @IdPersona
            COMMIT TRANSACTION

            SELECT 'Cuenta creada con el rol ' + (SELECT Descripcion FROM ROL WHERE IdRol = @IdRolCuenta)
                   + '. Ya puedes iniciar sesión.' AS Mensaje, 'success' AS TipoMensaje
        END
    END
END
GO

-- spEquipo
CREATE OR ALTER PROCEDURE spEquipo (
    @Accion             INT          = NULL,
    @IdEquipo           INT          = NULL,
    @IdCategoria        INT          = NULL,
    @Nombre             NVARCHAR(50) = NULL,
    @IdUsuarioAuditor   INT          = NULL
)
AS
BEGIN
    -- 1. Crear un nuevo registro
    IF @Accion = 1
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM EQUIPO WHERE UPPER(TRIM(Nombre)) = UPPER(TRIM(@Nombre)))
        BEGIN
            INSERT INTO EQUIPO (
                IdEstatus,
                IdCategoria,
                Nombre,
                FechaRegistro,
                UsuarioRegistro
            )
            VALUES (
                1,
                @IdCategoria,
                UPPER(TRIM(@Nombre)),
                GETDATE(),
                @IdUsuarioAuditor
            )
            SELECT 'Equipo creado correctamente.' AS Mensaje, 'success' AS TipoMensaje
        END
        ELSE
        BEGIN
            SELECT 'El nombre del equipo ya existe.' AS Mensaje, 'warning' AS TipoMensaje
        END
    END

    -- 2. Leer un registro específico
    IF @Accion = 2
    BEGIN
        SELECT IdEquipo, IdEstatus, IdCategoria, UPPER(Nombre) AS Nombre
        FROM EQUIPO
        WHERE IdEquipo = @IdEquipo
    END

    -- 3. Consulta general
    -- [CAMBIO] Sólo equipos ACTIVO y con la categoría por JOIN.
    --          La app usa esta consulta para el combo de equipos (columnas Id, Equipo, Categoria)
    IF @Accion = 3
    BEGIN
        -- [REGLA 2] Se muestra también el entrenador asignado al equipo
        SELECT E.IdEquipo AS Id, UPPER(E.Nombre) AS Equipo, C.Descripcion AS Categoria,
               ISNULL(NULLIF(UPPER(CONCAT_WS(' ', T.PrimerApellido, T.SegundoApellido, T.Nombre)), ''), 'SIN ENTRENADOR') AS Entrenador
        FROM EQUIPO E
        INNER JOIN CATEGORIA C ON C.IdCategoria = E.IdCategoria
        LEFT JOIN ENTRENADOR T ON T.IdEquipo    = E.IdEquipo AND T.IdEstatus = 1
        WHERE E.IdEstatus = 1
        AND (UPPER(E.Nombre) LIKE '%' + UPPER(TRIM(@Nombre)) + '%' OR @Nombre IS NULL)
        ORDER BY Equipo
    END

    -- 4. Modificar un registro
    IF @Accion = 4
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM EQUIPO WHERE UPPER(TRIM(Nombre)) = UPPER(TRIM(@Nombre)) AND IdEquipo != @IdEquipo)
        BEGIN
            UPDATE EQUIPO
            SET IdCategoria         = @IdCategoria,
                Nombre              = UPPER(TRIM(@Nombre)),
                FechaModificacion   = GETDATE(),
                UsuarioModificacion = @IdUsuarioAuditor
            WHERE IdEquipo = @IdEquipo

            SELECT 'Registro modificado correctamente.' AS Mensaje, 'success' AS TipoMensaje
        END
        ELSE
        BEGIN
            SELECT 'El nombre del equipo ya está ocupado.' AS Mensaje, 'warning' AS TipoMensaje
        END
    END

    -- 5. Eliminar (Baja lógica)
    -- [REGLA 2] No se da de baja un equipo que todavía tiene jugadores o entrenador activos
    IF @Accion = 5
    BEGIN
        IF EXISTS (SELECT 1 FROM JUGADOR    WHERE IdEquipo = @IdEquipo AND IdEstatus = 1)
        OR EXISTS (SELECT 1 FROM ENTRENADOR WHERE IdEquipo = @IdEquipo AND IdEstatus = 1)
        BEGIN
            SELECT 'El equipo tiene jugadores o entrenador activos.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE
        BEGIN
            UPDATE EQUIPO
            SET IdEstatus   = 2,
                FechaBaja   = GETDATE(),
                UsuarioBaja = @IdUsuarioAuditor
            WHERE IdEquipo = @IdEquipo

            SELECT 'Equipo dado de baja correctamente.' AS Mensaje, 'success' AS TipoMensaje
        END
    END
END
GO

-- spJugador
CREATE OR ALTER PROCEDURE spJugador (
    @Accion             INT          = NULL,
    @IdJugador          INT          = NULL,
    @IdUsuario          INT          = NULL,
    @IdEstatus          INT          = NULL,
    @IdEquipo           INT          = NULL,
    @Nombre             NVARCHAR(80) = NULL,
    @PrimerApellido     NVARCHAR(80) = NULL,
    @SegundoApellido    NVARCHAR(80) = NULL,
    @FechaNacimiento    DATE         = NULL,
    @Correo             NVARCHAR(50) = NULL,
    @Telefono           NVARCHAR(15) = NULL,
    @Buscar             NVARCHAR(80) = NULL,    -- [CAMBIO] Nuevo: texto de búsqueda de la consulta general
    @IdUsuarioAuditor   INT          = NULL     -- [CAMBIO] Antes @UsuarioAuditor (la app manda @IdUsuarioAuditor)
)
AS
BEGIN
    -- 1. Crear un registro
    -- [CAMBIO] Además del correo se valida el teléfono (el PDF pide ambos únicos)
    IF @Accion = 1
    BEGIN
        IF EXISTS (SELECT 1 FROM JUGADOR WHERE UPPER(TRIM(Correo)) = UPPER(TRIM(@Correo)))
        BEGIN
            SELECT 'El correo ya está ocupado por otro jugador.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE IF EXISTS (SELECT 1 FROM JUGADOR WHERE TRIM(Telefono) = TRIM(@Telefono))
        BEGIN
            SELECT 'El teléfono ya está ocupado por otro jugador.' AS Mensaje, 'warning' AS TipoMensaje
        END
        -- [REGLA 2] El jugador pertenece a un único equipo, que debe existir y estar activo
        ELSE IF NOT EXISTS (SELECT 1 FROM EQUIPO WHERE IdEquipo = @IdEquipo AND IdEstatus = 1)
        BEGIN
            SELECT 'Selecciona un equipo válido.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE
        BEGIN
            INSERT INTO JUGADOR (
                IdEstatus,
                IdEquipo,
                IdUsuario,
                Nombre,
                PrimerApellido,
                SegundoApellido,
                FechaNacimiento,
                Correo,
                Telefono,
                FechaRegistro,
                UsuarioRegistro
            )
            VALUES (
                1,
                @IdEquipo,
                @IdUsuario,
                UPPER(TRIM(@Nombre)),
                UPPER(TRIM(@PrimerApellido)),
                NULLIF(UPPER(TRIM(@SegundoApellido)), ''),
                @FechaNacimiento,
                UPPER(TRIM(@Correo)),
                TRIM(@Telefono),
                GETDATE(),
                @IdUsuarioAuditor
            )
            SELECT 'Jugador registrado correctamente.' AS Mensaje, 'success' AS TipoMensaje
        END
    END

    -- 2. Leer un registro específico
    IF @Accion = 2
    BEGIN
        SELECT IdJugador, IdEstatus, IdEquipo, IdUsuario,
               UPPER(Nombre) AS Nombre,
               UPPER(PrimerApellido) AS PrimerApellido,
               UPPER(SegundoApellido) AS SegundoApellido,
               FechaNacimiento,
               UPPER(Correo) AS Correo,
               Telefono,
               FechaRegistro
        FROM JUGADOR
        WHERE IdJugador = @IdJugador
        AND IdEstatus = 1      -- [CAMBIO] Un jugador dado de baja ya no se puede consultar para editar
    END

    -- 3. Consulta general
    -- [CAMBIO] Sólo jugadores ACTIVO, sin Ids en pantalla (equipo y categoría por JOIN),
    --          nombre completo, fecha dd/mm/aaaa, edad y búsqueda por nombre, correo, teléfono o equipo
    IF @Accion = 3
    BEGIN
        SELECT J.IdJugador AS Id,
               UPPER(CONCAT_WS(' ', J.PrimerApellido, J.SegundoApellido, J.Nombre)) AS Jugador,
               UPPER(E.Nombre) AS Equipo,
               C.Descripcion AS Categoria,
               CONVERT(VARCHAR(10), J.FechaNacimiento, 103) AS FechaNacimiento,
               DATEDIFF(YEAR, J.FechaNacimiento, GETDATE())
                   - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, J.FechaNacimiento, GETDATE()), J.FechaNacimiento) > GETDATE()
                          THEN 1 ELSE 0 END AS Edad,
               UPPER(J.Correo) AS Correo,
               J.Telefono
        FROM JUGADOR J
        INNER JOIN EQUIPO    E ON E.IdEquipo    = J.IdEquipo
        INNER JOIN CATEGORIA C ON C.IdCategoria = E.IdCategoria
        WHERE J.IdEstatus = 1
        AND (UPPER(CONCAT_WS(' ', J.Nombre, J.PrimerApellido, J.SegundoApellido)) LIKE '%' + UPPER(TRIM(@Buscar)) + '%'
             OR UPPER(J.Correo) LIKE '%' + UPPER(TRIM(@Buscar)) + '%'
             OR J.Telefono      LIKE '%' + TRIM(@Buscar) + '%'
             OR UPPER(E.Nombre) LIKE '%' + UPPER(TRIM(@Buscar)) + '%'
             OR @Buscar IS NULL)
        ORDER BY Jugador
    END

    -- 4. Modificar un registro
    -- [CAMBIO] Además del correo se valida el teléfono
    IF @Accion = 4
    BEGIN
        IF EXISTS (SELECT 1 FROM JUGADOR WHERE UPPER(TRIM(Correo)) = UPPER(TRIM(@Correo)) AND IdJugador != @IdJugador)
        BEGIN
            SELECT 'El correo ya está ocupado por otro jugador.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE IF EXISTS (SELECT 1 FROM JUGADOR WHERE TRIM(Telefono) = TRIM(@Telefono) AND IdJugador != @IdJugador)
        BEGIN
            SELECT 'El teléfono ya está ocupado por otro jugador.' AS Mensaje, 'warning' AS TipoMensaje
        END
        -- [REGLA 2] El jugador pertenece a un único equipo, que debe existir y estar activo
        ELSE IF NOT EXISTS (SELECT 1 FROM EQUIPO WHERE IdEquipo = @IdEquipo AND IdEstatus = 1)
        BEGIN
            SELECT 'Selecciona un equipo válido.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE
        BEGIN
            UPDATE JUGADOR
            SET IdEquipo            = @IdEquipo,
                Nombre              = UPPER(TRIM(@Nombre)),
                PrimerApellido      = UPPER(TRIM(@PrimerApellido)),
                SegundoApellido     = NULLIF(UPPER(TRIM(@SegundoApellido)), ''),
                FechaNacimiento     = @FechaNacimiento,
                Correo              = UPPER(TRIM(@Correo)),
                Telefono            = TRIM(@Telefono),
                FechaModificacion   = GETDATE(),
                UsuarioModificacion = @IdUsuarioAuditor
            WHERE IdJugador = @IdJugador
            AND IdEstatus = 1  -- [CAMBIO] No se modifican jugadores dados de baja
            -- [CAMBIO] Ya no se actualiza IdUsuario: la app no lo envía y quedaría en NULL

            SELECT 'Registro modificado correctamente.' AS Mensaje, 'success' AS TipoMensaje
        END
    END

    -- 5. Eliminar registro (Baja lógica)
    IF @Accion = 5
    BEGIN
        UPDATE JUGADOR
        SET IdEstatus   = 2,
            FechaBaja   = GETDATE(),
            UsuarioBaja = @IdUsuarioAuditor
        WHERE IdJugador = @IdJugador

        SELECT 'Jugador dado de baja correctamente.' AS Mensaje, 'success' AS TipoMensaje
    END
END
GO

-- spEntrenador
CREATE OR ALTER PROCEDURE spEntrenador (
    @Accion             INT          = NULL,
    @IdEntrenador       INT          = NULL,
    @IdUsuario          INT          = NULL,
    @IdEstatus          INT          = NULL,
    @IdEquipo           INT          = NULL,
    @Nombre             NVARCHAR(80) = NULL,
    @PrimerApellido     NVARCHAR(80) = NULL,
    @SegundoApellido    NVARCHAR(80) = NULL,
    @FechaNacimiento    DATE         = NULL,
    @Cedula             NVARCHAR(50) = NULL,
    @Telefono           NVARCHAR(15) = NULL,
    @Buscar             NVARCHAR(80) = NULL,    -- [CAMBIO] Nuevo: texto de búsqueda de la consulta general
    @IdUsuarioAuditor   INT          = NULL     -- [CAMBIO] Antes @UsuarioAuditor (la app manda @IdUsuarioAuditor)
)
AS
BEGIN
    -- 1. Crear un registro
    -- [CAMBIO] Además de la cédula se valida el teléfono (el PDF pide ambos únicos)
    IF @Accion = 1
    BEGIN
        IF EXISTS (SELECT 1 FROM ENTRENADOR WHERE UPPER(TRIM(Cedula)) = UPPER(TRIM(@Cedula)))
        BEGIN
            SELECT 'La cédula ya está registrada con otro entrenador.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE IF EXISTS (SELECT 1 FROM ENTRENADOR WHERE TRIM(Telefono) = TRIM(@Telefono))
        BEGIN
            SELECT 'El teléfono ya está registrado con otro entrenador.' AS Mensaje, 'warning' AS TipoMensaje
        END
        -- [REGLA 3] El entrenador representa a un solo equipo, que debe existir y estar activo
        ELSE IF NOT EXISTS (SELECT 1 FROM EQUIPO WHERE IdEquipo = @IdEquipo AND IdEstatus = 1)
        BEGIN
            SELECT 'Selecciona un equipo válido.' AS Mensaje, 'warning' AS TipoMensaje
        END
        -- [REGLA 2] Cada equipo tiene un solo entrenador asignado
        ELSE IF EXISTS (SELECT 1 FROM ENTRENADOR WHERE IdEquipo = @IdEquipo AND IdEstatus = 1)
        BEGIN
            SELECT 'Ese equipo ya tiene un entrenador asignado.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE
        BEGIN
            INSERT INTO ENTRENADOR (
                IdEstatus,
                IdEquipo,
                IdUsuario,
                Nombre,
                PrimerApellido,
                SegundoApellido,
                FechaNacimiento,
                Cedula,
                Telefono,
                FechaRegistro,
                UsuarioRegistro
            )
            VALUES (
                1,
                @IdEquipo,
                @IdUsuario,
                UPPER(TRIM(@Nombre)),
                UPPER(TRIM(@PrimerApellido)),
                NULLIF(UPPER(TRIM(@SegundoApellido)), ''),
                @FechaNacimiento,
                UPPER(TRIM(@Cedula)),
                TRIM(@Telefono),
                GETDATE(),
                @IdUsuarioAuditor
            )
            SELECT 'Entrenador registrado correctamente.' AS Mensaje, 'success' AS TipoMensaje
        END
    END

    -- 2. Leer un registro específico
    IF @Accion = 2
    BEGIN
        SELECT IdEntrenador, IdEstatus, IdEquipo, IdUsuario,
               UPPER(Nombre) AS Nombre,
               UPPER(PrimerApellido) AS PrimerApellido,
               UPPER(SegundoApellido) AS SegundoApellido,
               FechaNacimiento,
               UPPER(Cedula) AS Cedula,
               Telefono,
               FechaRegistro
        FROM ENTRENADOR
        WHERE IdEntrenador = @IdEntrenador
        AND IdEstatus = 1      -- [CAMBIO] Un entrenador dado de baja ya no se puede consultar para editar
    END

    -- 3. Consulta general
    -- [CAMBIO] Sólo entrenadores ACTIVO, sin Ids en pantalla (equipo y categoría por JOIN),
    --          nombre completo, fecha dd/mm/aaaa, edad y búsqueda por nombre, cédula, teléfono o equipo
    IF @Accion = 3
    BEGIN
        SELECT T.IdEntrenador AS Id,
               UPPER(CONCAT_WS(' ', T.PrimerApellido, T.SegundoApellido, T.Nombre)) AS Entrenador,
               UPPER(E.Nombre) AS Equipo,
               C.Descripcion AS Categoria,
               CONVERT(VARCHAR(10), T.FechaNacimiento, 103) AS FechaNacimiento,
               DATEDIFF(YEAR, T.FechaNacimiento, GETDATE())
                   - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, T.FechaNacimiento, GETDATE()), T.FechaNacimiento) > GETDATE()
                          THEN 1 ELSE 0 END AS Edad,
               UPPER(T.Cedula) AS Cedula,
               T.Telefono
        FROM ENTRENADOR T
        INNER JOIN EQUIPO    E ON E.IdEquipo    = T.IdEquipo
        INNER JOIN CATEGORIA C ON C.IdCategoria = E.IdCategoria
        WHERE T.IdEstatus = 1
        AND (UPPER(CONCAT_WS(' ', T.Nombre, T.PrimerApellido, T.SegundoApellido)) LIKE '%' + UPPER(TRIM(@Buscar)) + '%'
             OR UPPER(T.Cedula) LIKE '%' + UPPER(TRIM(@Buscar)) + '%'
             OR T.Telefono      LIKE '%' + TRIM(@Buscar) + '%'
             OR UPPER(E.Nombre) LIKE '%' + UPPER(TRIM(@Buscar)) + '%'
             OR @Buscar IS NULL)
        ORDER BY Entrenador
    END

    -- 4. Modificar un registro
    -- [CAMBIO] Además de la cédula se valida el teléfono
    IF @Accion = 4
    BEGIN
        IF EXISTS (SELECT 1 FROM ENTRENADOR WHERE UPPER(TRIM(Cedula)) = UPPER(TRIM(@Cedula)) AND IdEntrenador != @IdEntrenador)
        BEGIN
            SELECT 'La cédula ya está ocupada por otro entrenador.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE IF EXISTS (SELECT 1 FROM ENTRENADOR WHERE TRIM(Telefono) = TRIM(@Telefono) AND IdEntrenador != @IdEntrenador)
        BEGIN
            SELECT 'El teléfono ya está ocupado por otro entrenador.' AS Mensaje, 'warning' AS TipoMensaje
        END
        -- [REGLA 3] El entrenador representa a un solo equipo, que debe existir y estar activo
        ELSE IF NOT EXISTS (SELECT 1 FROM EQUIPO WHERE IdEquipo = @IdEquipo AND IdEstatus = 1)
        BEGIN
            SELECT 'Selecciona un equipo válido.' AS Mensaje, 'warning' AS TipoMensaje
        END
        -- [REGLA 2] Cada equipo tiene un solo entrenador asignado
        ELSE IF EXISTS (SELECT 1 FROM ENTRENADOR WHERE IdEquipo = @IdEquipo AND IdEstatus = 1 AND IdEntrenador != @IdEntrenador)
        BEGIN
            SELECT 'Ese equipo ya tiene un entrenador asignado.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE
        BEGIN
            UPDATE ENTRENADOR
            SET IdEquipo            = @IdEquipo,
                Nombre              = UPPER(TRIM(@Nombre)),
                PrimerApellido      = UPPER(TRIM(@PrimerApellido)),
                SegundoApellido     = NULLIF(UPPER(TRIM(@SegundoApellido)), ''),
                FechaNacimiento     = @FechaNacimiento,
                Cedula              = UPPER(TRIM(@Cedula)),
                Telefono            = TRIM(@Telefono),
                FechaModificacion   = GETDATE(),
                UsuarioModificacion = @IdUsuarioAuditor
            WHERE IdEntrenador = @IdEntrenador
            AND IdEstatus = 1  -- [CAMBIO] No se modifican entrenadores dados de baja
            -- [CAMBIO] Ya no se actualiza IdUsuario: la app no lo envía y quedaría en NULL

            SELECT 'Registro modificado correctamente.' AS Mensaje, 'success' AS TipoMensaje
        END
    END

    -- 5. Eliminar registro (Baja lógica)
    IF @Accion = 5
    BEGIN
        UPDATE ENTRENADOR
        SET IdEstatus   = 2,
            FechaBaja   = GETDATE(),
            UsuarioBaja = @IdUsuarioAuditor
        WHERE IdEntrenador = @IdEntrenador

        SELECT 'Entrenador dado de baja correctamente.' AS Mensaje, 'success' AS TipoMensaje
    END
END
GO

-- spPartido
CREATE OR ALTER PROCEDURE spPartido (
    @Accion             INT          = NULL,
    @IdPartido          INT          = NULL,
    @IdEstadio          INT          = NULL,
    @Nombre             NVARCHAR(50) = NULL,
    @FechaInicio        DATETIME     = NULL,
    @FechaFin           DATETIME     = NULL,
    @Resultado          NVARCHAR(30) = NULL,
    @IdUsuarioAuditor   INT          = NULL     -- [CAMBIO] Antes @UsuarioAuditor, igual que los demás SP
)
AS
BEGIN
    -- 1. Crear un nuevo registro
    -- [REGLA 4] El partido lleva nombre, lugar (estadio), fecha de inicio y de finalización
    IF @Accion = 1
    BEGIN
        IF EXISTS (SELECT 1 FROM PARTIDO WHERE UPPER(TRIM(Nombre)) = UPPER(TRIM(@Nombre)))
        BEGIN
            SELECT 'El nombre del partido ya existe.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE IF @FechaFin IS NOT NULL AND @FechaFin < @FechaInicio
        BEGIN
            SELECT 'La fecha de finalización no puede ser anterior a la de inicio.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE IF NOT EXISTS (SELECT 1 FROM ESTADIO WHERE IdEstadio = @IdEstadio)
        BEGIN
            SELECT 'Selecciona un estadio válido.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE
        BEGIN
            INSERT INTO PARTIDO (
                IdEstatus,
                IdEstadio,
                Nombre,
                FechaInicio,
                FechaFin,
                Resultado,
                FechaRegistro,
                UsuarioRegistro
            )
            VALUES (
                1,
                @IdEstadio,
                UPPER(TRIM(@Nombre)),
                @FechaInicio,
                @FechaFin,
                NULLIF(UPPER(TRIM(@Resultado)), ''),
                GETDATE(),
                @IdUsuarioAuditor
            )
            SELECT 'Partido creado correctamente.' AS Mensaje, 'success' AS TipoMensaje         -- [CAMBIO] + TipoMensaje
        END
    END

    -- 2. Leer un registro en específico
    IF @Accion = 2
    BEGIN
        SELECT IdPartido, IdEstatus, IdEstadio, UPPER(Nombre) AS Nombre, FechaInicio, FechaFin, UPPER(Resultado) AS Resultado
        FROM PARTIDO
        WHERE IdPartido = @IdPartido
    END

    -- 3. Consulta general
    -- [CAMBIO] Sólo partidos ACTIVO y sin Ids en pantalla
    -- [REGLA 5] Historial: lugar, fechas, equipo local, equipo visitante y resultado
    IF @Accion = 3
    BEGIN
        SELECT P.IdPartido AS Id,
               UPPER(P.Nombre) AS Partido,
               S.Descripcion AS Estadio,
               CONVERT(VARCHAR(16), P.FechaInicio, 103) + ' ' + CONVERT(VARCHAR(5), P.FechaInicio, 108) AS FechaInicio,
               CONVERT(VARCHAR(16), P.FechaFin, 103)    + ' ' + CONVERT(VARCHAR(5), P.FechaFin, 108)    AS FechaFin,
               ISNULL(UPPER(L.Nombre), 'POR DEFINIR') AS Local,
               ISNULL(UPPER(V.Nombre), 'POR DEFINIR') AS Visitante,
               ISNULL(UPPER(P.Resultado), 'SIN RESULTADO') AS Resultado
        FROM PARTIDO P
        INNER JOIN ESTADIO S ON S.IdEstadio = P.IdEstadio
        LEFT JOIN EQUIPO_PARTIDO EPL ON EPL.IdPartido = P.IdPartido AND EPL.IdTipoEquipo = 1
        LEFT JOIN EQUIPO L           ON L.IdEquipo    = EPL.IdEquipo
        LEFT JOIN EQUIPO_PARTIDO EPV ON EPV.IdPartido = P.IdPartido AND EPV.IdTipoEquipo = 2
        LEFT JOIN EQUIPO V           ON V.IdEquipo    = EPV.IdEquipo
        WHERE P.IdEstatus = 1
        AND (UPPER(P.Nombre) LIKE '%' + UPPER(TRIM(@Nombre)) + '%' OR @Nombre IS NULL)
        ORDER BY P.FechaInicio DESC
    END

    -- 4. Modificar un registro
    IF @Accion = 4
    BEGIN
        IF EXISTS (SELECT 1 FROM PARTIDO WHERE UPPER(TRIM(Nombre)) = UPPER(TRIM(@Nombre)) AND IdPartido != @IdPartido)
        BEGIN
            SELECT 'El nombre del partido ya está ocupado.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE IF @FechaFin IS NOT NULL AND @FechaFin < @FechaInicio
        BEGIN
            SELECT 'La fecha de finalización no puede ser anterior a la de inicio.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE IF NOT EXISTS (SELECT 1 FROM ESTADIO WHERE IdEstadio = @IdEstadio)
        BEGIN
            SELECT 'Selecciona un estadio válido.' AS Mensaje, 'warning' AS TipoMensaje
        END
        ELSE
        BEGIN
            UPDATE PARTIDO
            SET IdEstadio           = @IdEstadio,
                Nombre              = UPPER(TRIM(@Nombre)),
                FechaInicio         = @FechaInicio,
                FechaFin            = @FechaFin,
                Resultado           = NULLIF(UPPER(TRIM(@Resultado)), ''),
                FechaModificacion   = GETDATE(),
                UsuarioModificacion = @IdUsuarioAuditor
            WHERE IdPartido = @IdPartido

            SELECT 'Registro modificado correctamente.' AS Mensaje, 'success' AS TipoMensaje
        END
    END

    -- 5. Eliminar (Baja lógica)
    IF @Accion = 5
    BEGIN
        UPDATE PARTIDO
        SET IdEstatus   = 2,
            FechaBaja   = GETDATE(),
            UsuarioBaja = @IdUsuarioAuditor
        WHERE IdPartido = @IdPartido

        SELECT 'Partido dado de baja correctamente.' AS Mensaje, 'success' AS TipoMensaje       -- [CAMBIO] + TipoMensaje
    END
END
GO

-- spEstadisticaJugador
CREATE OR ALTER PROCEDURE spEstadisticaJugador (
    @Accion                 INT = NULL,
    @IdEstadisticaJugador   INT = NULL,
    @IdPartido              INT = NULL,
    @IdJugador              INT = NULL,
    @TarjetasAmarillas      INT = NULL,
    @TarjetasRojas          INT = NULL,
    @Asistencias            INT = NULL,
    @GolesAnotados          INT = NULL,
    @GolesAtajados          INT = NULL,
    @MinutosJugados         INT = NULL
)
AS
BEGIN
    -- [REGLA 6] Validaciones para registrar (1) y modificar (4) estadísticas
    IF @Accion IN (1, 4)
    BEGIN
        -- El jugador sólo tiene una estadística por partido
        IF EXISTS (SELECT 1 FROM ESTADISTICA_JUGADOR WHERE IdPartido = @IdPartido AND IdJugador = @IdJugador
                   AND IdEstadisticaJugador != ISNULL(@IdEstadisticaJugador, 0))
        BEGIN
            SELECT 'Este jugador ya tiene estadísticas registradas en este partido.' AS Mensaje, 'warning' AS TipoMensaje
            RETURN
        END
        -- El partido y el jugador deben estar activos
        IF NOT EXISTS (SELECT 1 FROM PARTIDO WHERE IdPartido = @IdPartido AND IdEstatus = 1)
        OR NOT EXISTS (SELECT 1 FROM JUGADOR WHERE IdJugador = @IdJugador AND IdEstatus = 1)
        BEGIN
            SELECT 'Selecciona un partido y un jugador activos.' AS Mensaje, 'warning' AS TipoMensaje
            RETURN
        END
        -- El equipo del jugador debe ser el local o el visitante de ese partido
        IF NOT EXISTS (SELECT 1 FROM EQUIPO_PARTIDO EP
                       INNER JOIN JUGADOR J ON J.IdEquipo = EP.IdEquipo
                       WHERE EP.IdPartido = @IdPartido AND J.IdJugador = @IdJugador)
        BEGIN
            SELECT 'El equipo del jugador no participa en este partido.' AS Mensaje, 'warning' AS TipoMensaje
            RETURN
        END
        -- Minutos, goles, asistencias y tarjetas con valores válidos
        IF ISNULL(@MinutosJugados, 0) NOT BETWEEN 0 AND 120
        OR ISNULL(@GolesAnotados, 0) < 0 OR ISNULL(@GolesAtajados, 0) < 0 OR ISNULL(@Asistencias, 0) < 0
        BEGIN
            SELECT 'Minutos (0 a 120), goles y asistencias no pueden ser negativos.' AS Mensaje, 'warning' AS TipoMensaje
            RETURN
        END
        IF ISNULL(@TarjetasAmarillas, 0) NOT BETWEEN 0 AND 2 OR ISNULL(@TarjetasRojas, 0) NOT BETWEEN 0 AND 1
        BEGIN
            SELECT 'Un jugador puede tener máximo 2 tarjetas amarillas y 1 roja por partido.' AS Mensaje, 'warning' AS TipoMensaje
            RETURN
        END
    END

    -- 1. Crear un nuevo registro
    IF @Accion = 1
    BEGIN
        INSERT INTO ESTADISTICA_JUGADOR (
            IdPartido,
            IdJugador,
            TarjetasAmarillas,
            TarjetasRojas,
            Asistencias,
            GolesAnotados,
            GolesAtajados,
            MinutosJugados
        )
        VALUES (
            @IdPartido,
            @IdJugador,
            ISNULL(@TarjetasAmarillas, 0),
            ISNULL(@TarjetasRojas, 0),
            ISNULL(@Asistencias, 0),
            ISNULL(@GolesAnotados, 0),
            ISNULL(@GolesAtajados, 0),
            ISNULL(@MinutosJugados, 0)
        )
        SELECT 'Estadística registrada correctamente.' AS Mensaje, 'success' AS TipoMensaje         -- [CAMBIO] + TipoMensaje
    END

    -- 2. Leer un registro específico
    IF @Accion = 2
    BEGIN
        SELECT IdEstadisticaJugador, IdPartido, IdJugador, TarjetasAmarillas, TarjetasRojas, Asistencias, GolesAnotados, GolesAtajados, MinutosJugados
        FROM ESTADISTICA_JUGADOR
        WHERE IdEstadisticaJugador = @IdEstadisticaJugador
    END

    -- 3. Consulta general
    -- [CAMBIO] Nombres de partido, jugador y equipo (JOIN) en lugar de Ids
    IF @Accion = 3
    BEGIN
        SELECT EJ.IdEstadisticaJugador AS Id,
               UPPER(P.Nombre) AS Partido,
               UPPER(CONCAT_WS(' ', J.PrimerApellido, J.SegundoApellido, J.Nombre)) AS Jugador,
               UPPER(E.Nombre) AS Equipo,
               EJ.MinutosJugados,
               EJ.GolesAnotados,
               EJ.Asistencias,
               EJ.TarjetasAmarillas,
               EJ.TarjetasRojas,
               EJ.GolesAtajados
        FROM ESTADISTICA_JUGADOR EJ
        INNER JOIN PARTIDO P ON P.IdPartido = EJ.IdPartido
        INNER JOIN JUGADOR J ON J.IdJugador = EJ.IdJugador
        INNER JOIN EQUIPO  E ON E.IdEquipo  = J.IdEquipo
        WHERE P.IdEstatus = 1
        AND (EJ.IdPartido = @IdPartido OR @IdPartido IS NULL)
        ORDER BY Partido, Jugador
    END

    -- 4. Modificar un registro
    IF @Accion = 4
    BEGIN
        UPDATE ESTADISTICA_JUGADOR
        SET IdPartido           = @IdPartido,
            IdJugador           = @IdJugador,
            TarjetasAmarillas   = ISNULL(@TarjetasAmarillas, 0),
            TarjetasRojas       = ISNULL(@TarjetasRojas, 0),
            Asistencias         = ISNULL(@Asistencias, 0),
            GolesAnotados       = ISNULL(@GolesAnotados, 0),
            GolesAtajados       = ISNULL(@GolesAtajados, 0),
            MinutosJugados      = ISNULL(@MinutosJugados, 0)
        WHERE IdEstadisticaJugador = @IdEstadisticaJugador

        SELECT 'Estadística modificada correctamente.' AS Mensaje, 'success' AS TipoMensaje
    END

    -- 5. Eliminar un registro (tabla de detalle sin estatus: baja física)
    IF @Accion = 5
    BEGIN
        DELETE FROM ESTADISTICA_JUGADOR
        WHERE IdEstadisticaJugador = @IdEstadisticaJugador

        SELECT 'Estadística eliminada correctamente.' AS Mensaje, 'success' AS TipoMensaje      -- [CAMBIO] + TipoMensaje
    END
END
GO

-- spEquipoPartido
CREATE OR ALTER PROCEDURE spEquipoPartido (
    @Accion             INT = NULL,
    @IdEquipoPartido    INT = NULL,
    @IdPartido          INT = NULL,
    @IdEquipo           INT = NULL,
    @IdTipoEquipo       INT = NULL,
    @Goles              INT = NULL
)
AS
BEGIN
    -- [REGLA 5] Validaciones para registrar (1) y modificar (4) los equipos de un partido
    IF @Accion IN (1, 4)
    BEGIN
        -- El partido debe estar activo y el equipo también
        IF NOT EXISTS (SELECT 1 FROM PARTIDO WHERE IdPartido = @IdPartido AND IdEstatus = 1)
        OR NOT EXISTS (SELECT 1 FROM EQUIPO  WHERE IdEquipo  = @IdEquipo  AND IdEstatus = 1)
        BEGIN
            SELECT 'Selecciona un partido y un equipo activos.' AS Mensaje, 'warning' AS TipoMensaje
            RETURN
        END
        -- El mismo equipo no puede estar dos veces en el partido
        IF EXISTS (SELECT 1 FROM EQUIPO_PARTIDO WHERE IdPartido = @IdPartido AND IdEquipo = @IdEquipo
                   AND IdEquipoPartido != ISNULL(@IdEquipoPartido, 0))
        BEGIN
            SELECT 'Este equipo ya está registrado en este partido.' AS Mensaje, 'warning' AS TipoMensaje
            RETURN
        END
        -- Sólo un LOCAL y un VISITANTE por partido (máximo dos equipos)
        IF EXISTS (SELECT 1 FROM EQUIPO_PARTIDO WHERE IdPartido = @IdPartido AND IdTipoEquipo = @IdTipoEquipo
                   AND IdEquipoPartido != ISNULL(@IdEquipoPartido, 0))
        BEGIN
            SELECT 'El partido ya tiene un equipo ' + (SELECT Descripcion FROM TIPO_EQUIPO WHERE IdTipoEquipo = @IdTipoEquipo) + '.' AS Mensaje,
                   'warning' AS TipoMensaje
            RETURN
        END
        IF ISNULL(@Goles, 0) < 0
        BEGIN
            SELECT 'Los goles no pueden ser negativos.' AS Mensaje, 'warning' AS TipoMensaje
            RETURN
        END
    END

    -- 1. Crear un nuevo registro
    IF @Accion = 1
    BEGIN
        INSERT INTO EQUIPO_PARTIDO (
            IdPartido,
            IdEquipo,
            IdTipoEquipo,
            Goles
        )
        VALUES (
            @IdPartido,
            @IdEquipo,
            @IdTipoEquipo,
            @Goles
        )
        SELECT 'Equipo asignado al partido correctamente.' AS Mensaje, 'success' AS TipoMensaje     -- [CAMBIO] + TipoMensaje
    END

    -- 2. Leer un registro específico
    IF @Accion = 2
    BEGIN
        SELECT IdEquipoPartido, IdPartido, IdEquipo, IdTipoEquipo, Goles
        FROM EQUIPO_PARTIDO
        WHERE IdEquipoPartido = @IdEquipoPartido
    END

    -- 3. Consulta general
    -- [CAMBIO] Nombres de partido, equipo y tipo (LOCAL / VISITANTE) en lugar de Ids
    IF @Accion = 3
    BEGIN
        SELECT EP.IdEquipoPartido AS Id,
               UPPER(P.Nombre) AS Partido,
               UPPER(E.Nombre) AS Equipo,
               T.Descripcion AS TipoEquipo,
               EP.Goles
        FROM EQUIPO_PARTIDO EP
        INNER JOIN PARTIDO     P ON P.IdPartido    = EP.IdPartido
        INNER JOIN EQUIPO      E ON E.IdEquipo     = EP.IdEquipo
        INNER JOIN TIPO_EQUIPO T ON T.IdTipoEquipo = EP.IdTipoEquipo
        WHERE P.IdEstatus = 1
        AND (EP.IdPartido = @IdPartido OR @IdPartido IS NULL)
        ORDER BY Partido, T.IdTipoEquipo
    END

    -- 4. Modificar un registro
    IF @Accion = 4
    BEGIN
        UPDATE EQUIPO_PARTIDO
        SET IdPartido       = @IdPartido,
            IdEquipo        = @IdEquipo,
            IdTipoEquipo    = @IdTipoEquipo,
            Goles           = @Goles
        WHERE IdEquipoPartido = @IdEquipoPartido

        SELECT 'Registro modificado correctamente.' AS Mensaje, 'success' AS TipoMensaje
    END

    -- 5. Eliminar
    IF @Accion = 5
    BEGIN
        -- Se guarda el partido antes de borrar para recalcular su resultado
        SELECT @IdPartido = IdPartido FROM EQUIPO_PARTIDO WHERE IdEquipoPartido = @IdEquipoPartido

        DELETE FROM EQUIPO_PARTIDO
        WHERE IdEquipoPartido = @IdEquipoPartido

        SELECT 'Registro eliminado correctamente.' AS Mensaje, 'success' AS TipoMensaje         -- [CAMBIO] + TipoMensaje
    END

    -- [REGLA 5] Resultado final: cuando el partido tiene LOCAL y VISITANTE con goles,
    -- se guarda en PARTIDO.Resultado como "2 - 1" (goles local - goles visitante) para el historial
    IF @Accion IN (1, 4, 5)
    BEGIN
        UPDATE P
        SET P.Resultado = CAST(EPL.Goles AS VARCHAR(3)) + ' - ' + CAST(EPV.Goles AS VARCHAR(3))
        FROM PARTIDO P
        INNER JOIN EQUIPO_PARTIDO EPL ON EPL.IdPartido = P.IdPartido AND EPL.IdTipoEquipo = 1
        INNER JOIN EQUIPO_PARTIDO EPV ON EPV.IdPartido = P.IdPartido AND EPV.IdTipoEquipo = 2
        WHERE P.IdPartido = @IdPartido
        AND EPL.Goles IS NOT NULL AND EPV.Goles IS NOT NULL
    END
END
GO


-- [CAMBIO] spCatalogos (nuevo)
-- Listas para los combos (ddl) de la app. Regresa siempre IdCatalogo y Descripcion
CREATE OR ALTER PROCEDURE spCatalogos (
    @Accion     INT = NULL,
    @IdFiltro   INT = NULL
)
AS
BEGIN
    -- 1. Equipos activos con su categoría (se puede filtrar por IdCategoria)
    IF @Accion = 1
    BEGIN
        SELECT E.IdEquipo AS IdCatalogo,
               UPPER(E.Nombre) + ' (' + C.Descripcion + ')' AS Descripcion
        FROM EQUIPO E
        INNER JOIN CATEGORIA C ON C.IdCategoria = E.IdCategoria
        WHERE E.IdEstatus = 1
        AND (E.IdCategoria = @IdFiltro OR @IdFiltro IS NULL)
        ORDER BY E.Nombre
    END

    -- 2. Categorías
    IF @Accion = 2
    BEGIN
        SELECT IdCategoria AS IdCatalogo, Descripcion
        FROM CATEGORIA
        ORDER BY IdCategoria
    END

    -- 3. Estadios
    IF @Accion = 3
    BEGIN
        SELECT IdEstadio AS IdCatalogo, Descripcion
        FROM ESTADIO
        ORDER BY Descripcion
    END

    -- 4. Tipos de equipo (LOCAL / VISITANTE)
    IF @Accion = 4
    BEGIN
        SELECT IdTipoEquipo AS IdCatalogo, Descripcion
        FROM TIPO_EQUIPO
        ORDER BY IdTipoEquipo
    END
END
GO

/* =====================================================================
   DBTORNEO - Script de base de datos (v2)
   Evidencia 4 - Programación distribuida
   ---------------------------------------------------------------------
   ADVERTENCIA: este script BORRA y vuelve a crear la base DBTORNEO.
   Ejecútalo completo (F5) en SSMS conectado a tu instancia local.

   Cambios respecto a la v1:
   - Roles ADMINISTRADOR / OBSERVADOR.
   - Login sensible a mayúsculas/minúsculas (COLLATE ..._CS_AS) y sólo
     para usuarios ACTIVO (spUsuario @Accion = 6).
   - Cuenta única (sin distinguir mayúsculas para evitar "Admin"/"ADMIN").
   - Jugador: correo y teléfono únicos. Entrenador: cédula y teléfono únicos.
     Se valida en el SP y además con restricciones UNIQUE.
   - Las consultas generales sólo devuelven registros ACTIVO y traen
     descripciones (JOIN) en lugar de Ids.
   - Todos los SP responden Mensaje + TipoMensaje (success / warning / danger)
     con la misma sintaxis que spCliente (Práctica 3).
   - Parámetro de auditoría homologado: @IdUsuarioAuditor.
   - JUGADOR.IdUsuario / ENTRENADOR.IdUsuario ahora son opcionales.
   ===================================================================== */

USE master
GO

IF DB_ID('DBTORNEO') IS NOT NULL
BEGIN
    ALTER DATABASE DBTORNEO SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DBTORNEO;
END
GO

CREATE DATABASE DBTORNEO
GO

USE DBTORNEO
GO

/* =====================================================================
   CATÁLOGOS
   ===================================================================== */

CREATE TABLE ESTATUS
(
    IdEstatus       INT IDENTITY(1,1)   NOT NULL,
    Descripcion     NVARCHAR(50)        NOT NULL,
    CONSTRAINT PK_IdEstatus PRIMARY KEY (IdEstatus)
);
GO

CREATE TABLE ROL
(
    IdRol           INT IDENTITY(1,1)   NOT NULL,
    Descripcion     NVARCHAR(30)        NOT NULL,
    CONSTRAINT PK_IdRol PRIMARY KEY (IdRol)
);
GO

CREATE TABLE CATEGORIA
(
    IdCategoria     INT IDENTITY(1,1)   NOT NULL,
    Descripcion     NVARCHAR(30)        NOT NULL,
    CONSTRAINT PK_IdCategoria PRIMARY KEY (IdCategoria)
);
GO

CREATE TABLE TIPO_EQUIPO
(
    IdTipoEquipo    INT IDENTITY(1,1)   NOT NULL,
    Descripcion     NVARCHAR(30)        NOT NULL,
    CONSTRAINT PK_IdTipoEquipo PRIMARY KEY (IdTipoEquipo)
);
GO

CREATE TABLE ESTADIO
(
    IdEstadio       INT IDENTITY(1,1)   NOT NULL,
    Descripcion     NVARCHAR(30)        NOT NULL,
    CONSTRAINT PK_IdEstadio PRIMARY KEY (IdEstadio)
);
GO

/* =====================================================================
   USUARIO
   ===================================================================== */

CREATE TABLE USUARIO
(
    IdUsuario           INT IDENTITY(1,1)   NOT NULL,
    IdRol               INT                 NOT NULL,
    IdEstatus           INT                 NOT NULL,
    Cuenta              NVARCHAR(30)        NOT NULL,
    Contrasenia         NVARCHAR(30)        NOT NULL,
    FechaRegistro       DATETIME            NOT NULL CONSTRAINT DF_Usuario_FechaRegistro DEFAULT (GETDATE()),
    UsuarioRegistro     INT                     NULL,   -- NULL sólo para el primer administrador
    FechaModificacion   DATETIME                NULL,
    UsuarioModificacion INT                     NULL,
    FechaBaja           DATETIME                NULL,
    UsuarioBaja         INT                     NULL,
    CONSTRAINT PK_IdUsuario                     PRIMARY KEY (IdUsuario),
    -- La BD es _CI_, así que UNIQUE impide "Admin" y "ADMIN" a la vez.
    CONSTRAINT UQ_Usuario_Cuenta                UNIQUE (Cuenta),
    CONSTRAINT FK_IdEstatus_Usuario             FOREIGN KEY (IdEstatus)           REFERENCES ESTATUS (IdEstatus),
    CONSTRAINT FK_IdRol_Usuario                 FOREIGN KEY (IdRol)               REFERENCES ROL     (IdRol),
    CONSTRAINT FK_UsuarioRegistro_Usuario       FOREIGN KEY (UsuarioRegistro)     REFERENCES USUARIO (IdUsuario),
    CONSTRAINT FK_UsuarioModificacion_Usuario   FOREIGN KEY (UsuarioModificacion) REFERENCES USUARIO (IdUsuario),
    CONSTRAINT FK_UsuarioBaja_Usuario           FOREIGN KEY (UsuarioBaja)         REFERENCES USUARIO (IdUsuario)
);
GO

/* =====================================================================
   EQUIPO
   ===================================================================== */

CREATE TABLE EQUIPO
(
    IdEquipo            INT IDENTITY(1,1)   NOT NULL,
    IdEstatus           INT                 NOT NULL,
    IdCategoria         INT                 NOT NULL,
    Nombre              NVARCHAR(50)        NOT NULL,
    FechaRegistro       DATETIME            NOT NULL,
    UsuarioRegistro     INT                 NOT NULL,
    FechaModificacion   DATETIME                NULL,
    UsuarioModificacion INT                     NULL,
    FechaBaja           DATETIME                NULL,
    UsuarioBaja         INT                     NULL,
    CONSTRAINT PK_IdEquipo                      PRIMARY KEY (IdEquipo),
    CONSTRAINT UQ_Equipo_Nombre                 UNIQUE (Nombre),
    CONSTRAINT FK_IdEstatus_Equipo              FOREIGN KEY (IdEstatus)           REFERENCES ESTATUS   (IdEstatus),
    CONSTRAINT FK_IdCategoria_Equipo            FOREIGN KEY (IdCategoria)         REFERENCES CATEGORIA (IdCategoria),
    CONSTRAINT FK_UsuarioRegistro_Equipo        FOREIGN KEY (UsuarioRegistro)     REFERENCES USUARIO   (IdUsuario),
    CONSTRAINT FK_UsuarioModificacion_Equipo    FOREIGN KEY (UsuarioModificacion) REFERENCES USUARIO   (IdUsuario),
    CONSTRAINT FK_UsuarioBaja_Equipo            FOREIGN KEY (UsuarioBaja)         REFERENCES USUARIO   (IdUsuario)
);
GO

/* =====================================================================
   PARTIDO
   ===================================================================== */

CREATE TABLE PARTIDO
(
    IdPartido           INT IDENTITY(1,1)   NOT NULL,
    IdEstatus           INT                 NOT NULL,
    IdEstadio           INT                 NOT NULL,
    Nombre              NVARCHAR(50)        NOT NULL,
    FechaInicio         DATETIME            NOT NULL,
    FechaFin            DATETIME                NULL,
    Resultado           NVARCHAR(30)            NULL,
    FechaRegistro       DATETIME            NOT NULL,
    UsuarioRegistro     INT                 NOT NULL,
    FechaModificacion   DATETIME                NULL,
    UsuarioModificacion INT                     NULL,
    FechaBaja           DATETIME                NULL,
    UsuarioBaja         INT                     NULL,
    CONSTRAINT PK_IdPartido                     PRIMARY KEY (IdPartido),
    CONSTRAINT CK_Partido_Fechas                CHECK (FechaFin IS NULL OR FechaFin >= FechaInicio),
    CONSTRAINT FK_IdEstatus_Partido             FOREIGN KEY (IdEstatus)           REFERENCES ESTATUS (IdEstatus),
    CONSTRAINT FK_IdEstadio_Partido             FOREIGN KEY (IdEstadio)           REFERENCES ESTADIO (IdEstadio),
    CONSTRAINT FK_UsuarioRegistro_Partido       FOREIGN KEY (UsuarioRegistro)     REFERENCES USUARIO (IdUsuario),
    CONSTRAINT FK_UsuarioModificacion_Partido   FOREIGN KEY (UsuarioModificacion) REFERENCES USUARIO (IdUsuario),
    CONSTRAINT FK_UsuarioBaja_Partido           FOREIGN KEY (UsuarioBaja)         REFERENCES USUARIO (IdUsuario)
);
GO

/* =====================================================================
   JUGADOR
   ===================================================================== */

CREATE TABLE JUGADOR
(
    IdJugador           INT IDENTITY(1,1)   NOT NULL,
    IdEstatus           INT                 NOT NULL,
    IdEquipo            INT                 NOT NULL,
    IdUsuario           INT                     NULL,   -- cuenta vinculada (opcional)
    Nombre              NVARCHAR(80)        NOT NULL,
    PrimerApellido      NVARCHAR(80)        NOT NULL,
    SegundoApellido     NVARCHAR(80)            NULL,
    FechaNacimiento     DATE                NOT NULL,
    Correo              NVARCHAR(50)        NOT NULL,
    Telefono            NVARCHAR(15)        NOT NULL,
    FechaRegistro       DATETIME            NOT NULL,
    UsuarioRegistro     INT                 NOT NULL,
    FechaModificacion   DATETIME                NULL,
    UsuarioModificacion INT                     NULL,
    FechaBaja           DATETIME                NULL,
    UsuarioBaja         INT                     NULL,
    CONSTRAINT PK_IdJugador                     PRIMARY KEY (IdJugador),
    CONSTRAINT UQ_Jugador_Correo                UNIQUE (Correo),
    CONSTRAINT UQ_Jugador_Telefono              UNIQUE (Telefono),
    CONSTRAINT CK_Jugador_Telefono              CHECK (Telefono NOT LIKE '%[^0-9]%' AND LEN(Telefono) BETWEEN 10 AND 15),
    CONSTRAINT CK_Jugador_Correo                CHECK (Correo LIKE '%_@_%._%'),
    CONSTRAINT FK_IdEstatus_Jugador             FOREIGN KEY (IdEstatus)           REFERENCES ESTATUS (IdEstatus),
    CONSTRAINT FK_IdEquipo_Jugador              FOREIGN KEY (IdEquipo)            REFERENCES EQUIPO  (IdEquipo),
    CONSTRAINT FK_IdUsuario_Jugador             FOREIGN KEY (IdUsuario)           REFERENCES USUARIO (IdUsuario),
    CONSTRAINT FK_UsuarioRegistro_Jugador       FOREIGN KEY (UsuarioRegistro)     REFERENCES USUARIO (IdUsuario),
    CONSTRAINT FK_UsuarioModificacion_Jugador   FOREIGN KEY (UsuarioModificacion) REFERENCES USUARIO (IdUsuario),
    CONSTRAINT FK_UsuarioBaja_Jugador           FOREIGN KEY (UsuarioBaja)         REFERENCES USUARIO (IdUsuario)
);
GO

/* =====================================================================
   ENTRENADOR
   ===================================================================== */

CREATE TABLE ENTRENADOR
(
    IdEntrenador        INT IDENTITY(1,1)   NOT NULL,
    IdEstatus           INT                 NOT NULL,
    IdEquipo            INT                 NOT NULL,
    IdUsuario           INT                     NULL,   -- cuenta vinculada (opcional)
    Nombre              NVARCHAR(80)        NOT NULL,
    PrimerApellido      NVARCHAR(80)        NOT NULL,
    SegundoApellido     NVARCHAR(80)            NULL,
    FechaNacimiento     DATE                NOT NULL,
    Cedula              NVARCHAR(50)        NOT NULL,
    Telefono            NVARCHAR(15)        NOT NULL,
    FechaRegistro       DATETIME            NOT NULL,
    UsuarioRegistro     INT                 NOT NULL,
    FechaModificacion   DATETIME                NULL,
    UsuarioModificacion INT                     NULL,
    FechaBaja           DATETIME                NULL,
    UsuarioBaja         INT                     NULL,
    CONSTRAINT PK_IdEntrenador                  PRIMARY KEY (IdEntrenador),
    CONSTRAINT UQ_Entrenador_Cedula             UNIQUE (Cedula),
    CONSTRAINT UQ_Entrenador_Telefono           UNIQUE (Telefono),
    CONSTRAINT CK_Entrenador_Telefono           CHECK (Telefono NOT LIKE '%[^0-9]%' AND LEN(Telefono) BETWEEN 10 AND 15),
    CONSTRAINT FK_IdEstatus_Entrenador          FOREIGN KEY (IdEstatus)           REFERENCES ESTATUS (IdEstatus),
    CONSTRAINT FK_IdEquipo_Entrenador           FOREIGN KEY (IdEquipo)            REFERENCES EQUIPO  (IdEquipo),
    CONSTRAINT FK_IdUsuario_Entrenador          FOREIGN KEY (IdUsuario)           REFERENCES USUARIO (IdUsuario),
    CONSTRAINT FK_UsuarioRegistro_Entrenador    FOREIGN KEY (UsuarioRegistro)     REFERENCES USUARIO (IdUsuario),
    CONSTRAINT FK_UsuarioModificacion_Entrenador FOREIGN KEY (UsuarioModificacion) REFERENCES USUARIO (IdUsuario),
    CONSTRAINT FK_UsuarioBaja_Entrenador        FOREIGN KEY (UsuarioBaja)         REFERENCES USUARIO (IdUsuario)
);
GO

/* =====================================================================
   TABLAS DE RELACIÓN
   ===================================================================== */

CREATE TABLE ESTADISTICA_JUGADOR
(
    IdEstadisticaJugador    INT IDENTITY(1,1)   NOT NULL,
    IdPartido               INT                 NOT NULL,
    IdJugador               INT                 NOT NULL,
    TarjetasAmarillas       INT                     NULL,
    TarjetasRojas           INT                     NULL,
    Asistencias             INT                     NULL,
    GolesAnotados           INT                     NULL,
    GolesAtajados           INT                     NULL,
    MinutosJugados          INT                     NULL,
    CONSTRAINT PK_IdEstadisticaJugador          PRIMARY KEY (IdEstadisticaJugador),
    CONSTRAINT UQ_EstadisticaJugador            UNIQUE (IdPartido, IdJugador),
    CONSTRAINT FK_IdPartido_EstadisticaJugador  FOREIGN KEY (IdPartido) REFERENCES PARTIDO (IdPartido),
    CONSTRAINT FK_IdJugador_EstadisticaJugador  FOREIGN KEY (IdJugador) REFERENCES JUGADOR (IdJugador)
);
GO

CREATE TABLE EQUIPO_PARTIDO
(
    IdEquipoPartido         INT IDENTITY(1,1)   NOT NULL,
    IdPartido               INT                 NOT NULL,
    IdEquipo                INT                 NOT NULL,
    IdTipoEquipo            INT                 NOT NULL,
    Goles                   INT                     NULL,
    CONSTRAINT PK_IdEquipoPartido               PRIMARY KEY (IdEquipoPartido),
    CONSTRAINT UQ_EquipoPartido                 UNIQUE (IdPartido, IdEquipo),
    CONSTRAINT FK_IdPartido_EquipoPartido       FOREIGN KEY (IdPartido)    REFERENCES PARTIDO     (IdPartido),
    CONSTRAINT FK_IdEquipo_EquipoPartido        FOREIGN KEY (IdEquipo)     REFERENCES EQUIPO      (IdEquipo),
    CONSTRAINT FK_IdTipoEquipo_EquipoPartido    FOREIGN KEY (IdTipoEquipo) REFERENCES TIPO_EQUIPO (IdTipoEquipo)
);
GO

/* =====================================================================
   DATOS INICIALES
   ===================================================================== */

INSERT INTO ESTATUS (Descripcion) VALUES ('ACTIVO'), ('INACTIVO');          -- 1, 2
INSERT INTO ROL     (Descripcion) VALUES ('ADMINISTRADOR'), ('OBSERVADOR');  -- 1, 2
INSERT INTO CATEGORIA (Descripcion) VALUES ('JUVENIL'), ('AMATEUR'), ('PROFESIONAL');
INSERT INTO TIPO_EQUIPO (Descripcion) VALUES ('LOCAL'), ('VISITANTE');
INSERT INTO ESTADIO (Descripcion)
VALUES ('ESTADIO 1'), ('ESTADIO 2'), ('ESTADIO 3'), ('ESTADIO 4'), ('ESTADIO 5'), ('ESTADIO 6');
GO

-- Usuarios de prueba (la contraseña distingue mayúsculas/minúsculas).
--   Admin / Admin123       -> ADMINISTRADOR
--   Observador / Obs123    -> OBSERVADOR
--   Inactivo / Inactivo123 -> OBSERVADOR dado de baja (para probar el login)
INSERT INTO USUARIO (IdRol, IdEstatus, Cuenta, Contrasenia, FechaRegistro, UsuarioRegistro)
VALUES (1, 1, 'Admin', 'Admin123', GETDATE(), NULL);

INSERT INTO USUARIO (IdRol, IdEstatus, Cuenta, Contrasenia, FechaRegistro, UsuarioRegistro)
VALUES (2, 1, 'Observador', 'Obs123',      GETDATE(), 1),
       (2, 2, 'Inactivo',   'Inactivo123', GETDATE(), 1);

UPDATE USUARIO SET FechaBaja = GETDATE(), UsuarioBaja = 1 WHERE Cuenta = 'Inactivo';
GO

-- Equipos de prueba (necesarios para asignar jugadores y entrenadores).
INSERT INTO EQUIPO (IdEstatus, IdCategoria, Nombre, FechaRegistro, UsuarioRegistro)
VALUES (1, 3, 'HALCONES FC',       GETDATE(), 1),
       (1, 3, 'LOBOS UNIDOS',      GETDATE(), 1),
       (1, 2, 'DEPORTIVO SIERRA',  GETDATE(), 1),
       (1, 1, 'JAGUARES JUVENIL',  GETDATE(), 1);
GO

-- Jugadores y entrenadores de ejemplo (datos ficticios).
INSERT INTO JUGADOR (IdEstatus, IdEquipo, Nombre, PrimerApellido, SegundoApellido, FechaNacimiento, Correo, Telefono, FechaRegistro, UsuarioRegistro)
VALUES (1, 1, 'CARLOS', 'MENDOZA', 'RUIZ',   '2001-03-14', 'carlos.mendoza@ejemplo.com', '8110000001', GETDATE(), 1),
       (1, 2, 'LUIS',   'GARZA',   NULL,     '1999-11-02', 'luis.garza@ejemplo.com',     '8110000002', GETDATE(), 1),
       (1, 3, 'ANDRÉS', 'TREVIÑO', 'SALAS',  '2003-07-21', 'andres.trevino@ejemplo.com', '8110000003', GETDATE(), 1);

INSERT INTO ENTRENADOR (IdEstatus, IdEquipo, Nombre, PrimerApellido, SegundoApellido, FechaNacimiento, Cedula, Telefono, FechaRegistro, UsuarioRegistro)
VALUES (1, 1, 'JORGE',  'VILLARREAL', 'CANTÚ', '1978-05-09', 'CED-0001', '8120000001', GETDATE(), 1),
       (1, 2, 'MARTHA', 'LEAL',       NULL,    '1983-01-30', 'CED-0002', '8120000002', GETDATE(), 1);
GO
/* =====================================================================
   PROCEDIMIENTOS ALMACENADOS
   @Accion: 1 = Crear | 2 = Leer un registro | 3 = Consulta general
            4 = Modificar | 5 = Eliminar (baja lógica) | 6 = Iniciar sesión
   ===================================================================== */

-- spUsuario
CREATE OR ALTER PROCEDURE [dbo].[spUsuario]
(
	@Accion				INT			 = NULL,
	@IdUsuario			INT			 = NULL,
	@IdRol				INT			 = NULL,
	@Cuenta				NVARCHAR(30) = NULL,
	@Contrasenia		NVARCHAR(30) = NULL,
	@IdUsuarioAuditor	INT			 = NULL
)
AS
BEGIN
	-- Crear un nuevo registro
	IF @Accion = 1
	BEGIN
		-- Validar que la cuenta no exista (sin importar mayúsculas: no puede haber "Admin" y "ADMIN")
		IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE Cuenta = TRIM(@Cuenta))
		BEGIN
			INSERT INTO USUARIO(IdRol, IdEstatus, Cuenta, Contrasenia, FechaRegistro, UsuarioRegistro)
			VALUES
			(
				@IdRol,
				1,
				TRIM(@Cuenta),
				@Contrasenia,
				GETDATE(),
				@IdUsuarioAuditor
			)

			SELECT 'Usuario registrado correctamente' AS Mensaje, 'success' AS TipoMensaje
		END
		ELSE
		BEGIN
			SELECT 'La cuenta ya está ocupada por otro usuario' AS Mensaje, 'warning' AS TipoMensaje
		END
	END

	-- Leer un registro
	IF @Accion = 2
	BEGIN
		SELECT	IdUsuario,
				IdRol,
				IdEstatus,
				Cuenta,
				Contrasenia
		FROM	USUARIO
		WHERE	IdUsuario = @IdUsuario
	END

	-- Consulta general (sólo activos)
	IF @Accion = 3
	BEGIN
		SELECT	U.IdUsuario AS Id,
				U.Cuenta,
				R.Descripcion AS Rol
		FROM	USUARIO U
		INNER JOIN ROL R ON R.IdRol = U.IdRol
		WHERE	U.IdEstatus = 1
		AND		(U.Cuenta LIKE '%' + @Cuenta + '%' OR @Cuenta IS NULL)
		ORDER BY U.Cuenta
	END

	-- Modificar un registro seleccionado
	IF @Accion = 4
	BEGIN
		-- Valida que al editar la cuenta no esté guardada con otro usuario
		IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE Cuenta = TRIM(@Cuenta) AND IdUsuario != @IdUsuario)
		BEGIN
			UPDATE	USUARIO
			SET		IdRol				= @IdRol,
					Cuenta				= TRIM(@Cuenta),
					Contrasenia			= @Contrasenia,
					FechaModificacion	= GETDATE(),
					UsuarioModificacion	= @IdUsuarioAuditor
			WHERE	IdUsuario			= @IdUsuario

			SELECT 'Registro modificado' AS Mensaje, 'success' AS TipoMensaje
		END
		ELSE
		BEGIN
			SELECT 'La cuenta ya está ocupada por otro usuario' AS Mensaje, 'warning' AS TipoMensaje
		END
	END

	-- Eliminar el registro (baja lógica)
	IF @Accion = 5
	BEGIN
		IF @IdUsuario = @IdUsuarioAuditor
		BEGIN
			SELECT 'No puedes darte de baja a ti mismo' AS Mensaje, 'warning' AS TipoMensaje
		END
		ELSE
		BEGIN
			UPDATE	USUARIO
			SET		IdEstatus	= 2,
					FechaBaja	= GETDATE(),
					UsuarioBaja	= @IdUsuarioAuditor
			WHERE	IdUsuario	= @IdUsuario

			SELECT 'Registro eliminado' AS Mensaje, 'success' AS TipoMensaje
		END
	END

	-- Iniciar sesión
	IF @Accion = 6
	BEGIN
		-- COLLATE ..._CS_AS hace que la comparación distinga mayúsculas y minúsculas
		IF NOT EXISTS (SELECT 1 FROM USUARIO
					   WHERE Cuenta		 COLLATE Modern_Spanish_CS_AS = @Cuenta
					   AND	 Contrasenia COLLATE Modern_Spanish_CS_AS = @Contrasenia)
		BEGIN
			SELECT 'Usuario o contraseña incorrectos' AS Mensaje, 'danger' AS TipoMensaje
		END
		-- Validar que el usuario esté en estatus ACTIVO
		ELSE IF EXISTS (SELECT 1 FROM USUARIO
						WHERE Cuenta	  COLLATE Modern_Spanish_CS_AS = @Cuenta
						AND	  Contrasenia COLLATE Modern_Spanish_CS_AS = @Contrasenia
						AND	  IdEstatus != 1)
		BEGIN
			SELECT 'El usuario está inactivo' AS Mensaje, 'warning' AS TipoMensaje
		END
		ELSE
		BEGIN
			SELECT	'Bienvenido' AS Mensaje,
					'success' AS TipoMensaje,
					U.IdUsuario,
					U.Cuenta,
					R.Descripcion AS Rol
			FROM	USUARIO U
			INNER JOIN ROL R ON R.IdRol = U.IdRol
			WHERE	U.Cuenta	  COLLATE Modern_Spanish_CS_AS = @Cuenta
			AND		U.Contrasenia COLLATE Modern_Spanish_CS_AS = @Contrasenia
		END
	END
END
GO

-- spEquipo
CREATE OR ALTER PROCEDURE [dbo].[spEquipo]
(
	@Accion				INT			 = NULL,
	@IdEquipo			INT			 = NULL,
	@IdCategoria		INT			 = NULL,
	@Nombre				NVARCHAR(50) = NULL,
	@IdUsuarioAuditor	INT			 = NULL
)
AS
BEGIN
	-- Crear un nuevo registro
	IF @Accion = 1
	BEGIN
		-- Validar que el nombre no esté ocupado por otro equipo
		IF NOT EXISTS (SELECT 1 FROM EQUIPO WHERE Nombre = UPPER(TRIM(@Nombre)))
		BEGIN
			INSERT INTO EQUIPO(IdEstatus, IdCategoria, Nombre, FechaRegistro, UsuarioRegistro)
			VALUES
			(
				1,
				@IdCategoria,
				UPPER(TRIM(@Nombre)),
				GETDATE(),
				@IdUsuarioAuditor
			)

			SELECT 'Registrado correctamente' AS Mensaje, 'success' AS TipoMensaje
		END
		ELSE
		BEGIN
			SELECT 'El nombre ya está ocupado por otro equipo' AS Mensaje, 'warning' AS TipoMensaje
		END
	END

	-- Leer un registro
	IF @Accion = 2
	BEGIN
		SELECT	IdEquipo,
				IdCategoria,
				Nombre
		FROM	EQUIPO
		WHERE	IdEquipo = @IdEquipo
	END

	-- Consulta general (sólo activos, con la descripción de la categoría)
	IF @Accion = 3
	BEGIN
		SELECT	E.IdEquipo AS Id,
				E.Nombre AS Equipo,
				C.Descripcion AS Categoria
		FROM	EQUIPO E
		INNER JOIN CATEGORIA C ON C.IdCategoria = E.IdCategoria
		WHERE	E.IdEstatus = 1
		AND		(E.Nombre LIKE '%' + @Nombre + '%' OR @Nombre IS NULL)
		ORDER BY Equipo
	END

	-- Modificar un registro seleccionado
	IF @Accion = 4
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM EQUIPO WHERE Nombre = UPPER(TRIM(@Nombre)) AND IdEquipo != @IdEquipo)
		BEGIN
			UPDATE	EQUIPO
			SET		IdCategoria			= @IdCategoria,
					Nombre				= UPPER(TRIM(@Nombre)),
					FechaModificacion	= GETDATE(),
					UsuarioModificacion	= @IdUsuarioAuditor
			WHERE	IdEquipo			= @IdEquipo

			SELECT 'Registro modificado' AS Mensaje, 'success' AS TipoMensaje
		END
		ELSE
		BEGIN
			SELECT 'El nombre ya está ocupado por otro equipo' AS Mensaje, 'warning' AS TipoMensaje
		END
	END

	-- Eliminar el registro (baja lógica)
	IF @Accion = 5
	BEGIN
		-- No se puede dar de baja si tiene jugadores o entrenadores activos
		IF EXISTS (SELECT 1 FROM JUGADOR	WHERE IdEquipo = @IdEquipo AND IdEstatus = 1)
		OR EXISTS (SELECT 1 FROM ENTRENADOR WHERE IdEquipo = @IdEquipo AND IdEstatus = 1)
		BEGIN
			SELECT 'El equipo tiene jugadores o entrenadores activos' AS Mensaje, 'warning' AS TipoMensaje
		END
		ELSE
		BEGIN
			UPDATE	EQUIPO
			SET		IdEstatus	= 2,
					FechaBaja	= GETDATE(),
					UsuarioBaja	= @IdUsuarioAuditor
			WHERE	IdEquipo	= @IdEquipo

			SELECT 'Registro eliminado' AS Mensaje, 'success' AS TipoMensaje
		END
	END
END
GO

-- spJugador
CREATE OR ALTER PROCEDURE [dbo].[spJugador]
(
	@Accion				INT			 = NULL,
	@IdJugador			INT			 = NULL,
	@IdEquipo			INT			 = NULL,
	@Nombre				NVARCHAR(80) = NULL,
	@PrimerApellido		NVARCHAR(80) = NULL,
	@SegundoApellido	NVARCHAR(80) = NULL,
	@FechaNacimiento	DATE		 = NULL,
	@Correo				NVARCHAR(50) = NULL,
	@Telefono			NVARCHAR(15) = NULL,
	@Buscar				NVARCHAR(80) = NULL,
	@IdUsuarioAuditor	INT			 = NULL
)
AS
BEGIN
	-- Validaciones para registrar (1) y modificar (4)
	IF @Accion IN (1, 4)
	BEGIN
		DECLARE @Aviso NVARCHAR(100) = NULL

		-- Campos obligatorios
		IF NULLIF(TRIM(@Nombre), '') IS NULL OR NULLIF(TRIM(@PrimerApellido), '') IS NULL
		OR NULLIF(TRIM(@Correo), '') IS NULL OR NULLIF(TRIM(@Telefono), '') IS NULL
		OR @FechaNacimiento IS NULL
			SET @Aviso = 'Captura todos los campos obligatorios'
		-- La fecha de nacimiento debe ser anterior a hoy
		ELSE IF @FechaNacimiento >= CAST(GETDATE() AS DATE)
			SET @Aviso = 'La fecha de nacimiento debe ser anterior a hoy'
		-- El teléfono sólo lleva números (10 a 15)
		ELSE IF TRIM(@Telefono) LIKE '%[^0-9]%' OR LEN(TRIM(@Telefono)) NOT BETWEEN 10 AND 15
			SET @Aviso = 'El teléfono debe tener sólo números (10 a 15 dígitos)'
		-- El equipo debe existir y estar activo
		ELSE IF NOT EXISTS (SELECT 1 FROM EQUIPO WHERE IdEquipo = @IdEquipo AND IdEstatus = 1)
			SET @Aviso = 'Selecciona un equipo válido'
		-- Validar que el correo no esté previamente con otro jugador
		ELSE IF EXISTS (SELECT 1 FROM JUGADOR WHERE Correo = LOWER(TRIM(@Correo)) AND IdJugador != ISNULL(@IdJugador, 0))
			SET @Aviso = 'El correo ya está ocupado por otro jugador'
		-- Validar que el teléfono no esté previamente con otro jugador
		ELSE IF EXISTS (SELECT 1 FROM JUGADOR WHERE Telefono = TRIM(@Telefono) AND IdJugador != ISNULL(@IdJugador, 0))
			SET @Aviso = 'El teléfono ya está ocupado por otro jugador'

		IF @Aviso IS NOT NULL
		BEGIN
			SELECT @Aviso AS Mensaje, 'warning' AS TipoMensaje
			RETURN
		END
	END

	-- Crear un nuevo registro
	IF @Accion = 1
	BEGIN
		INSERT INTO JUGADOR(IdEstatus, IdEquipo, Nombre, PrimerApellido, SegundoApellido,
							FechaNacimiento, Correo, Telefono, FechaRegistro, UsuarioRegistro)
		VALUES
		(
			1,
			@IdEquipo,
			UPPER(TRIM(@Nombre)),
			UPPER(TRIM(@PrimerApellido)),
			NULLIF(UPPER(TRIM(@SegundoApellido)), ''),
			@FechaNacimiento,
			LOWER(TRIM(@Correo)),
			TRIM(@Telefono),
			GETDATE(),
			@IdUsuarioAuditor
		)

		SELECT 'Registrado correctamente' AS Mensaje, 'success' AS TipoMensaje
	END

	-- Leer un registro
	IF @Accion = 2
	BEGIN
		SELECT	IdJugador,
				IdEquipo,
				Nombre,
				PrimerApellido,
				SegundoApellido,
				FechaNacimiento,
				Correo,
				Telefono
		FROM	JUGADOR
		WHERE	IdJugador = @IdJugador
		AND		IdEstatus = 1
	END

	-- Consulta general (sólo activos, sin Ids: el equipo y la categoría van por JOIN)
	IF @Accion = 3
	BEGIN
		SELECT	J.IdJugador AS Id,
				CONCAT_WS(' ', J.PrimerApellido, J.SegundoApellido, J.Nombre) AS Jugador,
				E.Nombre AS Equipo,
				C.Descripcion AS Categoria,
				CONVERT(VARCHAR(10), J.FechaNacimiento, 103) AS FechaNacimiento,
				DATEDIFF(YEAR, J.FechaNacimiento, GETDATE())
					- CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, J.FechaNacimiento, GETDATE()), J.FechaNacimiento) > GETDATE()
						   THEN 1 ELSE 0 END AS Edad,
				J.Correo,
				J.Telefono
		FROM	JUGADOR J
		INNER JOIN EQUIPO	 E ON E.IdEquipo	= J.IdEquipo
		INNER JOIN CATEGORIA C ON C.IdCategoria = E.IdCategoria
		WHERE	J.IdEstatus = 1
		AND		(CONCAT_WS(' ', J.Nombre, J.PrimerApellido, J.SegundoApellido) LIKE '%' + TRIM(@Buscar) + '%'
				 OR J.Correo   LIKE '%' + TRIM(@Buscar) + '%'
				 OR J.Telefono LIKE '%' + TRIM(@Buscar) + '%'
				 OR E.Nombre   LIKE '%' + TRIM(@Buscar) + '%'
				 OR NULLIF(TRIM(@Buscar), '') IS NULL)
		ORDER BY Jugador
	END

	-- Modificar un registro seleccionado
	IF @Accion = 4
	BEGIN
		UPDATE	JUGADOR
		SET		IdEquipo			= @IdEquipo,
				Nombre				= UPPER(TRIM(@Nombre)),
				PrimerApellido		= UPPER(TRIM(@PrimerApellido)),
				SegundoApellido		= NULLIF(UPPER(TRIM(@SegundoApellido)), ''),
				FechaNacimiento		= @FechaNacimiento,
				Correo				= LOWER(TRIM(@Correo)),
				Telefono			= TRIM(@Telefono),
				FechaModificacion	= GETDATE(),
				UsuarioModificacion	= @IdUsuarioAuditor
		WHERE	IdJugador			= @IdJugador
		AND		IdEstatus			= 1

		SELECT 'Registro modificado' AS Mensaje, 'success' AS TipoMensaje
	END

	-- Eliminar el registro (baja lógica)
	IF @Accion = 5
	BEGIN
		UPDATE	JUGADOR
		SET		IdEstatus	= 2,
				FechaBaja	= GETDATE(),
				UsuarioBaja	= @IdUsuarioAuditor
		WHERE	IdJugador	= @IdJugador

		SELECT 'Registro eliminado' AS Mensaje, 'success' AS TipoMensaje
	END
END
GO

-- spEntrenador
CREATE OR ALTER PROCEDURE [dbo].[spEntrenador]
(
	@Accion				INT			 = NULL,
	@IdEntrenador		INT			 = NULL,
	@IdEquipo			INT			 = NULL,
	@Nombre				NVARCHAR(80) = NULL,
	@PrimerApellido		NVARCHAR(80) = NULL,
	@SegundoApellido	NVARCHAR(80) = NULL,
	@FechaNacimiento	DATE		 = NULL,
	@Cedula				NVARCHAR(50) = NULL,
	@Telefono			NVARCHAR(15) = NULL,
	@Buscar				NVARCHAR(80) = NULL,
	@IdUsuarioAuditor	INT			 = NULL
)
AS
BEGIN
	-- Validaciones para registrar (1) y modificar (4)
	IF @Accion IN (1, 4)
	BEGIN
		DECLARE @Aviso NVARCHAR(100) = NULL

		-- Campos obligatorios
		IF NULLIF(TRIM(@Nombre), '') IS NULL OR NULLIF(TRIM(@PrimerApellido), '') IS NULL
		OR NULLIF(TRIM(@Cedula), '') IS NULL OR NULLIF(TRIM(@Telefono), '') IS NULL
		OR @FechaNacimiento IS NULL
			SET @Aviso = 'Captura todos los campos obligatorios'
		-- La fecha de nacimiento debe ser anterior a hoy
		ELSE IF @FechaNacimiento >= CAST(GETDATE() AS DATE)
			SET @Aviso = 'La fecha de nacimiento debe ser anterior a hoy'
		-- El teléfono sólo lleva números (10 a 15)
		ELSE IF TRIM(@Telefono) LIKE '%[^0-9]%' OR LEN(TRIM(@Telefono)) NOT BETWEEN 10 AND 15
			SET @Aviso = 'El teléfono debe tener sólo números (10 a 15 dígitos)'
		-- El equipo debe existir y estar activo
		ELSE IF NOT EXISTS (SELECT 1 FROM EQUIPO WHERE IdEquipo = @IdEquipo AND IdEstatus = 1)
			SET @Aviso = 'Selecciona un equipo válido'
		-- Validar que la cédula no esté previamente con otro entrenador
		ELSE IF EXISTS (SELECT 1 FROM ENTRENADOR WHERE Cedula = UPPER(TRIM(@Cedula)) AND IdEntrenador != ISNULL(@IdEntrenador, 0))
			SET @Aviso = 'La cédula ya está ocupada por otro entrenador'
		-- Validar que el teléfono no esté previamente con otro entrenador
		ELSE IF EXISTS (SELECT 1 FROM ENTRENADOR WHERE Telefono = TRIM(@Telefono) AND IdEntrenador != ISNULL(@IdEntrenador, 0))
			SET @Aviso = 'El teléfono ya está ocupado por otro entrenador'

		IF @Aviso IS NOT NULL
		BEGIN
			SELECT @Aviso AS Mensaje, 'warning' AS TipoMensaje
			RETURN
		END
	END

	-- Crear un nuevo registro
	IF @Accion = 1
	BEGIN
		INSERT INTO ENTRENADOR(IdEstatus, IdEquipo, Nombre, PrimerApellido, SegundoApellido,
							   FechaNacimiento, Cedula, Telefono, FechaRegistro, UsuarioRegistro)
		VALUES
		(
			1,
			@IdEquipo,
			UPPER(TRIM(@Nombre)),
			UPPER(TRIM(@PrimerApellido)),
			NULLIF(UPPER(TRIM(@SegundoApellido)), ''),
			@FechaNacimiento,
			UPPER(TRIM(@Cedula)),
			TRIM(@Telefono),
			GETDATE(),
			@IdUsuarioAuditor
		)

		SELECT 'Registrado correctamente' AS Mensaje, 'success' AS TipoMensaje
	END

	-- Leer un registro
	IF @Accion = 2
	BEGIN
		SELECT	IdEntrenador,
				IdEquipo,
				Nombre,
				PrimerApellido,
				SegundoApellido,
				FechaNacimiento,
				Cedula,
				Telefono
		FROM	ENTRENADOR
		WHERE	IdEntrenador = @IdEntrenador
		AND		IdEstatus	 = 1
	END

	-- Consulta general (sólo activos, sin Ids: el equipo y la categoría van por JOIN)
	IF @Accion = 3
	BEGIN
		SELECT	T.IdEntrenador AS Id,
				CONCAT_WS(' ', T.PrimerApellido, T.SegundoApellido, T.Nombre) AS Entrenador,
				E.Nombre AS Equipo,
				C.Descripcion AS Categoria,
				CONVERT(VARCHAR(10), T.FechaNacimiento, 103) AS FechaNacimiento,
				DATEDIFF(YEAR, T.FechaNacimiento, GETDATE())
					- CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, T.FechaNacimiento, GETDATE()), T.FechaNacimiento) > GETDATE()
						   THEN 1 ELSE 0 END AS Edad,
				T.Cedula,
				T.Telefono
		FROM	ENTRENADOR T
		INNER JOIN EQUIPO	 E ON E.IdEquipo	= T.IdEquipo
		INNER JOIN CATEGORIA C ON C.IdCategoria = E.IdCategoria
		WHERE	T.IdEstatus = 1
		AND		(CONCAT_WS(' ', T.Nombre, T.PrimerApellido, T.SegundoApellido) LIKE '%' + TRIM(@Buscar) + '%'
				 OR T.Cedula   LIKE '%' + TRIM(@Buscar) + '%'
				 OR T.Telefono LIKE '%' + TRIM(@Buscar) + '%'
				 OR E.Nombre   LIKE '%' + TRIM(@Buscar) + '%'
				 OR NULLIF(TRIM(@Buscar), '') IS NULL)
		ORDER BY Entrenador
	END

	-- Modificar un registro seleccionado
	IF @Accion = 4
	BEGIN
		UPDATE	ENTRENADOR
		SET		IdEquipo			= @IdEquipo,
				Nombre				= UPPER(TRIM(@Nombre)),
				PrimerApellido		= UPPER(TRIM(@PrimerApellido)),
				SegundoApellido		= NULLIF(UPPER(TRIM(@SegundoApellido)), ''),
				FechaNacimiento		= @FechaNacimiento,
				Cedula				= UPPER(TRIM(@Cedula)),
				Telefono			= TRIM(@Telefono),
				FechaModificacion	= GETDATE(),
				UsuarioModificacion	= @IdUsuarioAuditor
		WHERE	IdEntrenador		= @IdEntrenador
		AND		IdEstatus			= 1

		SELECT 'Registro modificado' AS Mensaje, 'success' AS TipoMensaje
	END

	-- Eliminar el registro (baja lógica)
	IF @Accion = 5
	BEGIN
		UPDATE	ENTRENADOR
		SET		IdEstatus	 = 2,
				FechaBaja	 = GETDATE(),
				UsuarioBaja	 = @IdUsuarioAuditor
		WHERE	IdEntrenador = @IdEntrenador

		SELECT 'Registro eliminado' AS Mensaje, 'success' AS TipoMensaje
	END
END
GO

-- spPartido
CREATE OR ALTER PROCEDURE [dbo].[spPartido]
(
	@Accion				INT			 = NULL,
	@IdPartido			INT			 = NULL,
	@IdEstadio			INT			 = NULL,
	@Nombre				NVARCHAR(50) = NULL,
	@FechaInicio		DATETIME	 = NULL,
	@FechaFin			DATETIME	 = NULL,
	@Resultado			NVARCHAR(30) = NULL,
	@IdUsuarioAuditor	INT			 = NULL
)
AS
BEGIN
	-- Crear un nuevo registro
	IF @Accion = 1
	BEGIN
		-- Validar que el nombre no esté ocupado por otro partido
		IF NOT EXISTS (SELECT 1 FROM PARTIDO WHERE Nombre = UPPER(TRIM(@Nombre)))
		BEGIN
			INSERT INTO PARTIDO(IdEstatus, IdEstadio, Nombre, FechaInicio, FechaFin, Resultado, FechaRegistro, UsuarioRegistro)
			VALUES
			(
				1,
				@IdEstadio,
				UPPER(TRIM(@Nombre)),
				@FechaInicio,
				@FechaFin,
				NULLIF(UPPER(TRIM(@Resultado)), ''),
				GETDATE(),
				@IdUsuarioAuditor
			)

			SELECT 'Registrado correctamente' AS Mensaje, 'success' AS TipoMensaje
		END
		ELSE
		BEGIN
			SELECT 'El nombre ya está ocupado por otro partido' AS Mensaje, 'warning' AS TipoMensaje
		END
	END

	-- Leer un registro
	IF @Accion = 2
	BEGIN
		SELECT	IdPartido,
				IdEstadio,
				Nombre,
				FechaInicio,
				FechaFin,
				Resultado
		FROM	PARTIDO
		WHERE	IdPartido = @IdPartido
	END

	-- Consulta general (sólo activos, con la descripción del estadio)
	IF @Accion = 3
	BEGIN
		SELECT	P.IdPartido AS Id,
				P.Nombre AS Partido,
				S.Descripcion AS Estadio,
				P.FechaInicio,
				P.FechaFin,
				P.Resultado
		FROM	PARTIDO P
		INNER JOIN ESTADIO S ON S.IdEstadio = P.IdEstadio
		WHERE	P.IdEstatus = 1
		AND		(P.Nombre LIKE '%' + @Nombre + '%' OR @Nombre IS NULL)
		ORDER BY P.FechaInicio DESC
	END

	-- Modificar un registro seleccionado
	IF @Accion = 4
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM PARTIDO WHERE Nombre = UPPER(TRIM(@Nombre)) AND IdPartido != @IdPartido)
		BEGIN
			UPDATE	PARTIDO
			SET		IdEstadio			= @IdEstadio,
					Nombre				= UPPER(TRIM(@Nombre)),
					FechaInicio			= @FechaInicio,
					FechaFin			= @FechaFin,
					Resultado			= NULLIF(UPPER(TRIM(@Resultado)), ''),
					FechaModificacion	= GETDATE(),
					UsuarioModificacion	= @IdUsuarioAuditor
			WHERE	IdPartido			= @IdPartido

			SELECT 'Registro modificado' AS Mensaje, 'success' AS TipoMensaje
		END
		ELSE
		BEGIN
			SELECT 'El nombre ya está ocupado por otro partido' AS Mensaje, 'warning' AS TipoMensaje
		END
	END

	-- Eliminar el registro (baja lógica)
	IF @Accion = 5
	BEGIN
		UPDATE	PARTIDO
		SET		IdEstatus	= 2,
				FechaBaja	= GETDATE(),
				UsuarioBaja	= @IdUsuarioAuditor
		WHERE	IdPartido	= @IdPartido

		SELECT 'Registro eliminado' AS Mensaje, 'success' AS TipoMensaje
	END
END
GO

-- spEstadisticaJugador
CREATE OR ALTER PROCEDURE [dbo].[spEstadisticaJugador]
(
	@Accion					INT = NULL,
	@IdEstadisticaJugador	INT = NULL,
	@IdPartido				INT = NULL,
	@IdJugador				INT = NULL,
	@TarjetasAmarillas		INT = NULL,
	@TarjetasRojas			INT = NULL,
	@Asistencias			INT = NULL,
	@GolesAnotados			INT = NULL,
	@GolesAtajados			INT = NULL,
	@MinutosJugados			INT = NULL
)
AS
BEGIN
	-- Crear un nuevo registro
	IF @Accion = 1
	BEGIN
		-- Validar que el jugador no tenga estadísticas en ese partido
		IF NOT EXISTS (SELECT 1 FROM ESTADISTICA_JUGADOR WHERE IdPartido = @IdPartido AND IdJugador = @IdJugador)
		BEGIN
			INSERT INTO ESTADISTICA_JUGADOR(IdPartido, IdJugador, TarjetasAmarillas, TarjetasRojas,
											Asistencias, GolesAnotados, GolesAtajados, MinutosJugados)
			VALUES (@IdPartido, @IdJugador, @TarjetasAmarillas, @TarjetasRojas,
					@Asistencias, @GolesAnotados, @GolesAtajados, @MinutosJugados)

			SELECT 'Registrado correctamente' AS Mensaje, 'success' AS TipoMensaje
		END
		ELSE
		BEGIN
			SELECT 'El jugador ya tiene estadísticas en este partido' AS Mensaje, 'warning' AS TipoMensaje
		END
	END

	-- Leer un registro
	IF @Accion = 2
	BEGIN
		SELECT	IdEstadisticaJugador, IdPartido, IdJugador, TarjetasAmarillas, TarjetasRojas,
				Asistencias, GolesAnotados, GolesAtajados, MinutosJugados
		FROM	ESTADISTICA_JUGADOR
		WHERE	IdEstadisticaJugador = @IdEstadisticaJugador
	END

	-- Consulta general (con nombres en lugar de Ids)
	IF @Accion = 3
	BEGIN
		SELECT	EJ.IdEstadisticaJugador AS Id,
				P.Nombre AS Partido,
				CONCAT_WS(' ', J.PrimerApellido, J.SegundoApellido, J.Nombre) AS Jugador,
				EJ.GolesAnotados, EJ.Asistencias, EJ.TarjetasAmarillas, EJ.TarjetasRojas,
				EJ.GolesAtajados, EJ.MinutosJugados
		FROM	ESTADISTICA_JUGADOR EJ
		INNER JOIN PARTIDO P ON P.IdPartido = EJ.IdPartido
		INNER JOIN JUGADOR J ON J.IdJugador = EJ.IdJugador
		WHERE	(EJ.IdPartido = @IdPartido OR @IdPartido IS NULL)
	END

	-- Modificar un registro seleccionado
	IF @Accion = 4
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM ESTADISTICA_JUGADOR WHERE IdPartido = @IdPartido AND IdJugador = @IdJugador
					   AND IdEstadisticaJugador != @IdEstadisticaJugador)
		BEGIN
			UPDATE	ESTADISTICA_JUGADOR
			SET		IdPartido			= @IdPartido,
					IdJugador			= @IdJugador,
					TarjetasAmarillas	= @TarjetasAmarillas,
					TarjetasRojas		= @TarjetasRojas,
					Asistencias			= @Asistencias,
					GolesAnotados		= @GolesAnotados,
					GolesAtajados		= @GolesAtajados,
					MinutosJugados		= @MinutosJugados
			WHERE	IdEstadisticaJugador = @IdEstadisticaJugador

			SELECT 'Registro modificado' AS Mensaje, 'success' AS TipoMensaje
		END
		ELSE
		BEGIN
			SELECT 'El jugador ya tiene estadísticas en este partido' AS Mensaje, 'warning' AS TipoMensaje
		END
	END

	-- Eliminar el registro (tabla de detalle sin estatus: baja física)
	IF @Accion = 5
	BEGIN
		DELETE
		FROM	ESTADISTICA_JUGADOR
		WHERE	IdEstadisticaJugador = @IdEstadisticaJugador

		SELECT 'Registro eliminado' AS Mensaje, 'success' AS TipoMensaje
	END
END
GO

-- spEquipoPartido
CREATE OR ALTER PROCEDURE [dbo].[spEquipoPartido]
(
	@Accion				INT = NULL,
	@IdEquipoPartido	INT = NULL,
	@IdPartido			INT = NULL,
	@IdEquipo			INT = NULL,
	@IdTipoEquipo		INT = NULL,
	@Goles				INT = NULL
)
AS
BEGIN
	-- Crear un nuevo registro
	IF @Accion = 1
	BEGIN
		-- Validar que el equipo no esté ya en ese partido
		IF NOT EXISTS (SELECT 1 FROM EQUIPO_PARTIDO WHERE IdPartido = @IdPartido AND IdEquipo = @IdEquipo)
		BEGIN
			INSERT INTO EQUIPO_PARTIDO(IdPartido, IdEquipo, IdTipoEquipo, Goles)
			VALUES (@IdPartido, @IdEquipo, @IdTipoEquipo, @Goles)

			SELECT 'Registrado correctamente' AS Mensaje, 'success' AS TipoMensaje
		END
		ELSE
		BEGIN
			SELECT 'El equipo ya está registrado en este partido' AS Mensaje, 'warning' AS TipoMensaje
		END
	END

	-- Leer un registro
	IF @Accion = 2
	BEGIN
		SELECT	IdEquipoPartido, IdPartido, IdEquipo, IdTipoEquipo, Goles
		FROM	EQUIPO_PARTIDO
		WHERE	IdEquipoPartido = @IdEquipoPartido
	END

	-- Consulta general (con nombres en lugar de Ids)
	IF @Accion = 3
	BEGIN
		SELECT	EP.IdEquipoPartido AS Id,
				P.Nombre AS Partido,
				E.Nombre AS Equipo,
				T.Descripcion AS TipoEquipo,
				EP.Goles
		FROM	EQUIPO_PARTIDO EP
		INNER JOIN PARTIDO	   P ON P.IdPartido	   = EP.IdPartido
		INNER JOIN EQUIPO	   E ON E.IdEquipo	   = EP.IdEquipo
		INNER JOIN TIPO_EQUIPO T ON T.IdTipoEquipo = EP.IdTipoEquipo
		WHERE	(EP.IdPartido = @IdPartido OR @IdPartido IS NULL)
	END

	-- Modificar un registro seleccionado
	IF @Accion = 4
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM EQUIPO_PARTIDO WHERE IdPartido = @IdPartido AND IdEquipo = @IdEquipo
					   AND IdEquipoPartido != @IdEquipoPartido)
		BEGIN
			UPDATE	EQUIPO_PARTIDO
			SET		IdPartido		= @IdPartido,
					IdEquipo		= @IdEquipo,
					IdTipoEquipo	= @IdTipoEquipo,
					Goles			= @Goles
			WHERE	IdEquipoPartido	= @IdEquipoPartido

			SELECT 'Registro modificado' AS Mensaje, 'success' AS TipoMensaje
		END
		ELSE
		BEGIN
			SELECT 'El equipo ya está registrado en este partido' AS Mensaje, 'warning' AS TipoMensaje
		END
	END

	-- Eliminar el registro (tabla de detalle sin estatus: baja física)
	IF @Accion = 5
	BEGIN
		DELETE
		FROM	EQUIPO_PARTIDO
		WHERE	IdEquipoPartido = @IdEquipoPartido

		SELECT 'Registro eliminado' AS Mensaje, 'success' AS TipoMensaje
	END
END
GO

using Microsoft.Data.SqlClient;
using Evidencia4.Datos;
using Evidencia4.Entidades;
using System.Data;

namespace Evidencia4.Logica
{
    public class logicaEntrenador
    {
        private readonly bdConexion _bd;

        public logicaEntrenador(bdConexion bd)
        {
            _bd = bd;
        }

        // Accion 1 (registrar) o 4 (modificar)
        public bdRespuesta Guardar(bdEntrenador entrenador, int idUsuarioAuditor)
        {
            int accion = entrenador.IdEntrenador == 0 ? 1 : 4;

            SqlParameter[] p = {
                new SqlParameter("@Accion", accion),
                new SqlParameter("@IdEntrenador", entrenador.IdEntrenador),
                new SqlParameter("@IdEquipo", entrenador.IdEquipo),
                new SqlParameter("@Nombre", Valor(entrenador.Nombre?.Trim().ToUpper())),
                new SqlParameter("@PrimerApellido", Valor(entrenador.PrimerApellido?.Trim().ToUpper())),
                new SqlParameter("@SegundoApellido", Valor(entrenador.SegundoApellido?.Trim().ToUpper())),
                new SqlParameter("@FechaNacimiento", (object?) entrenador.FechaNacimiento ?? DBNull.Value),
                new SqlParameter("@Cedula", Valor(entrenador.Cedula?.Trim().ToUpper())),
                new SqlParameter("@Telefono", Valor(entrenador.Telefono?.Trim())),
                new SqlParameter("@IdUsuarioAuditor", idUsuarioAuditor)
            };
            return Respuesta(_bd.EjecutarStoredProcedure("spEntrenador", p));
        }

        // Accion 2: leer un registro
        public bdEntrenador? Obtener(int id)
        {
            SqlParameter[] p = {
                new SqlParameter("@Accion", 2),
                new SqlParameter("@IdEntrenador", id)
            };
            DataTable dt = _bd.EjecutarStoredProcedure("spEntrenador", p);

            // Si no regresa filas, no existe o está dado de baja
            if (dt.Rows.Count == 0)
                return null;

            DataRow r = dt.Rows[0];
            return new bdEntrenador
            {
                IdEntrenador = Convert.ToInt32(r["IdEntrenador"]),
                IdEquipo = Convert.ToInt32(r["IdEquipo"]),
                Nombre = r["Nombre"].ToString(),
                PrimerApellido = r["PrimerApellido"].ToString(),
                SegundoApellido = r["SegundoApellido"].ToString(),
                FechaNacimiento = Convert.ToDateTime(r["FechaNacimiento"]),
                Cedula = r["Cedula"].ToString(),
                Telefono = r["Telefono"].ToString()
            };
        }

        // Accion 3: consulta general (sólo entrenadores activos)
        public DataTable Consultar(string? buscar)
        {
            SqlParameter[] p = {
                new SqlParameter("@Accion", 3),
                new SqlParameter("@Buscar", Valor(buscar?.Trim()))
            };
            return _bd.EjecutarStoredProcedure("spEntrenador", p);
        }

        // Accion 5: eliminar (baja lógica)
        public bdRespuesta Eliminar(int id, int idUsuarioAuditor)
        {
            SqlParameter[] p = {
                new SqlParameter("@Accion", 5),
                new SqlParameter("@IdEntrenador", id),
                new SqlParameter("@IdUsuarioAuditor", idUsuarioAuditor)
            };
            return Respuesta(_bd.EjecutarStoredProcedure("spEntrenador", p));
        }

        // Convierte el resultado del SP (Mensaje y TipoMensaje) en bdRespuesta
        private bdRespuesta Respuesta(DataTable dt)
        {
            return new bdRespuesta
            {
                Mensaje = dt.Rows[0]["Mensaje"].ToString() ?? "",
                TipoMensaje = dt.Rows[0]["TipoMensaje"].ToString() ?? ""
            };
        }

        // Manda NULL a SQL cuando el texto viene vacío
        private object Valor(string? texto)
        {
            return string.IsNullOrWhiteSpace(texto) ? DBNull.Value : texto;
        }
    }
}

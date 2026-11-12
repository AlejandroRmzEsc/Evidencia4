using Microsoft.Data.SqlClient;
using Evidencia4.Datos;
using Evidencia4.Entidades;
using System.Data;

namespace Evidencia4.Logica
{
    public class logicaJugador
    {
        private readonly bdConexion _bd;

        public logicaJugador(bdConexion bd)
        {
            _bd = bd;
        }

        // Accion 1 (registrar) o 4 (modificar)
        public bdRespuesta Guardar(bdJugador jugador, int idUsuarioAuditor)
        {
            int accion = jugador.IdJugador == 0 ? 1 : 4;

            SqlParameter[] p = {
                new SqlParameter("@Accion", accion),
                new SqlParameter("@IdJugador", jugador.IdJugador),
                new SqlParameter("@IdEquipo", jugador.IdEquipo),
                new SqlParameter("@Nombre", Valor(jugador.Nombre?.Trim().ToUpper())),
                new SqlParameter("@PrimerApellido", Valor(jugador.PrimerApellido?.Trim().ToUpper())),
                new SqlParameter("@SegundoApellido", Valor(jugador.SegundoApellido?.Trim().ToUpper())),
                new SqlParameter("@FechaNacimiento", (object?) jugador.FechaNacimiento ?? DBNull.Value),
                new SqlParameter("@Correo", Valor(jugador.Correo?.Trim().ToLower())),
                new SqlParameter("@Telefono", Valor(jugador.Telefono?.Trim())),
                new SqlParameter("@IdUsuarioAuditor", idUsuarioAuditor)
            };
            return Respuesta(_bd.EjecutarStoredProcedure("spJugador", p));
        }

        // Accion 2: leer un registro
        public bdJugador? Obtener(int id)
        {
            SqlParameter[] p = {
                new SqlParameter("@Accion", 2),
                new SqlParameter("@IdJugador", id)
            };
            DataTable dt = _bd.EjecutarStoredProcedure("spJugador", p);

            // Si no regresa filas, no existe o está dado de baja
            if (dt.Rows.Count == 0)
                return null;

            DataRow r = dt.Rows[0];
            return new bdJugador
            {
                IdJugador = Convert.ToInt32(r["IdJugador"]),
                IdEquipo = Convert.ToInt32(r["IdEquipo"]),
                Nombre = r["Nombre"].ToString(),
                PrimerApellido = r["PrimerApellido"].ToString(),
                SegundoApellido = r["SegundoApellido"].ToString(),
                FechaNacimiento = Convert.ToDateTime(r["FechaNacimiento"]),
                Correo = r["Correo"].ToString(),
                Telefono = r["Telefono"].ToString()
            };
        }

        // Accion 3: consulta general (sólo jugadores activos)
        public DataTable Consultar(string? buscar)
        {
            SqlParameter[] p = {
                new SqlParameter("@Accion", 3),
                new SqlParameter("@Buscar", Valor(buscar?.Trim()))
            };
            return _bd.EjecutarStoredProcedure("spJugador", p);
        }

        // Accion 5: eliminar (baja lógica)
        public bdRespuesta Eliminar(int id, int idUsuarioAuditor)
        {
            SqlParameter[] p = {
                new SqlParameter("@Accion", 5),
                new SqlParameter("@IdJugador", id),
                new SqlParameter("@IdUsuarioAuditor", idUsuarioAuditor)
            };
            return Respuesta(_bd.EjecutarStoredProcedure("spJugador", p));
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

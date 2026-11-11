using System.Data;
using Evidencia4.Datos;
using Evidencia4.Entidades;
using Microsoft.Data.SqlClient;

namespace Evidencia4.Logica
{
    public class logicaJugador
    {
        private readonly bdConexion _bd;

        public logicaJugador(bdConexion bd)
        {
            _bd = bd;
        }

        // Accion 1 o 4 (registrar o modificar)
        public bdRespuesta Guardar(bdJugador jugador, int idUsuarioAuditor)
        {
            int accion = jugador.IdJugador == 0 ? 1 : 4;

            SqlParameter[] p =
            {
                new SqlParameter("@Accion", accion),
                new SqlParameter("@IdJugador", jugador.IdJugador),
                new SqlParameter("@IdEquipo", jugador.IdEquipo),
                new SqlParameter("@Nombre", jugador.Nombre),
                new SqlParameter("@PrimerApellido", jugador.PrimerApellido),
                new SqlParameter("@SegundoApellido", jugador.SegundoApellido),
                new SqlParameter("@FechaNacimiento", jugador.FechaNacimiento),
                new SqlParameter("@Correo", jugador.Correo),
                new SqlParameter("@Telefono", jugador.Telefono),
                new SqlParameter("@IdUsuarioAuditor", idUsuarioAuditor)
            };
            return Ejecutar(p);
        }

        // Accion 2 (leer un registro)
        public bdJugador? Obtener(int id)
        {
            SqlParameter[] p =
            {
                new SqlParameter("@Accion", 2),
                new SqlParameter("@IdJugador", id)
            };
            DataTable dt = _bd.EjecutarStoredProcedure("spJugador", p);

            if (dt.Rows.Count == 0)
                return null;

            DataRow r = dt.Rows[0];

            // Un jugador dado de baja (estatus 2) ya no se puede editar
            if (dt.Columns.Contains("IdEstatus") && Convert.ToInt32(r["IdEstatus"]) != 1)
                return null;

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

        // Accion 3 (consulta general, sólo jugadores activos)
        public DataTable Consultar(string? buscar)
        {
            SqlParameter[] p =
            {
                new SqlParameter("@Accion", 3),
                new SqlParameter("@Buscar", buscar)
            };
            return _bd.EjecutarStoredProcedure("spJugador", p);
        }

        // Accion 5 (baja lógica)
        public bdRespuesta Eliminar(int id, int idUsuarioAuditor)
        {
            SqlParameter[] p =
            {
                new SqlParameter("@Accion", 5),
                new SqlParameter("@IdJugador", id),
                new SqlParameter("@IdUsuarioAuditor", idUsuarioAuditor)
            };
            return Ejecutar(p);
        }

        // Ejecuta el SP y convierte el error de SQL en un mensaje para la pantalla
        private bdRespuesta Ejecutar(SqlParameter[] p)
        {
            try
            {
                return Respuesta(_bd.EjecutarStoredProcedure("spJugador", p));
            }
            catch (SqlException)
            {
                return new bdRespuesta { Mensaje = "Ocurrió un error en la base de datos", TipoMensaje = "danger" };
            }
        }

        // Toma el Mensaje y TipoMensaje que regresa el SP
        private bdRespuesta Respuesta(DataTable dt)
        {
            bdRespuesta respuesta = new bdRespuesta();
            if (dt.Rows.Count > 0)
            {
                respuesta.Mensaje = dt.Rows[0]["Mensaje"].ToString() ?? "";
                respuesta.TipoMensaje = dt.Rows[0]["TipoMensaje"].ToString() ?? "";
            }
            return respuesta;
        }
    }
}

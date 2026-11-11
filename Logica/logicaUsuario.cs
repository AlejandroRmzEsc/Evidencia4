using System.Data;
using Evidencia4.Datos;
using Evidencia4.Entidades;
using Microsoft.Data.SqlClient;

namespace Evidencia4.Logica
{
    public class logicaUsuario
    {
        private readonly bdConexion _bd;

        public logicaUsuario(bdConexion bd)
        {
            _bd = bd;
        }

        // Accion 6 (iniciar sesión)
        // Regresa Mensaje y TipoMensaje; si es correcto también IdUsuario, Cuenta y Rol
        public DataTable IniciarSesion(string cuenta, string contrasenia)
        {
            SqlParameter[] p =
            {
                new SqlParameter("@Accion", 6),
                new SqlParameter("@Cuenta", cuenta),
                new SqlParameter("@Contrasenia", contrasenia)
            };
            return _bd.EjecutarStoredProcedure("spUsuario", p);
        }

        // Accion 7 (crear cuenta desde el login)
        // Entrenador -> rol ADMINISTRADOR, Jugador -> rol OBSERVADOR
        public bdRespuesta CrearCuenta(bdCuenta cuenta)
        {
            SqlParameter[] p =
            {
                new SqlParameter("@Accion", 7),
                new SqlParameter("@TipoCuenta", cuenta.TipoCuenta),
                new SqlParameter("@Dato", cuenta.Dato),
                new SqlParameter("@Telefono", cuenta.Telefono),
                new SqlParameter("@Cuenta", cuenta.Cuenta),
                new SqlParameter("@Contrasenia", cuenta.Contrasenia)
            };
            return Ejecutar(p);
        }

        // Accion 1 o 4 (registrar o modificar)
        public bdRespuesta Guardar(bdUsuario usuario, int idUsuarioAuditor)
        {
            int accion = usuario.IdUsuario == 0 ? 1 : 4;

            SqlParameter[] p =
            {
                new SqlParameter("@Accion", accion),
                new SqlParameter("@IdUsuario", usuario.IdUsuario),
                new SqlParameter("@IdRol", usuario.IdRol),
                new SqlParameter("@Cuenta", usuario.Cuenta),
                new SqlParameter("@Contrasenia", usuario.Contrasenia),
                new SqlParameter("@IdUsuarioAuditor", idUsuarioAuditor)
            };
            return Ejecutar(p);
        }

        // Accion 2 (leer un registro)
        public bdUsuario? Obtener(int id)
        {
            SqlParameter[] p =
            {
                new SqlParameter("@Accion", 2),
                new SqlParameter("@IdUsuario", id)
            };
            DataTable dt = _bd.EjecutarStoredProcedure("spUsuario", p);

            if (dt.Rows.Count == 0)
                return null;

            DataRow r = dt.Rows[0];
            return new bdUsuario
            {
                IdUsuario = Convert.ToInt32(r["IdUsuario"]),
                IdRol = Convert.ToInt32(r["IdRol"]),
                IdEstatus = Convert.ToInt32(r["IdEstatus"]),
                Cuenta = r["Cuenta"].ToString(),
                Contrasenia = r["Contrasenia"].ToString()
            };
        }

        // Accion 5 (baja lógica)
        public bdRespuesta Eliminar(int id, int idUsuarioAuditor)
        {
            SqlParameter[] p =
            {
                new SqlParameter("@Accion", 5),
                new SqlParameter("@IdUsuario", id),
                new SqlParameter("@IdUsuarioAuditor", idUsuarioAuditor)
            };
            return Ejecutar(p);
        }

        // Ejecuta el SP y convierte el error de SQL en un mensaje para la pantalla
        private bdRespuesta Ejecutar(SqlParameter[] p)
        {
            try
            {
                return Respuesta(_bd.EjecutarStoredProcedure("spUsuario", p));
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

using Microsoft.Data.SqlClient;
using Evidencia4.Datos;
using Evidencia4.Entidades;
using System.Data;

namespace Evidencia4.Logica
{
    public class logicaUsuario
    {
        private readonly bdConexion _bd;

        public logicaUsuario(bdConexion bd)
        {
            _bd = bd;
        }

        // Accion 6: iniciar sesión
        // El SP distingue mayúsculas/minúsculas y valida que el usuario esté ACTIVO.
        // Regresa el usuario si es correcto; si no, null y el motivo en "respuesta".
        public bdUsuario? IniciarSesion(bdUsuario usuario, out bdRespuesta respuesta)
        {
            SqlParameter[] p = {
                new SqlParameter("@Accion", 6),
                new SqlParameter("@Cuenta", Valor(usuario.Cuenta?.Trim())),
                new SqlParameter("@Contrasenia", Valor(usuario.Contrasenia))
            };
            DataTable dt = _bd.EjecutarStoredProcedure("spUsuario", p);

            respuesta = Respuesta(dt);

            // Si no es "success", la cuenta o la contraseña están mal o el usuario está inactivo
            if (respuesta.TipoMensaje != "success")
                return null;

            DataRow r = dt.Rows[0];
            return new bdUsuario
            {
                IdUsuario = Convert.ToInt32(r["IdUsuario"]),
                Cuenta = r["Cuenta"].ToString(),
                Rol = r["Rol"].ToString()
            };
        }

        // Accion 7: crear cuenta desde el login
        // Entrenador -> rol ADMINISTRADOR, Jugador -> rol OBSERVADOR
        public bdRespuesta CrearCuenta(bdCuenta cuenta)
        {
            SqlParameter[] p = {
                new SqlParameter("@Accion", 7),
                new SqlParameter("@TipoCuenta", Valor(cuenta.TipoCuenta)),
                new SqlParameter("@Dato", Valor(cuenta.Dato?.Trim())),
                new SqlParameter("@Telefono", Valor(cuenta.Telefono?.Trim())),
                new SqlParameter("@Cuenta", Valor(cuenta.Cuenta?.Trim())),
                new SqlParameter("@Contrasenia", Valor(cuenta.Contrasenia))
            };
            return Respuesta(_bd.EjecutarStoredProcedure("spUsuario", p));
        }

        // Convierte el resultado del SP (Mensaje y TipoMensaje) en bdRespuesta
        private bdRespuesta Respuesta(DataTable dt)
        {
            // Si el SP no regresa nada, la base no tiene la versión actual del script
            if (dt.Rows.Count == 0)
                return new bdRespuesta { Mensaje = "La base de datos no respondió. Ejecuta el script actualizado", TipoMensaje = "danger" };

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

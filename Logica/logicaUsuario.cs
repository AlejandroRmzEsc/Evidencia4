using System.Data;
using Evidencia4.Entidades;
using Microsoft.Data.SqlClient;
using Proyecto.Datos;
using Proyecto.Entidades;

namespace Evidencia4.Logica
{
    public class logicaUsuario
    {
        private readonly bdConexion _bd;

        public logicaUsuario(bdConexion bd)
        {
            _bd = bd;
        }
        // Accion 1 (registrar o modificar)
        public bdRespuesta Guardar(bdCliente cliente)
        {
            int accion = cliente.IdCliente == 0 ? 1 : 4;

            SqlParameter[] p =
            {
                new SqlParameter("@Accion", accion),
                new SqlParameter("@IdCliente", cliente.IdCliente),
                new SqlParameter("@IdRol", cliente.IdRol),
                new SqlParameter("@Cuenta", cliente.Cuenta),
                new SqlParameter("@Contrasenia", cliente.Contrasenia),
                new SqlParameter("@IdUsuarioAuditor", cliente.UsuarioRegistro)
            };
            return Respuesta(_bd.EjecutarStoredProcedure("spUsuario", p));
        }

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
                Cuenta = r["Cuenta"].ToString(),
                Contrasenia = r["Contrasenia"].ToString()
            };
        }
    }
}

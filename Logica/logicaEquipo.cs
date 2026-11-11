using System.Data;
using Evidencia4.Datos;
using Microsoft.Data.SqlClient;

namespace Evidencia4.Logica
{
    public class logicaEquipo
    {
        private readonly bdConexion _bd;

        public logicaEquipo(bdConexion bd)
        {
            _bd = bd;
        }

        // Accion 3 (consulta general, sólo equipos activos)
        // Se usa para llenar el combo de equipos en Jugador y Entrenador
        public DataTable Consultar()
        {
            SqlParameter[] p =
            {
                new SqlParameter("@Accion", 3)
            };
            return _bd.EjecutarStoredProcedure("spEquipo", p);
        }
    }
}

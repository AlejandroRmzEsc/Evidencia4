using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.Data.SqlClient;
using Evidencia4.Datos;
using System.Data;

namespace Evidencia4.Logica
{
    public class logicaCatalogos
    {
        private readonly bdConexion _bd;

        public logicaCatalogos(bdConexion bd)
        {
            _bd = bd;
        }

        // Métodos para cargar los catalogos
        public List<SelectListItem> ddlEquipo() => Listar(1);
        public List<SelectListItem> ddlCategoria() => Listar(2);
        public List<SelectListItem> ddlEstadio() => Listar(3);
        public List<SelectListItem> ddlTipoEquipo() => Listar(4);

        // Ejecutar la lógica para consultar la base de datos
        private List<SelectListItem> Listar(int accion, int? idFiltro = null)
        {
            SqlParameter[] p =
            {
                new SqlParameter("@Accion", accion),
                new SqlParameter("@IdFiltro", (object?) idFiltro ?? DBNull.Value)
            };
            DataTable dt = _bd.EjecutarStoredProcedure("spCatalogos", p);

            List<SelectListItem> lista = new List<SelectListItem>();

            foreach (DataRow r in dt.Rows)
            {
                lista.Add(new SelectListItem
                {
                    Value = r["IdCatalogo"].ToString(),
                    Text = r["Descripcion"].ToString()
                });
            }

            return lista;
        }
    }
}

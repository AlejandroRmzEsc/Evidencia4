using System.Data;
using System.Security.Claims;
using Evidencia4.Entidades;
using Evidencia4.Logica;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;

namespace Evidencia4.Pages
{
    public class EntrenadorModel : PageModel
    {
        private readonly logicaEntrenador _logica;
        private readonly logicaEquipo _logicaEquipo;

        public EntrenadorModel(logicaEntrenador logica, logicaEquipo logicaEquipo)
        {
            _logica = logica;
            _logicaEquipo = logicaEquipo;
        }

        [BindProperty]
        public bdEntrenador Entrenador { get; set; } = new bdEntrenador();

        [BindProperty(SupportsGet = true)]
        public string? Buscar { get; set; }

        public DataTable Entrenadores { get; set; } = new DataTable();
        public DataTable Equipos { get; set; } = new DataTable();

        public string Mensaje { get; set; } = "";
        public string TipoMensaje { get; set; } = "";

        // Sólo el ADMINISTRADOR puede registrar, editar y eliminar
        public bool EsAdministrador => User.IsInRole("ADMINISTRADOR");

        public void OnGet()
        {
            Cargar();
        }

        // Carga el entrenador seleccionado en el formulario
        public void OnGetEditar(int id)
        {
            if (EsAdministrador)
            {
                try
                {
                    bdEntrenador? entrenador = _logica.Obtener(id);
                    if (entrenador != null)
                    {
                        Entrenador = entrenador;
                    }
                    else
                    {
                        Mensaje = "El entrenador no existe o fue dado de baja";
                        TipoMensaje = "warning";
                    }
                }
                catch (SqlException)
                {
                    Mensaje = "No fue posible conectar con la base de datos";
                    TipoMensaje = "danger";
                }
            }
            else
            {
                SinPermiso();
            }

            Cargar();
        }

        // Registrar o modificar
        public void OnPostGuardar()
        {
            if (EsAdministrador)
            {
                bdRespuesta respuesta = _logica.Guardar(Entrenador, IdUsuarioSesion());
                Mensaje = respuesta.Mensaje;
                TipoMensaje = respuesta.TipoMensaje;

                // Si se guardó se limpia el formulario
                if (TipoMensaje == "success")
                {
                    ModelState.Clear();
                    Entrenador = new bdEntrenador();
                }
            }
            else
            {
                SinPermiso();
            }

            Cargar();
        }

        // Baja lógica
        public void OnPostEliminar(int id)
        {
            if (EsAdministrador)
            {
                bdRespuesta respuesta = _logica.Eliminar(id, IdUsuarioSesion());
                Mensaje = respuesta.Mensaje;
                TipoMensaje = respuesta.TipoMensaje;
            }
            else
            {
                SinPermiso();
            }

            Cargar();
        }

        // Llena la tabla y el combo de equipos
        private void Cargar()
        {
            try
            {
                Entrenadores = _logica.Consultar(Buscar);
                Equipos = _logicaEquipo.Consultar();
            }
            catch (SqlException)
            {
                Mensaje = "No fue posible conectar con la base de datos";
                TipoMensaje = "danger";
            }
        }

        // Id del usuario en sesión (se guarda en los campos de auditoría)
        private int IdUsuarioSesion()
        {
            return Convert.ToInt32(User.FindFirstValue(ClaimTypes.NameIdentifier));
        }

        private void SinPermiso()
        {
            Mensaje = "Tu rol sólo permite consultar la información";
            TipoMensaje = "warning";
        }
    }
}

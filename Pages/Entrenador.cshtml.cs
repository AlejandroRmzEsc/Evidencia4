using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Evidencia4.Entidades;
using Evidencia4.Logica;
using System.Data;

namespace Evidencia4.Pages
{
    public class EntrenadorModel : PaginaProtegida
    {
        private readonly logicaEntrenador _logica;
        private readonly logicaCatalogos _catalogo;

        public EntrenadorModel(logicaEntrenador logica, logicaCatalogos catalogo)
        {
            _logica = logica;
            _catalogo = catalogo;
        }

        [BindProperty]
        public bdEntrenador Entrenador { get; set; } = new bdEntrenador();

        [BindProperty(SupportsGet = true)]
        public string? Buscar { get; set; }

        public DataTable Entrenadores { get; set; } = new DataTable();
        public List<SelectListItem> Equipo { get; set; } = new List<SelectListItem>();
        public string Mensaje { get; set; } = "";
        public string TipoMensaje { get; set; } = "";

        public void OnGet()
        {
            Cargar();
        }

        public void OnGetEditar(int id)
        {
            try
            {
                if (EsAdministrador)
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
                else
                {
                    SinPermiso();
                }
            }
            catch (Exception ex)
            {
                Mensaje = "Error: " + ex.Message;
                TipoMensaje = "danger";
            }
            Cargar();
        }

        public IActionResult OnPostGuardar()
        {
            try
            {
                if (EsAdministrador)
                {
                    bdRespuesta r = _logica.Guardar(Entrenador, IdUsuarioSesion);
                    Mensaje = r.Mensaje;
                    TipoMensaje = r.TipoMensaje;

                    if (r.TipoMensaje == "success")
                        Limpiar();
                }
                else
                {
                    SinPermiso();
                }
            }
            catch (Exception ex)
            {
                Mensaje = "Error: " + ex.Message;
                TipoMensaje = "danger";
            }
            Cargar();
            return Page();
        }

        public IActionResult OnPostEliminar(int id)
        {
            try
            {
                if (EsAdministrador)
                {
                    bdRespuesta r = _logica.Eliminar(id, IdUsuarioSesion);
                    Mensaje = r.Mensaje;
                    TipoMensaje = r.TipoMensaje;

                    if (r.TipoMensaje == "success")
                        Limpiar();
                }
                else
                {
                    SinPermiso();
                }
            }
            catch (Exception ex)
            {
                Mensaje = "Error: " + ex.Message;
                TipoMensaje = "danger";
            }
            Cargar();
            return Page();
        }

        private void Cargar()
        {
            try
            {
                Entrenadores = _logica.Consultar(Buscar);
                Equipo = _catalogo.ddlEquipo();
            }
            catch (Exception ex)
            {
                Mensaje = "Error: " + ex.Message;
                TipoMensaje = "danger";
            }
        }

        private void Limpiar()
        {
            ModelState.Clear();
            Entrenador = new bdEntrenador();
        }

        private void SinPermiso()
        {
            Mensaje = "Tu rol sólo permite consultar la información";
            TipoMensaje = "warning";
        }
    }
}

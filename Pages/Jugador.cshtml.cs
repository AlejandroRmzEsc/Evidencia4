using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Evidencia4.Entidades;
using Evidencia4.Logica;
using System.Data;

namespace Evidencia4.Pages
{
    public class JugadorModel : PaginaProtegida
    {
        private readonly logicaJugador _logica;
        private readonly logicaCatalogos _catalogo;

        public JugadorModel(logicaJugador logica, logicaCatalogos catalogo)
        {
            _logica = logica;
            _catalogo = catalogo;
        }

        [BindProperty]
        public bdJugador Jugador { get; set; } = new bdJugador();

        [BindProperty(SupportsGet = true)]
        public string? Buscar { get; set; }

        public DataTable Jugadores { get; set; } = new DataTable();
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
                    bdJugador? jugador = _logica.Obtener(id);
                    if (jugador != null)
                    {
                        Jugador = jugador;
                    }
                    else
                    {
                        Mensaje = "El jugador no existe o fue dado de baja";
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
                    bdRespuesta r = _logica.Guardar(Jugador, IdUsuarioSesion);
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
                Jugadores = _logica.Consultar(Buscar);
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
            Jugador = new bdJugador();
        }

        private void SinPermiso()
        {
            Mensaje = "Tu rol sólo permite consultar la información";
            TipoMensaje = "warning";
        }
    }
}

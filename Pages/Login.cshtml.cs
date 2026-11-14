using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Evidencia4.Entidades;
using Evidencia4.Logica;

namespace Evidencia4.Pages
{
    public class LoginModel : PageModel
    {
        private readonly logicaUsuario _logica;

        public LoginModel(logicaUsuario logica)
        {
            _logica = logica;
        }

        [BindProperty]
        public bdUsuario Usuario { get; set; } = new bdUsuario();

        public string Mensaje { get; set; } = "";
        public string TipoMensaje { get; set; } = "";

        public IActionResult OnGet()
        {
            // Si ya tiene sesión, lo redirigimos según su rol
            if (HttpContext.Session.GetInt32("IdUsuario") != null)
            {
                string rolActual = (HttpContext.Session.GetString("Rol") ?? "").Trim().ToUpper();
                return RedireccionarPorRol(rolActual);
            }
            return Page();
        }

        public IActionResult OnPost()
        {
            try
            {
                bdUsuario? u = _logica.IniciarSesion(Usuario, out bdRespuesta r);

                if (u != null)
                {
                    string rolLimpio = (u.Rol ?? "").Trim().ToUpper();

                    // Guardamos la sesión
                    HttpContext.Session.SetInt32("IdUsuario", u.IdUsuario);
                    HttpContext.Session.SetString("Cuenta", u.Cuenta ?? "");
                    HttpContext.Session.SetString("Rol", rolLimpio);

                    // Lo mandamos a su pestaña
                    return RedireccionarPorRol(rolLimpio);
                }

                Mensaje = r.Mensaje;
                TipoMensaje = r.TipoMensaje;
            }
            catch (Exception ex)
            {
                Mensaje = "Error: " + ex.Message;
                TipoMensaje = "danger";
            }
            return Page();
        }

        public IActionResult OnGetSalir()
        {
            HttpContext.Session.Clear();
            return RedirectToPage("/Login");
        }

        // Método auxiliar para no repetir código
        private IActionResult RedireccionarPorRol(string rol)
        {
            if (rol == "ADMINISTRADOR")
            {
                return RedirectToPage("/Entrenador");
            }
            else if (rol == "OBSERVADOR")
            {
                return RedirectToPage("/Jugador");
            }
            else
            {
                HttpContext.Session.Clear();
                Mensaje = "Tu rol no tiene una página asignada.";
                TipoMensaje = "warning";
                return Page();
            }
        }
    }
}
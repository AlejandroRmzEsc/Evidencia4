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

        // Datos del formulario
        [BindProperty]
        public bdUsuario Usuario { get; set; } = new bdUsuario();

        public string Mensaje { get; set; } = "";
        public string TipoMensaje { get; set; } = "";

        // Al abrir el Login
        public IActionResult OnGet()
        {
            // Si ya inició sesión, lo manda directo al inicio
            if (HttpContext.Session.GetInt32("IdUsuario") != null)
                return RedirectToPage("/Inicio");

            return Page();
        }

        // Botón Iniciar sesión
        public IActionResult OnPost()
        {
            try
            {
                bdUsuario? u = _logica.IniciarSesion(Usuario, out bdRespuesta r);

                if (u != null)
                {
                    // Guardar los datos en la sesión
                    HttpContext.Session.SetInt32("IdUsuario", u.IdUsuario);
                    HttpContext.Session.SetString("Cuenta", u.Cuenta ?? "");
                    HttpContext.Session.SetString("Rol", u.Rol ?? "");

                    return RedirectToPage("/Inicio");
                }

                // Cuenta o contraseña incorrectas, o usuario INACTIVO (mensaje del SP)
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

        // Cerrar sesión: /Login?handler=Salir
        public IActionResult OnGetSalir()
        {
            HttpContext.Session.Clear();
            return RedirectToPage("/Login");
        }
    }
}

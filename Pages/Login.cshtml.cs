using System.Data;
using System.Security.Claims;
using Evidencia4.Logica;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;

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
        public string Cuenta { get; set; } = "";

        [BindProperty]
        public string Contrasenia { get; set; } = "";

        public string Mensaje { get; set; } = "";
        public string TipoMensaje { get; set; } = "";

        // Siempre muestra el acceso: si había una sesión abierta se cierra
        public async Task OnGetAsync()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        }

        // Iniciar sesión
        public async Task<IActionResult> OnPostAsync()
        {
            DataTable dt;
            try
            {
                // El SP valida mayúsculas/minúsculas y que el usuario esté ACTIVO
                dt = _logica.IniciarSesion(Cuenta, Contrasenia);
            }
            catch (SqlException)
            {
                Mensaje = "No fue posible conectar con la base de datos";
                TipoMensaje = "danger";
                return Page();
            }

            // Si el SP no regresa nada, la base no tiene la versión actual de spUsuario
            if (dt.Rows.Count == 0 || !dt.Columns.Contains("TipoMensaje"))
            {
                Mensaje = "La base de datos no respondió al inicio de sesión. Ejecuta el script BaseDatos/DBTORNEO.sql";
                TipoMensaje = "danger";
                return Page();
            }

            DataRow fila = dt.Rows[0];
            if (fila["TipoMensaje"].ToString() != "success")
            {
                Mensaje = fila["Mensaje"].ToString() ?? "";
                TipoMensaje = fila["TipoMensaje"].ToString() ?? "";
                return Page();
            }

            // Datos que se guardan en la cookie de sesión
            List<Claim> claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, fila["IdUsuario"].ToString() ?? ""),
                new Claim(ClaimTypes.Name, fila["Cuenta"].ToString() ?? ""),
                new Claim(ClaimTypes.Role, fila["Rol"].ToString() ?? "")
            };
            ClaimsIdentity identidad = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
            await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, new ClaimsPrincipal(identidad));

            return RedirectToPage("/Index");
        }

        // Cerrar sesión
        public async Task<IActionResult> OnPostSalirAsync()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            return RedirectToPage("/Login");
        }
    }
}

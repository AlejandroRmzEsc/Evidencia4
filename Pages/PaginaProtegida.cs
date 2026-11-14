using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace Evidencia4.Pages
{
    public class PaginaProtegida : PageModel
    {
        public override void OnPageHandlerExecuting(PageHandlerExecutingContext context)
        {
            // Solo validamos que exista la sesión. Si no hay, va al Login.
            // (Ya no bloqueamos el paso entre /Entrenador y /Jugador)
            if (HttpContext.Session.GetInt32("IdUsuario") == null)
            {
                context.Result = RedirectToPage("/Login");
            }
        }

        public int IdUsuarioSesion => HttpContext.Session.GetInt32("IdUsuario") ?? 0;

        // Esta línea es la que controla que solo el ADMIN vea los botones de Guardar/Editar/Eliminar en tus vistas
        public bool EsAdministrador => HttpContext.Session.GetString("Rol") == "ADMINISTRADOR";
    }
}
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace Evidencia4.Pages
{
    // Las páginas que hereden de esta clase solo se abren con sesión iniciada
    public class PaginaProtegida : PageModel
    {
        public override void OnPageHandlerExecuting(PageHandlerExecutingContext context)
        {
            // Si no hay IdUsuario en la sesión, lo manda al Login
            if (HttpContext.Session.GetInt32("IdUsuario") == null)
            {
                context.Result = RedirectToPage("/Login");
            }
        }

        // Id del usuario en sesión (se guarda en los campos de auditoría)
        public int IdUsuarioSesion => HttpContext.Session.GetInt32("IdUsuario") ?? 0;

        // Sólo el ADMINISTRADOR puede registrar, editar y eliminar; el OBSERVADOR sólo consulta
        public bool EsAdministrador => HttpContext.Session.GetString("Rol") == "ADMINISTRADOR";
    }
}

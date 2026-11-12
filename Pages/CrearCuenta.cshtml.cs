using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Evidencia4.Entidades;
using Evidencia4.Logica;

namespace Evidencia4.Pages
{
    public class CrearCuentaModel : PageModel
    {
        private readonly logicaUsuario _logica;

        public CrearCuentaModel(logicaUsuario logica)
        {
            _logica = logica;
        }

        // Datos del formulario
        [BindProperty]
        public bdCuenta Cuenta { get; set; } = new bdCuenta { TipoCuenta = "JUGADOR" };

        [BindProperty]
        public string? Confirmacion { get; set; }

        public string Mensaje { get; set; } = "";
        public string TipoMensaje { get; set; } = "";

        public void OnGet()
        {
        }

        // Botón Crear cuenta (el SP valida que la persona exista y le asigna su rol)
        public IActionResult OnPost()
        {
            try
            {
                if (Cuenta.Contrasenia != Confirmacion)
                {
                    Mensaje = "Las contraseñas no coinciden";
                    TipoMensaje = "warning";
                    return Page();
                }

                bdRespuesta r = _logica.CrearCuenta(Cuenta);
                Mensaje = r.Mensaje;
                TipoMensaje = r.TipoMensaje;

                if (r.TipoMensaje == "success")
                    Limpiar();
            }
            catch (Exception ex)
            {
                Mensaje = "Error: " + ex.Message;
                TipoMensaje = "danger";
            }
            return Page();
        }

        private void Limpiar()
        {
            ModelState.Clear();
            Cuenta = new bdCuenta { TipoCuenta = "JUGADOR" };
            Confirmacion = null;
        }
    }
}

using Evidencia4.Entidades;
using Evidencia4.Logica;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace Evidencia4.Pages
{
    public class CrearCuentaModel : PageModel
    {
        private readonly logicaUsuario _logica;

        public CrearCuentaModel(logicaUsuario logica)
        {
            _logica = logica;
        }

        [BindProperty]
        public bdCuenta Cuenta { get; set; } = new bdCuenta { TipoCuenta = "JUGADOR" };

        [BindProperty]
        public string? Confirmacion { get; set; }

        public string Mensaje { get; set; } = "";
        public string TipoMensaje { get; set; } = "";

        public void OnGet()
        {
        }

        // Crear la cuenta (el SP valida que la persona exista y le asigna su rol)
        public void OnPost()
        {
            if (Cuenta.Contrasenia != Confirmacion)
            {
                Mensaje = "Las contraseñas no coinciden";
                TipoMensaje = "warning";
                return;
            }

            bdRespuesta respuesta = _logica.CrearCuenta(Cuenta);
            Mensaje = respuesta.Mensaje;
            TipoMensaje = respuesta.TipoMensaje;

            // Si se creó se limpia el formulario
            if (TipoMensaje == "success")
            {
                ModelState.Clear();
                Cuenta = new bdCuenta { TipoCuenta = "JUGADOR" };
                Confirmacion = null;
            }
        }
    }
}

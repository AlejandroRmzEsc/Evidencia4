using Evidencia4.Datos;
using Evidencia4.Logica;
using Microsoft.AspNetCore.Authentication.Cookies;

namespace Evidencia4
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Todas las páginas piden sesión, menos el Login, Crear cuenta y la página de error
            builder.Services.AddRazorPages(options =>
            {
                options.Conventions.AuthorizeFolder("/");
                options.Conventions.AllowAnonymousToPage("/Login");
                options.Conventions.AllowAnonymousToPage("/CrearCuenta");
                options.Conventions.AllowAnonymousToPage("/Error");
            });

            // Sesión con cookie: si no hay sesión manda al Login
            builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
                .AddCookie(options =>
                {
                    options.LoginPath = "/Login";
                    options.ExpireTimeSpan = TimeSpan.FromHours(8);
                });

            // Conexión y lógica
            builder.Services.AddScoped<bdConexion>();
            builder.Services.AddScoped<logicaUsuario>();
            builder.Services.AddScoped<logicaJugador>();
            builder.Services.AddScoped<logicaEntrenador>();
            builder.Services.AddScoped<logicaEquipo>();

            var app = builder.Build();

            if (!app.Environment.IsDevelopment())
            {
                app.UseExceptionHandler("/Error");
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseStaticFiles();

            app.UseRouting();

            app.UseAuthentication();
            app.UseAuthorization();

            app.MapRazorPages();

            app.Run();
        }
    }
}

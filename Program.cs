using Evidencia4.Datos;
using Evidencia4.Logica;

namespace Evidencia4
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // El Login es la página inicial del sitio
            builder.Services.AddRazorPages(options =>
            {
                options.Conventions.AddPageRoute("/Login", "");
            });

            // Sesión donde se guardan IdUsuario, Cuenta y Rol al iniciar sesión
            builder.Services.AddSession(options =>
            {
                options.IdleTimeout = TimeSpan.FromMinutes(20);
                options.Cookie.HttpOnly = true;
                options.Cookie.IsEssential = true;
            });

            // Add services to the container.
            builder.Services.AddRazorPages();
            builder.Services.AddScoped<bdConexion>();
            builder.Services.AddScoped<logicaUsuario>();
            builder.Services.AddScoped<logicaJugador>();
            builder.Services.AddScoped<logicaEntrenador>();
            builder.Services.AddScoped<logicaCatalogos>();

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (!app.Environment.IsDevelopment())
            {
                app.UseExceptionHandler("/Error");
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseStaticFiles();

            app.UseRouting();

            app.UseAuthorization();

            app.UseSession();

            app.MapRazorPages();

            app.Run();
        }
    }
}

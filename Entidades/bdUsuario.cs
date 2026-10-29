namespace Evidencia4.Entidades
{
    public class bdUsuario
    { 
        public int IdUsuario { get; set; }
        public int IdRol { get; set; }
        public int IdEstatus { get; set; }
        public string? Cuenta { get; set; }
        public string? Contrasenia { get; set; }
    }
}

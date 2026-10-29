namespace Evidencia4.Entidades
{
    public class bdJugador
    {
        public int IdJugador { get; set; }
        public int IdEstatus { get; set; }
        public int IdEquipo { get; set; }
        public int IdUsuario { get; set; }
        public string? Nombre { get; set; }
        public string? ApellidoPaterno { get; set; }
        public string? ApellidoMaterno { get; set; }
        public DateTime FechaNacimiento { get; set; }
        public string? Correo { get; set; }
        public string? Telefono { get; set; }
    }
}

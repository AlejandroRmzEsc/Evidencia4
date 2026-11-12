namespace Evidencia4.Entidades
{
    public class bdEntrenador
    {
        public int IdEntrenador { get; set; }
        public string? Nombre { get; set; }
        public string? PrimerApellido { get; set; }
        public string? SegundoApellido { get; set; }
        public DateTime? FechaNacimiento { get; set; }
        public string? Cedula { get; set; }
        public string? Telefono { get; set; }

        public int IdEquipo { get; set; } // Especial para el ddl
    }
}

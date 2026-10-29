namespace Evidencia4.Entidades
{
    public class bdPartido
    {
        public int IdPartido { get; set; }
        public int IdEstatus { get; set; }
        public int IdEstadio { get; set; }
        public string? Nombre { get; set; }
        public DateTime FechaInicio { get; set; }
        public DateTime FechaFin { get; set; }
        public string? Resultado { get; set; }
    }
}

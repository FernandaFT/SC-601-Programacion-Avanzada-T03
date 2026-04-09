namespace T03.Models
{
    public class ConsultaModel
    {
        public long IdCompra { get; set; }
        public string Descripcion { get; set; }
        public decimal Precio { get; set; }
        public decimal Saldo { get; set; }
        public string Estado { get; set; }
    }
}
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;

namespace T03.Models
{
    public class RegistroModel
    {
        public long? IdCompra { get; set; }

        public decimal SaldoAnterior { get; set; }
        public decimal? Abono { get; set; }

        public List<SelectListItem> ComprasPendientes { get; set; } = new List<SelectListItem>();
    }
}
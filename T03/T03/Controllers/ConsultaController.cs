using T03.EntityFramework;
using T03.Models;
using System.Linq;
using System.Web.Mvc;

namespace T03.Controllers
{
    public class ConsultaController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }

        #region Consultar
        [HttpGet]
        public ActionResult Consultar()
        {
            using (var context = new PracticaS13Entities())
            {
                var resultado = context.sp_ConsultarCompras().ToList();

                var datos = resultado
                    .Select(c => new ConsultaModel
                    {
                        IdCompra = c.Id_Compra,
                        Descripcion = c.Descripcion,
                        Precio = c.Precio,
                        Saldo = c.Saldo,
                        Estado = c.Estado
                    })
                    .ToList();

                return View(datos);
            }
        }
        #endregion

        #region Registro
        [HttpGet]
        public ActionResult Registro()
        {
            return View();
        }
        #endregion
    }
}

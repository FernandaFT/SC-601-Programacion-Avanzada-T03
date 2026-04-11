using System;
using System.Linq;
using System.Web.Mvc;
using T03.EntityFramework;
using T03.Models;

namespace T03.Controllers
{
    public class RegistroController : Controller
    {
        [HttpGet]
        public ActionResult Registro()
        {
            var model = new RegistroModel();
            CargarComprasPendientes(model);
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Registro(RegistroModel model)
        {
            CargarComprasPendientes(model);

            try
            {
                if (!ModelState.IsValid)
                    return View(model);

                using (var context = new PracticaS13Entities())
                {
                    var saldoResult = context.sp_ConsultarSaldo(model.IdCompra.Value).FirstOrDefault();

                    if (saldoResult == null)
                    {
                        ModelState.AddModelError("", "No se encontró la compra seleccionada.");
                        return View(model);
                    }

                    decimal saldoActual = Convert.ToDecimal(saldoResult);
                    model.SaldoAnterior = saldoActual;

                    if (!model.Abono.HasValue || model.Abono.Value <= 0)
                    {
                        ModelState.AddModelError("Abono", "Campo obligatorio");
                        return View(model);
                    }

                    if (model.Abono.Value > saldoActual)
                    {
                        ModelState.AddModelError("Abono", "El abono no puede ser mayor al saldo disponible.");
                        return View(model);
                    }

                    context.sp_PagoParcial(model.IdCompra.Value, model.Abono.Value);

                    return RedirectToAction("Consultar", "Consulta");
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", "No se pudo registrar el abono. " + ex.Message);
                return View(model);
            }
        }

        [HttpPost]
        public JsonResult ConsultarSaldoCompra(long idCompra)
        {
            try
            {
                using (var context = new PracticaS13Entities())
                {
                    var datos = context.sp_ConsultarSaldo(idCompra).FirstOrDefault();

                    if (datos != null)
                    {
                        return Json(new { Saldo = Convert.ToDecimal(datos) });
                    }

                    return Json(new { Saldo = 0 });
                }
            }
            catch
            {
                return Json(new { Saldo = 0 });
            }
        }

        private void CargarComprasPendientes(RegistroModel model)
        {
            using (var context = new PracticaS13Entities())
            {
                var compras = context.sp_ConsultarComprasPendientes().ToList();

                model.ComprasPendientes = compras.Select(c => new SelectListItem
                {
                    Value = c.Id_Compra.ToString(),
                    Text = c.Id_Compra + " - " + c.Descripcion
                }).ToList();
            }
        }
    }
}
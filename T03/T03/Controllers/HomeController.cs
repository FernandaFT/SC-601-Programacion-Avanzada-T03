using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace T03.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }

        #region Consultar
        [HttpGet]
        public ActionResult Consultar()
        {
            return View();
        }
        #endregion

        #region Abonar Registro
        [HttpGet]
        public ActionResult Registro()
        {
            return View();
        }
        #endregion
    }
}
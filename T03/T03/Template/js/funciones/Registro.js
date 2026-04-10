//function soloNumeros(e) {
//    var codigo = e.charCode || e.keyCode;
//    if ((codigo < 48 || codigo > 57) && codigo !== 46) {
//        e.preventDefault();
//    }
//}

//$(document).ready(function () {

//    $("#Id_Compra").change(function () {
//        var idCompra = $(this).val();

//        if (idCompra !== "") {
//            $.ajax({
//                url: '/Registro/ConsultarSaldoCompra',
//                method: 'POST',
//                dataType: 'json',
//                data: {
//                    idCompra: idCompra
//                },
//                success: function (respuesta) {
//                    var saldo = parseFloat(respuesta.Saldo || 0);

//                    $("#SaldoAnterior").val(saldo);
//                    $("#SaldoAnteriorVista").val("₡" + saldo.toLocaleString("es-CR", {
//                        minimumFractionDigits: 2,
//                        maximumFractionDigits: 2
//                    }));
//                },
//                error: function (xhr, status, error) {
//                    console.log("Error AJAX:", xhr.responseText);
//                    console.log("Status:", status);
//                    console.log("Error:", error);
//                }
//            });
//        } else {
//            $("#SaldoAnterior").val("");
//            $("#SaldoAnteriorVista").val("");
//        }
//    });

//    $("#formAbono").submit(function (e) {
//        var saldoTexto = $("#SaldoAnterior").val().toString().trim();
//        var abonoTexto = $("#Abono").val().toString().trim();

//        // limpiar formato moneda y convertir coma decimal a punto
//        saldoTexto = saldoTexto.replace("₡", "").replace(/\./g, "").replace(",", ".");
//        abonoTexto = abonoTexto.replace("₡", "").replace(/\./g, "").replace(",", ".");

//        var saldo = parseFloat(saldoTexto) || 0;
//        var abono = parseFloat(abonoTexto) || 0;

//        console.log("Saldo:", saldo);
//        console.log("Abono:", abono);

//        if (abono > saldo) {
//            e.preventDefault();

//            Swal.fire({
//                title: "Monto inválido",
//                html: "<b>El abono no puede ser mayor al saldo disponible.</b>",
//                icon: "error",
//                confirmButtonColor: "#d33",
//                confirmButtonText: "OK"
//            });

//            return false;
//        }
//    });

//    $("#formAbono").validate({
//        rules: {
//            Id_Compra: {
//                required: true
//            },
//            Abono: {
//                required: true
//            }
//        },
//        messages: {
//            I_dCompra: {
//                required: "Campo obligatorio"
//            },
//            Abono: {
//                required: "Campo obligatorio"
//            }
//        },
//        errorElement: "span",
//        errorClass: "text-danger",
//        highlight: function (element) {
//            $(element).addClass("is-invalid");
//        },
//        unhighlight: function (element) {
//            $(element).removeClass("is-invalid");
//        }
//    });
//});
function soloNumeros(e) {
    var codigo = e.charCode || e.keyCode;
    if ((codigo < 48 || codigo > 57) && codigo !== 46 && codigo !== 44) {
        e.preventDefault();
    }
}

$(document).ready(function () {
    console.log("Script de registro cargado");

    $("#Id_Compra").change(function () {
        var idCompra = $(this).val();

        if (idCompra !== "") {
            $.ajax({
                url: '/Registro/ConsultarSaldoCompra',
                type: 'POST',
                dataType: 'json',
                data: { idCompra: idCompra },
                success: function (respuesta) {
                    var saldo = Number(respuesta.Saldo || 0);

                    $("#SaldoAnterior").val(saldo);
                    $("#SaldoAnteriorVista").val("₡" + saldo.toLocaleString("es-CR", {
                        minimumFractionDigits: 2,
                        maximumFractionDigits: 2
                    }));
                },
                error: function (xhr, status, error) {
                    console.log("Error AJAX:", xhr.responseText);
                    console.log("Status:", status);
                    console.log("Error:", error);
                }
            });
        } else {
            $("#SaldoAnterior").val("");
            $("#SaldoAnteriorVista").val("");
        }
    });

    $("#formAbono").validate({
        rules: {
            IdCompra: {
                required: true
            },
            Abono: {
                required: true
            }
        },
        messages: {
            IdCompra: {
                required: "Campo obligatorio"
            },
            Abono: {
                required: "Campo obligatorio"
            }
        },
        errorElement: "span",
        errorClass: "text-danger",
        highlight: function (element) {
            $(element).addClass("is-invalid");
        },
        unhighlight: function (element) {
            $(element).removeClass("is-invalid");
        },
        submitHandler: function (form) {
            var saldoTexto = ($("#SaldoAnterior").val() || "").toString().trim();
            var abonoTexto = ($("#Abono").val() || "").toString().trim();

            saldoTexto = saldoTexto.replace("₡", "").replace(/\./g, "").replace(",", ".");
            abonoTexto = abonoTexto.replace("₡", "").replace(/\./g, "").replace(",", ".");

            var saldo = parseFloat(saldoTexto) || 0;
            var abono = parseFloat(abonoTexto) || 0;

            console.log("Saldo:", saldo);
            console.log("Abono:", abono);

            if (abono > saldo) {
                Swal.fire({
                    title: "Monto inválido",
                    html: "<b>El abono no puede ser mayor al saldo disponible.</b>",
                    icon: "error",
                    confirmButtonColor: "#d33",
                    confirmButtonText: "OK"
                });
                return false;
            }

            form.submit();
        }
    });
});
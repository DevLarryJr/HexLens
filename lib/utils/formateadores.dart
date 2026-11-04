import 'package:flutter/services.dart';

import 'formato.dart';

/// Da formato a un campo numérico mientras se escribe: deja solo dígitos (hasta [maxDigitos]),
/// los pasa por [formatear] y deja el cursor al final.
class _FormatoNumerico extends TextInputFormatter {
  const _FormatoNumerico(this.maxDigitos, this.formatear);

  final int maxDigitos;
  final String Function(String digitos) formatear;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue anterior, TextEditingValue nuevo) {
    var digitos = soloDigitos(nuevo.text);
    if (digitos.length > maxDigitos) digitos = digitos.substring(0, maxDigitos);
    final texto = formatear(digitos);
    return TextEditingValue(text: texto, selection: TextSelection.collapsed(offset: texto.length));
  }
}

/// Cédula / NIT con puntos de miles mientras se escribe: "1098765432" → "1.098.765.432".
/// Máximo 10 dígitos: el largo de una cédula colombiana (y de un NIT con su dígito de verificación).
const formatoDocumento = _FormatoNumerico(10, milesConPunto);

/// Celular colombiano de 10 dígitos mientras se escribe: "3001234567" → "300 123 4567".
const formatoTelefono = _FormatoNumerico(10, telefonoConEspacios);

/// Precio en pesos con puntos de miles mientras se escribe: "150000" → "150.000" (hasta 999.999.999).
const formatoPrecio = _FormatoNumerico(9, milesConPunto);

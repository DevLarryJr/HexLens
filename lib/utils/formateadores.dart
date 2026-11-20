import 'package:flutter/services.dart';

import 'formato.dart';

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

const formatoDocumento = _FormatoNumerico(10, milesConPunto);

const formatoTelefono = _FormatoNumerico(10, telefonoConEspacios);

const formatoPrecio = _FormatoNumerico(9, milesConPunto);

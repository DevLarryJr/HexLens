const _dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
const _meses = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

/// Nombre del día en español: "Jueves".
String nombreDia(DateTime fecha) => _dias[fecha.weekday - 1];

/// Nombre del mes en español: "Octubre".
String nombreMes(DateTime fecha) => _meses[fecha.month - 1];

/// Abreviatura del mes: "Oct".
String mesCorto(DateTime fecha) => nombreMes(fecha).substring(0, 3);

/// Número con dos cifras: 4 → "04".
String dosCifras(int n) => n.toString().padLeft(2, '0');

/// Día y mes: "04 Oct".
String diaMes(DateTime fecha) => '${dosCifras(fecha.day)} ${mesCorto(fecha)}';

/// Fecha corta con día de dos cifras: "04 Oct 2026".
String fechaCorta(DateTime fecha) => '${diaMes(fecha)} ${fecha.year}';

/// Fecha numérica de formularios: "04/10/2026".
String fechaNumerica(DateTime fecha) => '${dosCifras(fecha.day)}/${dosCifras(fecha.month)}/${fecha.year}';

/// Lo contrario de [fechaNumerica]: "22/05/1995" → 22 may 1995; null si el texto no es una fecha válida.
DateTime? fechaDesdeNumerica(String texto) {
  final partes = texto.split('/').map((p) => int.tryParse(p.trim())).toList();
  if (partes.length != 3 || partes.contains(null)) return null;
  final [dia!, mes!, anio!] = partes;
  final fecha = DateTime(anio, mes, dia);
  return fecha.day == dia && fecha.month == mes ? fecha : null;
}

/// Fecha larga: "Jueves, 15 de Octubre 2026".
String fechaLarga(DateTime fecha) => '${nombreDia(fecha)}, ${fecha.day} de ${nombreMes(fecha)} ${fecha.year}';

/// Inicial del día usada en los calendarios: L M X J V S D.
String letraDia(DateTime fecha) => const ['L', 'M', 'X', 'J', 'V', 'S', 'D'][fecha.weekday - 1];

bool mismoDia(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// Número de semana ISO-8601 (la semana empieza el lunes).
int semanaIso(DateTime fecha) {
  final d = DateTime.utc(fecha.year, fecha.month, fecha.day);
  final jueves = d.add(Duration(days: 4 - d.weekday));
  final primeroEnero = DateTime.utc(jueves.year, 1, 1);
  return jueves.difference(primeroEnero).inDays ~/ 7 + 1;
}

/// Horas con hasta 2 decimales, sin ceros sobrantes: 255 min → "4.25 h", 180 → "3 h".
String horasDesdeMinutos(int minutos) {
  final texto = (minutos / 60).toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  return '$texto h';
}

/// Hora de 12 h con sufijo: 14:15 → "02:15 PM".
String horaAmPm(DateTime t) => '${_hora12(t)} ${t.hour < 12 ? 'AM' : 'PM'}';

/// Rango de 12 h; el sufijo va una sola vez si ambos extremos lo comparten:
/// "10:00 - 10:45 AM", "11:30 AM - 12:15 PM".
String rangoAmPm(DateTime inicio, DateTime fin) {
  final mismoPeriodo = (inicio.hour < 12) == (fin.hour < 12);
  return mismoPeriodo ? '${_hora12(inicio)} - ${horaAmPm(fin)}' : '${horaAmPm(inicio)} - ${horaAmPm(fin)}';
}

String _hora12(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '${dosCifras(h)}:${dosCifras(t.minute)}';
}

/// Abreviatura del día en mayúsculas: "JUE".
String diaCorto(DateTime fecha) => nombreDia(fecha).substring(0, 3).toUpperCase();

/// Hora de 24 h: "08:30".
String horaCorta(DateTime t) => '${dosCifras(t.hour)}:${dosCifras(t.minute)}';

/// Formatea pesos colombianos con punto de miles: 120000 → `$120.000`.
String formatCop(int valor) => '${valor < 0 ? '-' : ''}\$${milesConPunto(valor.abs().toString())}';

/// Celular en grupos 3-3-4: "3001234567" → "300 123 4567". Con menos dígitos agrupa lo que haya.
String telefonoConEspacios(String digitos) {
  final b = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i == 3 || i == 6) b.write(' ');
    b.write(digitos[i]);
  }
  return b.toString();
}

/// Dígitos agrupados de a tres con punto: "1018490231" → "1.018.490.231".
String milesConPunto(String digitos) {
  final b = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) b.write('.');
    b.write(digitos[i]);
  }
  return b.toString();
}

/// Iniciales de las dos primeras palabras: "Laura Méndez" → "LM".
String iniciales(String nombre) =>
    nombre.split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0].toUpperCase()).join();

/// Minúsculas y sin tildes, para búsquedas: "Andrés" → "andres".
String sinTildes(String texto) {
  const de = 'áéíóúüñ', a = 'aeiouun';
  final b = StringBuffer();
  for (final ch in texto.toLowerCase().split('')) {
    final i = de.indexOf(ch);
    b.write(i < 0 ? ch : a[i]);
  }
  return b.toString();
}

/// Si [consulta] aparece en alguno de los [campos], sin importar tildes ni mayúsculas.
/// Una consulta vacía coincide siempre.
bool coincideBusqueda(String consulta, Iterable<String> campos) {
  final q = sinTildes(consulta.trim());
  return q.isEmpty || campos.any((c) => sinTildes(c).contains(q));
}

/// Solo los dígitos: "+57 312 987 6543" → "573129876543".
String soloDigitos(String texto) => texto.replaceAll(RegExp(r'\D'), '');

/// Nombre con la inicial del apellido: "Laura Méndez" → "Laura M.".
String nombreCorto(String nombre) {
  final partes = nombre.trim().split(RegExp(r'\s+'));
  return partes.length < 2 ? partes.first : '${partes.first} ${partes[1][0]}.';
}

/// Correo con usuario, @ y dominio con punto: "a@b.co".
bool esCorreo(String texto) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(texto.trim());

/// Saludo según la hora: "Buenos días" (antes de 12), "Buenas tardes" (antes de 19) o "Buenas noches".
String saludoSegunHora(DateTime t) => t.hour < 12
    ? 'Buenos días'
    : t.hour < 19
        ? 'Buenas tardes'
        : 'Buenas noches';

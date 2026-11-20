const _dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
const _meses = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

String nombreDia(DateTime fecha) => _dias[fecha.weekday - 1];

String nombreMes(DateTime fecha) => _meses[fecha.month - 1];

String mesCorto(DateTime fecha) => nombreMes(fecha).substring(0, 3);

String dosCifras(int n) => n.toString().padLeft(2, '0');

String diaMes(DateTime fecha) => '${dosCifras(fecha.day)} ${mesCorto(fecha)}';

String fechaCorta(DateTime fecha) => '${diaMes(fecha)} ${fecha.year}';

String fechaNumerica(DateTime fecha) => '${dosCifras(fecha.day)}/${dosCifras(fecha.month)}/${fecha.year}';

DateTime? fechaDesdeNumerica(String texto) {
  final partes = texto.split('/').map((p) => int.tryParse(p.trim())).toList();
  if (partes.length != 3 || partes.contains(null)) return null;
  final [dia!, mes!, anio!] = partes;
  final fecha = DateTime(anio, mes, dia);
  return fecha.day == dia && fecha.month == mes ? fecha : null;
}

String fechaLarga(DateTime fecha) => '${nombreDia(fecha)}, ${fecha.day} de ${nombreMes(fecha)} ${fecha.year}';

String letraDia(DateTime fecha) => const ['L', 'M', 'X', 'J', 'V', 'S', 'D'][fecha.weekday - 1];

bool mismoDia(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

int semanaIso(DateTime fecha) {
  final d = DateTime.utc(fecha.year, fecha.month, fecha.day);
  final jueves = d.add(Duration(days: 4 - d.weekday));
  final primeroEnero = DateTime.utc(jueves.year, 1, 1);
  return jueves.difference(primeroEnero).inDays ~/ 7 + 1;
}

String horasDesdeMinutos(int minutos) {
  final texto = (minutos / 60).toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  return '$texto h';
}

String horaAmPm(DateTime t) => '${_hora12(t)} ${t.hour < 12 ? 'AM' : 'PM'}';

String rangoAmPm(DateTime inicio, DateTime fin) {
  final mismoPeriodo = (inicio.hour < 12) == (fin.hour < 12);
  return mismoPeriodo ? '${_hora12(inicio)} - ${horaAmPm(fin)}' : '${horaAmPm(inicio)} - ${horaAmPm(fin)}';
}

String _hora12(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '${dosCifras(h)}:${dosCifras(t.minute)}';
}

String diaCorto(DateTime fecha) => nombreDia(fecha).substring(0, 3).toUpperCase();

String horaCorta(DateTime t) => '${dosCifras(t.hour)}:${dosCifras(t.minute)}';

String formatCop(int valor) => '${valor < 0 ? '-' : ''}\$${milesConPunto(valor.abs().toString())}';

String telefonoConEspacios(String digitos) {
  final b = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i == 3 || i == 6) b.write(' ');
    b.write(digitos[i]);
  }
  return b.toString();
}

String milesConPunto(String digitos) {
  final b = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) b.write('.');
    b.write(digitos[i]);
  }
  return b.toString();
}

String iniciales(String nombre) =>
    nombre.split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0].toUpperCase()).join();

String sinTildes(String texto) {
  const de = 'áéíóúüñ', a = 'aeiouun';
  final b = StringBuffer();
  for (final ch in texto.toLowerCase().split('')) {
    final i = de.indexOf(ch);
    b.write(i < 0 ? ch : a[i]);
  }
  return b.toString();
}

bool coincideBusqueda(String consulta, Iterable<String> campos) {
  final q = sinTildes(consulta.trim());
  return q.isEmpty || campos.any((c) => sinTildes(c).contains(q));
}

String soloDigitos(String texto) => texto.replaceAll(RegExp(r'\D'), '');

String nombreCorto(String nombre) {
  final partes = nombre.trim().split(RegExp(r'\s+'));
  return partes.length < 2 ? partes.first : '${partes.first} ${partes[1][0]}.';
}

bool esCorreo(String texto) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(texto.trim());

String saludoSegunHora(DateTime t) => t.hour < 12
    ? 'Buenos días'
    : t.hour < 19
        ? 'Buenas tardes'
        : 'Buenas noches';

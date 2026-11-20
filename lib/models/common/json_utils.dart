library;

dynamic campo(Map json, String nombre) {
  if (json.containsKey(nombre)) return json[nombre];
  final buscado = nombre.toLowerCase();
  for (final e in json.entries) {
    if ('${e.key}'.toLowerCase() == buscado) return e.value;
  }
  return null;
}

dynamic primerCampo(Map json, List<String> nombres) {
  for (final n in nombres) {
    final v = campo(json, n);
    if (v != null) return v;
  }
  return null;
}

String parseApiText(Map json, String nombre) => '${campo(json, nombre) ?? ''}'.trim();

int? parseApiInt(Object? value) =>
    value is num ? value.toInt() : int.tryParse('${value ?? ''}'.trim().split('.').first);

int? minutosDeHora(Object? value) {
  final m = RegExp(r'(?:^|[T ])(\d{1,2}):(\d{2})').firstMatch('${value ?? ''}'.trim());
  return m == null ? null : int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);
}

String nombreDe(Object? value) {
  if (value is Map) {
    final completo = [campo(value, 'nombres'), campo(value, 'apellidos')]
        .where((p) => p != null && '$p'.trim().isNotEmpty)
        .join(' ');
    return completo.isNotEmpty ? completo : '${campo(value, 'nombre') ?? ''}'.trim();
  }
  return '${value ?? ''}'.trim();
}

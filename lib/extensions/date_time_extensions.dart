import '../utils/formato.dart';

extension DateTimeFormatting on DateTime {
  String toIsoDateString() => '$year-${dosCifras(month)}-${dosCifras(day)}';

  String toIsoDateTimeString() => '${toIsoDateString()}T${dosCifras(hour)}:${dosCifras(minute)}:00';
}

DateTime? fechaDesdeApi(Object? v) {
  final m = RegExp(r'(\d{4})-(\d{2})-(\d{2})(?:[T ](\d{2}):(\d{2}))?').firstMatch('${v ?? ''}');
  if (m == null) return null;
  int g(int i) => int.parse(m.group(i) ?? '0');
  return DateTime(g(1), g(2), g(3), g(4), g(5));
}

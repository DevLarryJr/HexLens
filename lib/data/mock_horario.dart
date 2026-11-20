import 'package:flutter/foundation.dart';

import '../models/fotografo.dart';
import '../models/horario_laboral.dart';
import '../models/jornada.dart';
import '../models/login/login_response.dart';
import '../services/local/sesion_actual.dart';
import '../services/remote/horarios_laborales_api.dart';
import 'mock_fotografos.dart';

const almuerzoInicioMin = 13 * 60;

List<Jornada> semanaLaura(DateTime lunes) => [
      for (var i = 0; i < 5; i++)
        Jornada(fecha: lunes.add(Duration(days: i)), inicioMin: 8 * 60, finMin: 17 * 60),
      Jornada(fecha: lunes.add(const Duration(days: 5)), inicioMin: 9 * 60, finMin: 14 * 60, almuerzo: false, especial: true),
      Jornada(fecha: lunes.add(const Duration(days: 6))),
    ];

final revisionJornada = ValueNotifier(0);

final _cache = <int, List<HorarioLaboral>>{};
int? _elegido;
LoginResponse? _usuarioDelCache;

Map<int, List<HorarioLaboral>> get _horarios {
  if (!identical(_usuarioDelCache, SesionActual.usuario)) {
    _usuarioDelCache = SesionActual.usuario;
    _cache.clear();
    _elegido = null;
  }
  return _cache;
}

int? get _elegidoId {
  _horarios;
  return _elegido;
}

List<Fotografo> get fotografosConJornada =>
    SesionActual.conectada ? [for (final f in fotografos) if (f.id != null) f] : const [];

Fotografo? get fotografoJornada {
  final lista = fotografosConJornada;
  return lista.where((f) => f.id == _elegidoId).firstOrNull ??
      lista.where((f) => f.activo).firstOrNull ??
      lista.firstOrNull;
}

void elegirFotografoJornada(Fotografo f) {
  _horarios;
  _elegido = f.id;
  revisionJornada.value++;
}

bool horariosCargados(Fotografo f) => f.id != null && _horarios.containsKey(f.id);

Future<void> cargarHorarios(Fotografo f) async {
  final id = f.id;
  if (!SesionActual.conectada || id == null) return;
  _horarios[id] = await HorariosLaboralesApi().listarPorProfesional(id);
  revisionJornada.value++;
}

List<Jornada> semanaDe(Fotografo? f, DateTime lunes) {
  final id = f?.id;
  if (id == null) return semanaLaura(lunes);
  final lista = _horarios[id] ?? const <HorarioLaboral>[];
  return [
    for (var i = 0; i < 7; i++)
      () {
        final fecha = lunes.add(Duration(days: i));
        final dia = HorarioLaboral.diaSemanaDe(fecha.weekday);
        return lista.where((h) => h.diaSemana == dia).firstOrNull?.jornada(fecha) ?? Jornada(fecha: fecha);
      }(),
  ];
}

Future<void> guardarJornadas(Fotografo f, Map<int, Jornada> jornadas) async {
  final id = f.id;
  if (!SesionActual.conectada || id == null) return;
  final horariosApi = HorariosLaboralesApi();
  final lista = _horarios[id] = [...?_horarios[id]];
  for (final MapEntry(key: weekday, value: j) in jornadas.entries) {
    if (j.libre) continue;
    final dia = HorarioLaboral.diaSemanaDe(weekday);
    final i = lista.indexWhere((h) => h.diaSemana == dia);
    final existente = i >= 0 ? lista[i] : null;
    final horario = HorarioLaboral(
      id: existente?.id,
      profesionalId: id,
      diaSemana: dia,
      inicioMin: j.inicioMin!,
      finMin: j.finMin!,
      tieneAlmuerzo: j.almuerzo,
      almuerzoInicioMin: j.almuerzo ? j.almuerzoInicioMin ?? almuerzoInicioMin : null,
      almuerzoFinMin: j.almuerzo ? j.almuerzoFinMin ?? almuerzoInicioMin + Jornada.pausaAlmuerzoMin : null,
    );
    final HorarioLaboral guardado;
    if (existente?.id != null) {
      await horariosApi.actualizar(horario);
      guardado = horario;
    } else {
      guardado = await horariosApi.crear(horario);
    }
    if (i >= 0) {
      lista[i] = guardado;
    } else {
      lista.add(guardado);
    }
  }
  await cargarHorarios(f);
}

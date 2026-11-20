import 'common/json_utils.dart';
import 'jornada.dart';

class HorarioLaboral {
  const HorarioLaboral({
    this.id,
    required this.profesionalId,
    required this.diaSemana,
    required this.inicioMin,
    required this.finMin,
    this.tieneAlmuerzo = false,
    this.almuerzoInicioMin,
    this.almuerzoFinMin,
  });

  static HorarioLaboral? tryFromJson(Map<String, dynamic> json, {int? profesionalId}) {
    final dia = parseApiInt(campo(json, 'diaSemana'));
    final inicio = minutosDeHora(campo(json, 'horaInicio'));
    final fin = minutosDeHora(campo(json, 'horaFin'));
    final profesional = parseApiInt(campo(json, 'profesionalId')) ?? profesionalId;
    if (dia == null || inicio == null || fin == null || profesional == null) return null;
    final almuerzo = campo(json, 'tieneAlmuerzo') == true;
    return HorarioLaboral(
      id: parseApiInt(campo(json, 'id')),
      profesionalId: profesional,
      diaSemana: dia,
      inicioMin: inicio,
      finMin: fin,
      tieneAlmuerzo: almuerzo,
      almuerzoInicioMin: almuerzo ? minutosDeHora(campo(json, 'horaInicioAlmuerzo')) : null,
      almuerzoFinMin: almuerzo ? minutosDeHora(campo(json, 'horaFinAlmuerzo')) : null,
    );
  }

  final int? id;
  final int profesionalId;

  final int diaSemana;

  final int inicioMin;
  final int finMin;
  final bool tieneAlmuerzo;
  final int? almuerzoInicioMin;
  final int? almuerzoFinMin;

  static int diaSemanaDe(int weekday) => weekday % 7;

  Jornada jornada(DateTime fecha) => Jornada(
        fecha: fecha,
        inicioMin: inicioMin,
        finMin: finMin,
        almuerzo: tieneAlmuerzo,
        almuerzoInicioMin: tieneAlmuerzo ? almuerzoInicioMin : null,
        almuerzoFinMin: tieneAlmuerzo ? almuerzoFinMin : null,
      );

  static String horaApi(int min) => '${Jornada.hhmm(min)}:00';

  Map<String, dynamic> toCrearJson() => {
        'profesionalId': profesionalId,
        'diaSemana': diaSemana,
        ...toActualizarJson(),
      };

  Map<String, dynamic> toActualizarJson() => {
        'horaInicio': horaApi(inicioMin),
        'horaFin': horaApi(finMin),
        'tieneAlmuerzo': tieneAlmuerzo,
        if (tieneAlmuerzo && almuerzoInicioMin != null) 'horaInicioAlmuerzo': horaApi(almuerzoInicioMin!),
        if (tieneAlmuerzo && almuerzoFinMin != null) 'horaFinAlmuerzo': horaApi(almuerzoFinMin!),
      };

  HorarioLaboral conId(int? id) => HorarioLaboral(
        id: id,
        profesionalId: profesionalId,
        diaSemana: diaSemana,
        inicioMin: inicioMin,
        finMin: finMin,
        tieneAlmuerzo: tieneAlmuerzo,
        almuerzoInicioMin: almuerzoInicioMin,
        almuerzoFinMin: almuerzoFinMin,
      );
}

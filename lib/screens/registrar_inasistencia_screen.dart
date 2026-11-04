import 'package:flutter/material.dart';

import '../core/reloj.dart';
import '../data/mock_agenda.dart';
import '../models/sesion.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/staff/registro_inasistencia_widgets.dart';

/// Figma: "HexLens - Registrar Nueva Inasistencia" (41:608)
class RegistrarInasistenciaScreen extends StatefulWidget {
  const RegistrarInasistenciaScreen({super.key});

  @override
  State<RegistrarInasistenciaScreen> createState() => _RegistrarInasistenciaScreenState();
}

class _RegistrarInasistenciaScreenState extends State<RegistrarInasistenciaScreen> with ProtegeCambios {
  @override
  String get firmaFormulario => '$_modalidad|$_jornadaCompleta|$_motivo|$_inicio|$_fin|${_obs.text}';

  int _modalidad = 1;
  bool _jornadaCompleta = true;
  String _motivo = 'Capacitación institucional';
  /// Por defecto, una ausencia de dos días dentro de dos semanas.
  DateTime _inicio = Reloj.dia(13);
  DateTime _fin = Reloj.dia(14);
  final _obs = TextEditingController(
      text: 'Asistencia al workshop de iluminación avanzada y ciclorama en Bogotá Norte.');

  @override
  void dispose() {
    _obs.dispose();
    super.dispose();
  }

  int get _dias => _modalidad == 0 ? 1 : _fin.difference(_inicio).inDays + 1;
  bool get _valido => _modalidad == 0 || !_fin.isBefore(_inicio);

  DateTime get _hasta => _modalidad == 0 ? _inicio : _fin;

  /// "28-29 Oct 2026", "28 Oct 2026" o "30 Oct - 02 Nov 2026".
  String get _rango {
    String d(DateTime x) => dosCifras(x.day);
    if (mismoDia(_inicio, _hasta)) return fechaCorta(_inicio);
    if (_inicio.month == _hasta.month && _inicio.year == _hasta.year) {
      return '${d(_inicio)}-${d(_hasta)} ${mesCorto(_hasta)} ${_hasta.year}';
    }
    return '${d(_inicio)} ${mesCorto(_inicio)} - ${fechaCorta(_hasta)}';
  }

  /// Reservas programadas del fotógrafo dentro de la ausencia.
  int get _citas => sesionesAgenda
      .where((s) =>
          s.fotografo == _fotografo &&
          s.estado == SesionEstado.programada &&
          !s.inicio.isBefore(_inicio) &&
          s.inicio.isBefore(_hasta.add(const Duration(days: 1))))
      .length;

  static const _fotografo = 'Laura Méndez';

  Future<void> _pick(bool inicio) async {
    final d = await showDatePicker(
      context: context,
      initialDate: inicio ? _inicio : _fin,
      firstDate: Reloj.hoy,
      lastDate: Reloj.dia(365),
    );
    if (d != null) setState(() => inicio ? _inicio = d : _fin = d);
  }

  @override
  Widget build(BuildContext context) {
    return protegerSalida(HeaderScaffold(
      header: HexHeader(title: 'Nueva Ausencia', cerrar: true),
      bottomPadding: 28,
      children: [
        const SizedBox(height: 16),
        ModuleHeader(
          tag: 'STAFF · AUSENCIAS',
          title: 'Registrar Ausencia',
          subtitle: 'Bloquea la agenda del fotógrafo mientras esté ausente.',
        ),
        const SizedBox(height: 28),
        const FieldLabel('Fotógrafo', required: true),
        const PersonalAsignadoCard(
          nombre: 'Ingris Méndez',
          foto: 'foto_inasistencia.jpg',
          staffId: 'STAFF-ID: 804',
          detalle: 'Especialidad: Retratos de Moda • C.C. 52.890.123',
          operador: 'Laura Méndez (Retratos - C.C. 52.890.123)',
        ),
        const SizedBox(height: 28),
        const FieldLabel('Modalidad de Ausencia'),
        HexSegmented(
          options: const ['Día específico (1 día)', 'Rango de fechas'],
          leadings: const [
            SvgIcon('reg_inasistencia/dia.svg', width: 13.5, height: 15),
            SvgIcon('reg_inasistencia/rango.svg', width: 13.5, height: 15),
          ],
          selected: _modalidad,
          onChanged: (i) => setState(() => _modalidad = i),
        ),
        const SizedBox(height: 20),
        PeriodoDesconexionCard(
          dias: _dias,
          inicio: fechaNumerica(_inicio),
          fin: _modalidad == 1 ? fechaNumerica(_fin) : null,
          valido: _valido,
          jornadaCompleta: _jornadaCompleta,
          onJornadaCompleta: (v) => setState(() => _jornadaCompleta = v),
          onInicio: () => _pick(true),
          onFin: () => _pick(false),
        ),
        const SizedBox(height: 24),
        const FieldLabel('Categoría de Motivo', required: true),
        HexDropdown(
          value: _motivo,
          items: const [
            'Capacitación institucional',
            'Cita médica certificada',
            'Licencia temporal',
            'Calamidad doméstica',
            'Vacaciones programadas',
          ],
          onChanged: (v) => setState(() => _motivo = v),
        ),
        const SizedBox(height: 20),
        FieldLabel(
          'Observaciones o detalle del motivo',
          trailing: Text('${_obs.text.length} / 200\ncaracteres',
              style: AppText.mono(12, lineHeight: 18)),
        ),
        HexTextField(controller: _obs, maxLines: 4, onChanged: (_) => setState(() {})),
        const SizedBox(height: 28),
        AuditoriaAgendaCard(rango: _rango, citas: _valido ? _citas : 0, fotografo: _fotografo),
        const SizedBox(height: 28),
        InfoBox(
          leading: const SvgIcon('reg_inasistencia/autorizacion.svg', width: 11.7, height: 11.7),
          child: Text('Al confirmar, se avisa al fotógrafo y sus horarios quedan bloqueados en la agenda.',
              style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 20)),
        ),
        const SizedBox(height: 28),
        HexButton(
          label: 'Confirmar y Bloquear Agenda',
          radius: 2,
          shadow: AppShadows.medium,
          onPressed: _valido
              ? () {
                  showHexToast(context, 'Agenda bloqueada: $_dias ${_dias == 1 ? 'día' : 'días'}');
                  salirSinPreguntar();
                }
              : null,
          leading: const SvgIcon('reg_inasistencia/lock.svg', width: 12, height: 15.8),
        ),
      ],
    ));
  }
}

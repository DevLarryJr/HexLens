import 'package:flutter/material.dart';

import '../api/api.dart';
import '../core/reloj.dart';
import '../data/mock_cierres.dart';
import '../models/cierre.dart';
import '../models/liquidacion.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/cierres/nuevo_cierre_widgets.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';

/// Figma: "HexLens - Nuevo Cierre Contable" (19:5310)
class NuevoCierreScreen extends StatefulWidget {
  const NuevoCierreScreen({super.key, this.onConfirmar});

  final VoidCallback? onConfirmar;

  @override
  State<NuevoCierreScreen> createState() => _NuevoCierreScreenState();
}

class _NuevoCierreScreenState extends State<NuevoCierreScreen> with ProtegeCambios {
  @override
  String get firmaFormulario => '$_inicio|$_fin';

  /// Por defecto, la última quincena ya terminada.
  DateTime _inicio = ultimaQuincenaCerrable(Reloj.hoy).inicio;
  DateTime _fin = ultimaQuincenaCerrable(Reloj.hoy).fin;

  int get _dias => _fin.difference(_inicio).inDays + 1;
  bool get _valido => !_fin.isBefore(_inicio);

  Future<void> _pick(bool inicio) async {
    final d = await showDatePicker(
      context: context,
      initialDate: inicio ? _inicio : _fin,
      firstDate: DateTime(Reloj.hoy.year - 1),
      lastDate: Reloj.hoy,
    );
    if (d != null) setState(() => inicio ? _inicio = d : _fin = d);
  }

  String _plural(int n, String uno, String varios) => '$n ${n == 1 ? uno : varios}';

  /// Enviando a la API.
  bool _guardando = false;

  /// Genera el cierre del rango (con la API: `POST /api/liquidaciones-comisiones`). No repite un rango ya cerrado.
  Future<void> _confirmar() async {
    final repetido = cierres.where((c) => mismoDia(c.inicio, _inicio) && mismoDia(c.fin, _fin)).firstOrNull;
    if (repetido != null) {
      showHexToast(context, 'El período ${repetido.codigo} ya tiene cierre');
      return;
    }
    setState(() => _guardando = true);
    try {
      final cierre = await generarCierre(_inicio, _fin);
      if (!mounted) return;
      showHexToast(context, 'Cierre ${cierre.codigo} generado');
      widget.onConfirmar?.call();
      salirSinPreguntar();
    } on ApiError catch (e) {
      if (mounted) showHexToast(context, e.mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final liquidaciones = _valido ? liquidacionesEntre(_inicio, _fin) : <Liquidacion>[];
    final sesiones = liquidaciones.fold(0, (a, l) => a + l.sesiones.length);
    final total = liquidaciones.fold(0, (a, l) => a + l.base);
    final comisiones = liquidaciones.fold(0, (a, l) => a + l.comision);
    final estado = _valido ? pendientesEntre(_inicio, _fin) : (canceladas: 0, pendientes: 0);

    return protegerSalida(HeaderScaffold(
      header: HexHeader(title: 'Nuevo Cierre', cerrar: true),
      bottomPadding: 28,
      children: [
        const SizedBox(height: 12),
        const PasoAuditoriaHeader(paso: 'PASO 1 DE 2 · CONSOLIDACIÓN'),
        const SizedBox(height: 10),
        Text('Nuevo Cierre de Período', style: AppText.sans(30, weight: FontWeight.w700, lineHeight: 38, letterSpacing: -0.6)),
        const SizedBox(height: 4),
        Text('Define el rango de fechas para auditar servicios realizados y calcular comisiones.',
            style: AppText.sans(17, color: AppColors.onSurfaceVariant, lineHeight: 26)),
        const SizedBox(height: 24),
        RangoLiquidacionCard(
          etiqueta: 'T${(_inicio.month - 1) ~/ 3 + 1} · ${_inicio.year}',
          inicio: fechaNumerica(_inicio),
          fin: fechaNumerica(_fin),
          valido: _valido,
          validacion: _valido
              ? 'Validación de fechas: Rango válido ($_dias días naturales). Fecha final posterior o igual a la inicial.'
              : 'Validación de fechas: La fecha final debe ser posterior o igual a la inicial.',
          onInicio: () => _pick(true),
          onFin: () => _pick(false),
        ),
        const SizedBox(height: 24),
        EscaneoSesiones(realizadas: sesiones, canceladas: estado.canceladas, enCurso: estado.pendientes),
        const SizedBox(height: 24),
        DesgloseFinancieroCard(
          total: formatCop(total),
          servicios: _plural(sesiones, 'servicio realizado', 'servicios realizados'),
          comisiones: formatCop(comisiones),
          fotografos: _plural(liquidaciones.length, 'fotógrafo asignado', 'fotógrafos asignados'),
          estudio: formatCop(total - comisiones),
        ),
        const SizedBox(height: 28),
        EncabezadoSeccion('FOTÓGRAFOS (${liquidaciones.length})',
            marca: const SvgIcon('nuevo_cierre/fotografos.svg', width: 16.5, height: 12), dato: 'Detalle individual'),
        for (final (i, l) in liquidaciones.indexed) ...[
          SizedBox(height: i == 0 ? 16 : 12),
          FotografoComisionCard(
            fotografo: l.fotografo,
            detalle: '${_plural(l.sesiones.length, 'servicio', 'servicios')} | Tasa ${l.tasa}%',
            comision: formatCop(l.comision),
            base: '${formatCop(l.base)} COP',
            // El primero muestra su sesión más reciente.
            sesion: i == 0 ? 'Sesión ${l.sesiones.first.cliente} (${formatCop(l.sesiones.first.tarifa)})' : null,
            sesionComision: i == 0 ? '${formatCop(l.comisionDe(l.sesiones.first.tarifa))} COP' : null,
            destacado: i == 0,
          ),
        ],
        const SizedBox(height: 28),
        HexButton(
          label: _guardando ? 'Generando cierre…' : 'Confirmar y Generar Cierre Contable',
          radius: 2,
          height: 54,
          shadow: AppShadows.medium,
          background: _valido ? Colors.black : AppColors.outlineVariant,
          onPressed: _valido && !_guardando ? _confirmar : null,
          leading: const SvgIcon('nuevo_cierre/lock.svg', width: 13.3, height: 17.5),
          textStyle: AppText.sans(17, weight: FontWeight.w600, color: Colors.white, lineHeight: 22),
        ),
      ],
    ));
  }
}

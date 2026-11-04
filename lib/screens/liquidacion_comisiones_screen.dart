import 'package:flutter/material.dart';

import '../api/api.dart';
import '../data/mock_cierres.dart';
import '../models/cierre.dart';
import '../models/liquidacion.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/cierres/cierre_cards.dart';
import '../widgets/cierres/liquidacion_widgets.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';

/// Figma: "HexLens - Liquidación de Comisiones" (19:4794)
class LiquidacionComisionesScreen extends StatefulWidget {
  const LiquidacionComisionesScreen({super.key, this.cierre});

  /// Cierre a liquidar. Por defecto, el más reciente.
  final Cierre? cierre;

  @override
  State<LiquidacionComisionesScreen> createState() => _LiquidacionComisionesScreenState();
}

class _LiquidacionComisionesScreenState extends State<LiquidacionComisionesScreen> {
  int _sel = 1; // 0 = Todos

  Cierre? get _cierre => widget.cierre ?? cierres.firstOrNull;

  /// Comisiones por fotógrafo (de la API si hay sesión); null mientras se consultan.
  List<Liquidacion>? _liquidaciones;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final cierre = _cierre;
    if (cierre == null) {
      setState(() => _liquidaciones = const []);
      return;
    }
    setState(() {
      _liquidaciones = null;
      _error = null;
    });
    try {
      final liquidaciones = await liquidacionesDe(cierre);
      if (mounted) setState(() => _liquidaciones = liquidaciones);
    } on ApiError catch (e) {
      if (mounted) {
        setState(() {
          _error = e.mensaje;
          _liquidaciones = const [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cierre = _cierre;
    final liquidaciones = _liquidaciones;
    if (cierre == null || liquidaciones == null || liquidaciones.isEmpty) {
      return HeaderScaffold(
        header: HexHeader(title: 'Liquidación de Comisiones'),
        bottomPadding: 28,
        children: [
          const SizedBox(height: 24),
          if (liquidaciones == null)
            const Center(child: CircularProgressIndicator())
          else
            InfoBox(
              icon: _error == null ? Icons.info_outline : Icons.cloud_off,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _error ??
                        (cierre == null
                            ? 'Aún no hay cierres. Genera uno en Cierres de Período.'
                            : 'Este cierre no tiene comisiones: no hubo servicios realizados en el período.'),
                    style: AppText.sans(14, lineHeight: 18),
                  ),
                  if (_error != null) TextButton(onPressed: _cargar, child: const Text('Reintentar')),
                ],
              ),
            ),
        ],
      );
    }
    if (_sel > liquidaciones.length) _sel = 0;
    final visibles = _sel == 0 ? liquidaciones : [liquidaciones[_sel - 1]];

    return HeaderScaffold(
      header: HexHeader(title: 'Liquidación de Comisiones'),
      bottomPadding: 28,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Flexible(child: FinanceTag('CIERRE ${cierre.codigo} · QUINCENAL')),
            const SizedBox(width: 8),
            const Dot(size: 6, color: AppColors.accentBright),
            const SizedBox(width: 4),
            Text(cierre.estado == EstadoCierre.liquidado ? 'LIQUIDADO' : 'AUDITADO',
                style: AppText.sans(13, weight: FontWeight.w600, color: AppColors.accentBright)),
          ],
        ),
        const SizedBox(height: 12),
        Text('LIQUIDACIÓN DE COMISIONES', style: AppText.sans(24, weight: FontWeight.w700, lineHeight: 30, letterSpacing: -0.4)),
        IconoTexto(const SvgIcon('liquidacion/periodo.svg', width: 12, height: 13.3),
            'Período: ${fechaCorta(cierre.inicio)} – ${fechaCorta(cierre.fin)}',
            estilo: AppText.sans(16, lineHeight: 22)),
        const SizedBox(height: 16),
        LiquidacionSelector(liquidaciones: liquidaciones, selected: _sel, onSelect: (i) => setState(() => _sel = i)),
        const SizedBox(height: 24),
        for (final l in visibles) ...[
          LiquidacionResumenCard(liquidacion: l),
          const SizedBox(height: 24),
          EncabezadoSeccion('SESIONES ASIGNADAS (${l.sesiones.length})',
              marca: const SvgIcon('liquidacion/sesiones.svg', width: 15, height: 15.8), dato: 'Tarifa / Split'),
          const SizedBox(height: 12),
          for (final s in l.sesiones) ...[SesionLiquidadaCard(sesion: s, tasa: l.tasa), const SizedBox(height: 16)],
          const SizedBox(height: 8),
        ],
        FormulaLiquidacion(porcentaje: _sel == 0 ? 'según cada contrato' : '${visibles.single.tasa}%'),
        const SizedBox(height: 24),
        HexButton(
          label: 'Exportar Comprobante de Liquidación',
          radius: 2,
          height: 54,
          shadow: AppShadows.medium,
          // La API no genera comprobantes: se avisa en vez de fingir una exportación.
          onPressed: () => showHexToast(context, 'La exportación a PDF aún no está disponible'),
          leading: const SvgIcon('liquidacion/exportar.svg', width: 13.3, height: 13.3),
          textStyle: AppText.sans(17, weight: FontWeight.w500, color: Colors.white, lineHeight: 22),
        ),
      ],
    );
  }
}

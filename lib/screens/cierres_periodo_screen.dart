import 'package:flutter/material.dart';

import '../core/reloj.dart';
import '../data/mock_cierres.dart';
import '../models/cierre.dart';
import '../services/local/sesion_actual.dart';
import '../services/remote/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/cierres/cierre_cards.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';

export '../widgets/cierres/cierre_cards.dart' show FinanceTag;

class CierresPeriodoScreen extends StatefulWidget {
  const CierresPeriodoScreen({super.key, this.onNuevoCierre, this.onVerDetalle});

  final VoidCallback? onNuevoCierre;

  final ValueChanged<Cierre>? onVerDetalle;

  @override
  State<CierresPeriodoScreen> createState() => _CierresPeriodoScreenState();
}

class _CierresPeriodoScreenState extends State<CierresPeriodoScreen> with RedibujarAlCambiar {
  @override
  Listenable get escuchar => revisionCierres;

  int _filtro = 0;

  bool _cargando = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  Future<void> _recargar() async {
    if (!SesionActual.conectada) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await sincronizarCierres();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  static List<DateTime> get _meses =>
      {for (final c in cierres) DateTime(c.inicio.year, c.inicio.month)}.toList()..sort((a, b) => b.compareTo(a));

  @override
  Widget build(BuildContext context) {
    final meses = _meses;
    if (_filtro > meses.length) _filtro = 0;
    final filtros = ['Todos', for (final m in meses) nombreMes(m)];
    final mes = _filtro == 0 ? null : meses[_filtro - 1];
    final visibles =
        cierres.where((c) => mes == null || (c.inicio.year == mes.year && c.inicio.month == mes.month)).toList();
    final total = visibles.fold(0, (s, c) => s + c.total);
    final staff = visibles.fold(0, (s, c) => s + c.staff);
    return HeaderScaffold(
      header: HexHeader(title: 'Cierres de Período'),
      bottomPadding: 40,
      children: [
        const SizedBox(height: 16),
        const FinanceTag('FINANZAS · CIERRES Y CAJA'),
        const SizedBox(height: 10),
        Text('Cierres de Período', style: AppText.sans(32, weight: FontWeight.w700, lineHeight: 40, letterSpacing: -0.6)),
        const SizedBox(height: 6),
        Text('Consolidación de servicios realizados y balance para liquidación',
            style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22)),
        const SizedBox(height: 20),
        NuevoCierreBoton(onTap: widget.onNuevoCierre),
        const SizedBox(height: 24),
        PeriodoFiltros(
          anio: Reloj.hoy.year,
          filtros: filtros,
          selected: _filtro,
          onSelect: (i) => setState(() => _filtro = i),
        ),
        const SizedBox(height: 24),
        ResumenConsolidadoCard(total: formatCop(total), staff: formatCop(staff), estudio: formatCop(total - staff)),
        const SizedBox(height: 20),
        EncabezadoSeccion('HISTORIAL DE CIERRES',
            marca: const MarcaSeccion(),
            dato: '${visibles.length} ${visibles.length == 1 ? 'registro' : 'registros'}'),
        const SizedBox(height: 16),
        if (_cargando)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
        else if (_error != null) ...[
          InfoBox(
            icon: Icons.cloud_off,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_error!, style: AppText.sans(14, lineHeight: 18)),
                TextButton(onPressed: _recargar, child: const Text('Reintentar')),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ] else if (visibles.isEmpty) ...[
          Text(cierres.isEmpty ? 'Aún no hay cierres. Genera el primero con "Nuevo Cierre".' : 'Sin cierres en este periodo.',
              style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22)),
          const SizedBox(height: 24),
        ],
        for (final (i, c) in _cargando ? const <(int, Cierre)>[] : visibles.indexed) ...[
          CierreCard(cierre: c, onVerDetalle: widget.onVerDetalle == null ? null : () => widget.onVerDetalle!(c)),
          SizedBox(height: i == visibles.length - 1 ? 24 : 20),
        ],
        const ReglaConsolidacion(),
      ],
    );
  }
}

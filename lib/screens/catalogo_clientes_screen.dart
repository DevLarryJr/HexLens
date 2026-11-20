import 'package:flutter/material.dart';

import '../data/mock_agenda.dart';
import '../data/mock_clientes.dart';
import '../models/cliente.dart';
import '../models/sesion.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/clientes/cliente_card.dart';
import '../widgets/hex_chips.dart';
import '../widgets/hex_search_field.dart';
import '../widgets/hex_widgets.dart';

class CatalogoClientesScreen extends StatefulWidget {
  const CatalogoClientesScreen({
    super.key,
    this.bottomBar,
    this.onNuevoCliente,
    this.onAgendar,
    this.onVerFicha,
    this.onSinResultados,
  });

  final Widget? bottomBar;
  final VoidCallback? onNuevoCliente;
  final VoidCallback? onAgendar;
  final VoidCallback? onVerFicha;

  final ValueChanged<String>? onSinResultados;

  @override
  State<CatalogoClientesScreen> createState() => _CatalogoClientesScreenState();
}

class _CatalogoClientesScreenState extends State<CatalogoClientesScreen> with ConBusqueda, RedibujarAlCambiar {
  @override
  Listenable get escuchar => revisionClientes;

  int _filtro = 0;

  List<Cliente> get _visibles {
    return clientes.where((c) {
      final porFiltro = switch (_filtro) {
        1 => c.estado == EstadoCliente.programada || c.estado == EstadoCliente.activaHoy,
        2 => c.estado == EstadoCliente.frecuente,
        _ => true,
      };
      return porFiltro && c.coincide(busqueda.text);
    }).toList();
  }

  static String _detalle(Cliente c) {
    if (c.estado != EstadoCliente.programada) return c.detalle;
    final proximas = sesionesAgenda
        .where((s) => s.cliente == c.nombre && s.estado == SesionEstado.programada)
        .toList()
      ..sort((a, b) => a.inicio.compareTo(b.inicio));
    if (proximas.isEmpty) return c.detalle;
    final s = proximas.first;
    return '${s.nombreServicio} · ${s.inicio.day} ${mesCorto(s.inicio)}, ${horaCorta(s.inicio)} ${s.lugar}';
  }

  @override
  Widget build(BuildContext context) {
    final visibles = _visibles;
    return HeaderScaffold(
      header: const HexHeader(section: 'Clientes'),
      bottomBar: widget.bottomBar,
      bottomPadding: 96 + 80,
      children: [
        const SizedBox(height: 4),
        _encabezado(),
        const SizedBox(height: 20),
        _buscador(),
        const SizedBox(height: 20),
        if (visibles.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text('Sin coincidencias para "${busqueda.text}"',
                  style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
            ),
          ),
        for (final c in visibles) ...[
          ClienteCard(cliente: c, detalle: _detalle(c), onVerFicha: widget.onVerFicha, onAgendar: widget.onAgendar),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 4),
        const _BaseDatos(),
      ],
    );
  }

  Widget _encabezado() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Dot(size: 8),
                const SizedBox(width: 4),
                Text('BASE OPERATIVA',
                    style: AppText.sans(14,
                        weight: FontWeight.w600, color: AppColors.onSurfaceVariant, lineHeight: 18, letterSpacing: 0.7)),
              ],
            ),
            Tag(
              label: '${clientes.length} Registrados',
              radius: 12,
              background: AppColors.surfaceHigh,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              style: AppText.sans(14, weight: FontWeight.w500, lineHeight: 18),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Directorio\nClientes',
                style: AppText.sans(28, weight: FontWeight.w700, lineHeight: 36, letterSpacing: -0.7)),
            SizedBox(
              width: 112,
              child: HexButton(
                label: '+\nNuevo',
                gap: 4,
                shadow: AppShadows.medium,
                onPressed: widget.onNuevoCliente,
                leading: const SvgIcon('clientes/person_add.svg', width: 18.333, height: 13.333),
                textStyle: AppText.sans(16, weight: FontWeight.w500, color: Colors.white, lineHeight: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buscador() {
    final filtros = ['Todos (${clientes.length})', 'Sesiones Activas', '★ Frecuentes'];
    return Column(
      children: [
        HexSearchField(
          controller: busqueda,
          hint: 'Buscar por nombre, C.C. o celular...',
          icon: const SvgIcon('clientes/search.svg', width: 15),
          onChanged: (_) => setState(() {}),
          onSubmitted: (v) {
            if (_visibles.isEmpty) widget.onSinResultados?.call(v);
          },
          textInputAction: TextInputAction.search,
          suffix: const Padding(padding: EdgeInsets.all(15), child: SvgIcon('clientes/tune.svg', width: 10.5)),
        ),
        const SizedBox(height: 8),
        HexChipBar(
          itemCount: filtros.length,
          itemBuilder: (_, i) => HexChip(
            label: filtros[i],
            selected: i == _filtro,
            onTap: () => setState(() => _filtro = i),
            color: AppColors.surfaceHigh,
            selectedShadow: AppShadows.soft,
            leading: i == 1 ? const Dot() : null,
            style: AppText.sans(14, weight: FontWeight.w500, lineHeight: 18),
          ),
        ),
      ],
    );
  }
}

class _BaseDatos extends StatelessWidget {
  const _BaseDatos();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHighFaded,
        borderRadius: AppRadius.md,
        boxShadow: AppShadows.hairline,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.black, borderRadius: AppRadius.xs),
            child: const SvgIcon('clientes/sync.svg', width: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Base de Datos Local', style: AppText.sans(14, weight: FontWeight.w600, lineHeight: 18)),
                Text('Sincronizado vía HexLens Cloud',
                    style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
              ],
            ),
          ),
          Text('EN LÍNEA', style: AppText.mono(14, weight: FontWeight.w700, color: AppColors.accent, lineHeight: 18)),
        ],
      ),
    );
  }
}

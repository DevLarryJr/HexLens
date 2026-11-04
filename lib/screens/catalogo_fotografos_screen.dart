import 'package:flutter/material.dart';

import '../api/api.dart';
import '../core/reloj.dart';
import '../data/estado_staff.dart';
import '../data/mock_especialidades.dart';
import '../data/mock_fotografos.dart';
import '../data/mock_inasistencias.dart';
import '../models/fotografo.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/fotografos/fotografo_card.dart';
import '../widgets/hex_chips.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_search_field.dart';
import '../widgets/hex_widgets.dart';
import 'actualizar_condiciones_screen.dart';

/// Figma: "HexLens - Catálogo de Fotógrafos" (19:2985)
class CatalogoFotografosScreen extends StatefulWidget {
  const CatalogoFotografosScreen({
    super.key,
    this.onRegistrar,
    this.onJornada,
    this.onInasistencia,
    this.onHorarios,
    this.onComisiones,
  });

  final VoidCallback? onRegistrar;
  final VoidCallback? onJornada;
  final VoidCallback? onInasistencia;
  final VoidCallback? onHorarios;
  final VoidCallback? onComisiones;

  @override
  State<CatalogoFotografosScreen> createState() => _CatalogoFotografosScreenState();
}

class _CatalogoFotografosScreenState extends State<CatalogoFotografosScreen> with ConBusqueda, RedibujarAlCambiar {
  @override
  Listenable get escuchar => revisionFotografos;

  int _filtro = 0;

  /// Consultando la API al abrir.
  bool _cargando = false;

  /// Error al consultar la API; null si no hubo.
  String? _error;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  /// Trae especialidades y profesionales de la API (las especialidades dan el nombre de la de cada uno).
  Future<void> _recargar() async {
    if (!Api.conectada) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await sincronizarEspecialidades();
      await sincronizarFotografos();
    } on ApiError catch (e) {
      _error = e.mensaje;
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// "Todos" + las especialidades del staff, en orden de aparición.
  List<String> get _filtros => [
        'Todos',
        ...{for (final f in fotografos) f.especialidad},
      ];

  Future<void> _reactivar(Fotografo f) async {
    try {
      await cambiarEstadoFotografo(f, activo: true);
      if (mounted) showHexToast(context, '${f.nombre} reactivado');
    } on ApiError catch (e) {
      if (mounted) showHexToast(context, e.mensaje);
    }
  }

  /// Por qué está inactivo: una ausencia vigente hoy (licencia, permiso…) o su estado en el staff.
  String _motivoInactivo(Fotografo f) =>
      inasistencias.any((i) => i.fotografo == f.nombre && i.cubre(Reloj.hoy)) ? 'LICENCIA TEMPORAL' : 'INACTIVO';

  /// "Ver Ficha" / "Editar": abre las condiciones de ese fotógrafo.
  void _verFicha(Fotografo f) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ActualizarCondicionesScreen(fotografo: f)));

  @override
  Widget build(BuildContext context) {
    final filtros = _filtros;
    if (_filtro >= filtros.length) _filtro = 0;
    final activos = fotografos.where((f) => estadoEnTiempoReal(f) != EstadoFotografo.inactivo).length;
    final visibles = fotografos
        .where((f) => _filtro == 0 || f.especialidad == filtros[_filtro])
        .where((f) => coincideBusqueda(busqueda.text, [f.nombre, f.documento, f.equipo]))
        .toList();

    return HeaderScaffold(
      header: HexHeader(title: 'Fotógrafos'),
      bottomPadding: 28,
      children: [
        const SizedBox(height: 16),
        _cabecera(),
        const SizedBox(height: 16),
        if (_cargando)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          InfoBox(
            icon: Icons.cloud_off,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_error!, style: AppText.sans(14, lineHeight: 18)),
                TextButton(onPressed: _recargar, child: const Text('Reintentar')),
              ],
            ),
          )
        else if (visibles.isEmpty)
          InfoBox(
            icon: Icons.info_outline,
            child: Text(
              fotografos.isEmpty ? 'Aún no hay fotógrafos. Registra el primero con "+ Registrar".' : 'Ningún fotógrafo coincide.',
              style: AppText.sans(14, lineHeight: 18),
            ),
          ),
        for (var i = 0; i < visibles.length && !_cargando; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          FotografoCard(
            fotografo: visibles[i],
            estado: estadoEnTiempoReal(visibles[i]),
            onJornada: widget.onJornada,
            onInasistencia: widget.onInasistencia,
            onHorarios: widget.onHorarios,
            onComisiones: widget.onComisiones,
            onEditarFicha: () => _verFicha(visibles[i]),
            onReactivar: () => _reactivar(visibles[i]),
            motivoInactivo: _motivoInactivo(visibles[i]),
          ),
        ],
        const SizedBox(height: 20),
        const _ReglaComisiones(),
        const SizedBox(height: 16),
        _EstadoTurno(texto: '$activos ${activos == 1 ? 'fotógrafo activo' : 'fotógrafos activos'} en turno hoy'),
      ],
    );
  }

  Widget _cabecera() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Dot(size: 8),
                      const SizedBox(width: 4),
                      Text(
                        'EQUIPO HEXLENS',
                        style: AppText.sans(
                          14,
                          weight: FontWeight.w600,
                          color: AppColors.accent,
                          lineHeight: 18,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Equipo de Fotógrafos',
                    style: AppText.sans(20, weight: FontWeight.w700, lineHeight: 28, letterSpacing: -0.5),
                  ),
                  Text(
                    'Gestión de Staff y Asignación Operativa',
                    style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 20),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.black,
              borderRadius: AppRadius.sm,
              elevation: 2,
              child: InkWell(
                onTap: widget.onRegistrar,
                borderRadius: AppRadius.sm,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconoTexto(const SvgIcon('fotografos/person_add.svg', width: 16.5, height: 12), '+ Registrar',
                      estilo: AppText.sans(12, weight: FontWeight.w600, color: Colors.white, lineHeight: 16),
                      separacion: 4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        HexSearchField(
          controller: busqueda,
          hint: 'Buscar por nombre, cédula o equipo...',
          icon: const SvgIcon('fotografos/search.svg', width: 15),
          iconPadding: const EdgeInsets.only(left: 16, right: 13),
          onChanged: (_) => setState(() {}),
          textStyle: AppText.sans(16, weight: FontWeight.w500),
          hintStyle: AppText.sans(16, weight: FontWeight.w500, color: AppColors.outline),
        ),
        const SizedBox(height: 8),
        HexChipBar(
          height: 38,
          itemCount: _filtros.length,
          itemBuilder: (_, i) {
            final selected = i == _filtro;
            return Center(
              child: HexChip(
                label: _filtros[i],
                selected: selected,
                onTap: () => setState(() => _filtro = i),
                color: AppColors.surfaceLow,
                foreground: AppColors.onSurfaceVariant,
                selectedShadow: AppShadows.soft,
                style: AppText.sans(14, weight: FontWeight.w500, lineHeight: 18),
                leading: i == 0
                    ? SvgIcon(
                        'fotografos/bolt.svg',
                        width: 9.333,
                        height: 11.667,
                        color: selected ? null : AppColors.onSurfaceVariant,
                      )
                    : null,
                trailingGap: 10,
                trailing: i == 0
                    ? Tag(label: '${fotografos.length}', background: AppColors.surfaceHigh, radius: 12, padding: const EdgeInsets.symmetric(horizontal: 6),
                        style: AppText.sans(11, weight: FontWeight.w700, lineHeight: 18))
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ReglaComisiones extends StatelessWidget {
  const _ReglaComisiones();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: AppRadius.md,
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.black, borderRadius: AppRadius.sm),
            child: const SvgIcon('fotografos/info.svg', width: 15),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Regla de Asignación y Comisiones',
                  style: AppText.sans(16, weight: FontWeight.w700, lineHeight: 20, letterSpacing: -0.4),
                ),
                Text(
                  'La comisión se liquida automáticamente sobre el valor de cada servicio '
                  'completado en los cierres de período.',
                  style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 22.75),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoTurno extends StatelessWidget {
  const _EstadoTurno({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      radius: 4,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Dot(size: 10),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texto, style: AppText.sans(12, weight: FontWeight.w500, lineHeight: 18)),
          ),
        ],
      ),
    );
  }
}

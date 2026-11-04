import 'package:flutter/material.dart';

import '../core/reloj.dart';
import '../data/mock_agenda.dart';
import '../data/mock_mis_servicios.dart';
import '../models/sesion.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/hex_chips.dart';
import '../widgets/hex_search_field.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/mis_servicios/servicio_staff_card.dart';
import '../widgets/mis_servicios/staff_bottom_nav.dart';
import '../widgets/mis_servicios/staff_resumen_cards.dart';

/// Figma: "HexLens - Mis Servicios (Fotógrafo)" (19:5041). Inicio del rol Fotógrafo.
class MisServiciosScreen extends StatefulWidget {
  const MisServiciosScreen({super.key, this.onVerFicha, this.onComisiones, this.onCuenta});

  final VoidCallback? onVerFicha;
  final VoidCallback? onComisiones;
  final VoidCallback? onCuenta;

  @override
  State<MisServiciosScreen> createState() => _MisServiciosScreenState();
}

class _MisServiciosScreenState extends State<MisServiciosScreen> with ConBusqueda {
  int _filtro = 0;

  List<String> get _filtros => ['Todos (${misServicios.length})', 'Este mes', 'Retrato profesional', 'Graduación'];

  List<Sesion> get _visibles {
    return misServicios.where((s) {
      final txt = coincideBusqueda(busqueda.text, [s.cliente, s.codigo ?? '']);
      final servicio = s.descripcion.toLowerCase();
      final f = switch (_filtro) {
        1 => s.inicio.year == Reloj.hoy.year && s.inicio.month == Reloj.hoy.month,
        2 => servicio.contains('retrato'),
        3 => servicio.contains('graduación'),
        _ => true,
      };
      return txt && f;
    }).toList();
  }

  void _onNav(int i) {
    if (i == 1) widget.onComisiones?.call();
    if (i == 2) widget.onCuenta?.call();
  }

  /// Primera sesión programada de hoy, por hora de inicio.
  Sesion? get _proxima {
    final hoy = programadasDeHoy(misServicios)
      ..sort((a, b) => a.inicio.compareTo(b.inicio));
    return hoy.isEmpty ? null : hoy.first;
  }

  /// "Retrato Profesional" → "Retrato profesional".
  static String _oracion(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final visibles = _visibles;
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: StaffBottomNav(seleccion: 0, onSelect: _onNav),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 64 + top, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ModoStaffBanner(),
                const SizedBox(height: 16),
                SaludoStaffCard(
                  nombre: 'Sara',
                  saludo: saludoSegunHora(Reloj.ahora()),
                  foto: 'foto_staff_servicios.jpg',
                  id: 'HEX-LM89',
                  especialidad: 'Retratos',
                  camara: 'CAM\n02',
                ),
                const SizedBox(height: 16),
                ContadorServiciosCard(total: misServicios.length),
                const SizedBox(height: 16),
                if (_proxima case final p?) ...[
                  ProximaSesionCard(
                    titulo: 'Próxima sesión: Hoy ${horaAmPm(p.inicio)}',
                    cliente: p.cliente,
                    detalle: '${_oracion(p.descripcion)} • ${p.lugar}',
                  ),
                  const SizedBox(height: 16),
                ],
                _buscador(),
                const SizedBox(height: 16),
                if (visibles.isEmpty) ...[
                  HexCard(
                    color: AppColors.surfaceLow,
                    shadow: null,
                    child: Text('Ningún servicio coincide con la búsqueda.',
                        style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                  ),
                  const SizedBox(height: 16),
                ],
                for (final s in visibles) ...[
                  ServicioStaffCard(
                    sesion: s,
                    hoy: Reloj.hoy,
                    comisionPct: comisionStaffPct,
                    onVerFicha: widget.onVerFicha,
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 8),
                Center(
                  child: Text('✦  CÁMARA LISTA  ✦',
                      style: AppText.mono(11, color: AppColors.outline, lineHeight: 16, letterSpacing: 2)),
                ),
              ],
            ),
          ),
          const Positioned(top: 0, left: 0, right: 0, child: BlurTopBar(child: _Marca())),
        ],
      ),
    );
  }

  Widget _buscador() {
    return Column(
      children: [
        TextField(
          controller: busqueda,
          onChanged: (_) => setState(() {}),
          style: AppText.sans(16),
          decoration: InputDecoration(
            hintText: 'Buscar por cliente o código RSV...',
            hintStyle: AppText.sans(16, color: AppColors.outline),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Center(
              widthFactor: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: SvgIcon('mis_servicios/search.svg', width: 15, height: 20),
              ),
            ),
            border: OutlineInputBorder(borderRadius: AppRadius.sm, borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        HexChipBar(
          height: 34,
          itemCount: _filtros.length,
          itemBuilder: (_, i) => HexChip(
            label: _filtros[i],
            selected: i == _filtro,
            onTap: () => setState(() => _filtro = i),
            height: 34,
            radius: 4,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            style: AppText.sans(14, weight: FontWeight.w500, lineHeight: 18),
          ),
        ),
      ],
    );
  }
}

/// Logo, estado ONLINE y nombre de la sección en la barra superior.
class _Marca extends StatelessWidget {
  const _Marca();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/images/logo_hexlens.png', width: 110, height: 36, fit: BoxFit.contain),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('HEXLENS', style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 20)),
              Row(
                children: [
                  const Dot(size: 6, color: AppColors.accentBright),
                  const SizedBox(width: 4),
                  Text('EN LÍNEA', style: AppText.sans(12, color: AppColors.accentBright, lineHeight: 16)),
                  const SizedBox(width: 10),
                  Text('Mis Servicios', style: AppText.sans(14, weight: FontWeight.w500, lineHeight: 16)),
                ],
              ),
            ],
          ),
        ),
        const UserAvatar(icon: 'agenda/person.svg'),
      ],
    );
  }
}

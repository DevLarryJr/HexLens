import 'package:flutter/material.dart';

import '../data/mock_clientes.dart';
import '../data/mock_servicios.dart';
import '../models/cliente.dart';
import '../models/servicio.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/hex_chips.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/reserva/fotografo_opcion_cards.dart';
import '../widgets/reserva/reserva_stepper.dart';
import '../widgets/reserva/resumen_footer.dart';
import '../widgets/reserva/servicio_card.dart';

class NuevaReservaServicioScreen extends StatefulWidget {
  const NuevaReservaServicioScreen({super.key, this.onContinuar, this.onSalir, this.cliente});

  final ValueChanged<Servicio>? onContinuar;

  final VoidCallback? onSalir;

  final Cliente? cliente;

  @override
  State<NuevaReservaServicioScreen> createState() => _NuevaReservaServicioScreenState();
}

class _NuevaReservaServicioScreenState extends State<NuevaReservaServicioScreen> {
  final List<String> _categorias = ['Todas', ...{for (final s in serviciosReserva) s.categoria}];

  late int _categoria = _categorias.length > 1 ? 1 : 0;

  Servicio? _servicio = serviciosReserva.firstOrNull;
  int _fotografo = 1;

  static const _titulos = {
    'Retratos': 'Servicios de Retrato',
    'Familiar': 'Servicios Familiares',
    'Productos': 'Servicios de Producto',
    'Editorial': 'Servicios Editoriales',
  };

  String get _tituloServicios =>
      _categoria == 0 ? 'Todos los Servicios' : _titulos[_categorias[_categoria]] ?? 'Servicios de ${_categorias[_categoria]}';

  @override
  Widget build(BuildContext context) {
    void back() => Navigator.of(context).maybePop();

    return HeaderScaffold(
      header: HexHeader(title: 'Nueva Reserva', cerrar: true, onBack: widget.onSalir),
      bottomPadding: 170,
      overlay: Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: ResumenFooter(
          precio: _servicio == null ? '—' : formatCop(_servicio!.precio),
          duracion: _servicio?.duracion ?? '—',
          asignacion: _fotografo == 1 ? 'Fotógrafa disponible' : 'Auto-asignación',
          onBack: back,
          onContinuar: _servicio == null || widget.onContinuar == null ? null : () => widget.onContinuar!(_servicio!),
        ),
      ),
      children: [
        const _Intro(),
        const SizedBox(height: 16),
        ReservaStepper(
          current: 1,
          cliente: (widget.cliente ?? clienteEjemplo).nombre,
          documento: (widget.cliente ?? clienteEjemplo).documento,
        ),
        const SizedBox(height: 20),
        _especialidades(),
        const SizedBox(height: 20),
        _servicios(),
        const SizedBox(height: 28),
        _fotografos(),
      ],
    );
  }

  Widget _especialidades() {
    return Column(
      children: [
        _SectionTitle(
          'Selecciona Especialidad',
          trailing: Text('${_categorias.length - 1} categorías',
              style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
        ),
        const SizedBox(height: 8),
        HexChipBar(
          itemCount: _categorias.length,
          itemBuilder: (_, i) {
            final selected = i == _categoria;
            return HexChip(
              label: _categorias[i],
              selected: selected,
              onTap: () => setState(() => _categoria = i),
              color: AppColors.surfaceContainer,
              shadow: AppShadows.soft,
              leading: selected ? const Dot(size: 8) : null,
              style: AppText.sans(14, weight: selected ? FontWeight.w600 : FontWeight.w400, lineHeight: 18),
            );
          },
        ),
      ],
    );
  }

  Widget _servicios() {
    final visibles = _categoria == 0
        ? serviciosReserva
        : serviciosReserva.where((s) => s.categoria == _categorias[_categoria]).toList();

    return Column(
      children: [
        _SectionTitle(
          _tituloServicios,
          trailing: IconoTexto(const SvgIcon('servicio/camera.svg', width: 13.333, height: 12), 'Estudio Norte',
              estilo: AppText.sans(14, weight: FontWeight.w500, color: AppColors.accent, lineHeight: 18),
              separacion: 4),
        ),
        const SizedBox(height: 16),
        if (visibles.isEmpty)
          InfoBox(
            icon: Icons.info_outline,
            child: Text('El estudio aún no tiene servicios. Créalos en Más → Servicios y Tarifas.',
                style: AppText.sans(14, lineHeight: 18)),
          ),
        for (final s in visibles) ...[
          if (s != visibles.first) const SizedBox(height: 16),
          ServicioCard(
            servicio: s,
            selected: s == _servicio,
            onTap: () => setState(() => _servicio = s),
          ),
        ],
      ],
    );
  }

  Widget _fotografos() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fotógrafo asignado',
                    style: AppText.sans(20, weight: FontWeight.w600, lineHeight: 28, letterSpacing: -0.2)),
                Text('Disponibilidad en tiempo real',
                    style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
              ],
            ),
            Tag(
              label: 'Automático',
              gap: 4,
              background: AppColors.accentContainer,
              leading: const SvgIcon('servicio/automatch.svg', width: 11.25, height: 13.125),
              style: AppText.sans(14, weight: FontWeight.w600, color: AppColors.onAccentContainer, lineHeight: 18),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AutoAsignarCard(selected: _fotografo == 0, onTap: () => setState(() => _fotografo = 0)),
        const SizedBox(height: 16),
        FotografoRecomendadoCard(
          nombre: 'Laura Méndez',
          foto: 'foto_laura.jpg',
          detalle: 'Retratos • Comisión: 30%',
          disponibilidad: 'Disponible para ${_servicio?.nombre ?? "el servicio"}',
          score: '4.9',
          equipo: 'Sony A7R V • Lente 85mm f/1.4 GM',
          selected: _fotografo == 1,
          onTap: () => setState(() => _fotografo = 1),
        ),
        const SizedBox(height: 16),
        FotografoNoDisponibleCard(
          nombre: 'Nicolás Vega',
          foto: 'foto_nicolas.jpg',
          especialidad: 'Editorial',
          motivo: 'Incompatible: No cubre categoría ${_servicio?.categoria ?? ""} en esta sede.',
        ),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconoTexto(const SvgIcon('servicio/workflow.svg', width: 13.75), 'RESERVAS', estilo: AppText.sans(14,
                        weight: FontWeight.w600, color: AppColors.accent, lineHeight: 18, letterSpacing: 0.7), separacion: 4),
            Text('Servicio',
                style: AppText.sans(14, weight: FontWeight.w500, color: AppColors.onSurfaceVariant, lineHeight: 18)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Nueva Reserva',
            style: AppText.sans(28, weight: FontWeight.w700, lineHeight: 36, letterSpacing: -0.56)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {required this.trailing});

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(title,
              style: AppText.sans(20, weight: FontWeight.w600, lineHeight: 28, letterSpacing: -0.2)),
        ),
        trailing,
      ],
    );
  }
}

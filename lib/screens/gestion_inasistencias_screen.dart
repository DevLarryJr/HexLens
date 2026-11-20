import 'package:flutter/material.dart';

import '../core/reloj.dart';
import '../data/mock_agenda.dart';
import '../data/mock_fotografos.dart';
import '../data/mock_inasistencias.dart';
import '../models/inasistencia.dart';
import '../theme/app_theme.dart';
import '../widgets/hex_chips.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/staff/inasistencia_card.dart';
import '../widgets/staff/staff_tabs.dart';

class GestionInasistenciasScreen extends StatefulWidget {
  const GestionInasistenciasScreen({super.key, this.onRegistrar, this.onJornada});

  final VoidCallback? onRegistrar;
  final VoidCallback? onJornada;

  @override
  State<GestionInasistenciasScreen> createState() => _GestionInasistenciasScreenState();
}

class _GestionInasistenciasScreenState extends State<GestionInasistenciasScreen> {
  int _filtro = 1;

  final _liberadas = <String>{};

  static int _citasAfectadas(Inasistencia i) => sesionesAgenda.where((s) {
        final dia = DateTime(s.inicio.year, s.inicio.month, s.inicio.day);
        return s.fotografo == i.fotografo && !s.cancelada && !dia.isBefore(i.desde) && !dia.isAfter(i.hasta);
      }).length;

  @override
  Widget build(BuildContext context) {
    final registradas = inasistencias.where((i) => !_liberadas.contains(i.id)).toList();
    final vigentes = registradas.where((i) => i.vigenteEn(Reloj.hoy)).toList();
    final historial = registradas.where((i) => !i.vigenteEn(Reloj.hoy)).toList();
    final visibles = [registradas, vigentes, historial][_filtro];

    return HeaderScaffold(
      header: HexHeader(
        title: 'Inasistencias',
      ),
      bottomPadding: 28,
      children: [
        const SizedBox(height: 8),
        StaffTabs(current: 1, onTap: (i) => i == 0 ? widget.onJornada?.call() : null),
        const SizedBox(height: 16),
        const _StaffActivo(),
        const SizedBox(height: 16),
        _RegistrarButton(onTap: widget.onRegistrar),
        const SizedBox(height: 16),
        _filtros([registradas.length, vigentes.length, historial.length]),
        const SizedBox(height: 16),
        for (final i in visibles) ...[
          InasistenciaCard(
            inasistencia: i,
            citasAfectadas: _citasAfectadas(i),
            especialidad: fotografoPorNombre(i.fotografo)?.especialidad ?? '',
            onEditar: widget.onRegistrar,
            onLiberar: () => setState(() => _liberadas.add(i.id)),
          ),
          const SizedBox(height: 16),
        ],
        const _FlujoAgendamiento(),
      ],
    );
  }

  Widget _filtros(List<int> conteos) {
    const etiquetas = ['Todas', 'Vigentes / Futuras', 'Historial Pasado'];
    return HexChipBar(
      itemCount: etiquetas.length,
      itemBuilder: (_, i) {
        final selected = i == _filtro;
        return HexChip(
          label: etiquetas[i],
          selected: selected,
          onTap: () => setState(() => _filtro = i),
          radius: 2,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shadow: AppShadows.soft,
          leading: selected ? const Dot(size: 6, color: AppColors.accentBright) : null,
          leadingGap: 8,
          trailingGap: 8,
          trailing: Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.graphite : AppColors.surfaceHigh,
              shape: BoxShape.circle,
            ),
            child: Text('${conteos[i]}',
                style: AppText.sans(12,
                    weight: FontWeight.w600, color: selected ? Colors.white : AppColors.onSurfaceVariant)),
          ),
          style: AppText.sans(16, weight: FontWeight.w500, lineHeight: 20),
        );
      },
    );
  }
}

class _StaffActivo extends StatelessWidget {
  const _StaffActivo();

  @override
  Widget build(BuildContext context) {
    Widget chip(String label) => Tag(label: label, background: AppColors.surfaceHigh,
        style: AppText.sans(14, lineHeight: 18));

    return HexCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SvgIcon('inasistencias/sparkle.svg', width: 14, height: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text('FOTÓGRAFO',
                    style: AppText.sans(14,
                        weight: FontWeight.w600, color: AppColors.accent, lineHeight: 18, letterSpacing: 0.7)),
              ),
              Text('ID: HEX-LM89', style: AppText.mono(13, lineHeight: 18)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.sm,
                    child: Image.asset('assets/images/foto_sara_mendez.jpg', width: 56, height: 56, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Dot(size: 10, color: AppColors.accentBright),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sara Méndez',
                        style: AppText.sans(20, weight: FontWeight.w600, lineHeight: 28, letterSpacing: -0.2)),
                    Text('C.C. 52.890.123 • Esp. Retratos',
                        style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Alternar:', style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
              const SizedBox(width: 8),
              chip('Nicolás V.'),
              const SizedBox(width: 6),
              chip('Mateo R.'),
              const Spacer(),
              Text('Cambiar', style: AppText.sans(14, weight: FontWeight.w600, lineHeight: 18)),
              const SizedBox(width: 4),
              const SvgIcon('inasistencias/swap.svg', width: 13.3, height: 10.7),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegistrarButton extends StatelessWidget {
  const _RegistrarButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      borderRadius: AppRadius.xs,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.xs,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(color: AppColors.accentBright, shape: BoxShape.circle),
                child: const SvgIcon('inasistencias/plus.svg', width: 10.5, height: 10.5),
              ),
              Expanded(
                child: Text('Registrar Nueva\nInasistencia',
                    textAlign: TextAlign.center,
                    style: AppText.sans(16, weight: FontWeight.w500, color: Colors.white, lineHeight: 24)),
              ),
              Text('BLOQUEA\nAGENDA',
                  textAlign: TextAlign.center,
                  style: AppText.mono(12, color: AppColors.outline, lineHeight: 18, letterSpacing: 1.2)),
              const SizedBox(width: 12),
              const SvgIcon('inasistencias/bloqueo_iso.svg', width: 13.5, height: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlujoAgendamiento extends StatelessWidget {
  const _FlujoAgendamiento();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: AppRadius.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: Colors.black, borderRadius: AppRadius.sm),
                child: const SvgIcon('inasistencias/flujo.svg', width: 13.3, height: 12),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Efecto en las\nreservas', style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
              ),
              Text('Paso 3', style: AppText.mono(13, weight: FontWeight.w700, color: AppColors.accent, lineHeight: 18)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Cualquier fecha registrada como inasistencia inhabilita automáticamente la selección de '
            'este fotógrafo en el Paso 3 (Fecha y Hora) del módulo de reservas públicas e internas.',
            style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 26),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Estado:', style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
              const SizedBox(width: 12),
              const Dot(size: 6, color: AppColors.accentBright),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Activo', style: AppText.mono(13, color: AppColors.accent, lineHeight: 18)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

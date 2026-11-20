import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../calendario_mensual.dart';
import '../hex_widgets.dart';

class DiaSemana {
  const DiaSemana(this.letra, this.numero, {this.puntos = 0, this.alerta = false, this.domingo = false});

  final String letra;
  final int numero;

  final int puntos;

  final bool alerta;
  final bool domingo;
}

class SemanaStrip extends StatelessWidget {
  const SemanaStrip({
    super.key,
    required this.titulo,
    required this.semana,
    required this.dias,
    required this.seleccion,
    this.onSelect,
    this.onAnterior,
    this.onSiguiente,
    this.onTitulo,
  });

  final String titulo;

  final String semana;
  final List<DiaSemana> dias;
  final int seleccion;
  final ValueChanged<int>? onSelect;

  final VoidCallback? onAnterior;
  final VoidCallback? onSiguiente;

  final VoidCallback? onTitulo;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                InkWell(
                  onTap: onTitulo,
                  borderRadius: AppRadius.xs,
                  child: Row(
                    children: [
                      Text(titulo, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                      if (onTitulo != null)
                        const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.onSurfaceVariant),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Tag(
                  label: semana,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18),
                ),
                const Spacer(),
                FlechaCalendario(Icons.chevron_left, etiqueta: 'Semana anterior', onTap: onAnterior),
                const SizedBox(width: 4),
                FlechaCalendario(Icons.chevron_right, etiqueta: 'Semana siguiente', onTap: onSiguiente),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (var i = 0; i < dias.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: _DiaButton(dia: dias[i], selected: i == seleccion, onTap: () => onSelect?.call(i)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DiaButton extends StatelessWidget {
  const _DiaButton({required this.dia, required this.selected, required this.onTap});

  final DiaSemana dia;
  final bool selected;
  final VoidCallback onTap;

  Color _dotColor(int d) {
    if (selected) return Colors.white;
    if (dia.alerta || d == 0) return AppColors.accent;
    return AppColors.outlineVariant;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: AppRadius.xs,
          boxShadow: selected ? AppShadows.medium : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: selected ? 0.9 : (dia.domingo ? 0.5 : 1),
              child: Text(dia.letra,
                  style: AppText.sans(14, color: selected ? Colors.white : AppColors.onSurfaceVariant, lineHeight: 18)),
            ),
            Text(
              '${dia.numero}',
              style: AppText.sans(16,
                  weight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? Colors.white : (dia.domingo ? AppColors.onSurfaceVariant : AppColors.onSurface),
                  lineHeight: 20),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var d = 0; d < dia.puntos; d++) ...[
                    if (d > 0) const SizedBox(width: 2),
                    Dot(size: 4, color: _dotColor(d)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

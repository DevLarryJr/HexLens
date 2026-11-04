import 'package:flutter/material.dart';

import '../../models/bloque_horario.dart';
import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

/// Bloque de horario del día: libre (seleccionable), ocupado, almuerzo o ya pasado.
class BloqueTile extends StatelessWidget {
  const BloqueTile({
    super.key,
    required this.horario,
    required this.nota,
    required this.tipo,
    this.selected = false,
    this.onTap,
  });

  /// Ej.: "10:00 - 10:45 AM".
  final String horario;
  final String nota;
  final BloqueTipo tipo;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return switch (tipo) {
      BloqueTipo.ocupado => _ocupado('OCUPADO'),
      BloqueTipo.pasado => _ocupado('PASADO'),
      BloqueTipo.almuerzo => _almuerzo(),
      BloqueTipo.libre => _libre(),
    };
  }

  Widget _ocupado(String etiqueta) {
    return Opacity(
      opacity: 0.8,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: AppColors.surfaceHighFaded, borderRadius: AppRadius.md),
        child: Row(
          children: [
            const SvgIcon('fecha/busy.svg', width: 15, height: 16.667),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(horario,
                      style: AppText.sans(16,
                          weight: FontWeight.w500,
                          color: AppColors.outline,
                          lineHeight: 20,
                          decoration: TextDecoration.lineThrough)),
                  Text(nota, style: AppText.sans(11, color: AppColors.outline, lineHeight: 16.5)),
                ],
              ),
            ),
            Tag(
              label: etiqueta,
              radius: 0,
              background: AppColors.surfaceHighest,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              style: AppText.sans(11, weight: FontWeight.w600, color: AppColors.outline, lineHeight: 16.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _almuerzo() {
    return Opacity(
      opacity: 0.85,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: AppRadius.md),
        child: Row(
          children: [
            const SvgIcon('fecha/lunch.svg', width: 12.5, height: 16.667),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(horario,
                      style: AppText.sans(16, weight: FontWeight.w500, color: AppColors.onSurfaceVariant, lineHeight: 20)),
                  Text(nota, style: AppText.sans(11, color: AppColors.outline, lineHeight: 16.5)),
                ],
              ),
            ),
            Text('ALMUERZO',
                style: AppText.sans(11,
                    weight: FontWeight.w600, color: AppColors.onSurfaceVariant, lineHeight: 16.5, letterSpacing: 0.55)),
          ],
        ),
      ),
    );
  }

  Widget _libre() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: selected ? 58 : 52),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.md,
          boxShadow: selected
              ? const [
                  BoxShadow(color: AppColors.accent, spreadRadius: 2),
                  BoxShadow(color: AppColors.accentFaint, offset: Offset(0, 4), blurRadius: 14),
                ]
              : AppShadows.soft,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(selected ? 20 : 16, 10, 16, 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent : AppColors.surfaceContainer,
                      borderRadius: AppRadius.sm,
                    ),
                    child: selected
                        ? const SvgIcon('fecha/selected.svg', width: 16.5)
                        : const SvgIcon('fecha/clock.svg', width: 15),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(horario,
                                style: selected
                                    ? AppText.sans(17, weight: FontWeight.w700, lineHeight: 25.5)
                                    : AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                            if (selected)
                              Tag(label: 'SELECCIONADO', background: AppColors.accentContainer, padding: const EdgeInsets.symmetric(horizontal: 6),
                                  style: AppText.sans(10,
                                        weight: FontWeight.w700, color: AppColors.onAccentContainer, lineHeight: 15)),
                          ],
                        ),
                        Row(
                          children: [
                            if (selected) ...[const Dot(), const SizedBox(width: 4)],
                            Flexible(
                              child: Text(nota,
                                  style: AppText.sans(12,
                                      weight: selected ? FontWeight.w500 : FontWeight.w400,
                                      color: selected ? AppColors.accent : AppColors.onSurfaceVariant,
                                      lineHeight: 18)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  selected
                      ? Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: AppColors.accent, borderRadius: AppRadius.lg),
                          child: const SvgIcon('fecha/check.svg', width: 11.933, height: 9.1),
                        )
                      : Tag(label: 'Elegir',
                          style: AppText.sans(12, weight: FontWeight.w700, color: Colors.black, lineHeight: 18)),
                ],
              ),
            ),
            if (selected)
              const Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: SizedBox(width: 6, child: ColoredBox(color: AppColors.accent)),
              ),
          ],
        ),
      ),
    );
  }
}

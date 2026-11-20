import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

class StaffTabs extends StatelessWidget {
  const StaffTabs({super.key, required this.current, required this.onTap, this.inasistencias = 1});

  final int current;
  final ValueChanged<int> onTap;

  final int inasistencias;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: AppRadius.md),
      child: Row(
        children: [
          _Tab(
            selected: current == 0,
            onTap: () => onTap(0),
            icon: 'horario/tab_jornada.svg',
            w: 15,
            h: 15,
            label: 'Jornada y\nHorarios',
          ),
          _Tab(
            selected: current == 1,
            dark: current == 1,
            onTap: () => onTap(1),
            icon: 'horario/tab_inasistencias.svg',
            w: 13.5,
            h: 15,
            label: 'Inasistencias',
            badge: inasistencias == 0
                ? null
                : Tag(label: '$inasistencias', background: AppColors.accent, radius: 12, padding: const EdgeInsets.symmetric(horizontal: 6),
                    style: AppText.sans(11, weight: FontWeight.w700, color: Colors.white, lineHeight: 24)),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.w,
    required this.h,
    required this.label,
    this.dark = false,
    this.badge,
  });

  final bool selected;
  final bool dark;
  final VoidCallback onTap;
  final String icon;
  final double w;
  final double h;
  final String label;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          margin: dark ? const EdgeInsets.symmetric(vertical: 10) : EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: dark ? Colors.black : (selected ? Colors.white : Colors.transparent),
            borderRadius: AppRadius.sm,
            boxShadow: selected ? AppShadows.soft : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!dark) ...[SvgIcon(icon, width: w, height: h), const SizedBox(width: 4)],
              Flexible(
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: AppText.sans(16,
                        weight: FontWeight.w600,
                        color: dark ? Colors.white : (selected ? Colors.black : AppColors.onSurfaceVariant),
                        lineHeight: 24)),
              ),
              if (dark) ...[const SizedBox(width: 8), const Dot(size: 8)] else if (badge != null) ...[
                const SizedBox(width: 4),
                badge!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

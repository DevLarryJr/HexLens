import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

/// Selector de vista de la agenda: Semanas / Día / Mensual.
class VistaTabs extends StatelessWidget {
  const VistaTabs({super.key, required this.seleccion, this.onSelect});

  final int seleccion;
  final ValueChanged<int>? onSelect;

  static const _tabs = [
    ('Semanas', 'agenda/tab_semanas.svg', 15.0, 12.0),
    ('Día', 'agenda/tab_dia.svg', 13.5, 12.0),
    ('Mensual', 'agenda/tab_mensual.svg', 13.5, 15.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: AppRadius.xs),
      child: Row(
        children: [
          for (var i = 0; i < _tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect?.call(i),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: seleccion == i ? Colors.white : Colors.transparent,
                    borderRadius: AppRadius.xs,
                    boxShadow: seleccion == i ? AppShadows.soft : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgIcon(_tabs[i].$2, width: _tabs[i].$3, height: _tabs[i].$4),
                      const SizedBox(width: 6),
                      Text(_tabs[i].$1,
                          style: AppText.sans(16,
                              weight: FontWeight.w500,
                              color: seleccion == i ? AppColors.onSurface : AppColors.onSurfaceVariant,
                              lineHeight: 20)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

class DiaCard extends StatelessWidget {
  const DiaCard({
    super.key,
    required this.abrev,
    required this.numero,
    required this.estado,
    required this.selected,
    this.pasado = false,
    this.altaDemanda = false,
    this.hoy = false,
    this.onTap,
  });

  final String abrev;
  final int numero;

  final String estado;
  final bool selected;
  final bool pasado;
  final bool altaDemanda;

  final bool hoy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color tagBg;
    final Color tagFg;
    if (selected) {
      tagBg = AppColors.onDarkFaint;
      tagFg = Colors.white;
    } else if (altaDemanda) {
      tagBg = AppColors.accentTint;
      tagFg = AppColors.accent;
    } else {
      tagBg = AppColors.surfaceContainer;
      tagFg = pasado ? AppColors.onSurfaceVariant : Colors.black;
    }

    return GestureDetector(
      onTap: pasado ? null : onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: BoxConstraints(minWidth: selected ? 84 : 76),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? Colors.black : Colors.white,
              borderRadius: AppRadius.md,
              boxShadow: selected ? AppShadows.medium : AppShadows.soft,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(abrev,
                    style: AppText.sans(12,
                        color: selected ? const Color(0xFFE5E2E1) : AppColors.onSurfaceVariant, lineHeight: 18)),
                Text('$numero',
                    style: selected
                        ? AppText.sans(28, weight: FontWeight.w700, color: Colors.white, lineHeight: 35, letterSpacing: -0.84)
                        : AppText.sans(22, weight: FontWeight.w700, lineHeight: 27.5)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: altaDemanda ? 4 : 6, vertical: 2),
                  color: tagBg,
                  child: Text(estado,
                      style: AppText.sans(10,
                          weight: selected || altaDemanda
                              ? (altaDemanda ? FontWeight.w700 : FontWeight.w500)
                              : (pasado ? FontWeight.w400 : FontWeight.w500),
                          color: tagFg,
                          lineHeight: 15)),
                ),
              ],
            ),
          ),
          if (hoy)
            Positioned(
              right: 6,
              top: -4,
              child: Container(
                color: AppColors.accent,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: IconoTexto(const SvgIcon('fecha/hoy.svg', width: 9.167), 'HOY', estilo: AppText.sans(9,
                            weight: FontWeight.w700, color: Colors.white, lineHeight: 13.5, letterSpacing: 0.45), separacion: 2),
              ),
            ),
        ],
      ),
    );
  }
}

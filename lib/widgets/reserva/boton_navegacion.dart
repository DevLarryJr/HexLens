import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

class BotonNavegacion extends StatelessWidget {
  const BotonNavegacion(this.icon, {super.key, required this.etiqueta, this.onTap, this.ancho = 6.167, this.alto = 10});

  final String icon;

  final String etiqueta;

  final VoidCallback? onTap;
  final double ancho;
  final double alto;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: etiqueta,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Material(
          color: Colors.white,
          borderRadius: AppRadius.sm,
          child: InkWell(
            borderRadius: AppRadius.sm,
            onTap: onTap,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(borderRadius: AppRadius.sm, boxShadow: AppShadows.soft),
              child: SvgIcon(icon, width: ancho, height: alto),
            ),
          ),
        ),
      ),
    );
  }
}

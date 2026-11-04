import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

/// Contenedor común de las hojas de confirmación: asa, encabezado, cuerpo desplazable y barra de acciones
/// fija abajo. Sin botón cerrar: la salida es el botón secundario de [actions] (o deslizar la hoja hacia abajo).
class ConfirmacionSheetFrame extends StatelessWidget {
  const ConfirmacionSheetFrame({
    super.key,
    required this.header,
    required this.body,
    required this.actions,
    this.accentTop = false,
  });

  final Widget header;
  final List<Widget> body;
  final Widget actions;

  /// Borde superior rosado (acciones destructivas).
  final bool accentTop;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: accentTop ? const Border(top: BorderSide(color: AppColors.accentBorder, width: 2)) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: AppRadius.sm),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 16, 26, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  ...body,
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(color: Colors.white, boxShadow: AppShadows.sheetActions),
            padding: const EdgeInsets.fromLTRB(26, 26, 26, 26),
            child: SafeArea(top: false, child: actions),
          ),
        ],
      ),
    );
  }
}

/// Fila "📷 #ORD-9821 · ● ESTADO" de las hojas de confirmación.
class OrdenHeader extends StatelessWidget {
  const OrdenHeader({super.key, required this.codigo, required this.estado, required this.dark});

  final String codigo;
  final String estado;

  /// Etiqueta de estado negra (programada) o gris (en curso).
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SvgIcon('confirmar/camara.svg', width: 15, height: 13.5),
        const SizedBox(width: 8),
        Expanded(
          child: Text(codigo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.sans(19, weight: FontWeight.w600, letterSpacing: 0.4)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: dark ? Colors.black : AppColors.surfaceHigh,
          child: IconoTexto(const Icon(Icons.circle, size: 7, color: AppColors.accentBright), estado,
              estilo: AppText.sans(14,
                      weight: FontWeight.w500, color: dark ? Colors.white : AppColors.onSurface, letterSpacing: 0.4)),
        ),
      ],
    );
  }
}

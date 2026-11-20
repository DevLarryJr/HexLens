import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

class NuevaReservaBanner extends StatelessWidget {
  const NuevaReservaBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    void tap() {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(_preparandoToast());
      onTap();
    }

    return Container(
      height: 48,
      decoration: BoxDecoration(borderRadius: AppRadius.sm, boxShadow: AppShadows.medium),
      child: Material(
        color: Colors.black,
        borderRadius: AppRadius.sm,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: tap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  children: [
                    const SvgIcon('inicio/add_circle.svg', width: 16.667),
                    const SizedBox(width: 8),
                    Text('Nueva reserva',
                        style: AppText.sans(16,
                            weight: FontWeight.w500, color: Colors.white, lineHeight: 20, letterSpacing: 0.4)),
                    const Spacer(),
                    const SvgIcon('inicio/chevron_right.svg', width: 7.85, height: 13.333),
                  ],
                ),
              ),
              const Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: SizedBox(width: 6, child: ColoredBox(color: AppColors.accent)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SnackBar _preparandoToast() {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black,
      duration: const Duration(milliseconds: 1500),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
      content: Row(
        children: [
          const SvgIcon('inicio/toast.svg', width: 16.667),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Preparando formulario de reserva...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.sans(14, color: Colors.white, lineHeight: 18)),
          ),
          Text('HEXLENS',
              style: AppText.sans(12,
                  weight: FontWeight.w700, color: AppColors.outlineVariant, lineHeight: 18, letterSpacing: 0.6)),
        ],
      ),
    );
  }
}

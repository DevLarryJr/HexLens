import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_form.dart';
import '../hex_widgets.dart';

class ValidacionEstadoBar extends StatelessWidget {
  const ValidacionEstadoBar({super.key, required this.errores});

  final int errores;

  @override
  Widget build(BuildContext context) {
    final mal = errores > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      color: mal ? AppColors.surfaceHigh : AppColors.successContainer,
      child: Row(
        children: [
          Dot(size: 7, color: mal ? AppColors.accent : AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(mal ? 'HAY CAMPOS\nPOR CORREGIR' : 'TODO\nCORRECTO',
                style: AppText.sans(17,
                    weight: FontWeight.w500,
                    color: mal ? AppColors.accent : AppColors.successDark,
                    lineHeight: 24,
                    letterSpacing: 0.6)),
          ),
        ],
      ),
    );
  }
}

class ErrorGuardarBanner extends StatelessWidget {
  const ErrorGuardarBanner({super.key, required this.errores});

  final int errores;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: AppRadius.sm,
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            color: AppColors.accent,
            child: const SvgIcon('condiciones/error.svg', width: 20, height: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No se pudo guardar', style: AppText.sans(20, weight: FontWeight.w600, color: AppColors.accent)),
                Text.rich(TextSpan(
                  style: AppText.sans(17, color: AppColors.accent, lineHeight: 24),
                  children: [
                    const TextSpan(text: 'Por favor corrige los '),
                    TextSpan(
                        text: '$errores ${errores == 1 ? 'campo señalado' : 'campos señalados'}',
                        style: const TextStyle(decoration: TextDecoration.underline)),
                    const TextSpan(text: ' para habilitar la sincronización.'),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentoVerificadoCard extends StatelessWidget {
  const DocumentoVerificadoCard({super.key, required this.documento});

  final String documento;

  @override
  Widget build(BuildContext context) {
    return TarjetaCampo(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel('Documento de Identidad (C.C. / NIT)'),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
            color: AppColors.surfaceLow,
            child: Row(
              children: [
                const SvgIcon('condiciones/huella.svg', width: 23, height: 16.6),
                const SizedBox(width: 10),
                Expanded(child: Text(documento, style: AppText.sans(19))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: AppColors.surfaceHigh,
                  child: IconoTexto(const SvgIcon('condiciones/verificado.svg', width: 14.7, height: 14), 'VERIFICADO',
                      estilo: AppText.sans(13, weight: FontWeight.w700, letterSpacing: 1), separacion: 4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CanalPagoCard extends StatelessWidget {
  const CanalPagoCard({super.key, required this.cuenta});

  final String cuenta;

  @override
  Widget build(BuildContext context) {
    return TarjetaCampo(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel('Canal de Pago / Transferencia',
              trailing: Text('ACH Activo', style: AppText.sans(14, color: AppColors.accent))),
          Container(
            padding: const EdgeInsets.all(14),
            color: AppColors.surfaceLow,
            child: Row(
              children: [
                const SvgIcon('condiciones/banco.svg', width: 24.7, height: 16.7),
                const SizedBox(width: 10),
                Expanded(child: Text(cuenta, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.sans(19))),
                const SvgIcon('condiciones/lock.svg', width: 12, height: 15.8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuditoriaCard extends StatelessWidget {
  const AuditoriaCard({super.key, required this.hash});

  final String hash;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: AppRadius.sm,
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            color: AppColors.surfaceLow,
            child: const SvgIcon('condiciones/auditoria.svg', width: 13.3, height: 16.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Registro de cambios', style: AppText.sans(19, weight: FontWeight.w600)),
                Text('Código de registro: $hash', style: AppText.sans(15, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          const SvgIcon('condiciones/escudo.svg', width: 13.3, height: 16.7),
        ],
      ),
    );
  }
}

class ErroresInsignia extends StatelessWidget {
  const ErroresInsignia({super.key, required this.errores});

  final int errores;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.accent, borderRadius: AppRadius.lg),
      child: Text('$errores ${errores == 1 ? 'error' : 'errores'}',
          style: AppText.sans(13, weight: FontWeight.w700, color: Colors.white)),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

/// "SYS.ONLINE" y "APERTURE // 01".
class LoginTopIndicator extends StatelessWidget {
  const LoginTopIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Tag(
          label: 'EN LÍNEA',
          leading: const Dot(),
          gap: 4,
          radius: 4,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18, letterSpacing: 0.7),
        ),
        IconoTexto(const SvgIcon('login/aperture.svg', width: 13.333), 'BOGOTÁ',
            estilo: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18, letterSpacing: 1.4),
            separacion: 4),
      ],
    );
  }
}

/// "SISTEMA ADMINISTRATIVO OPERATIVO" con el destello girado.
class LoginEncabezado extends StatelessWidget {
  const LoginEncabezado({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            // Espacio reservado del logo central (72px en el diseño).
            const SizedBox(height: 72),
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 12, height: 1, color: AppColors.outline),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text('SISTEMA ADMINISTRATIVO OPERATIVO',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18, letterSpacing: 1.4)),
                  ),
                  const SizedBox(width: 4),
                  Container(width: 12, height: 1, color: AppColors.outline),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 22,
          top: -10,
          child: Transform.rotate(
            angle: 12 * math.pi / 180,
            child: const SvgIcon('login/starburst.svg', width: 24),
          ),
        ),
      ],
    );
  }
}

/// Selector de rol Admin / Fotógrafo.
class RolSelector extends StatelessWidget {
  const RolSelector({super.key, required this.isAdmin, required this.onChanged});

  final bool isAdmin;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.sm,
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _opcion('Admin', isAdmin, () => onChanged(true)),
          const SizedBox(width: 4),
          _opcion('Fotógrafo', !isAdmin, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _opcion(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: AppRadius.sm,
          boxShadow: selected ? AppShadows.soft : null,
        ),
        child: Row(
          children: [
            Dot(color: selected ? AppColors.accent : AppColors.outlineVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppText.sans(14,
                  weight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                  lineHeight: 18),
            ),
          ],
        ),
      ),
    );
  }
}

/// Campo de 48 px del login; con [error], borde rojo.
class LoginCampo extends StatelessWidget {
  const LoginCampo({
    super.key,
    required this.controller,
    required this.prefix,
    this.suffix,
    this.obscure = false,
    this.keyboardType,
    this.error = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final Widget prefix;
  final Widget? suffix;
  final bool obscure;
  final TextInputType? keyboardType;
  final bool error;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final radio = AppRadius.sm;
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: AppText.sans(16),
        cursorColor: AppColors.accent,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
          prefixIcon: Padding(padding: const EdgeInsets.only(left: 14, right: 12), child: prefix),
          prefixIconConstraints: const BoxConstraints(minWidth: 44),
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: radio,
            borderSide: error ? const BorderSide(color: AppColors.accentBright) : BorderSide.none,
          ),
          enabledBorder: error
              ? OutlineInputBorder(borderRadius: radio, borderSide: const BorderSide(color: AppColors.accentBright))
              : null,
          focusedBorder: OutlineInputBorder(
            borderRadius: radio,
            borderSide: BorderSide(color: error ? AppColors.accentBright : AppColors.onSurface),
          ),
        ),
      ),
    );
  }
}

/// Casilla "Mantener sesión activa" y sello "SSL 256".
class RecordarSesionRow extends StatelessWidget {
  const RecordarSesionRow({super.key, required this.recordar, required this.onToggle});

  final bool recordar;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: recordar ? Colors.black : Colors.white,
                  borderRadius: AppRadius.xs,
                  border: recordar ? null : Border.all(color: AppColors.outline),
                ),
              ),
              const SizedBox(width: 8),
              Text('Mantener sesión activa', style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
            ],
          ),
        ),
        IconoTexto(const SvgIcon('login/ssl_shield.svg', width: 9.333, height: 11.667), 'SSL 256',
            estilo: AppText.sans(14, color: AppColors.muted, lineHeight: 18), separacion: 4),
      ],
    );
  }
}

/// "Estado de Estudio Hoy": sesiones activas y set en uso.
class EstadoEstudioCard extends StatelessWidget {
  const EstadoEstudioCard({super.key, required this.sesiones, required this.set, required this.horario});

  final int sesiones;
  final String set;
  final String horario;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: AppRadius.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconoTexto(const SvgIcon('login/studio.svg', width: 13.333), 'Estado de Estudio Hoy',
                  estilo: AppText.sans(14, weight: FontWeight.w600, lineHeight: 18), separacion: 4),
              Text('$sesiones ${sesiones == 1 ? 'Sesión Activa' : 'Sesiones Activas'}',
                  style: AppText.sans(14, weight: FontWeight.w500, color: AppColors.accent, lineHeight: 18)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(set, style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
              Text(horario, style: AppText.sans(14, weight: FontWeight.w500, lineHeight: 18)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Versión y lema al pie del login.
class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Dot(color: AppColors.outline),
              const SizedBox(width: 6),
              Text('v2.4.0 • HEXLENS STUDIO CO',
                  style: AppText.sans(14,
                      weight: FontWeight.w500, color: AppColors.onSurfaceVariant, lineHeight: 18, letterSpacing: 0.35)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Gestión de estudio fotográfico',
              textAlign: TextAlign.center, style: AppText.sans(14, color: AppColors.muted, lineHeight: 18)),
        ],
      ),
    );
  }
}

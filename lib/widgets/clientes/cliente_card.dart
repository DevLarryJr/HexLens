import 'package:flutter/material.dart';

import '../../models/cliente.dart';
import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

/// Tarjeta de un cliente del directorio: datos, estado de sus sesiones,
/// contacto y dos acciones que dependen del estado.
class ClienteCard extends StatelessWidget {
  const ClienteCard({
    super.key,
    required this.cliente,
    required this.detalle,
    this.onVerFicha,
    this.onAgendar,
  });

  final Cliente cliente;

  /// Línea de detalle del estado (por defecto `cliente.detalle`).
  final String detalle;
  final VoidCallback? onVerFicha;
  final VoidCallback? onAgendar;

  @override
  Widget build(BuildContext context) {
    final c = cliente;
    final frecuente = c.estado == EstadoCliente.frecuente;
    final (left, right) = _acciones();

    return HexCard(
      shadow: AppShadows.hairline,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: frecuente ? 24 : 0),
                  child: Row(
                    children: [
                      _Avatar(cliente: c),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(c.nombre, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                                if (c.estado == EstadoCliente.activaHoy) ...[
                                  const SizedBox(width: 6),
                                  const SvgIcon('clientes/bolt.svg', width: 10.667, height: 13.333),
                                ],
                              ],
                            ),
                            Text(c.documento, style: AppText.mono(14, lineHeight: 18)),
                          ],
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: AppRadius.lg),
                        child: const SvgIcon('clientes/more.svg', width: 3, height: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _EstadoBox(cliente: c, detalle: detalle),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _Contacto(frecuente ? 'clientes/phone.svg' : 'clientes/phone_dark.svg', 12, 12, c.telefono),
                    const SizedBox(width: 8),
                    _Contacto(frecuente ? 'clientes/mail.svg' : 'clientes/mail_dark.svg', 13.333, 10.667, c.email),
                  ],
                ),
                const SizedBox(height: 20),
                Row(children: [left, const SizedBox(width: 8), right]),
              ],
            ),
          ),
          if (frecuente)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(8),
                alignment: Alignment.topRight,
                decoration: const BoxDecoration(
                  color: AppColors.accentWash,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24)),
                ),
                child: const SvgIcon('clientes/flash.svg', width: 14.667),
              ),
            ),
        ],
      ),
    );
  }

  (Widget, Widget) _acciones() {
    const gris = AppColors.surfaceHigh;
    return switch (cliente.estado) {
      EstadoCliente.frecuente => (
          _Accion('Ver Ficha', const SvgIcon('clientes/ficha.svg', width: 15), gris, AppColors.onSurface, onVerFicha),
          _Accion('Agendar Sesión', const SvgIcon('clientes/agendar.svg', width: 14.25, height: 15),
              AppColors.accentBright, AppColors.onAccentBright, onAgendar,
              weight: FontWeight.w600),
        ),
      EstadoCliente.programada => (
          _Accion('Ver Ficha', const SvgIcon('clientes/eye.svg', width: 16.5, height: 11.25), gris, AppColors.onSurface,
              onVerFicha),
          _Accion('Gestionar', const SvgIcon('clientes/manage.svg', width: 15.75, height: 16.5), Colors.black,
              Colors.white, onAgendar),
        ),
      EstadoCliente.activaHoy => (
          _Accion('Monitor Set', const SvgIcon('clientes/monitor.svg', width: 15, height: 13.5), gris,
              AppColors.onSurface, null),
          _Accion('Ver Ficha', const SvgIcon('clientes/folder.svg', width: 15, height: 12), Colors.black, Colors.white,
              onVerFicha),
        ),
      EstadoCliente.realizada => (
          _Accion('Historial', const SvgIcon('clientes/historial.svg', width: 13.5), gris, AppColors.onSurface, null),
          _Accion('Nueva Sesión', const SvgIcon('clientes/plus.svg', width: 10.5), Colors.black, Colors.white,
              onAgendar),
        ),
      EstadoCliente.nuevo => (
          _Accion('Ver Ficha', const SvgIcon('clientes/ficha.svg', width: 15), gris, AppColors.onSurface, onVerFicha),
          _Accion('Agendar Sesión', const SvgIcon('clientes/agendar.svg', width: 14.25, height: 15),
              AppColors.accentBright, AppColors.onAccentBright, onAgendar,
              weight: FontWeight.w600),
        ),
    };
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: AppRadius.md),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: cliente.foto != null
          ? Image.asset('assets/images/${cliente.foto}', width: 48, height: 48, fit: BoxFit.cover)
          : Text(cliente.iniciales, style: AppText.sans(16, weight: FontWeight.w700, lineHeight: 24)),
    );
  }
}

/// Recuadro con el estado de las sesiones del cliente.
class _EstadoBox extends StatelessWidget {
  const _EstadoBox({required this.cliente, required this.detalle});

  final Cliente cliente;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    final c = cliente;
    final (Color bg, Widget top, String icon, double w, double h) = switch (c.estado) {
      EstadoCliente.frecuente => (
          AppColors.surfaceLow,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Tag(
                label: 'CLIENTE FRECUENTE',
                background: Colors.black,
                gap: 4,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                leading: const SvgIcon('clientes/star.svg', width: 11.667, height: 11.083),
                style: AppText.sans(14, weight: FontWeight.w600, color: Colors.white, lineHeight: 18, letterSpacing: 0.35),
              ),
              Text('${c.sesiones} Sesiones',
                  style: AppText.sans(14, weight: FontWeight.w600, color: AppColors.accent, lineHeight: 18)),
            ],
          ),
          'clientes/history.svg',
          13.333,
          14.0,
        ),
      EstadoCliente.programada => (
          AppColors.surfaceLow,
          Row(
            children: [
              const Dot(size: 8),
              const SizedBox(width: 8),
              Text('${c.programadas} ${c.programadas == 1 ? 'SESIÓN PROGRAMADA' : 'SESIONES PROGRAMADAS'}',
                  style: AppText.sans(14, weight: FontWeight.w700, lineHeight: 18, letterSpacing: 0.35)),
            ],
          ),
          'clientes/family.svg',
          16.0,
          8.0,
        ),
      EstadoCliente.activaHoy => (
          AppColors.accentContainer,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Dot(size: 8, color: AppColors.accentBright),
                  const SizedBox(width: 8),
                  Text('SESIÓN ACTIVA HOY',
                      style: AppText.sans(14,
                          weight: FontWeight.w700, color: AppColors.accent, lineHeight: 18, letterSpacing: 0.7)),
                ],
              ),
              if (c.set != null)
                Tag(
                  label: c.set!,
                  background: AppColors.accentFaint,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  style: AppText.sans(14, weight: FontWeight.w600, color: AppColors.accent, lineHeight: 18),
                ),
            ],
          ),
          'clientes/product.svg',
          13.333,
          13.333,
        ),
      EstadoCliente.realizada => (
          AppColors.surfaceLow,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconoTexto(const SvgIcon('clientes/done.svg', width: 13.333), 'SESIÓN REALIZADA',
                  estilo: AppText.sans(14, weight: FontWeight.w700, lineHeight: 18), separacion: 4),
              Text('Archivada', style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
            ],
          ),
          'clientes/school.svg',
          14.667,
          12.0,
        ),
      EstadoCliente.nuevo => (
          AppColors.surfaceLow,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Tag(
                label: 'CLIENTE NUEVO',
                background: AppColors.accentContainer,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                style: AppText.sans(14, weight: FontWeight.w700, color: AppColors.accent, lineHeight: 18, letterSpacing: 0.35),
              ),
              Text('Sin sesiones', style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
            ],
          ),
          'clientes/agendar.svg',
          14.25,
          15.0,
        ),
    };
    final activa = c.estado == EstadoCliente.activaHoy;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.sm,
        boxShadow: activa ? AppShadows.soft : null,
      ),
      child: Column(
        children: [
          top,
          const SizedBox(height: 6),
          Row(
            children: [
              SvgIcon(icon, width: w, height: h),
              const SizedBox(width: 8),
              Expanded(
                child: Text(detalle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sans(14,
                        weight: activa ? FontWeight.w500 : FontWeight.w400,
                        color: activa ? AppColors.onAccentContainer : AppColors.onSurfaceVariant,
                        lineHeight: 18)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Contacto extends StatelessWidget {
  const _Contacto(this.icon, this.w, this.h, this.label);

  final String icon;
  final double w;
  final double h;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.surfaceHigh,
        borderRadius: AppRadius.xs,
        child: InkWell(
          onTap: () {},
          borderRadius: AppRadius.xs,
          child: SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgIcon(icon, width: w, height: h),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.sans(14, weight: FontWeight.w500, lineHeight: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Accion extends StatelessWidget {
  const _Accion(this.label, this.icon, this.bg, this.fg, this.onTap, {this.weight = FontWeight.w500});

  final String label;
  final Widget icon;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: HexButton(
        label: label,
        height: 44,
        gap: 4,
        background: bg,
        foreground: fg,
        shadow: bg == AppColors.surfaceHigh ? null : AppShadows.soft,
        onPressed: onTap,
        leading: icon,
        textStyle: AppText.sans(16, weight: weight, color: fg, lineHeight: 20),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

class ReservaClienteIntro extends StatelessWidget {
  const ReservaClienteIntro({super.key});

  static const _pasos = [
    ('Cliente', 'reserva/step_cliente.svg', 12.0, 12.0, 1.0),
    ('Servicio', 'reserva/step_servicio.svg', 15.0, 13.5, 0.7),
    ('Fecha y hora', 'reserva/step_fecha.svg', 13.5, 15.0, 0.4),
    ('Confirmación', 'reserva/step_confirmacion.svg', 16.5, 15.75, 0.4),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconoTexto(const SvgIcon('reserva/aperture.svg', width: 18.333), 'RESERVAS',
                estilo: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18, letterSpacing: 0.7),
                separacion: 4),
            Tag(
              label: 'Paso 1 de 4',
              leading: const Dot(),
              gap: 4,
              radius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Nueva Reserva', style: AppText.sans(28, weight: FontWeight.w700, lineHeight: 36, letterSpacing: -0.7)),
        Text('Selección de cliente para asignación de estudio técnico',
            style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 24)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.md),
          child: Row(
            children: [
              for (var i = 0; i < _pasos.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(child: _paso(i)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _paso(int i) {
    final (label, icono, w, h, opacidad) = _pasos[i];
    final actual = i == 0;
    return Opacity(
      opacity: opacidad,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: actual ? AppColors.accent : AppColors.surfaceHighest,
              borderRadius: AppRadius.sm,
              boxShadow: actual ? AppShadows.soft : null,
            ),
            child: SvgIcon(icono, width: w, height: h),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.sans(10, weight: actual ? FontWeight.w600 : FontWeight.w400, lineHeight: 18),
          ),
          const SizedBox(height: 6),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: actual ? AppColors.accent : AppColors.surfaceHigh,
              borderRadius: AppRadius.lg,
            ),
          ),
        ],
      ),
    );
  }
}

class ClienteResultadoCard extends StatelessWidget {
  const ClienteResultadoCard({
    super.key,
    required this.nombre,
    required this.documento,
    required this.telefono,
    required this.avatar,
    required this.selected,
    this.onTap,
    this.email,
    this.recurrente,
    this.ultimaSesion,
    this.fechaUltima,
  });

  final String nombre;
  final String documento;
  final String telefono;

  final Widget avatar;
  final bool selected;
  final VoidCallback? onTap;
  final String? email;

  final String? recurrente;

  final String? ultimaSesion;
  final String? fechaUltima;

  @override
  Widget build(BuildContext context) {
    final details = recurrente != null;
    final muted = AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18);

    final card = HexCard(
      accentBar: selected,
      shadow: AppShadows.hairline,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: selected ? 4 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: AppRadius.sm),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: avatar,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre,
                          style: AppText.sans(16, weight: details ? FontWeight.w700 : FontWeight.w600, lineHeight: 24)),
                      if (recurrente != null) ...[
                        const SizedBox(height: 6),
                        Tag(
                          label: recurrente!,
                          gap: 2,
                          background: AppColors.accentBright,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          leading: const SvgIcon('reserva/recurrent.svg', width: 10.833),
                          style: AppText.sans(14, color: AppColors.onAccentBright, lineHeight: 18),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(documento, style: muted),
                      SizedBox(height: details ? 6 : 4),
                      IconoTexto(const SvgIcon('reserva/phone.svg', width: 11.25), telefono,
                          estilo: muted, separacion: 4),
                      if (email != null) ...[
                        const SizedBox(height: 7.5),
                        Row(
                          children: [
                            const SvgIcon('reserva/mail.svg', width: 12.5, height: 10),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(email!,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.sans(12, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                _Radio(selected),
              ],
            ),
          ),
          if (ultimaSesion != null) ...[
            const SizedBox(height: 8),
            Container(
              margin: EdgeInsets.only(left: selected ? 4 : 0),
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.sm),
              child: Row(
                children: [
                  const SvgIcon('reserva/history.svg', width: 12),
                  const SizedBox(width: 4),
                  Expanded(child: Text(ultimaSesion!, style: AppText.sans(14, weight: FontWeight.w500, lineHeight: 18))),
                  SizedBox(width: 84, child: Text(fechaUltima ?? '', style: AppText.mono(14, lineHeight: 18))),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: selected ? card : Opacity(opacity: 0.9, child: card),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio(this.selected);

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.accent : AppColors.surfaceHigh,
        borderRadius: AppRadius.lg,
        boxShadow: selected ? AppShadows.soft : null,
      ),
      child: selected
          ? const SvgIcon('reserva/check.svg', width: 12.225, height: 9.019)
          : const SvgIcon('reserva/radio_off.svg', width: 15),
    );
  }
}

class ParametrosRapidosCard extends StatelessWidget {
  const ParametrosRapidosCard({super.key, required this.cliente});

  final String cliente;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconoTexto(const SvgIcon('reserva/tune.svg', width: 13.5), 'Parámetros Rápidos de\nSesión',
                  estilo: AppText.sans(16, weight: FontWeight.w600, lineHeight: 20)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Al validar a $cliente se habilitará la preselección de lentes prime 35mm f/1.4 '
            'y el esquema lumínico de flash parabólico en el Paso 2.',
            style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18),
          ),
        ],
      ),
    );
  }
}

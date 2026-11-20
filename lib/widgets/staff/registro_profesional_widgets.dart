import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/formato.dart';
import '../hex_form.dart';
import '../hex_widgets.dart';

class RegistroStaffEncabezado extends StatelessWidget {
  const RegistroStaffEncabezado({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: AppColors.surfaceHigh,
                child: Text('STAFF · NUEVO PROFESIONAL',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sans(15, color: AppColors.onSurfaceVariant, letterSpacing: 0.6)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Tag(label: 'FICHA DE REGISTRO', background: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                style: AppText.mono(12, color: Colors.white)),
            Text(' • RECURSOS HUMANOS',
                style: AppText.sans(17, weight: FontWeight.w600, color: AppColors.accentBright, letterSpacing: 1.2)),
          ],
        ),
        const SizedBox(height: 10),
        Text('Ficha de Registro de Staff', style: AppText.sans(26, weight: FontWeight.w600, lineHeight: 34)),
        Text('Vinculación contractual, régimen de comisiones y habilitación de cámara.',
            style: AppText.sans(17, color: AppColors.onSurfaceVariant, lineHeight: 24)),
      ],
    );
  }
}

class FichaPill extends StatelessWidget {
  const FichaPill(this.texto, {super.key, this.rojo = false, this.punto = false});

  final String texto;
  final bool rojo;
  final bool punto;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        color: rojo ? AppColors.accentBright : AppColors.surfaceHigh,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (punto) ...[const Dot(size: 5, color: AppColors.accent), const SizedBox(width: 6)],
            Text(texto, style: AppText.mono(11, color: rojo ? Colors.white : AppColors.onSurface, letterSpacing: 0.8)),
          ],
        ),
      );
}

class ComisionSimuladorCard extends StatelessWidget {
  const ComisionSimuladorCard({super.key, required this.valor, required this.onChanged, required this.precioSesion});

  final double valor;
  final ValueChanged<double> onChanged;

  final int precioSesion;

  @override
  Widget build(BuildContext context) {
    final pct = valor.round();
    final staff = precioSesion * pct ~/ 100;
    return HexCard(
      radius: 2,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text.rich(TextSpan(children: [
                TextSpan(text: '$pct ', style: AppText.sans(34, weight: FontWeight.w700)),
                TextSpan(text: '%', style: AppText.sans(22, weight: FontWeight.w700)),
              ])),
              const Spacer(),
              Tag(label: 'TASA PACTADA', background: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  style: AppText.mono(13, color: Colors.white, letterSpacing: 1)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              activeTrackColor: Colors.black,
              inactiveTrackColor: AppColors.surfaceHigh,
              thumbColor: AppColors.accentBright,
              overlayColor: AppColors.accentOverlay,
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(value: valor, min: 0, max: 100, divisions: 20, onChanged: onChanged),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%', style: AppText.mono(12)),
              Text('50%', style: AppText.mono(12)),
              Text('100%', style: AppText.mono(12)),
            ],
          ),
          const SizedBox(height: 16),
          InfoBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconoTexto(const SvgIcon('profesional/simulacion.svg', width: 10.5, height: 10.5),
                    'SIMULACIÓN DE LIQUIDACIÓN',
                    estilo: AppText.mono(13, weight: FontWeight.w700, color: AppColors.onSurface)),
                const SizedBox(height: 6),
                Text('En una sesión de ${formatCop(precioSesion)} COP:', style: AppText.sans(18, lineHeight: 26)),
                const SizedBox(height: 6),
                _fila('Percibe Staff:', '${formatCop(staff)} COP', AppColors.accentBright),
                _fila('Margen Estudio:', '${formatCop(precioSesion - staff)} COP', AppColors.onSurface),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fila(String label, String valor, Color color) => Row(
        children: [
          Expanded(child: Text(label, style: AppText.sans(17, color: AppColors.onSurfaceVariant))),
          Text(valor, style: AppText.mono(16, weight: FontWeight.w700, color: color)),
        ],
      );
}

class EstadoOperativoSelector extends StatelessWidget {
  const EstadoOperativoSelector({super.key, required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  static const _estados = ['Activo', 'En Licencia', 'Inactivo'];
  static const _mensajes = [
    'Puede recibir reservas desde ya.',
    'Bloqueado temporalmente para nuevas reservas.',
    'Excluido de la agenda y del auto-match.',
  ];

  @override
  Widget build(BuildContext context) {
    final activo = selected == 0;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          color: AppColors.surfaceHigh,
          child: Row(
            children: [
              for (var i = 0; i < _estados.length; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(i),
                    child: Container(
                      height: 56,
                      color: i == selected ? Colors.black : Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (i == selected) ...[const Dot(size: 6, color: AppColors.accentBright), const SizedBox(width: 6)],
                          Text(_estados[i],
                              style: AppText.sans(18,
                                  weight: i == selected ? FontWeight.w500 : FontWeight.w400,
                                  color: i == selected ? Colors.white : AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Dot(size: 14, color: activo ? AppColors.accent : AppColors.outline),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_mensajes[selected],
                  style: AppText.sans(18, color: activo ? AppColors.accent : AppColors.onSurfaceVariant)),
            ),
          ],
        ),
      ],
    );
  }
}

class NotaCumplimiento extends StatelessWidget {
  const NotaCumplimiento({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.surfaceContainer,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SvgIcon('profesional/cumplimiento.svg', width: 13.3, height: 24.7),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NOTA DE CUMPLIMIENTO', style: AppText.sans(18, weight: FontWeight.w600, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text(
                    'La tasa de comisión configurada se aplicará de forma automática a todas las reservas futuras finalizadas. Los cierres contables ya auditados mantendrán su tasa histórica sin alteración.',
                    style: AppText.sans(17, color: AppColors.onSurfaceVariant, lineHeight: 30)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

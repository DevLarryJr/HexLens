import 'package:flutter/material.dart';

import '../../models/liquidacion.dart';
import '../../theme/app_theme.dart';
import '../../utils/formato.dart';
import '../fotografos/foto_fotografo.dart';
import '../hex_widgets.dart';

class LiquidacionSelector extends StatelessWidget {
  const LiquidacionSelector({super.key, required this.liquidaciones, required this.selected, required this.onSelect});

  final List<Liquidacion> liquidaciones;

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = ['Todos (${liquidaciones.length})', for (final l in liquidaciones) l.fotografo.nombre];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final sel = i == selected;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              color: sel ? Colors.black : AppColors.surfaceHigh,
              child: Row(
                children: [
                  if (sel && i > 0) ...[const Dot(size: 8, color: AppColors.accentBright), const SizedBox(width: 10)],
                  Text(items[i],
                      style: AppText.sans(16,
                          weight: sel ? FontWeight.w600 : FontWeight.w400,
                          color: sel ? Colors.white : AppColors.onSurfaceVariant)),
                  if (i > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      color: sel ? AppColors.surfaceHighest : Colors.transparent,
                      child: Text(sel ? '${liquidaciones[i - 1].tasa}%' : '(${liquidaciones[i - 1].tasa}%)',
                          style: AppText.sans(12,
                              weight: FontWeight.w600, color: sel ? Colors.black : AppColors.onSurfaceVariant)),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class LiquidacionResumenCard extends StatelessWidget {
  const LiquidacionResumenCard({super.key, required this.liquidacion});

  final Liquidacion liquidacion;

  @override
  Widget build(BuildContext context) {
    final l = liquidacion;
    final f = l.fotografo;
    return HexCard(
      radius: 4,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: EsquinaTriangulo(size: 64, color: AppColors.accentContainer.withValues(alpha: 0.6)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: AppRadius.xs,
                          child: FotoFotografo(f, tamano: 64),
                        ),
                        Positioned(
                          right: -6,
                          bottom: -2,
                          child: Tag(label: 'PRO', background: AppColors.accent, padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              style: AppText.sans(11, weight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(f.nombre, style: AppText.sans(20, weight: FontWeight.w500, lineHeight: 26))),
                              Text('TASA ${l.tasa}%',
                                  style: AppText.sans(13, weight: FontWeight.w700, color: AppColors.accent)),
                            ],
                          ),
                          Text('${f.documento} • Especialidad ${f.especialidad}',
                              style: AppText.sans(15, color: AppColors.onSurfaceVariant, lineHeight: 22)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            color: AppColors.surfaceLow,
                            child: IconoTexto(const SvgIcon('liquidacion/contrato.svg', width: 11.9, height: 11.4),
                                'Contrato Activo: ${l.tasa}% fijo por toma',
                                estilo: AppText.sans(13, lineHeight: 18), ajuste: FlexFit.loose),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.black,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('COMISIÓN NETA FOTÓGRAFO',
                                style: AppText.sans(13, color: AppColors.outlineVariant, letterSpacing: 1)),
                          ),
                          const SvgIcon('liquidacion/comision.svg', width: 16.5, height: 12),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: '${formatCop(l.comision)} ',
                            style: AppText.sans(32, weight: FontWeight.w700, color: Colors.white, lineHeight: 40)),
                        TextSpan(text: 'COP', style: AppText.sans(16, color: AppColors.outlineVariant)),
                      ])),
                      const SizedBox(height: 8),
                      Text('Liquidación neta directa a cuenta de ahorros',
                          style: AppText.sans(13, color: AppColors.outlineVariant)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _mini('BASE (${l.sesiones.length} SESIONES)', formatCop(l.base)),
                      const SizedBox(width: 10),
                      _mini('MARGEN ESTUDIO (${100 - l.tasa}%)', formatCop(l.base - l.comision)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mini(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        color: AppColors.surfaceHigh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.sans(13, color: AppColors.onSurfaceVariant, lineHeight: 20)),
            const SizedBox(height: 8),
            Text.rich(TextSpan(children: [
              TextSpan(text: '$value ', style: AppText.sans(18, weight: FontWeight.w700)),
              TextSpan(text: 'COP', style: AppText.sans(11, color: AppColors.onSurfaceVariant)),
            ])),
          ],
        ),
      ),
    );
  }
}

class SesionLiquidadaCard extends StatelessWidget {
  const SesionLiquidadaCard({super.key, required this.sesion, required this.tasa});

  final SesionLiquidada sesion;
  final int tasa;

  @override
  Widget build(BuildContext context) {
    final s = sesion;
    final com = s.tarifa * tasa ~/ 100;
    return HexCard(
      radius: 4,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(TextSpan(children: [
                      TextSpan(text: '${s.cliente} ', style: AppText.sans(19, weight: FontWeight.w600, lineHeight: 26)),
                      TextSpan(text: s.codigo, style: AppText.mono(12, lineHeight: 26)),
                    ])),
                    Text(s.detalle, style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22)),
                  ],
                ),
              ),
              Tag(
                label: 'Realizada',
                leading: const Dot(size: 6, color: AppColors.accent),
                background: AppColors.surfaceHigh,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                style: AppText.sans(14, weight: FontWeight.w500, lineHeight: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.surfaceLow,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TARIFA CLIENTE', style: AppText.sans(12, color: AppColors.onSurfaceVariant, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text('${formatCop(s.tarifa)} COP', style: AppText.sans(18, weight: FontWeight.w700)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('COMISIÓN ($tasa%)',
                        style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.accent, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text('+${formatCop(com)} COP', style: AppText.sans(19, weight: FontWeight.w700, color: AppColors.accent)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text('Retención de Estudio (${100 - tasa}%):', style: AppText.sans(13, color: AppColors.onSurfaceVariant)),
              ),
              Text('${formatCop(s.tarifa - com)} COP', style: AppText.sans(13, weight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class FormulaLiquidacion extends StatelessWidget {
  const FormulaLiquidacion({super.key, required this.porcentaje});

  final String porcentaje;

  @override
  Widget build(BuildContext context) {
    final base = AppText.sans(15, weight: FontWeight.w600, color: AppColors.onSurfaceVariant, lineHeight: 24);
    final negrita = AppText.sans(15, weight: FontWeight.w700, lineHeight: 24);
    return Container(
      padding: const EdgeInsets.all(18),
      color: AppColors.surfaceHigh,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Σ', style: AppText.sans(22, weight: FontWeight.w700, color: AppColors.accentBright, lineHeight: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FÓRMULA DE LIQUIDACIÓN TRANSPARENTE',
                    style: AppText.sans(13, weight: FontWeight.w600, lineHeight: 20, letterSpacing: 1)),
                const SizedBox(height: 6),
                Text.rich(TextSpan(style: base, children: [
                  TextSpan(text: 'Comisión: ', style: negrita),
                  TextSpan(text: 'Total servicios realizados × % contractual ($porcentaje).'),
                ])),
                const SizedBox(height: 6),
                Text.rich(TextSpan(style: base, children: [
                  TextSpan(text: 'Margen de Estudio: ', style: negrita),
                  const TextSpan(text: 'Total facturado − Comisiones desembolsadas.'),
                ])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

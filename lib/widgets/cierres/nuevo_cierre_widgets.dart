import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_form.dart';
import '../../models/fotografo.dart';
import '../fotografos/foto_fotografo.dart';
import '../hex_widgets.dart';
import 'cierre_cards.dart';

class PasoAuditoriaHeader extends StatelessWidget {
  const PasoAuditoriaHeader({super.key, required this.paso});

  final String paso;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 3, child: FinanceTag(paso)),
        const SizedBox(width: 6),
        Expanded(
          flex: 2,
          child: Tag(label: 'EN REVISIÓN', background: AppColors.surfaceHigh, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 20, letterSpacing: 1)),
        ),
      ],
    );
  }
}

class RangoLiquidacionCard extends StatelessWidget {
  const RangoLiquidacionCard({
    super.key,
    required this.etiqueta,
    required this.inicio,
    required this.fin,
    required this.validacion,
    required this.valido,
    this.onInicio,
    this.onFin,
  });

  final String etiqueta;

  final String inicio;
  final String fin;
  final String validacion;
  final bool valido;
  final VoidCallback? onInicio;
  final VoidCallback? onFin;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      radius: 4,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              const SvgIcon('nuevo_cierre/rango.svg', width: 13.5, height: 15),
              const SizedBox(width: 8),
              Expanded(child: Text('Rango de Liquidación', style: AppText.sans(18, weight: FontWeight.w600, lineHeight: 24))),
              Tag(label: etiqueta, background: AppColors.accentContainer, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  style: AppText.mono(14, weight: FontWeight.w700, color: AppColors.accent, lineHeight: 20)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _fecha('Fecha Inicial', inicio, Icons.calendar_today_outlined, onInicio),
              const SizedBox(width: 14),
              _fecha('Fecha Final', fin, Icons.event_outlined, onFin),
            ],
          ),
          const SizedBox(height: 16),
          InfoBox(
            icon: valido ? Icons.check_circle : Icons.cancel,
            iconColor: AppColors.accentBright,
            background: AppColors.surfaceHigh,
            child: Text(validacion, style: AppText.sans(15, weight: FontWeight.w600, lineHeight: 22)),
          ),
        ],
      ),
    );
  }

  Widget _fecha(String label, String valor, IconData icon, VoidCallback? onTap) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22)),
          const SizedBox(height: 6),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              color: AppColors.surfaceLow,
              child: Row(
                children: [
                  Expanded(child: Text(valor, style: AppText.sans(17, weight: FontWeight.w500, lineHeight: 22))),
                  Icon(icon, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EscaneoSesiones extends StatelessWidget {
  const EscaneoSesiones({super.key, required this.realizadas, required this.canceladas, required this.enCurso});

  final int realizadas;
  final int canceladas;
  final int enCurso;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SvgIcon('nuevo_cierre/escaneo.svg', width: 15, height: 15),
            const SizedBox(width: 8),
            Expanded(child: Text('Resumen del período', style: AppText.sans(18, weight: FontWeight.w600, lineHeight: 24))),
            const Dot(size: 7, color: AppColors.accentBright),
            const SizedBox(width: 6),
            Text('Sincronizado', style: AppText.sans(15, color: AppColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text('SESIONES A\nLIQUIDAR',
                        style: AppText.sans(15, weight: FontWeight.w600, color: Colors.white, lineHeight: 22, letterSpacing: 1.4)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    color: AppColors.charcoal,
                    child: IconoTexto(const SvgIcon('nuevo_cierre/auditado.svg', width: 12.8, height: 7),
                        '100%\nverificado',
                        estilo: AppText.sans(15, color: Colors.white, lineHeight: 20)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text.rich(TextSpan(children: [
                TextSpan(
                    text: '$realizadas Sesiones ',
                    style: AppText.sans(32, weight: FontWeight.w700, color: Colors.white, lineHeight: 40)),
                TextSpan(text: 'Realizadas', style: AppText.sans(16, color: Colors.white)),
              ])),
              const SizedBox(height: 4),
              Text('Todas validadas con entrega de archivos brutos y acta de conformidad de cliente.',
                  style: AppText.sans(16, color: AppColors.outlineVariant, lineHeight: 22)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _mini('Canceladas', 'nuevo_cierre/canceladas.svg', '$canceladas', 'sesiones', 'Excluidas automáticamente del cálculo'),
              const SizedBox(width: 12),
              _mini('En Curso', 'nuevo_cierre/en_curso.svg', '$enCurso', 'programadas', 'Pendientes de cierre fotográfico'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mini(String title, String icono, String n, String unidad, String desc) {
    return Expanded(
      child: HexCard(
        radius: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22))),
                SvgIcon(icono, width: 15, height: 15),
              ],
            ),
            const SizedBox(height: 8),
            Text.rich(TextSpan(children: [
              TextSpan(text: '$n ', style: AppText.sans(22, weight: FontWeight.w600, lineHeight: 28)),
              TextSpan(text: unidad, style: AppText.sans(16, color: AppColors.onSurfaceVariant)),
            ])),
            const SizedBox(height: 6),
            Text(desc, style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
          ],
        ),
      ),
    );
  }
}

class DesgloseFinancieroCard extends StatelessWidget {
  const DesgloseFinancieroCard({
    super.key,
    required this.total,
    required this.servicios,
    required this.comisiones,
    required this.fotografos,
    required this.estudio,
  });

  final String total;
  final String comisiones;
  final String estudio;

  final String servicios;
  final String fotografos;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      radius: 4,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              const SvgIcon('nuevo_cierre/desglose.svg', width: 14.3, height: 13.5),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Desglose Financiero Preliminar', style: AppText.sans(18, weight: FontWeight.w600, lineHeight: 24)),
              ),
              Text('COP', style: AppText.sans(16, color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 16),
          _fila(const SvgIcon('nuevo_cierre/facturado.svg', width: 13.5, height: 15), AppColors.surfaceHigh, 'Total Facturado',
              servicios, total),
          const SizedBox(height: 12),
          _fila(const SvgIcon('nuevo_cierre/comisiones.svg', width: 16.5, height: 12), AppColors.accentContainer,
              'Comisiones a Liquidar', fotografos, '- $comisiones',
              color: AppColors.accentBright),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            color: AppColors.surfaceHigh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SvgIcon('nuevo_cierre/estudio.svg', width: 15.1, height: 13.5),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('Valor para el Estudio', style: AppText.sans(19, weight: FontWeight.w600, lineHeight: 24)),
                    ),
                    Text(estudio, style: AppText.sans(24, weight: FontWeight.w700, lineHeight: 30)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Ingreso bruto del estudio antes de costos fijos',
                    style: AppText.sans(17, color: AppColors.onSurfaceVariant, lineHeight: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fila(Widget icon, Color bg, String title, String sub, String monto, {Color color = AppColors.onSurface}) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surfaceLow,
      child: Row(
        children: [
          Container(width: 40, height: 40, color: bg, child: Center(child: icon)),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.sans(17, color: AppColors.onSurfaceVariant, lineHeight: 24)),
                Text(sub,
                    style: AppText.sans(14,
                        color: color == AppColors.onSurface ? AppColors.onSurfaceVariant : color, lineHeight: 18)),
              ],
            ),
          ),
          Text(monto, style: AppText.sans(19, weight: FontWeight.w700, color: color, lineHeight: 24)),
        ],
      ),
    );
  }
}

class FotografoComisionCard extends StatelessWidget {
  const FotografoComisionCard({
    super.key,
    required this.fotografo,
    required this.detalle,
    required this.comision,
    required this.base,
    this.sesion,
    this.sesionComision,
    this.destacado = false,
  });

  final Fotografo fotografo;

  final String detalle;
  final String comision;

  final String base;

  final String? sesion;
  final String? sesionComision;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      radius: 2,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: AppRadius.xs,
                child: FotoFotografo(fotografo, tamano: 54),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(fotografo.nombre, style: AppText.sans(19, weight: FontWeight.w600, lineHeight: 26)),
                        if (destacado) const Text(' ✦', style: TextStyle(color: AppColors.accentBright, fontSize: 14)),
                      ],
                    ),
                    Text(detalle, style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(comision, style: AppText.sans(19, weight: FontWeight.w700, color: AppColors.accent, lineHeight: 26)),
                  Text('Comisión', style: AppText.sans(14, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
          if (sesion != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: AppColors.surfaceLow,
              child: Row(
                children: [
                  const SvgIcon('nuevo_cierre/sesion.svg', width: 10, height: 11.3),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(sesion!, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.sans(16, lineHeight: 22)),
                  ),
                  Text(sesionComision ?? '', style: AppText.sans(16, weight: FontWeight.w500)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text('Base de producción asignada:',
                    style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22)),
              ),
              Text(base, style: AppText.sans(16, weight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

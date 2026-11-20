import 'package:flutter/material.dart';

import '../../models/fotografo.dart';
import '../../theme/app_theme.dart';
import '../fotografos/foto_fotografo.dart';
import '../hex_widgets.dart';

Future<Fotografo?> elegirFotografoSheet(BuildContext context, List<Fotografo> opciones, Fotografo? actual) {
  return showModalBottomSheet<Fotografo>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('Elegir fotógrafo', style: AppText.sans(16, weight: FontWeight.w700, lineHeight: 24)),
          ),
          for (final f in opciones)
            ListTile(
              leading: ClipRRect(borderRadius: AppRadius.sm, child: FotoFotografo(f, tamano: 40)),
              title: Text(f.nombre),
              subtitle: Text(f.activo ? f.especialidad : '${f.especialidad} • Inactivo'),
              trailing: f.id == actual?.id ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop(f),
            ),
        ],
      ),
    ),
  );
}

class StaffPerfilCard extends StatelessWidget {
  const StaffPerfilCard({
    super.key,
    required this.nombre,
    required this.foto,
    required this.detalle,
    this.onCambiar,
    this.fotografo,
  });

  final String nombre;

  final String foto;

  final Fotografo? fotografo;

  final String detalle;
  final VoidCallback? onCambiar;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      shadow: AppShadows.hairline,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.md,
            child: fotografo != null
                ? FotoFotografo(fotografo!, tamano: 56)
                : Image.asset('assets/images/$foto',
                    width: 56, height: 56, fit: BoxFit.cover, alignment: Alignment.topCenter),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FOTÓGRAFO ACTIVO',
                    style: AppText.sans(11,
                        weight: FontWeight.w600, color: AppColors.accent, lineHeight: 16.5, letterSpacing: 0.55)),
                Text(nombre, style: AppText.sans(16, weight: FontWeight.w700, lineHeight: 24)),
                Text(detalle, style: AppText.sans(13, color: AppColors.onSurfaceVariant, lineHeight: 18)),
              ],
            ),
          ),
          Material(
            color: AppColors.surfaceLow,
            borderRadius: AppRadius.sm,
            child: InkWell(
              onTap: onCambiar ?? () {},
              borderRadius: AppRadius.sm,
              child: Container(
                height: 33,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconoTexto(const SvgIcon('horario/swap.svg', width: 15, height: 12), 'CAMBIAR',
                    estilo: AppText.sans(10,
                            weight: FontWeight.w700, color: Colors.black, lineHeight: 20, letterSpacing: 0.6), separacion: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HorarioMetricas extends StatelessWidget {
  const HorarioMetricas({super.key, required this.carga, required this.jornadas, required this.pausa});

  final String carga;

  final String jornadas;

  final String pausa;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Metrica('horario/carga.svg', 13.333, 13.333, 'CARGA TOTAL', carga, 'Asignadas'),
          const SizedBox(width: 8),
          _Metrica('horario/jornadas.svg', 12, 13.333, 'JORNADAS', jornadas, 'Laborales'),
          const SizedBox(width: 8),
          _Metrica('horario/pausa.svg', 10, 13.333, 'PAUSA DÍA', pausa, 'Técnica (Almuerzo)'),
        ],
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica(this.icon, this.w, this.h, this.label, this.valor, this.sub);

  final String icon;
  final double w;
  final double h;
  final String label;
  final String valor;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: HexCard(
        radius: 4,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconoTexto(SvgIcon(icon, width: w, height: h), label,
                estilo: AppText.sans(11, weight: FontWeight.w500, color: AppColors.onSurfaceVariant, lineHeight: 13.75),
                separacion: 4, ajuste: FlexFit.loose),
            const SizedBox(height: 4),
            Text(valor, style: AppText.sans(22, weight: FontWeight.w700, color: Colors.black, lineHeight: 22)),
            Text(sub, style: AppText.sans(11, color: AppColors.onSurfaceVariant, lineHeight: 24)),
          ],
        ),
      ),
    );
  }
}

class SemanaNavegador extends StatelessWidget {
  const SemanaNavegador({super.key, required this.etiqueta, required this.titulo, this.onAnterior, this.onSiguiente});

  final String etiqueta;

  final String titulo;
  final VoidCallback? onAnterior;
  final VoidCallback? onSiguiente;

  @override
  Widget build(BuildContext context) {
    Widget nav(String icon, VoidCallback? onTap) => InkWell(
          onTap: onTap,
          borderRadius: AppRadius.sm,
          child: SizedBox(width: 40, height: 40, child: Center(child: SvgIcon(icon, width: 6.167, height: 10))),
        );

    return HexCard(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          nav('horario/chevron_left.svg', onAnterior),
          Column(
            children: [
              Row(
                children: [
                  const Dot(),
                  const SizedBox(width: 4),
                  Text(etiqueta,
                      style: AppText.sans(12,
                          weight: FontWeight.w700, color: AppColors.accent, lineHeight: 24, letterSpacing: 0.6)),
                ],
              ),
              Text(titulo, style: AppText.sans(16, weight: FontWeight.w700, color: Colors.black, lineHeight: 24)),
            ],
          ),
          nav('horario/chevron_right.svg', onSiguiente),
        ],
      ),
    );
  }
}

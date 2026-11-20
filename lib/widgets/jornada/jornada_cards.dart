import 'package:flutter/material.dart';

import '../../models/fotografo.dart';
import '../../theme/app_theme.dart';
import '../fotografos/foto_fotografo.dart';
import '../hex_form.dart';
import '../hex_widgets.dart';

class FichaJornadaCard extends StatelessWidget {
  const FichaJornadaCard({
    super.key,
    required this.nombre,
    required this.foto,
    required this.detalle,
    required this.dia,
    this.fotografo,
  });

  final Fotografo? fotografo;

  final String nombre;

  final String foto;

  final String detalle;

  final String dia;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      radius: 4,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SvgIcon('jornada/sparkle.svg', width: 10.4, height: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text('JORNADA DE TRABAJO',
                    style: AppText.sans(15, color: AppColors.onSurfaceVariant, lineHeight: 22, letterSpacing: 1)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                color: AppColors.accentBright,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 8), child: Dot(size: 5, color: Colors.white)),
                    const SizedBox(width: 6),
                    Text('EDICIÓN DÍA\n$dia',
                        style: AppText.sans(15, color: Colors.white, lineHeight: 22, letterSpacing: 1)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ClipRRect(
                borderRadius: AppRadius.sm,
                child: fotografo != null
                    ? FotoFotografo(fotografo!, tamano: 60)
                    : Image.asset('assets/images/$foto', width: 60, height: 60, fit: BoxFit.cover),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre, style: AppText.sans(22, weight: FontWeight.w600, lineHeight: 28)),
                    IconoTexto(const SvgIcon('jornada/camera.svg', width: 13.3, height: 12), detalle,
                        estilo: AppText.sans(15, color: AppColors.onSurfaceVariant, lineHeight: 20),
                        ajuste: FlexFit.loose),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DiaProgramaSelector extends StatelessWidget {
  const DiaProgramaSelector({
    super.key,
    required this.cortos,
    required this.completos,
    required this.seleccionado,
    required this.onSelect,
  });

  final List<String> cortos;

  final List<String> completos;
  final int seleccionado;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: cortos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final sel = i == seleccionado;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? Colors.black : Colors.white,
                borderRadius: AppRadius.xs,
                boxShadow: AppShadows.soft,
              ),
              child: Row(
                children: [
                  if (sel) ...[
                    const SvgIcon('jornada/sparkle_dia.svg', width: 12),
                    const SizedBox(width: 6),
                  ],
                  Text(sel ? completos[i] : cortos[i],
                      style: AppText.sans(18,
                          weight: sel ? FontWeight.w600 : FontWeight.w400,
                          color: sel ? Colors.white : AppColors.onSurfaceVariant,
                          lineHeight: 24)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class HoraStepperBox extends StatelessWidget {
  const HoraStepperBox({
    super.key,
    required this.label,
    required this.hora,
    required this.icon,
    this.onTap,
    this.onSubir,
    this.onBajar,
  });

  final String label;

  final String hora;
  final Widget icon;
  final VoidCallback? onTap;
  final VoidCallback? onSubir;
  final VoidCallback? onBajar;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.sans(15, color: AppColors.onSurfaceVariant, lineHeight: 22)),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
              color: AppColors.surfaceHigh,
              child: Row(
                children: [
                  icon,
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(hora, style: AppText.sans(18, weight: FontWeight.w600, lineHeight: 24)),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(onTap: onSubir, child: const Icon(Icons.keyboard_arrow_up, size: 18)),
                      InkWell(onTap: onBajar, child: const Icon(Icons.keyboard_arrow_down, size: 18)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TurnoCard extends StatelessWidget {
  const TurnoCard({
    super.key,
    required this.inicio,
    required this.fin,
    required this.valido,
    required this.cobertura,
  });

  final Widget inicio;
  final Widget fin;
  final bool valido;

  final String cobertura;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      radius: 4,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.surfaceHigh))),
            child: Row(
              children: [
                const SvgIcon('jornada/turno.svg', width: 16.7, height: 16.7),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Rango de Turno\nGeneral', style: AppText.sans(18, weight: FontWeight.w600, lineHeight: 28)),
                ),
                Text('TURNO\nMAÑANA/TARDE',
                    style: AppText.sans(15,
                        weight: FontWeight.w600, color: AppColors.accentBright, lineHeight: 22, letterSpacing: 1)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [inicio, const SizedBox(width: 10), fin]),
          const SizedBox(height: 20),
          InfoBox(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Cálculo de cobertura',
                          style: AppText.sans(15, color: AppColors.onSurfaceVariant, lineHeight: 22)),
                    ),
                    Text(valido ? cobertura : '—', style: AppText.sans(17, weight: FontWeight.w700, lineHeight: 24)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(6),
                  color: AppColors.surfaceHigh,
                  child: MensajeCampo(
                    valido
                        ? 'Hora de inicio anterior a la hora de fin'
                        : 'La hora de inicio debe ser anterior a la hora de fin',
                    tipo: valido ? TipoMensaje.ok : TipoMensaje.error,
                    margenSuperior: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AlmuerzoCard extends StatelessWidget {
  const AlmuerzoCard({
    super.key,
    required this.activo,
    required this.onActivo,
    required this.inicio,
    required this.fin,
    required this.valido,
    required this.okText,
    required this.antes,
    required this.duracion,
    required this.duracionMin,
    required this.netoMin,
  });

  final bool activo;
  final ValueChanged<bool> onActivo;

  final Widget inicio;
  final Widget fin;
  final bool valido;

  final String okText;

  final double antes;
  final double duracion;
  final int duracionMin;

  final int netoMin;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      radius: 4,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: SvgIcon('jornada/almuerzo.svg', width: 12.5, height: 16.7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pausa de Almuerzo y Receso Técnico',
                        style: AppText.sans(18, weight: FontWeight.w600, lineHeight: 28)),
                    Text('Bloquea automáticamente la agenda para evitar citas durante la comida del staff.',
                        style: AppText.sans(15, color: AppColors.onSurfaceVariant, lineHeight: 24)),
                  ],
                ),
              ),
              Switch(
                value: activo,
                onChanged: onActivo,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.accentBright,
                trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
              ),
            ],
          ),
          if (activo) ...[
            const SizedBox(height: 20),
            Row(children: [inicio, const SizedBox(width: 10), fin]),
            const SizedBox(height: 20),
            InfoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MensajeCampo(
                    valido ? okText : 'La pausa debe estar dentro de la jornada laboral.',
                    tipo: valido ? TipoMensaje.ok : TipoMensaje.error,
                    margenSuperior: 0,
                  ),
                  const SizedBox(height: 16),
                  _BarraJornada(antes: antes, duracion: duracion),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Dot(size: 8, color: Colors.black),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('Disponibilidad',
                            style: AppText.sans(15, color: AppColors.onSurfaceVariant, lineHeight: 20)),
                      ),
                      const Dot(size: 8, color: AppColors.accentBright),
                      const SizedBox(width: 6),
                      Text('Almuerzo ($duracionMin min)',
                          style: AppText.sans(15, color: AppColors.onSurfaceVariant, lineHeight: 20)),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          _DisponibilidadNeta(netoMin: netoMin),
        ],
      ),
    );
  }
}

class _BarraJornada extends StatelessWidget {
  const _BarraJornada({required this.antes, required this.duracion});

  final double antes;
  final double duracion;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.md,
      child: SizedBox(
        height: 14,
        child: LayoutBuilder(builder: (context, c) {
          return Stack(
            children: [
              Container(color: Colors.black),
              Positioned(
                left: c.maxWidth * antes,
                width: c.maxWidth * duracion,
                top: 0,
                bottom: 0,
                child: Container(color: AppColors.accentBright),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _DisponibilidadNeta extends StatelessWidget {
  const _DisponibilidadNeta({required this.netoMin});

  final int netoMin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.surfaceHigh,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DISPONIBILIDAD NETA',
                    style: AppText.sans(15, color: AppColors.onSurfaceVariant, lineHeight: 22, letterSpacing: 1.2)),
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: '${(netoMin / 60).toStringAsFixed(netoMin % 60 == 0 ? 0 : 1)} horas ',
                      style: AppText.sans(24, weight: FontWeight.w700, lineHeight: 32)),
                  TextSpan(
                      text: '($netoMin min)',
                      style: AppText.sans(15, color: AppColors.onSurfaceVariant, lineHeight: 20)),
                ])),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.md),
            child: const SvgIcon('jornada/timer.svg', width: 16.5, height: 19.3),
          ),
        ],
      ),
    );
  }
}

class AplicarTodosCard extends StatelessWidget {
  const AplicarTodosCard({super.key, required this.aplicar, required this.onToggle, required this.estado});

  final bool aplicar;
  final VoidCallback onToggle;

  final String estado;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      radius: 4,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: aplicar ? Colors.black : Colors.white,
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: AppRadius.xs,
                  ),
                  child: aplicar ? const SvgIcon('jornada/check.svg', width: 12.2, height: 9) : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text('Aplicar este horario a todos los días de lunes a viernes',
                      style: AppText.sans(18, lineHeight: 28)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InfoBox(
            leading: const SvgIcon('jornada/estado_agenda.svg', width: 15, height: 16.7),
            iconColor: AppColors.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estado de Agenda', style: AppText.sans(18, weight: FontWeight.w500, lineHeight: 22)),
                Text(estado, style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_form.dart';
import '../hex_widgets.dart';

/// Franja "HEX-CATALOG // GESTIÓN DE TARIFAS" con la versión del formulario.
class CatalogoFranja extends StatelessWidget {
  const CatalogoFranja({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: AppColors.surfaceHigh,
      child: Row(
        children: [
          const Dot(size: 7, color: AppColors.accentBright),
          const SizedBox(width: 10),
          Expanded(
            child: Text('CATÁLOGO · TARIFAS',
                style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 22, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}

/// Reparto del precio entre el estudio y el fotógrafo.
class RepartoTarifa extends StatelessWidget {
  const RepartoTarifa({
    super.key,
    required this.estudioLabel,
    required this.estudio,
    required this.fotografoLabel,
    required this.fotografo,
  });

  final String estudioLabel;
  final String estudio;
  final String fotografoLabel;
  final String fotografo;

  @override
  Widget build(BuildContext context) {
    return InfoBox(
      background: AppColors.surfaceHighFaded,
      child: Column(
        children: [
          _fila(estudioLabel, estudio, Colors.black, AppColors.onSurface),
          const SizedBox(height: 6),
          _fila(fotografoLabel, fotografo, AppColors.accentBright, AppColors.accentBright),
        ],
      ),
    );
  }

  Widget _fila(String label, String value, Color dot, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 8), child: Dot(size: 5, color: dot)),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22))),
        const SizedBox(width: 8),
        Text(value, style: AppText.mono(15, weight: FontWeight.w700, color: valueColor, lineHeight: 22)),
      ],
    );
  }
}

/// Encabezado "Duración estimada" con el valor elegido ("45 MIN // STD").
class DuracionHeader extends StatelessWidget {
  const DuracionHeader({super.key, required this.valor});

  final String valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('Duración\nestimada', style: AppText.sans(18, weight: FontWeight.w600, lineHeight: 24))),
        Tag(label: 'Bloqueo en\nAgenda', background: AppColors.surfaceHigh, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            style: AppText.sans(13, lineHeight: 20)),
        const SizedBox(width: 12),
        Text(valor, style: AppText.mono(15, weight: FontWeight.w700, color: AppColors.accentBright, lineHeight: 20)),
      ],
    );
  }
}

/// Cuatro bloques de duración (minutos + nombre).
class DuracionSelector extends StatelessWidget {
  const DuracionSelector({super.key, required this.opciones, required this.selected, required this.onSelect});

  final List<(int, String)> opciones;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < opciones.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _bloque(i)),
        ],
      ],
    );
  }

  Widget _bloque(int i) {
    final sel = i == selected;
    final (min, nombre) = opciones[i];
    return GestureDetector(
      onTap: () => onSelect(i),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: sel ? Colors.black : Colors.white,
          borderRadius: AppRadius.xs,
          boxShadow: AppShadows.soft,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(sel ? '$min✓' : '$min',
                      style: AppText.sans(20, weight: FontWeight.w700, color: sel ? Colors.white : AppColors.onSurface)),
                  Text(nombre, style: AppText.sans(14, color: sel ? Colors.white : AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            if (sel) const Positioned(right: 4, top: 4, child: Dot(size: 6, color: AppColors.accentBright)),
          ],
        ),
      ),
    );
  }
}

/// Foto de preset con título y detalle sobre degradado.
class PresetCard extends StatelessWidget {
  const PresetCard({super.key, required this.foto, required this.titulo, required this.detalle});

  final String foto;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.xs,
      child: SizedBox(
        height: 130,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/$foto', fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.scrim],
                ),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: AppText.sans(15, weight: FontWeight.w600, color: Colors.white)),
                  Text(detalle, style: AppText.mono(11, color: AppColors.outlineVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "FICHA TÉCNICA DE EQUIPAMIENTO": cámara, disparador y tiempo de edición.
class FichaEquipamiento extends StatelessWidget {
  const FichaEquipamiento({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      color: AppColors.surfaceHigh,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text('EQUIPO RECOMENDADO',
                    style: AppText.sans(16, weight: FontWeight.w600, letterSpacing: 1.2)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _dato('CÁMARA', 'Sony A7 IV'),
              const SizedBox(width: 8),
              _dato('DISPARADOR', 'Godox XPro'),
              const SizedBox(width: 8),
              _dato('TIEMPO EDICIÓN', '24 Horas', accent: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dato(String label, String value, {bool accent = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: Colors.white,
        child: Column(
          children: [
            Text(label, style: AppText.sans(12, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(value,
                style: AppText.mono(14, weight: FontWeight.w700, color: accent ? AppColors.accentBright : AppColors.onSurface)),
          ],
        ),
      ),
    );
  }
}

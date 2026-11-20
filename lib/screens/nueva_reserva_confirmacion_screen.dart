import 'package:flutter/material.dart';

import '../core/reloj.dart';
import '../data/mock_agenda.dart';
import '../data/mock_clientes.dart';
import '../data/mock_fotografos.dart';
import '../data/mock_pagos.dart';
import '../data/mock_servicios.dart';
import '../models/cliente.dart';
import '../models/fotografo.dart';
import '../models/servicio.dart';
import '../models/sesion.dart';
import '../services/local/sesion_actual.dart';
import '../services/remote/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/reserva/confirmacion_cards.dart';

class NuevaReservaConfirmacionScreen extends StatefulWidget {
  const NuevaReservaConfirmacionScreen({
    super.key,
    this.onConfirmada,
    this.onSalir,
    this.cliente,
    this.servicio,
    this.fotografo,
    this.inicio,
    this.lugar = 'Ciclorama Blanco',
    this.codigo = '#RSV-NUEVA',
  });

  final ValueChanged<Sesion>? onConfirmada;

  final VoidCallback? onSalir;

  final Cliente? cliente;
  final Servicio? servicio;
  final Fotografo? fotografo;
  final DateTime? inicio;
  final String lugar;

  final String codigo;

  @override
  State<NuevaReservaConfirmacionScreen> createState() => _NuevaReservaConfirmacionScreenState();
}

class _NuevaReservaConfirmacionScreenState extends State<NuevaReservaConfirmacionScreen> {
  int _pago = 0;

  bool _guardando = false;

  Servicio get _servicio => widget.servicio ?? serviciosReserva.firstOrNull ?? servicioEjemplo;

  late Fotografo? _fotografo = widget.fotografo;

  @override
  void initState() {
    super.initState();
    if (widget.fotografo == null) _cargarFotografo();
  }

  Future<void> _cargarFotografo() async {
    final f = await fotografoSugerido(_servicio);
    if (mounted) setState(() => _fotografo = f);
  }

  Future<void> _confirmar(Cliente c, Servicio s, Fotografo? f, DateTime inicio) async {
    setState(() => _guardando = true);
    try {
      final reserva = await crearReserva(
        inicio: inicio,
        cliente: c.nombre,
        clienteId: c.id,
        servicio: s.nombre,
        servicioId: s.id,
        duracionMin: s.duracionMin,
        precio: s.precio,
        fotografo: f?.nombre ?? 'Por asignar',
      );
      widget.onConfirmada?.call(reserva);
    } on ApiException catch (e) {
      if (mounted) showHexToast(context, e.message);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cliente ?? clienteEjemplo;
    final s = _servicio;
    final f = _fotografo ?? (SesionActual.conectada ? null : fotografos.firstOrNull ?? fotografosEjemplo.first);
    final inicio = widget.inicio ?? Reloj.hoy.add(const Duration(hours: 10));
    final fin = inicio.add(Duration(minutes: s.duracionMin));

    return HeaderScaffold(
      header: HexHeader(title: 'Nueva Reserva', cerrar: true, onBack: widget.onSalir),
      bottomPadding: 32,
      children: [
        const SizedBox(height: 16),
        const ConfirmacionCabecera(),
        const SizedBox(height: 36),
        ResumenReservaCard(
          codigo: widget.codigo,
          categoria: s.categoria.toUpperCase(),
          servicio: s.nombre,
          lugarDuracion: '${widget.lugar} • ${s.duracion}',
          clienteIniciales: c.iniciales,
          clienteNombre: c.nombre,
          clienteDocumento: c.ciudad == null ? c.documento : '${c.documento} (${c.ciudad})',
          telefono: c.telefono,
          email: c.email,
          fecha: '${nombreDia(inicio).substring(0, 3)}, ${inicio.day} ${mesCorto(inicio)} ${inicio.year}',
          horario: rangoAmPm(inicio, fin),
          fotografo: f?.nombre ?? 'Asignado por el estudio',
          comision: f == null ? 'Comisión según el profesional' : 'Comisión: ${f.comisionPct}%',
          total: formatCop(s.precio),
        ),
        const SizedBox(height: 16),
        _pagos(),
        const SizedBox(height: 16),
        HexButton(
          label: _guardando ? 'Creando reserva…' : 'Confirmar reserva',
          radius: 2,
          shadow: AppShadows.medium,
          onPressed: _guardando ? null : () => _confirmar(c, s, f, inicio),
          trailing: const SvgIcon('confirm/arrow_forward.svg', width: 12),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const SvgIcon('fecha/arrow_back.svg', width: 12),
            label: Text('Volver a Fecha y hora', style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
          ),
        ),
        const SizedBox(height: 16),
        const _PieVersion(),
      ],
    );
  }

  Widget _pagos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Medio de Pago Registrado', style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
            const SvgIcon('confirm/header_sparkle.svg', width: 14.667),
          ],
        ),
        Text('Registro de control operativo, no pasarela bancaria.',
            style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
        const SizedBox(height: 12),
        for (var i = 0; i < mediosPago.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          PagoOpcionTile(
            icon: mediosPago[i].icon,
            iconWidth: mediosPago[i].iconWidth,
            iconHeight: mediosPago[i].iconHeight,
            titulo: mediosPago[i].titulo,
            detalle: mediosPago[i].detalle,
            sugerido: mediosPago[i].sugerido,
            selected: i == _pago,
            onTap: () => setState(() => _pago = i),
          ),
        ],
      ],
    );
  }
}

class _PieVersion extends StatelessWidget {
  const _PieVersion();

  @override
  Widget build(BuildContext context) {
    final linea = Expanded(child: Container(height: 1, color: AppColors.outlineFaint));
    return Row(
      children: [
        linea,
        const SizedBox(width: 12),
        const SvgIcon('confirm/footer_sparkle.svg', width: 12.833),
        const SizedBox(width: 12),
        linea,
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../data/mock_clientes.dart';
import '../models/cliente.dart';
import '../services/local/sesion_actual.dart';
import '../theme/app_theme.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_search_field.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/reserva/cliente_seleccion.dart';

const _ultimoLookbook = {
  'Valentina Ruiz': ('Último lookbook: Editorial\nNeon Y2K', '18 ENE\n2025'),
};

class NuevaReservaClienteScreen extends StatefulWidget {
  const NuevaReservaClienteScreen({super.key, this.onContinuar, this.onRegistrarCliente});

  final ValueChanged<Cliente>? onContinuar;
  final Future<Cliente?> Function()? onRegistrarCliente;

  @override
  State<NuevaReservaClienteScreen> createState() => _NuevaReservaClienteScreenState();
}

class _NuevaReservaClienteScreenState extends State<NuevaReservaClienteScreen> with ConBusqueda, RedibujarAlCambiar {
  @override
  Listenable get escuchar => revisionClientes;

  String? _seleccionado = (SesionActual.conectada ? clientes.firstOrNull : clienteEjemplo)?.nombre;

  Cliente? get _cliente => clientes.where((c) => c.nombre == _seleccionado).firstOrNull ??
      (_seleccionado == clienteEjemplo.nombre ? clienteEjemplo : null);

  Future<void> _registrar() async {
    final nuevo = await widget.onRegistrarCliente!();
    if (nuevo == null || !mounted) return;
    setState(() {
      busqueda.clear();
      _seleccionado = nuevo.nombre;
    });
  }

  Widget _avatar(Cliente c) => c.foto != null
      ? Image.asset('assets/images/${c.foto}', width: 48, height: 48, fit: BoxFit.cover)
      : const SvgIcon('reserva/face_1.svg', width: 20, height: 20);

  @override
  Widget build(BuildContext context) {
    final resultados = clientes.where((c) => c.coincide(busqueda.text)).toList();

    return HeaderScaffold(
      header: HexHeader(title: 'Nueva Reserva', cerrar: true),
      bottomPadding: 128 + 64,
      overlay: Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: BlurBottomBar(
          blur: 12,
          padding: const EdgeInsets.all(20),
          child: HexButton(
            label: 'Continuar a Servicio y Fotógrafo',
            gap: 4,
            shadow: AppShadows.medium,
            onPressed: _cliente == null || widget.onContinuar == null ? null : () => widget.onContinuar!(_cliente!),
            trailing: const SvgIcon('reserva/arrow_right.svg', width: 13.333),
          ),
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const ReservaClienteIntro(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Buscar Cliente Registrado', style: AppText.sans(16, weight: FontWeight.w500, lineHeight: 20)),
            Text('EN LÍNEA', style: AppText.sans(14, weight: FontWeight.w500, color: AppColors.accent, lineHeight: 18)),
          ],
        ),
        const SizedBox(height: 4),
        HexSearchField(
          controller: busqueda,
          hint: 'Nombre, cédula o teléfono',
          onChanged: (_) => setState(() {}),
          icon: const SvgIcon('reserva/search.svg', width: 15),
          iconPadding: const EdgeInsets.only(left: 18.5, right: 14.5),
          iconMinWidth: 48,
          suffix: busqueda.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () => setState(busqueda.clear),
                  icon: const SvgIcon('reserva/clear.svg', width: 15),
                ),
        ),
        const SizedBox(height: 16),
        HexButton(
          label: 'Registrar nuevo cliente en sistema',
          onPressed: widget.onRegistrarCliente == null ? null : _registrar,
          background: AppColors.surfaceHigh,
          foreground: AppColors.onSurface,
          gap: 4,
          leading: const SvgIcon('reserva/person_add.svg', width: 18.333, height: 13.333),
        ),
        const SizedBox(height: 28),
        EncabezadoSeccion(
          'RESULTADOS',
          extra: Tag(
            label: '${resultados.length}',
            background: AppColors.surfaceHighest,
            radius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
        ),
        const SizedBox(height: 8),
        if (resultados.isEmpty)
          Text('Sin coincidencias. Registra al cliente como nuevo.',
              style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
        for (var i = 0; i < resultados.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _tarjeta(resultados[i]),
        ],
        const SizedBox(height: 28),
        if (_seleccionado != null) ParametrosRapidosCard(cliente: _seleccionado!),
      ],
    );
  }

  Widget _tarjeta(Cliente c) {
    final frecuente = c.estado == EstadoCliente.frecuente;
    final lookbook = frecuente ? _ultimoLookbook[c.nombre] : null;
    return ClienteResultadoCard(
      nombre: c.nombre,
      documento: c.documento,
      telefono: c.telefono,
      avatar: _avatar(c),
      email: frecuente ? c.email : null,
      recurrente: frecuente ? 'Recurrente (${c.sesiones} sesiones)' : null,
      ultimaSesion: lookbook?.$1,
      fechaUltima: lookbook?.$2,
      selected: c.nombre == _seleccionado,
      onTap: () => setState(() => _seleccionado = c.nombre),
    );
  }
}

import 'package:flutter/material.dart';

import '../core/reloj.dart';
import '../data/mock_agenda.dart';
import '../models/sesion.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/inicio/kpi_resumen.dart';
import '../widgets/inicio/modulo_link.dart';
import '../widgets/inicio/nueva_reserva_banner.dart';
import '../widgets/inicio/reserva_hoy_card.dart';
import '../widgets/inicio/saludo_admin.dart';

class InicioAdminScreen extends StatelessWidget {
  const InicioAdminScreen({
    super.key,
    this.bottomBar,
    required this.onNuevaReserva,
    required this.onAbrirSesion,
    this.onEspecialidades,
    this.onServicios,
    this.onFotografos,
    this.onCierres,
  });

  final Widget? bottomBar;
  final VoidCallback onNuevaReserva;
  final ValueChanged<Sesion> onAbrirSesion;
  final VoidCallback? onEspecialidades;
  final VoidCallback? onServicios;
  final VoidCallback? onFotografos;
  final VoidCallback? onCierres;

  static List<Sesion> get _deHoy {
    final hoy = sesionesAgenda.where((s) => mismoDia(s.inicio, Reloj.hoy) && !s.cancelada).toList();
    int orden(Sesion s) => s.estado == SesionEstado.realizada ? 1 : 0;
    return hoy..sort((a, b) => orden(a) != orden(b) ? orden(a) - orden(b) : a.inicio.compareTo(b.inicio));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: revisionAgenda, builder: _contenido);

  Widget _contenido(BuildContext context, Widget? _) {
    final hoy = _deHoy;
    final pendientes = hoy.where((s) => s.estado == SesionEstado.programada).length;
    final fecha = '${nombreDia(Reloj.hoy)}, ${Reloj.hoy.day} de ${nombreMes(Reloj.hoy).toLowerCase()} de ${Reloj.hoy.year}';

    return HeaderScaffold(
      header: const HexHeader(section: 'Inicio'),
      bottomBar: bottomBar,
      bottomPadding: 112 + 80,
      children: [
        const SizedBox(height: 8),
        SaludoAdmin(fecha: fecha, saludo: saludoSegunHora(Reloj.ahora())),
        const SizedBox(height: 44),
        NuevaReservaBanner(onTap: onNuevaReserva),
        const SizedBox(height: 44),
        KpiResumen(total: hoy.length, pendientes: pendientes, realizadas: hoy.length - pendientes),
        const SizedBox(height: 44),
        _proximasReservas(hoy),
        const SizedBox(height: 44),
        _modulos(),
        const SizedBox(height: 44),
        const HardwareStatusCard(
          titulo: 'Estudio A — SONY α7 IV',
          detalle: 'Óptica 50mm f/1.2 GM · Flash sincronizado',
        ),
      ],
    );
  }

  Widget _proximasReservas(List<Sesion> hoy) {
    return Column(
      children: [
        _Titulo(
          'Próximas reservas de hoy',
          leading: const SvgIcon('inicio/upcoming.svg', width: 16.667),
          trailing: Text('${hoy.length} turnos', style: AppText.sans(14, color: AppColors.outline, lineHeight: 18)),
        ),
        for (final s in hoy) ...[
          const SizedBox(height: 16),
          if (s.destacada)
            ReservaDestacadaCard(
              cliente: s.cliente,
              servicio: s.nombreServicio,
              horario: rangoAmPm(s.inicio, s.fin),
              fotografo: s.fotografo,
              precio: '${formatCop(s.precio ?? 0)} COP',
              onDetalles: () => onAbrirSesion(s),
            )
          else
            ReservaHoyCard(
              cliente: s.cliente,
              servicio: s.nombreServicio,
              horario: rangoAmPm(s.inicio, s.fin),
              fotografo: s.fotografo,
              precio: '${formatCop(s.precio ?? 0)} COP',
              realizada: s.estado == SesionEstado.realizada,
              onGestionar: () => onAbrirSesion(s),
            ),
        ],
      ],
    );
  }

  Widget _modulos() {
    return Column(
      children: [
        const _Titulo('Módulos de Gestión', trailing: SvgIcon('inicio/modules.svg', width: 15, height: 16.667)),
        const SizedBox(height: 16),
        ModuloLink(
          icon: 'inicio/especialidades.svg',
          iconWidth: 15.833,
          iconHeight: 16.667,
          titulo: 'Especialidades',
          subtitulo: 'Retratos, Familiar, Prod.',
          onTap: onEspecialidades,
        ),
        const SizedBox(height: 8),
        ModuloLink(
          icon: 'inicio/servicios.svg',
          iconWidth: 18.333,
          iconHeight: 13.333,
          titulo: 'Servicios y Tarifas',
          subtitulo: 'Catálogo y lista \$COP',
          onTap: onServicios,
        ),
        const SizedBox(height: 8),
        ModuloLink(
          icon: 'inicio/fotografos.svg',
          iconWidth: 16.667,
          iconHeight: 16.667,
          titulo: 'Fotógrafos',
          subtitulo: 'Disponibilidad de equipo',
          onTap: onFotografos,
        ),
        const SizedBox(height: 8),
        ModuloLink(
          icon: 'inicio/cierres.svg',
          iconWidth: 15.833,
          iconHeight: 15,
          titulo: 'Cierres y Caja',
          subtitulo: 'Liquidación comisiones',
          onTap: onCierres,
        ),
      ],
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto, {this.leading, required this.trailing});

  final String texto;
  final Widget? leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final titulo = Text(texto,
        style: AppText.sans(20, weight: FontWeight.w600, color: Colors.black, lineHeight: 28, letterSpacing: -0.2));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (leading != null) Row(children: [leading!, const SizedBox(width: 8), titulo]) else titulo,
        trailing,
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../models/sesion.dart';
import '../navegacion.dart';
import '../theme/app_theme.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';
import 'agenda_screen.dart';
import 'busqueda_global_screen.dart';
import 'catalogo_clientes_screen.dart';
import 'catalogo_especialidades_screen.dart';
import 'catalogo_fotografos_screen.dart';
import 'catalogo_servicios_screen.dart';
import 'cierres_periodo_screen.dart';
import 'configurar_jornada_screen.dart';
import 'crear_servicio_screen.dart';
import 'ficha_nuevo_cliente_screen.dart';
import 'gestion_inasistencias_screen.dart';
import 'horario_semanal_screen.dart';
import 'inicio_admin_screen.dart';
import 'liquidacion_comisiones_screen.dart';
import 'nueva_especialidad_sheet.dart';
import 'nueva_reserva_cliente_screen.dart';
import 'nueva_reserva_confirmacion_screen.dart';
import 'nueva_reserva_fecha_screen.dart';
import 'nueva_reserva_servicio_screen.dart';
import 'nuevo_cierre_screen.dart';
import 'registrar_cliente_sheet.dart';
import 'registrar_inasistencia_screen.dart';
import 'registrar_profesional_screen.dart';

/// Contenedor del rol Admin con la barra inferior: Inicio · Agenda · Clientes · Más.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _onTab(int i) {
    if (i == 3) {
      _menuMas();
      return;
    }
    setState(() => _index = i);
  }

  void _push(Widget screen, {String? desde}) => Rutas.push(context, screen, desde: desde);

  // ---- Flujos de navegación ----

  /// Nueva reserva en 4 pasos; cada paso pasa lo elegido al siguiente: cliente → servicio → fecha y hora →
  /// confirmación (que crea la reserva y vuelve a la agenda).
  /// En cada paso hay dos salidas distintas: la ✕ del header sale de toda la reserva ([_salirDeReserva]) y
  /// "Volver" (o el atrás del sistema) regresa solo al paso anterior.
  void _nuevaReserva() => _push(
        NuevaReservaClienteScreen(
          onRegistrarCliente: () => showRegistrarClienteSheet(context),
          onContinuar: (cliente) => _push(
            NuevaReservaServicioScreen(
              cliente: cliente,
              onSalir: _salirDeReserva,
              onContinuar: (servicio) => _push(
                NuevaReservaFechaScreen(
                  cliente: cliente,
                  servicio: servicio,
                  onSalir: _salirDeReserva,
                  onContinuar: (inicio) => _push(
                    NuevaReservaConfirmacionScreen(
                      cliente: cliente,
                      servicio: servicio,
                      inicio: inicio,
                      onSalir: _salirDeReserva,
                      onConfirmada: (reserva) =>
                          _volverAlInicio('Reserva ${reserva.codigo ?? ''} confirmada'.replaceAll('  ', ' '), agenda: true),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  /// ✕ de la nueva reserva (pasos 2 a 4): pregunta y vuelve a la pestaña desde la que se empezó.
  Future<void> _salirDeReserva() async {
    final salir = await confirmarSalida(
      context,
      titulo: '¿Salir de la nueva reserva?',
      mensaje: 'Lo que elegiste en los pasos anteriores no se guardará.',
      seguir: 'Seguir reservando',
      salir: 'Salir',
    );
    if (salir && mounted) _volverAlInicio(null);
  }

  void _volverAlInicio(String? mensaje, {bool agenda = false}) {
    Navigator.of(context).popUntil((r) => r.isFirst);
    setState(() => _index = agenda ? 1 : _index);
    if (mensaje != null) showHexToast(context, mensaje);
  }

  /// Detalle de [s], abierto desde la pestaña actual (Inicio o Agenda): su header dice a cuál vuelve.
  void _abrirSesion(Sesion s) => _push(Rutas.sesionDetalle(context, s), desde: _index == 1 ? 'Agenda' : 'Inicio');

  void _horarios() => _push(
        HorarioSemanalScreen(
          onInasistencias: _inasistencias,
          onConfigurarDia: () => _push(const ConfigurarJornadaScreen()),
        ),
      );

  void _inasistencias() => _push(
        GestionInasistenciasScreen(
          onRegistrar: () => _push(const RegistrarInasistenciaScreen()),
          onJornada: _horarios,
        ),
      );

  void _fotografos() => _push(
        CatalogoFotografosScreen(
          onRegistrar: () => _push(const RegistrarProfesionalScreen()),
          onJornada: () => _push(const ConfigurarJornadaScreen()),
          onHorarios: _horarios,
          onInasistencia: _inasistencias,
          onComisiones: () => _push(Rutas.liquidacion(), desde: 'Fotógrafos'),
        ),
      );

  void _servicios() => _push(CatalogoServiciosScreen(onNuevo: () => _push(const CrearServicioScreen())));

  void _especialidades() => _push(
        CatalogoEspecialidadesScreen(
          onNueva: () async {
            final nombre = await showNuevaEspecialidadSheet(context);
            if (nombre != null && mounted) showHexToast(context, 'Especialidad "$nombre" creada');
          },
        ),
      );

  void _cierres() => _push(
        CierresPeriodoScreen(
          onNuevoCierre: () => _push(const NuevoCierreScreen()),
          onVerDetalle: (cierre) => _push(LiquidacionComisionesScreen(cierre: cierre), desde: 'Cierres'),
        ),
      );

  void _busqueda([String inicial = '']) => _push(
        BusquedaGlobalScreen(inicial: inicial, onRegistrar: (_) => _push(const FichaNuevoClienteScreen())),
      );

  /// Menú "Más" de la barra inferior: cada opción cierra el menú y abre su pantalla.
  void _menuMas() {
    final opciones = [
      (Icons.search, 'Búsqueda Global', 'Clientes, servicios y fotógrafos', _busqueda),
      (Icons.category_outlined, 'Especialidades', 'Retratos, Familiar, Prod.', _especialidades),
      (Icons.sell_outlined, 'Servicios y Tarifas', 'Catálogo y lista \$COP', _servicios),
      (Icons.photo_camera_outlined, 'Fotógrafos', 'Disponibilidad de equipo', _fotografos),
      (Icons.schedule, 'Horarios', 'Jornada semanal del staff', _horarios),
      (Icons.event_busy_outlined, 'Inasistencias', 'Bloqueos y ausencias del staff', _inasistencias),
      (Icons.account_balance_wallet_outlined, 'Cierres y Caja', 'Cierres de periodo y liquidación', _cierres),
      (Icons.logout, 'Cerrar sesión', 'Volver al inicio de sesión', () => Rutas.login(context)),
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (hoja) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (icono, titulo, detalle, abrir) in opciones)
                _OpcionMenu(icono, titulo, detalle, onTap: () {
                  Navigator.of(hoja).pop();
                  abrir();
                }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Un único Scaffold raíz: las pestañas quedan anidadas y el SnackBar se
    // dibuja una sola vez (con tres Scaffolds raíz se duplicaba su Hero).
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: HexBottomNav(currentIndex: _index, onTap: _onTab),
      body: IndexedStack(
        index: _index,
        children: [
          InicioAdminScreen(
            onNuevaReserva: _nuevaReserva,
            onAbrirSesion: _abrirSesion,
            onEspecialidades: _especialidades,
            onServicios: _servicios,
            onFotografos: _fotografos,
            onCierres: _cierres,
          ),
          AgendaScreen(onNuevaReserva: _nuevaReserva, onAbrirSesion: _abrirSesion),
          CatalogoClientesScreen(
            onAgendar: _nuevaReserva,
            onNuevoCliente: () => _push(const FichaNuevoClienteScreen()),
            onVerFicha: () => _push(Rutas.sesionDetalle(context), desde: 'Clientes'),
            onSinResultados: _busqueda,
          ),
        ],
      ),
    );
  }
}

/// Fila del menú "Más": icono en caja gris, título y detalle.
class _OpcionMenu extends StatelessWidget {
  const _OpcionMenu(this.icono, this.titulo, this.detalle, {required this.onTap});

  final IconData icono;
  final String titulo;
  final String detalle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: AppColors.surfaceContainer, borderRadius: AppRadius.xs),
        child: Icon(icono, size: 18, color: AppColors.onSurface),
      ),
      title: Text(titulo, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 20)),
      subtitle: Text(detalle, style: AppText.sans(12, color: AppColors.onSurfaceVariant, lineHeight: 18)),
      onTap: onTap,
    );
  }
}

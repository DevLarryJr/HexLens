import 'package:flutter/material.dart';

import 'data/mock_agenda.dart';
import 'models/login/login_response.dart';
import 'models/sesion.dart';
import 'screens/home_shell.dart';
import 'screens/liquidacion_comisiones_screen.dart';
import 'screens/login_screen.dart';
import 'screens/mis_servicios_screen.dart';
import 'screens/reagendar_sesion_screen.dart';
import 'screens/recuperacion_acceso_screen.dart';
import 'screens/sesion_detalle_screen.dart';
import 'services/remote/login_service.dart';
import 'widgets/hex_widgets.dart';

class Rutas {
  static void push(BuildContext context, Widget screen, {String? desde}) => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen, settings: RouteSettings(arguments: desde == null ? null : VolverA(desde))));

  static void login(BuildContext context) {
    LoginService().logout();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  static Widget sesionDetalle(BuildContext context, [Sesion? sesion]) {
    final s = sesion ?? sesionEnGestion;
    return SesionDetalleScreen(sesion: s, onReagendar: () => push(context, ReagendarSesionScreen(sesion: s)));
  }

  static Widget liquidacion() => const LiquidacionComisionesScreen();

  static Widget inicioDe(LoginResponse sesion) => sesion.esGestor ? const HomeShell() : const FotografoHome();
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      onRecuperar: () => Rutas.push(context, const RecuperacionAccesoScreen()),
      onLogin: (admin) => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => admin ? const HomeShell() : const FotografoHome()),
      ),
    );
  }
}

class FotografoHome extends StatelessWidget {
  const FotografoHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MisServiciosScreen(
      onVerFicha: () => Rutas.push(context, Rutas.sesionDetalle(context), desde: 'Mis Servicios'),
      onComisiones: () => Rutas.push(context, Rutas.liquidacion(), desde: 'Mis Servicios'),
      onCuenta: () => Rutas.login(context),
    );
  }
}

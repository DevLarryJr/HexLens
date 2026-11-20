import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/mock_clientes.dart';
import 'data/sincronizacion.dart';
import 'models/login/login_response.dart';
import 'navegacion.dart';
import 'screens/splash_screen.dart';
import 'services/local/sesion_actual.dart';
import 'theme/app_theme.dart';

export 'navegacion.dart';
export 'screens/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cargarClientesRegistrados();
  final sesion = await SesionActual.restaurar();
  runApp(MyApp(sesionInicial: sesion));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.showSplash = true, this.sesionInicial});

  final bool showSplash;

  final LoginResponse? sesionInicial;

  Widget get _inicio {
    final sesion = sesionInicial;
    return sesion == null ? const LoginPage() : Rutas.inicioDe(sesion);
  }

  Future<void> _entrar(BuildContext context) async {
    final navigator = Navigator.of(context);
    if (sesionInicial != null) await sincronizarTodo();
    final usuario = SesionActual.usuario;
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => usuario == null ? const LoginPage() : Rutas.inicioDe(usuario)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HexLens Studio',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'CO'),
      supportedLocales: const [Locale('es', 'CO'), Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildAppTheme(),
      home: showSplash
          ? Builder(builder: (context) => SplashScreen(onFinished: () => _entrar(context)))
          : _inicio,
    );
  }
}

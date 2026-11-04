import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/mock_clientes.dart';
import 'navegacion.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

export 'navegacion.dart';
export 'screens/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cargarClientesRegistrados();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.showSplash = true});

  /// Permite saltar la animación de carga (útil en tests).
  final bool showSplash;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HexLens Studio',
      debugShowCheckedModeBanner: false,
      // Español de Colombia: calendarios, selector de hora y textos del sistema.
      locale: const Locale('es', 'CO'),
      supportedLocales: const [Locale('es', 'CO'), Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildAppTheme(),
      home: showSplash
          ? Builder(
              builder: (context) => SplashScreen(
                onFinished: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
              ),
            )
          : const LoginPage(),
    );
  }
}

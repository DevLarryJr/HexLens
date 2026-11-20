import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/screens/splash_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<List<int>> abrir(WidgetTester t) async {
    final fin = <int>[];
    await t.pumpWidget(MaterialApp(theme: buildAppTheme(), home: SplashScreen(onFinished: () => fin.add(1))));
    return fin;
  }

  testWidgets('Splash: avisa al terminar la carga', (t) async {
    final fin = await abrir(t);
    await t.pump(const Duration(milliseconds: 2000));
    expect(fin, isEmpty);
    await t.pump(const Duration(milliseconds: 300));
    await t.pump(const Duration(milliseconds: 400));
    expect(fin, [1]);
  });

  testWidgets('Splash: si se cierra durante la pausa final no deja temporizadores', (t) async {
    final fin = await abrir(t);
    await t.pump(const Duration(milliseconds: 2000));
    await t.pump(const Duration(milliseconds: 300));
    await t.pumpWidget(const SizedBox());
    expect(fin, isEmpty);
  });
}

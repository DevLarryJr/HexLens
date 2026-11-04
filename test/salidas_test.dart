import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/main.dart';
import 'package:proyecto_movil/screens/crear_servicio_screen.dart';
import 'package:proyecto_movil/screens/nueva_reserva_confirmacion_screen.dart';
import 'package:proyecto_movil/screens/nueva_reserva_servicio_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

/// Una sola salida por pantalla: formularios con ✕ que protege lo escrito, y la nueva reserva con
/// ✕ (salir de todo) separada de "Volver" (paso anterior).
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> montar(WidgetTester t, Widget home) async {
    t.view.physicalSize = const Size(1600, 8000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    // La fuente de pruebas (Ahem) es más ancha que Noto Sans; este test solo mira lógica.
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.6)),
        child: child!,
      ),
      home: home,
    ));
  }

  /// Pantalla de arranque con un botón que abre [pantalla] encima (así hay a dónde volver).
  Future<void> abrirEncima(WidgetTester t, Widget pantalla) async {
    await montar(
      t,
      Builder(
        builder: (context) => TextButton(onPressed: () => Rutas.push(context, pantalla), child: const Text('abrir')),
      ),
    );
    await t.tap(find.text('abrir'));
    await t.pumpAndSettle();
  }

  group('Formulario (Nuevo Servicio)', () {
    testWidgets('solo tiene la ✕ arriba: ya no hay "Descartar Cambios" abajo', (t) async {
      await abrirEncima(t, const CrearServicioScreen());
      expect(find.bySemanticsLabel('Cerrar'), findsOneWidget);
      expect(find.text('Descartar Cambios'), findsNothing);
      expect(find.text('Guardar Servicio'), findsOneWidget);
    });

    testWidgets('sin cambios, la ✕ cierra sin preguntar', (t) async {
      await abrirEncima(t, const CrearServicioScreen());
      await t.tap(find.bySemanticsLabel('Cerrar'));
      await t.pumpAndSettle();
      expect(find.byType(CrearServicioScreen), findsNothing);
      expect(find.text('¿Descartar los cambios?'), findsNothing);
    });

    testWidgets('con cambios, la ✕ pregunta; "Seguir editando" se queda y "Descartar" cierra', (t) async {
      await abrirEncima(t, const CrearServicioScreen());
      await t.enterText(find.byType(TextField).first, 'Retrato de prueba');
      await t.pump();

      await t.tap(find.bySemanticsLabel('Cerrar'));
      await t.pumpAndSettle();
      expect(find.text('¿Descartar los cambios?'), findsOneWidget);
      await t.tap(find.text('Seguir editando'));
      await t.pumpAndSettle();
      expect(find.byType(CrearServicioScreen), findsOneWidget);
      expect(find.text('Retrato de prueba'), findsOneWidget, reason: 'lo escrito sigue ahí');

      await t.tap(find.bySemanticsLabel('Cerrar'));
      await t.pumpAndSettle();
      await t.tap(find.text('Descartar'));
      await t.pumpAndSettle();
      expect(find.byType(CrearServicioScreen), findsNothing);
    });

    testWidgets('el atrás del sistema (Android) también pregunta si hay cambios', (t) async {
      await abrirEncima(t, const CrearServicioScreen());
      await t.enterText(find.byType(TextField).first, 'Retrato de prueba');
      await t.pump();
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.text('¿Descartar los cambios?'), findsOneWidget);
      expect(find.byType(CrearServicioScreen), findsOneWidget);
    });
  });

  group('Nueva reserva', () {
    testWidgets('la ✕ llama a "salir de la reserva"; "Volver" solo regresa un paso', (t) async {
      var salidas = 0;
      await abrirEncima(t, NuevaReservaServicioScreen(onSalir: () => salidas++));

      await t.tap(find.bySemanticsLabel('Cerrar'));
      await t.pumpAndSettle();
      expect(salidas, 1);
      expect(find.byType(NuevaReservaServicioScreen), findsOneWidget, reason: 'la ✕ no es "paso anterior"');

      await t.tap(find.text('Volver'));
      await t.pumpAndSettle();
      expect(salidas, 1);
      expect(find.byType(NuevaReservaServicioScreen), findsNothing);
    });

    testWidgets('Confirmación: sin "Volver a la Agenda Operativa"; queda "Volver a Fecha y hora"', (t) async {
      await montar(t, const NuevaReservaConfirmacionScreen());
      expect(find.text('Volver a la Agenda Operativa'), findsNothing);
      expect(find.text('Volver y corregir datos'), findsNothing);
      expect(find.text('Volver a Fecha y hora'), findsOneWidget);
      expect(find.bySemanticsLabel('Cerrar'), findsOneWidget);
    });

    testWidgets('desde la agenda: paso 1 sin "Cancelar"; en el paso 2 la ✕ pregunta y vuelve a la agenda',
        (t) async {
      await montar(t, const HomeShell());
      await t.tap(find.text('Agenda').last);
      await t.pumpAndSettle();
      await t.tap(find.text('Nueva'));
      await t.pumpAndSettle();

      expect(find.text('Cancelar y volver a Agenda'), findsNothing);
      await t.tap(find.text('Continuar a Servicio y Fotógrafo'));
      await t.pumpAndSettle();
      expect(find.byType(NuevaReservaServicioScreen), findsOneWidget);

      await t.tap(find.bySemanticsLabel('Cerrar'));
      await t.pumpAndSettle();
      expect(find.text('¿Salir de la nueva reserva?'), findsOneWidget);
      await t.tap(find.text('Seguir reservando'));
      await t.pumpAndSettle();
      expect(find.byType(NuevaReservaServicioScreen), findsOneWidget);

      await t.tap(find.bySemanticsLabel('Cerrar'));
      await t.pumpAndSettle();
      await t.tap(find.text('Salir'));
      await t.pumpAndSettle();
      expect(find.text('Nueva Reserva'), findsNothing, reason: 'salió de los 4 pasos');
      expect(find.text('Nueva'), findsOneWidget, reason: 'sigue en la agenda, donde empezó');
    });
  });
}

import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:proyecto_movil/core/reloj.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  Reloj.fijar(DateTime(2026, 10, 15, 9, 45));
  SharedPreferences.setMockInitialValues({});
  FlutterSecureStorage.setMockInitialValues({});
  await testMain();
}

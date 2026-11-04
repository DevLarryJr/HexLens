import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/hex_form.dart';
import '../widgets/login/recuperacion_widgets.dart';

/// Figma: "HexLens - Recuperación de Acceso" (41:2295)
class RecuperacionAccesoScreen extends StatefulWidget {
  const RecuperacionAccesoScreen({super.key});

  @override
  State<RecuperacionAccesoScreen> createState() => _RecuperacionAccesoScreenState();
}

class _RecuperacionAccesoScreenState extends State<RecuperacionAccesoScreen> {
  final _correo = TextEditingController(text: 'p.soto@hexlens.studio');
  final _otp = TextEditingController(text: '7409');
  final _otpFocus = FocusNode();
  Timer? _timer;
  int _segundos = 52;

  @override
  void initState() {
    super.initState();
    // El borde de la casilla activa depende del foco.
    _otpFocus.addListener(_alCambiarFoco);
    _iniciarConteo();
  }

  void _iniciarConteo([int desde = 52]) {
    _timer?.cancel();
    _segundos = desde;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_segundos == 0) {
        t.cancel();
      } else {
        setState(() => _segundos--);
      }
    });
  }

  void _alCambiarFoco() => setState(() {});

  @override
  void dispose() {
    _timer?.cancel();
    _otpFocus.removeListener(_alCambiarFoco);
    _correo.dispose();
    _otp.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  /// Correo ("p.soto@hexlens.studio"), C.C. numérica o ID de operador ("HL-084").
  bool get _correoValido =>
      RegExp(r'^([^@\s]+@[^@\s]+\.[^@\s]+|\d{3,}|#?HL-\d{3})$', caseSensitive: false).hasMatch(_correo.text.trim());

  void _enviarCodigo() {
    if (!_correoValido) {
      showHexToast(context, 'Ingresa tu ID de operador o correo');
      return;
    }
    setState(_otp.clear);
    _iniciarConteo(59);
    _otpFocus.requestFocus();
    showHexToast(context, 'Código OTP enviado a ${_correo.text.trim()}');
  }

  void _validar() {
    if (_otp.text.length < 6) {
      showHexToast(context, 'Ingresa los 6 dígitos del código');
      return;
    }
    showHexToast(context, 'Código validado. Ya puedes definir tu nueva contraseña.');
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(26, 24, 26, 32),
          children: [
            // Única salida: la flecha de arriba (antes también había "Volver al Inicio de Sesión" al final).
            RecuperacionTopBar(onBack: () => Navigator.of(context).maybePop()),
            const SizedBox(height: 30),
            const RecuperacionEncabezado(),
            const SizedBox(height: 26),
            SolicitarOtpCard(
              controller: _correo,
              valido: _correoValido,
              onChanged: (_) => setState(() {}),
              onEnviar: _enviarCodigo,
            ),
            const SizedBox(height: 28),
            ValidarOtpCard(
              casillas: OtpCasillas(controller: _otp, focusNode: _otpFocus, onChanged: (_) => setState(() {})),
              segundos: _segundos,
              completo: _otp.text.length == 6,
              onReenviar: _enviarCodigo,
              onValidar: _validar,
            ),
            const SizedBox(height: 32),
            const CaducidadNota(),
          ],
        ),
      ),
    );
  }
}

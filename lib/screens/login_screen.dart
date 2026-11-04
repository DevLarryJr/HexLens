import 'package:flutter/material.dart';

import '../api/api.dart';
import '../data/mock_agenda.dart';
import '../data/mock_cierres.dart';
import '../data/mock_clientes.dart';
import '../data/mock_especialidades.dart';
import '../data/mock_fotografos.dart';
import '../data/mock_servicios.dart';
import '../theme/app_theme.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/login/login_widgets.dart';

/// Figma: "HexLens - Inicio de Sesión" (19:2)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin, this.onRecuperar});

  /// Se llama tras iniciar sesión en la API: `true` si el rol del usuario es Gestor (panel
  /// administrativo), `false` si no (Mis Servicios).
  final ValueChanged<bool> onLogin;
  final VoidCallback? onRecuperar;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController();
  final _password = TextEditingController();
  bool _isAdmin = true;
  bool _obscure = true;
  bool _remember = true;
  bool _intentado = false;

  /// Esperando la respuesta de la API.
  bool _cargando = false;

  bool get _userError => _intentado && _user.text.trim().isEmpty;
  bool get _passwordError => _intentado && _password.text.isEmpty;

  /// Inicia sesión en la API (`POST /api/sesion`) y carga el directorio de clientes.
  /// El panel al que entra lo decide el rol del usuario en la API, no el selector.
  Future<void> _iniciar() async {
    setState(() => _intentado = true);
    if (_user.text.trim().isEmpty || _password.text.isEmpty) {
      showHexToast(context, 'Ingresa tu usuario y contraseña');
      return;
    }
    setState(() => _cargando = true);
    try {
      final sesion = await Api.iniciarSesion(_user.text, _password.text);
      // Datos que se cargan al entrar; si alguno falla se avisa y se sigue con los demás.
      // Las especialidades van antes que servicios y fotógrafos: dan el nombre de la especialidad de cada uno.
      final cargas = [
        ('los clientes', sincronizarClientes),
        ('las especialidades', sincronizarEspecialidades),
        ('los servicios', sincronizarServicios),
        ('los fotógrafos', sincronizarFotografos),
        // La agenda al final: completa nombres de cliente y servicio con los ya cargados.
        ('la agenda', sincronizarAgenda),
        ('los cierres', sincronizarCierres),
      ];
      for (final (nombre, cargar) in cargas) {
        try {
          await cargar();
        } on ApiError catch (e) {
          if (mounted) showHexToast(context, 'No se pudieron cargar $nombre: ${e.mensaje}');
        }
      }
      if (!mounted) return;
      _password.clear();
      widget.onLogin(sesion.esGestor);
    } on ApiError catch (e) {
      if (mounted) showHexToast(context, e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _user.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LoginTopIndicator(),
              const SizedBox(height: 40),
              const LoginEncabezado(),
              const SizedBox(height: 48),
              Center(child: Image.asset('assets/images/logo_hexlens.png', width: 233, height: 68, fit: BoxFit.contain)),
              const SizedBox(height: 20),
              Center(child: RolSelector(isAdmin: _isAdmin, onChanged: (v) => setState(() => _isAdmin = v))),
              const SizedBox(height: 40),
              _loginCard(),
              const SizedBox(height: 40),
              EstadoEstudioCard(
                sesiones: programadasDeHoy().length,
                set: 'Set A: Campaña Primavera',
                horario: '10:00 - 18:00',
              ),
              const SizedBox(height: 48),
              const LoginFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginCard() {
    return HexCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconoTexto(const SvgIcon('login/lock.svg', width: 12, height: 15.75), 'Acceso al estudio',
                  estilo: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24, letterSpacing: -0.4),
                  separacion: 4),
              Tag(
                label: 'ACCESO SEGURO',
                background: AppColors.surfaceHigh,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SvgIcon('login/shield.svg', width: 13.333, height: 18.667),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ingresa con tu cuenta', style: AppText.sans(14, weight: FontWeight.w600, lineHeight: 18)),
                      Text('Usa tu número de cédula y la clave de tu cuenta del estudio.',
                          style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FieldLabel(
            'Usuario (cédula)',
            trailing: Text('ID Oficial', style: AppText.sans(14, color: AppColors.muted, lineHeight: 18)),
          ),
          LoginCampo(
            controller: _user,
            prefix: const SvgIcon('login/at.svg', width: 16.667),
            keyboardType: TextInputType.number,
            error: _userError,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          FieldLabel(
            'Contraseña',
            trailing: GestureDetector(
              onTap: widget.onRecuperar,
              child: Text('¿Olvidaste tu contraseña?',
                  style: AppText.sans(14, color: AppColors.accent, lineHeight: 18, letterSpacing: -0.35)),
            ),
          ),
          LoginCampo(
            controller: _password,
            obscure: _obscure,
            error: _passwordError,
            onChanged: (_) => setState(() {}),
            prefix: const SvgIcon('login/key.svg', width: 19.167, height: 10),
            suffix: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: const SvgIcon('login/eye.svg', width: 18.333, height: 12.5),
            ),
          ),
          const SizedBox(height: 20),
          RecordarSesionRow(recordar: _remember, onToggle: () => setState(() => _remember = !_remember)),
          const SizedBox(height: 12),
          Stack(
            clipBehavior: Clip.none,
            children: [
              HexButton(
                label: _cargando ? 'Conectando…' : 'Iniciar sesión',
                onPressed: _cargando ? null : _iniciar,
                shadow: AppShadows.medium,
                trailing: const SvgIcon('login/arrow_right.svg', width: 12),
              ),
              const Positioned(right: -6, top: -6, child: SvgIcon('login/sparkle.svg', width: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

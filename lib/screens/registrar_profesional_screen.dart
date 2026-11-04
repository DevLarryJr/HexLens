import 'package:flutter/material.dart';

import '../api/api.dart';
import '../core/reloj.dart';
import '../data/mock_especialidades.dart';
import '../data/mock_fotografos.dart';
import '../data/mock_servicios.dart';
import '../theme/app_theme.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/staff/registro_profesional_widgets.dart';
import '../utils/formato.dart';

/// Figma: "HexLens - Registrar Nuevo Profesional" (41:1969)
class RegistrarProfesionalScreen extends StatefulWidget {
  const RegistrarProfesionalScreen({super.key});

  @override
  State<RegistrarProfesionalScreen> createState() => _RegistrarProfesionalScreenState();
}

class _RegistrarProfesionalScreenState extends State<RegistrarProfesionalScreen> with ProtegeCambios {
  @override
  String get firmaFormulario =>
      '${_doc.text}|${_nombres.text}|${_apellidos.text}|$_nacimiento|$_comision|$_especialidad|$_estado';

  final _doc = TextEditingController();
  final _nombres = TextEditingController();
  final _apellidos = TextEditingController();

  /// Obligatoria en la API; null hasta que se elija.
  DateTime? _nacimiento;
  double _comision = 30;
  String _especialidad = _especialidades.firstOrNull ?? '';

  /// 0 Activo, 1 En licencia, 2 Inactivo. La API solo guarda activo (sí/no): licencia e inactivo = no activo.
  int _estado = 0;

  /// Enviando a la API.
  bool _guardando = false;

  /// Especialidades activas del estudio.
  /// Nombres de las especialidades (de la API si hay sesión).
  static List<String> get _especialidades => [for (final e in especialidades) e.nombre];

  /// Servicio base de la especialidad: el primero del catálogo (Retratos → Retrato profesional).
  int get _precioBase =>
      (serviciosCatalogo.where((s) => s.categoria == _especialidad).firstOrNull ?? servicioEjemplo).precio;

  @override
  void dispose() {
    _doc.dispose();
    _nombres.dispose();
    _apellidos.dispose();
    super.dispose();
  }

  bool get _mayorEdad {
    final n = _nacimiento;
    if (n == null) return false;
    final hoy = Reloj.hoy;
    var edad = hoy.year - n.year;
    if (hoy.month < n.month || (hoy.month == n.month && hoy.day < n.day)) edad--;
    return edad >= 18;
  }

  Future<void> _elegirNacimiento() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _nacimiento ?? DateTime(Reloj.hoy.year - 25),
      firstDate: DateTime(1940),
      lastDate: Reloj.hoy,
      helpText: 'Fecha de nacimiento',
    );
    if (d != null) setState(() => _nacimiento = d);
  }

  Future<void> _registrar() async {
    setState(() => _guardando = true);
    try {
      final nuevo = await registrarFotografo(
        documento: _doc.text,
        nombres: _nombres.text,
        apellidos: _apellidos.text,
        nacimiento: _nacimiento!,
        comisionPct: _comision.round(),
        activo: _estado == 0,
        especialidad: especialidades.firstWhere((e) => e.nombre == _especialidad),
      );
      if (!mounted) return;
      showHexToast(context, '${nuevo.nombre} registrado con comisión del ${nuevo.comisionPct}%');
      salirSinPreguntar();
    } on ApiError catch (e) {
      if (mounted) showHexToast(context, e.mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final valido = _doc.text.trim().isNotEmpty &&
        _nombres.text.trim().isNotEmpty &&
        _mayorEdad &&
        especialidades.any((e) => e.nombre == _especialidad);
    final muted = AppText.sans(17, color: AppColors.onSurfaceVariant, lineHeight: 24);

    return protegerSalida(HeaderScaffold(
      header: HexHeader(title: 'Nuevo Profesional', cerrar: true),
      bottomPadding: 28,
      children: [
        const SizedBox(height: 8),
        const RegistroStaffEncabezado(),
        const SizedBox(height: 20),
        const EncabezadoSeccion('01 · DATOS PERSONALES', marca: _estrella, franja: true),
        const SizedBox(height: 20),
        const FieldLabel('Documento de Identidad (C.C. / ID)', required: true),
        HexTextField(
          controller: _doc,
          error: _doc.text.trim().isEmpty,
          keyboardType: TextInputType.number,
          prefix: const SvgIcon('profesional/documento.svg', width: 16.7, height: 16.7),
          suffix: _doc.text.trim().isEmpty ? null : const SvgIcon('profesional/verificado.svg', width: 15, height: 15),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Text('Documento legal para emisión de comprobantes de liquidación fiscal.', style: muted),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel('Nombres'),
                  HexTextField(controller: _nombres, onChanged: (_) => setState(() {})),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const FieldLabel('Apellidos'), HexTextField(controller: _apellidos)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        FieldLabel('Fecha de Nacimiento',
            trailing: FichaPill(_mayorEdad ? 'MAYOR DE EDAD ✓' : 'MENOR DE EDAD', punto: true)),
        InkWell(
          onTap: _elegirNacimiento,
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const SvgIcon('profesional/calendario.svg', width: 15, height: 16.7),
                const SizedBox(width: 14),
                Text(
                    _nacimiento == null ? 'Elegir fecha' : fechaNumerica(_nacimiento!),
                    style: AppText.sans(19, color: _nacimiento == null ? AppColors.outline : AppColors.onSurface)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('La fecha no puede ser futura.', style: muted),
        const SizedBox(height: 28),
        const EncabezadoSeccion('02 · CONDICIONES', marca: _estrella, franja: true),
        const SizedBox(height: 20),
        const FieldLabel('Porcentaje de Comisión'),
        ComisionSimuladorCard(
          valor: _comision,
          onChanged: (v) => setState(() => _comision = v),
          precioSesion: _precioBase,
        ),
        const SizedBox(height: 24),
        const FieldLabel('Especialidad Principal', trailing: FichaPill('CÁMARA DISPONIBLE')),
        HexDropdown(
          value: _especialidad,
          items: _especialidades,
          onChanged: (v) => setState(() => _especialidad = v),
        ),
        const SizedBox(height: 8),
        Text('Define las sesiones que aparecerán preasignadas en su agenda personal.', style: muted),
        const SizedBox(height: 20),
        const FieldLabel('Estado Operativo'),
        EstadoOperativoSelector(selected: _estado, onSelect: (i) => setState(() => _estado = i)),
        const SizedBox(height: 32),
        const NotaCumplimiento(),
        const SizedBox(height: 32),
        HexButton(
          label: _guardando ? 'Registrando…' : 'Registrar Profesional',
          radius: 2,
          height: 60,
          background: valido ? Colors.black : AppColors.outlineVariant,
          onPressed: valido && !_guardando ? _registrar : null,
          leading: const SvgIcon('profesional/registrar.svg', width: 18.3, height: 13.3),
          textStyle: AppText.sans(20, weight: FontWeight.w500, color: Colors.white),
        ),
      ],
    ));
  }
}

const _estrella = Text('✦', style: TextStyle(color: AppColors.accentBright, fontSize: 16));

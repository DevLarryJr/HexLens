import 'package:flutter/material.dart';

import '../api/api.dart';
import '../data/mock_especialidades.dart';
import '../data/mock_fotografos.dart';
import '../models/fotografo.dart';
import '../theme/app_theme.dart';
import '../widgets/condiciones/condiciones_widgets.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';

/// Figma: "HexLens - Error de Validación en Formulario" (41:791).
/// Formulario de condiciones del fotógrafo con validación en vivo; se abre
/// mostrando el estado de error del diseño (nombre vacío y comisión 125%).
class ActualizarCondicionesScreen extends StatefulWidget {
  const ActualizarCondicionesScreen({super.key, this.nombre = '', this.comision = '125', this.fotografo});

  final String nombre;
  final String comision;

  /// Fotógrafo a editar: rellena nombre, C.C., comisión y especialidad.
  /// Sin él se muestra el estado de error del diseño.
  final Fotografo? fotografo;

  @override
  State<ActualizarCondicionesScreen> createState() => _ActualizarCondicionesScreenState();
}

class _ActualizarCondicionesScreenState extends State<ActualizarCondicionesScreen> with ProtegeCambios {
  @override
  String get firmaFormulario => '${_nombre.text}|${_comision.text}|$_especialidad';

  late final _nombre = TextEditingController(text: widget.fotografo?.nombre ?? widget.nombre);
  late final _comision = TextEditingController(text: widget.fotografo?.comisionPct.toString() ?? widget.comision);
  late String _especialidad = widget.fotografo?.especialidad ?? _especialidades.firstOrNull ?? '';

  /// Especialidades activas del estudio.
  /// Nombres de las especialidades (de la API si hay sesión).
  static List<String> get _especialidades => [for (final e in especialidades) e.nombre];

  @override
  void dispose() {
    _nombre.dispose();
    _comision.dispose();
    super.dispose();
  }

  bool get _nombreError => _nombre.text.trim().isEmpty;
  int? get _pct => int.tryParse(_comision.text.replaceAll('%', '').trim());
  bool get _comisionError => _pct == null || _pct! < 0 || _pct! > 100;
  int get _errores => (_nombreError ? 1 : 0) + (_comisionError ? 1 : 0);

  /// Enviando a la API.
  bool _guardando = false;

  /// Guarda nombre, comisión y especialidad del fotógrafo (`PUT /api/profesionales/{id}` si hay sesión).
  Future<void> _guardar() async {
    if (_errores > 0) {
      showHexToast(context, 'Corrige $_errores ${_errores == 1 ? 'campo' : 'campos'} antes de guardar');
      return;
    }
    final fotografo = widget.fotografo;
    final especialidad = especialidades.where((e) => e.nombre == _especialidad).firstOrNull;
    if (fotografo == null || especialidad == null) {
      showHexToast(context, 'Condiciones sincronizadas con el módulo contable');
      salirSinPreguntar();
      return;
    }
    setState(() => _guardando = true);
    try {
      await actualizarCondiciones(fotografo,
          nombreCompleto: _nombre.text, comisionPct: _pct!, especialidad: especialidad);
      if (!mounted) return;
      showHexToast(context, 'Condiciones de ${_nombre.text.trim()} guardadas');
      salirSinPreguntar();
    } on ApiError catch (e) {
      if (mounted) showHexToast(context, e.mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return protegerSalida(Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: BarraAcciones(
        child: ParAcciones(
          principal: 'Guardar Cambios',
          iconoPrincipal: const SvgIcon('condiciones/sync.svg', width: 15, height: 13.3),
          onPrincipal: _guardando ? null : _guardar,
          insignia: _errores > 0 ? ErroresInsignia(errores: _errores) : null,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 64 + MediaQuery.paddingOf(context).top, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValidacionEstadoBar(errores: _errores),
                const SizedBox(height: 20),
                if (_errores > 0) ...[ErrorGuardarBanner(errores: _errores), const SizedBox(height: 16)],
                IconoTexto(const SvgIcon('condiciones/tune.svg', width: 12, height: 12), 'PARÁMETROS OPERATIVOS',
                    estilo: AppText.sans(17, weight: FontWeight.w700, color: AppColors.accent, letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text('Actualizar Condiciones y Comisiones',
                    style: AppText.sans(26, weight: FontWeight.w700, lineHeight: 34, letterSpacing: -0.4)),
                const SizedBox(height: 6),
                Text('Revisión de parámetros contractuales de fotógrafo titular antes de sincronizar con el módulo contable.',
                    style: AppText.sans(19, color: AppColors.onSurfaceVariant, lineHeight: 30)),
                const SizedBox(height: 24),
                TarjetaCampo(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FieldLabel('Nombre del Profesional / Titular', required: true, error: _nombreError),
                      HexTextField(
                        controller: _nombre,
                        hint: 'Ej: Carlos Morales',
                        error: _nombreError,
                        fill: AppColors.surfaceLow,
                        prefix: const SvgIcon('condiciones/documento.svg', width: 24.7, height: 16.7),
                        suffix: _nombreError
                            ? Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text('!',
                                    textAlign: TextAlign.center,
                                    style: AppText.sans(22, weight: FontWeight.w800, color: AppColors.accent)),
                              )
                            : const Icon(Icons.check_circle_outline, color: AppColors.success),
                        onChanged: (_) => setState(() {}),
                      ),
                      if (_nombreError)
                        const MensajeCampo('Este campo es obligatorio. Ingrese el nombre legal completo.', tipo: TipoMensaje.error),
                    ],
                  ),
                ),
                DocumentoVerificadoCard(
                    documento: widget.fotografo?.documento.replaceFirst('C.C. ', '') ?? '1.020.345.981'),
                TarjetaCampo(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FieldLabel('Porcentaje de Comisión (%)', required: true, error: _comisionError),
                      HexTextField(
                        controller: _comision,
                        error: _comisionError,
                        keyboardType: TextInputType.number,
                        fill: AppColors.surfaceLow,
                        prefix: Text('%',
                            style: AppText.sans(22,
                                weight: FontWeight.w700, color: _comisionError ? AppColors.accent : AppColors.onSurface)),
                        suffix: _comisionError
                            ? IconButton(
                                onPressed: () => setState(_comision.clear),
                                icon: const Icon(Icons.highlight_off, color: AppColors.accent),
                              )
                            : const Icon(Icons.check_circle_outline, color: AppColors.success),
                        onChanged: (_) => setState(() {}),
                      ),
                      if (_comisionError)
                        const MensajeCampo('El porcentaje de comisión debe estar entre 0% y 100%.', tipo: TipoMensaje.error),
                      const SizedBox(height: 10),
                      Text(
                          (_pct ?? 0) > 65
                              ? 'El valor ingresado supera el tope máximo estipulado por política interna del estudio (máximo 65% para perfil sénior).'
                              : 'Tope máximo por política interna: 65% para perfil sénior.',
                          style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 26)),
                    ],
                  ),
                ),
                TarjetaCampo(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FieldLabel('Especialidad Principal',
                          trailing: Text('Perfil Técnico', style: AppText.sans(14, color: AppColors.onSurfaceVariant))),
                      HexDropdown(
                        value: _especialidad,
                        items: _especialidades,
                        onChanged: (v) => setState(() => _especialidad = v),
                      ),
                    ],
                  ),
                ),
                const CanalPagoCard(cuenta: 'Bancolombia Ahorros - 459-002-129'),
                const AuditoriaCard(hash: '#HEX-78F9A1'),
              ],
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: HexHeader(title: 'Condiciones del Staff', cerrar: true)),
        ],
      ),
    ));
  }
}

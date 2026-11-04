import 'package:flutter/material.dart';

import '../api/api.dart';
import '../data/mock_especialidades.dart';
import '../models/especialidad.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/especialidades/nueva_especialidad_widgets.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';

/// Figma: "HexLens - Nueva Especialidad (Modal)" (41:2172).
/// Devuelve el nombre de la especialidad creada (o null si se cancela).
Future<String?> showNuevaEspecialidadSheet(BuildContext context) =>
    mostrarHoja<String>(context, const _NuevaEspecialidadSheet());

class _NuevaEspecialidadSheet extends StatefulWidget {
  const _NuevaEspecialidadSheet();

  @override
  State<_NuevaEspecialidadSheet> createState() => _NuevaEspecialidadSheetState();
}

class _NuevaEspecialidadSheetState extends State<_NuevaEspecialidadSheet> {
  final _nombre = TextEditingController();

  /// Enviando la especialidad a la API.
  bool _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  /// Especialidad con el mismo nombre, sin distinguir mayúsculas ni tildes.
  Especialidad? get _existente {
    final nombre = sinTildes(_nombre.text.trim());
    return especialidades.where((e) => sinTildes(e.nombre) == nombre).firstOrNull;
  }

  /// Crea la especialidad (en la API si hay sesión) y cierra devolviendo su nombre.
  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      final nueva = await crearEspecialidad(_nombre.text);
      if (mounted) Navigator.of(context).pop(nueva.nombre);
    } on ApiError catch (e) {
      if (mounted) showHexToast(context, e.mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vacio = _nombre.text.trim().isEmpty;
    final existente = _existente;
    final error = vacio || existente != null;
    void cerrar() => Navigator.of(context).pop();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const SheetHandle(width: 48),
                const NuevaEspecialidadCabecera(),
                const Divider(height: 1, color: AppColors.surfaceHigh),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FieldLabel('Nombre de la Especialidad', required: true, error: error),
                      HexTextField(
                        controller: _nombre,
                        error: error,
                        suffix: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('*',
                              textAlign: TextAlign.center,
                              style: AppText.sans(30, weight: FontWeight.w700, color: AppColors.accent)),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          vacio
                              ? 'El nombre de la especialidad es obligatorio.'
                              : existente != null
                                  ? 'Ya existe la especialidad ${existente.nombre}.'
                              : 'Define la categoría matriz para vincular servicios fotográficos y asignar fotógrafos titulares.',
                          style: AppText.sans(15, color: error ? AppColors.accentBright : AppColors.onSurfaceVariant, lineHeight: 22)),
                      const SizedBox(height: 32),
                      ParAcciones(
                        secundario: 'Cancelar',
                        onSecundario: cerrar,
                        iconoPrincipal: const SvgIcon('especialidad/guardar.svg', width: 16.5, height: 15.8),
                        principal: _guardando ? 'Guardando…' : 'Guardar Especialidad',
                        onPrincipal: error || _guardando ? null : _guardar,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

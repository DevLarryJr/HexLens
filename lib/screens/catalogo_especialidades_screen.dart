import 'package:flutter/material.dart';

import '../data/mock_especialidades.dart';
import '../data/mock_servicios.dart';
import '../models/especialidad.dart';
import '../services/local/sesion_actual.dart';
import '../services/remote/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/especialidades/especialidad_cards.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_search_field.dart';
import '../widgets/hex_widgets.dart';

class CatalogoEspecialidadesScreen extends StatefulWidget {
  const CatalogoEspecialidadesScreen({super.key, this.onNueva});

  final VoidCallback? onNueva;

  @override
  State<CatalogoEspecialidadesScreen> createState() => _CatalogoEspecialidadesScreenState();
}

class _CatalogoEspecialidadesScreenState extends State<CatalogoEspecialidadesScreen>
    with ConBusqueda, RedibujarAlCambiar {
  @override
  Listenable get escuchar => Listenable.merge([revisionEspecialidades, revisionServicios]);

  String? _aviso;

  bool _cargando = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  Future<void> _recargar() async {
    if (!SesionActual.conectada) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await sincronizarEspecialidades();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _titular(Especialidad e) => titularDe(e.nombre)?.nombre ?? 'Sin asignar';

  Future<void> _eliminar(Especialidad e) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('¿Eliminar "${e.nombre}"?'),
        content: const Text('Se borrará la especialidad. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await eliminarEspecialidad(e);
      if (mounted) setState(() => _aviso = "Especialidad '${e.nombre}' eliminada");
    } on ApiException catch (error) {
      if (mounted) showHexToast(context, error.message);
    }
  }

  Future<void> _editar(Especialidad e) async {
    final nombre = await showDialog<String>(context: context, builder: (_) => _DialogoNombre(e.nombre));
    if (nombre == null || nombre.isEmpty || nombre == e.nombre) return;
    try {
      await renombrarEspecialidad(e, nombre);
      if (mounted) setState(() => _aviso = "Especialidad '$nombre' actualizada correctamente");
    } on ApiException catch (error) {
      if (mounted) showHexToast(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibles =
        especialidades.where((e) => coincideBusqueda(busqueda.text, [e.nombre, _titular(e)])).toList();

    return HeaderScaffold(
      header: HexHeader(title: 'Especialidades'),
      bottomPadding: 28,
      children: [
        if (_aviso != null) ...[
          SincronizacionBanner(mensaje: _aviso!, onCerrar: () => setState(() => _aviso = null)),
          const SizedBox(height: 16),
        ],
        EspecialidadesTitulo(onNueva: widget.onNueva),
        const SizedBox(height: 8),
        HexSearchField(
          controller: busqueda,
          onChanged: (_) => setState(() {}),
          hint: 'Filtrar especialidad o titular...',
          icon: const SvgIcon('especialidades/search.svg', width: 15),
          iconPadding: const EdgeInsets.only(left: 8, right: 17),
          iconMinWidth: 40,
          radius: 2,
        ),
        const SizedBox(height: 12),
        Text('${visibles.length} ${visibles.length == 1 ? 'especialidad' : 'especialidades'}',
            style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
        const SizedBox(height: 16),
        if (_cargando)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          InfoBox(
            icon: Icons.cloud_off,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_error!, style: AppText.sans(14, lineHeight: 18)),
                TextButton(onPressed: _recargar, child: const Text('Reintentar')),
              ],
            ),
          )
        else if (visibles.isEmpty)
          InfoBox(
            icon: Icons.info_outline,
            child: Text(
              especialidades.isEmpty ? 'Aún no hay especialidades. Crea la primera con "Nueva".' : 'Ninguna coincide con la búsqueda.',
              style: AppText.sans(14, lineHeight: 18),
            ),
          )
        else
          for (final e in visibles) ...[
            EspecialidadCard(
              especialidad: e,
              servicios: [for (final s in serviciosDe(e)) s.nombre],
              titular: _titular(e),
              iniciales: titularDe(e.nombre) == null ? '--' : iniciales(_titular(e)),
              onEditar: () => _editar(e),
              onEliminar: () => _eliminar(e),
            ),
            const SizedBox(height: 16),
          ],
      ],
    );
  }
}

class _DialogoNombre extends StatefulWidget {
  const _DialogoNombre(this.actual);

  final String actual;

  @override
  State<_DialogoNombre> createState() => _DialogoNombreState();
}

class _DialogoNombreState extends State<_DialogoNombre> {
  late final _nombre = TextEditingController(text: widget.actual);

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar especialidad'),
      content: TextField(controller: _nombre, autofocus: true, decoration: const InputDecoration(labelText: 'Nombre')),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.of(context).pop(_nombre.text.trim()), child: const Text('Guardar')),
      ],
    );
  }
}

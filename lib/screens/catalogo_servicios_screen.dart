import 'package:flutter/material.dart';

import '../data/mock_especialidades.dart';
import '../data/mock_servicios.dart';
import '../models/servicio.dart';
import '../services/local/sesion_actual.dart';
import '../services/remote/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/hex_chips.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_search_field.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/servicios/servicio_catalogo_cards.dart';
import 'crear_servicio_screen.dart';

class CatalogoServiciosScreen extends StatefulWidget {
  const CatalogoServiciosScreen({super.key, this.onNuevo});

  final VoidCallback? onNuevo;

  @override
  State<CatalogoServiciosScreen> createState() => _CatalogoServiciosScreenState();
}

class _CatalogoServiciosScreenState extends State<CatalogoServiciosScreen> with ConBusqueda, RedibujarAlCambiar {
  @override
  Listenable get escuchar => Listenable.merge([revisionServicios, revisionEspecialidades]);

  String? _categoria;

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
      await sincronizarServicios();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _editar(Servicio s) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => CrearServicioScreen(servicio: s)));

  @override
  Widget build(BuildContext context) {
    final todos = serviciosCatalogo;
    final categorias = {for (final s in todos) s.categoria}.toList();
    if (_categoria != null && !categorias.contains(_categoria)) _categoria = null;
    final visibles = todos
        .where((s) => _categoria == null || s.categoria == _categoria)
        .where((s) => coincideBusqueda(busqueda.text, [s.nombre, s.codigo, s.categoria]))
        .toList();

    return HeaderScaffold(
      header: HexHeader(title: 'Servicios'),
      bottomPadding: 48,
      children: [
        const SizedBox(height: 16),
        ServiciosCabecera(activos: todos.length, onNuevo: widget.onNuevo),
        const SizedBox(height: 12),
        HexSearchField(
          controller: busqueda,
          onChanged: (_) => setState(() {}),
          hint: 'Buscar servicio por nombre, tag o código...',
          icon: const SvgIcon('servicios/search.svg', width: 15),
          suffix: IconButton(
            onPressed: () => setState(busqueda.clear),
            icon: const SvgIcon('servicios/clear.svg', width: 10.5),
          ),
        ),
        const SizedBox(height: 8),
        HexChipBar(
          height: 44,
          itemCount: categorias.length + 1,
          itemBuilder: (_, i) {
            final categoria = i == 0 ? null : categorias[i - 1];
            return CategoriaChip(
              label: categoria ?? 'Todas',
              count: categoria == null ? todos.length : todos.where((s) => s.categoria == categoria).length,
              selected: categoria == _categoria,
              onTap: () => setState(() => _categoria = categoria),
            );
          },
        ),
        const SizedBox(height: 12),
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
              todos.isEmpty ? 'Aún no hay servicios. Crea el primero con "Nuevo".' : 'Ningún servicio coincide con la búsqueda.',
              style: AppText.sans(14, lineHeight: 18),
            ),
          )
        else
          for (var i = 0; i < visibles.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            ServicioCatalogoCard(
              servicio: visibles[i],
              destacado: visibles[i] == todos.first,
              onEditar: () => _editar(visibles[i]),
            ),
          ],
        const SizedBox(height: 20),
        const IntegridadNota(),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../data/mock_clientes.dart';
import '../data/mock_fotografos.dart';
import '../data/mock_servicios.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/busqueda/busqueda_widgets.dart';
import '../widgets/hex_chips.dart';
import '../widgets/hex_search_field.dart';
import '../widgets/hex_widgets.dart';

enum _Tipo { cliente, servicio, fotografo }

List<(_Tipo, String, String)> get _indice => [
  for (final c in clientes) (_Tipo.cliente, c.nombre, c.documento),
  for (final s in serviciosEstudio.where((s) => s.activo))
    (_Tipo.servicio, s.nombre, '${s.codigo} • ${formatCop(s.precio)}'),
  for (final f in fotografos) (_Tipo.fotografo, f.nombre, '${f.especialidad} • ${f.documento}'),
];

bool _esNumero(String q) =>
    soloDigitos(q).isNotEmpty && q.replaceAll(RegExp(r'c\.?c\.?|nit|[\d\s.\-]'), '').isEmpty;

class BusquedaGlobalScreen extends StatefulWidget {
  const BusquedaGlobalScreen({super.key, this.inicial = 'Carlos Pérez', this.onRegistrar});

  final String inicial;
  final ValueChanged<String>? onRegistrar;

  @override
  State<BusquedaGlobalScreen> createState() => _BusquedaGlobalScreenState();
}

class _BusquedaGlobalScreenState extends State<BusquedaGlobalScreen> with ConBusqueda {
  @override
  String get textoInicial => widget.inicial;

  int _filtro = 0;

  static const _filtros = ['Todos', 'Clientes', 'Servicios', 'Fotógrafos'];
  static const _iconos = {
    _Tipo.cliente: Icons.person_outline,
    _Tipo.servicio: Icons.photo_camera_outlined,
    _Tipo.fotografo: Icons.camera_alt_outlined,
  };

  List<(_Tipo, String, String)> _resultados(int filtro) {
    final q = sinTildes(busqueda.text.trim());
    if (q.isEmpty) return [];
    final digitos = _esNumero(q) ? soloDigitos(q) : null;
    return _indice.where((r) {
      final tipoOk = filtro == 0 || r.$1.index == filtro - 1;
      final coincide = digitos != null
          ? soloDigitos(r.$3).contains(digitos)
          : sinTildes(r.$2).contains(q) || sinTildes(r.$3).contains(q);
      return tipoOk && coincide;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final res = _resultados(_filtro);
    final consulta = busqueda.text.trim();
    void back() => Navigator.of(context).maybePop();

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: BusquedaNav(onTap: (_) => back()),
      body: Column(
        children: [
          BusquedaHeader(onBack: back),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                TextField(
                  controller: busqueda,
                  autofocus: consulta.isEmpty,
                  onChanged: (_) => setState(() {}),
                  style: AppText.sans(18),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Buscar clientes, servicios o fotógrafos',
                    prefixIcon: const Center(
                        widthFactor: 1,
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SvgIcon('busqueda/search.svg', width: 15))),
                    suffixIcon: IconButton(
                      onPressed: () => setState(busqueda.clear),
                      icon: const SvgIcon('busqueda/clear.svg', width: 10.5, height: 10.5),
                    ),
                    border: OutlineInputBorder(borderRadius: AppRadius.sm, borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),
                HexChipBar(
                  height: 42,
                  spacing: 10,
                  itemCount: _filtros.length,
                  itemBuilder: (_, i) => BusquedaFiltroChip(
                    label: _filtros[i],
                    count: _resultados(i).length,
                    selected: i == _filtro,
                    onTap: () => setState(() => _filtro = i),
                  ),
                ),
                const SizedBox(height: 14),
                QueryEstadoBar(coincidencias: res.length),
                const SizedBox(height: 24),
                if (res.isNotEmpty)
                  for (final r in res) ...[
                    ResultadoBusquedaCard(
                      icon: _iconos[r.$1]!,
                      titulo: r.$2,
                      detalle: r.$3,
                      tipo: _filtros[r.$1.index + 1].toUpperCase(),
                    ),
                    const SizedBox(height: 10),
                  ]
                else
                  SinResultados(
                    consulta: consulta,
                    onRestablecer: () => setState(() {
                      busqueda.clear();
                      _filtro = 0;
                    }),
                    onRegistrar: () => widget.onRegistrar?.call(consulta),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

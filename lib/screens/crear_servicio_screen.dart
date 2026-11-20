import 'package:flutter/material.dart';

import '../data/mock_especialidades.dart';
import '../data/mock_fotografos.dart';
import '../data/mock_servicios.dart';
import '../models/servicio.dart';
import '../services/remote/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/formateadores.dart';
import '../utils/formato.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/servicios/crear_servicio_widgets.dart';

class CrearServicioScreen extends StatefulWidget {
  const CrearServicioScreen({super.key, this.servicio});

  final Servicio? servicio;

  @override
  State<CrearServicioScreen> createState() => _CrearServicioScreenState();
}

class _CrearServicioScreenState extends State<CrearServicioScreen> with ProtegeCambios {
  Servicio? get _editando => widget.servicio;

  @override
  String get firmaFormulario => '${_nombre.text}|${_precio.text}|${_descripcion.text}|$_duracion|$_especialidad';

  late final _nombre = TextEditingController(text: _editando?.nombre ?? '');
  late final _precio = TextEditingController(text: _editando == null ? '' : milesConPunto('${_editando!.precio}'));
  late final _descripcion = TextEditingController(text: _editando?.descripcion ?? '');

  late final List<(int, String)> _duraciones = [
    (30, 'Compacto'),
    (45, 'Estándar'),
    (60, 'Completo'),
    (90, 'Extendido'),
    if (_editando != null && ![30, 45, 60, 90].contains(_editando!.duracionMin)) (_editando!.duracionMin, 'Actual'),
  ];
  late int _duracion = _editando == null ? 1 : _duraciones.indexWhere((d) => d.$1 == _editando!.duracionMin);
  late String _especialidad = _editando?.categoria ?? _especialidades.firstOrNull ?? '';
  bool _intentado = false;

  bool _guardando = false;

  static List<String> get _especialidades => [for (final e in especialidades) e.nombre];

  String get _habilitados =>
      fotografos.where((f) => f.especialidad == _especialidad).map((f) => nombreCorto(f.nombre)).join(', ');

  int get _comisionPct => titularDe(_especialidad)?.comisionPct ?? 30;

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  int get _precioNum => int.tryParse(soloDigitos(_precio.text)) ?? 0;

  bool get _nombreError => _intentado && _nombre.text.trim().isEmpty;
  bool get _precioError => _intentado && _precioNum <= 0;
  bool get _descripcionError => _intentado && _descripcion.text.trim().isEmpty;
  bool get _especialidadError => _intentado && especialidades.every((e) => e.nombre != _especialidad);

  Future<void> _guardar() async {
    setState(() => _intentado = true);
    if (_nombreError || _precioError || _descripcionError || _especialidadError) {
      showHexToast(context, 'Revisa los campos obligatorios');
      return;
    }
    setState(() => _guardando = true);
    try {
      final minutos = _duraciones[_duracion].$1;
      final editando = _editando;
      if (editando == null) {
        final nuevo = await crearServicio(
          nombre: _nombre.text,
          precio: _precioNum,
          descripcion: _descripcion.text,
          duracionMin: minutos,
          especialidad: especialidades.firstWhere((e) => e.nombre == _especialidad),
        );
        if (mounted) showHexToast(context, 'Servicio "${nuevo.nombre}" creado');
      } else {
        await actualizarServicio(editando, precio: _precioNum, duracionMin: minutos, descripcion: _descripcion.text);
        if (mounted) showHexToast(context, 'Servicio "${editando.nombre}" actualizado');
      }
      if (mounted) salirSinPreguntar();
    } on ApiException catch (e) {
      if (mounted) showHexToast(context, e.message);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _eliminar() async {
    final s = _editando!;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('¿Eliminar "${s.nombre}"?'),
        content: const Text('El servicio dejará de ofrecerse. Esta acción no se puede deshacer.'),
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
      await eliminarServicio(s);
      if (!mounted) return;
      showHexToast(context, 'Servicio "${s.nombre}" eliminado');
      salirSinPreguntar();
    } on ApiException catch (e) {
      if (mounted) showHexToast(context, e.message);
    }
  }

  Widget _bloqueado(String valor) => InfoBox(
        icon: Icons.lock_outline,
        child: Text(valor, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 22)),
      );

  @override
  Widget build(BuildContext context) {
    final (minutos, nombreDuracion) = _duraciones[_duracion];
    final editando = _editando != null;

    return protegerSalida(HeaderScaffold(
      header: HexHeader(title: editando ? 'Editar Servicio' : 'Nuevo Servicio', cerrar: true),
      bottomPadding: 28,
      children: [
        const SizedBox(height: 12),
        const CatalogoFranja(),
        const SizedBox(height: 20),
        IconoTexto(const SvgIcon('crear_servicio/parametro.svg', width: 13, height: 13.5), 'DATOS DEL SERVICIO',
            estilo: AppText.sans(16, weight: FontWeight.w600, color: AppColors.accent, letterSpacing: 1.6)),
        const SizedBox(height: 4),
        Text(editando ? _editando!.nombre : 'Nuevo Servicio Fotográfico',
            style: AppText.sans(32, weight: FontWeight.w700, lineHeight: 40, letterSpacing: -0.6)),
        const SizedBox(height: 6),
        Text(
            editando
                ? 'Ajusta el precio, la duración y la descripción del servicio.'
                : 'Define el precio, la duración y la especialidad del servicio.',
            style: AppText.sans(18, color: AppColors.onSurfaceVariant, lineHeight: 28)),
        const SizedBox(height: 20),
        FieldLabel(
          'Nombre del Servicio',
          required: !editando,
          trailing: editando ? null : Text('${_nombre.text.length}/50', style: AppText.mono(14)),
        ),
        if (editando)
          _bloqueado(_editando!.nombre)
        else ...[
          HexTextField(
            controller: _nombre,
            error: _nombreError,
            prefix: const SvgIcon('crear_servicio/camara.svg', width: 16.7, height: 15),
            onChanged: (v) {
              if (v.length > 50) _nombre.text = v.substring(0, 50);
              setState(() {});
            },
          ),
          const SizedBox(height: 8),
          MensajeCampo(
            _nombreError
                ? 'El nombre del servicio es obligatorio.'
                : 'Nombre público que figurará en la agenda y facturación de clientes.',
            tipo: _nombreError ? TipoMensaje.error : TipoMensaje.ayuda,
          ),
        ],
        const SizedBox(height: 24),
        const FieldLabel('Descripción', required: true),
        HexTextField(
          controller: _descripcion,
          maxLines: 3,
          error: _descripcionError,
          hint: 'Ej: Sesión de 1 hora en estudio con 10 fotos editadas',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        MensajeCampo(
          _descripcionError
              ? 'La descripción es obligatoria.'
              : 'La ve el cliente al reservar: qué incluye el servicio.',
          tipo: _descripcionError ? TipoMensaje.error : TipoMensaje.ayuda,
        ),
        const SizedBox(height: 24),
        const FieldLabel('Precio Base (\$ COP)', trailing: Tag(label: 'IVA INCLUIDO')),
        HexTextField(
          controller: _precio,
          mono: true,
          error: _precioError,
          hint: 'Ej: 150.000',
          formatos: const [formatoPrecio],
          keyboardType: TextInputType.number,
          prefix: const SvgIcon('crear_servicio/precio.svg', width: 18.3, height: 13.3),
          suffix: Padding(
            padding: const EdgeInsets.only(right: 14, top: 14),
            child: Text('COP', style: AppText.mono(15, color: AppColors.onSurface)),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        RepartoTarifa(
          estudioLabel: 'Margen base estudio (${100 - _comisionPct}%):',
          estudio: '${formatCop(_precioNum * (100 - _comisionPct) ~/ 100)} COP',
          fotografoLabel: 'Comisión fotógrafo estimada ($_comisionPct%):',
          fotografo: '${formatCop(_precioNum * _comisionPct ~/ 100)} COP',
        ),
        const SizedBox(height: 24),
        DuracionHeader(
            valor: '$minutos min\n$nombreDuracion'),
        const SizedBox(height: 10),
        DuracionSelector(
          opciones: _duraciones,
          selected: _duracion,
          onSelect: (i) => setState(() => _duracion = i),
        ),
        const SizedBox(height: 8),
        Text('Determina el intervalo de ocupación en set y previene solapamientos con otras sesiones.',
            style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22)),
        const SizedBox(height: 24),
        FieldLabel('Especialidad Asociada', required: !editando, trailing: const Tag(label: 'Fotógrafos')),
        if (editando)
          _bloqueado(_especialidad)
        else ...[
          HexDropdown(
            value: _especialidad,
            items: _especialidades,
            onChanged: (v) => setState(() => _especialidad = v),
          ),
          if (_especialidadError) ...[
            const SizedBox(height: 8),
            const MensajeCampo('Elige una especialidad (créala primero en Especialidades si no hay).',
                tipo: TipoMensaje.error),
          ],
        ],
        const SizedBox(height: 8),
        InfoBox(
          leading: const SvgIcon('crear_servicio/fotografos.svg', width: 16, height: 8),
          iconColor: AppColors.accentBright,
          child: Text.rich(TextSpan(
            style: AppText.mono(15, color: AppColors.onSurface, lineHeight: 22),
            children: [
              const TextSpan(text: 'Fotógrafos habilitados: '),
              TextSpan(
                  text: _habilitados,
                  style: AppText.mono(15, weight: FontWeight.w700, color: AppColors.onSurface, lineHeight: 22)),
            ],
          )),
        ),
        const SizedBox(height: 24),
        IconoTexto(const SvgIcon('crear_servicio/presets.svg', width: 12, height: 12),
            'PRESETS ÓPTICOS Y SET RECOMENDADO',
            estilo: AppText.sans(15, weight: FontWeight.w600, color: AppColors.onSurfaceVariant, letterSpacing: 0.8),
            ajuste: FlexFit.tight),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(child: PresetCard(foto: 'preset_lente.jpg', titulo: 'Lente 85mm f/1.4', detalle: 'Set A · Luz suave')),
            SizedBox(width: 12),
            Expanded(
                child: PresetCard(foto: 'preset_cabina.jpg', titulo: 'Cabina Retrato 02', detalle: 'Flash 400W Sync')),
          ],
        ),
        const SizedBox(height: 24),
        const FichaEquipamiento(),
        const SizedBox(height: 24),
        InfoBox(
          leading: const SvgIcon('crear_servicio/nota.svg', width: 17.4, height: 22.2),
          iconColor: AppColors.accentBright,
          background: AppColors.surfaceHigh,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nota de Integridad Contable', style: AppText.sans(18, weight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                  'En modo edición, el Nombre y la Especialidad no se pueden modificar para proteger el histórico financiero y la liquidación de comisiones pasadas.',
                  style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 26)),
            ],
          ),
        ),
        const SizedBox(height: 28),
        HexButton(
          label: _guardando ? 'Guardando…' : (editando ? 'Guardar Cambios' : 'Guardar Servicio'),
          radius: 2,
          height: 56,
          onPressed: _guardando ? null : _guardar,
          leading: const SvgIcon('crear_servicio/guardar.svg', width: 15, height: 15),
          textStyle: AppText.sans(18, weight: FontWeight.w500, color: Colors.white),
        ),
        if (editando) ...[
          const SizedBox(height: 12),
          HexButton(
            label: 'Eliminar Servicio',
            radius: 2,
            height: 56,
            shadow: null,
            background: AppColors.accentContainer,
            foreground: AppColors.accent,
            onPressed: _guardando ? null : _eliminar,
            leading: const Icon(Icons.delete_outline, size: 18, color: AppColors.accent),
            textStyle: AppText.sans(18, weight: FontWeight.w500, color: AppColors.accent),
          ),
        ],
      ],
    ));
  }
}

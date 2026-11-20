import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/reloj.dart';
import '../data/mock_clientes.dart';
import '../models/cliente.dart';
import '../services/remote/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/formateadores.dart';
import '../utils/formato.dart';
import '../widgets/clientes/ficha_cliente_widgets.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';

class FichaNuevoClienteScreen extends StatefulWidget {
  const FichaNuevoClienteScreen({super.key});

  @override
  State<FichaNuevoClienteScreen> createState() => _FichaNuevoClienteScreenState();
}

class _FichaNuevoClienteScreenState extends State<FichaNuevoClienteScreen> with ProtegeCambios {
  @override
  String get firmaFormulario =>
      '$_tipoDoc|${[_doc, _nombres, _apellidos, _nacimiento, _telefono, _email].map((c) => c.text).join('|')}';

  int _tipoDoc = 0;
  final _doc = TextEditingController();
  final _nombres = TextEditingController();
  final _apellidos = TextEditingController();
  final _nacimiento = TextEditingController();
  final _telefono = TextEditingController();
  final _email = TextEditingController();
  bool _intentado = false;

  @override
  void dispose() {
    for (final c in [_doc, _nombres, _apellidos, _nacimiento, _telefono, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _vacio(TextEditingController c) => _intentado && c.text.trim().isEmpty;
  bool get _emailInvalido => _intentado && !esCorreo(_email.text);

  Cliente? get _duplicado => clientePorDocumento(_doc.text);

  bool _guardando = false;

  Future<void> _confirmar() async {
    setState(() => _intentado = true);
    final duplicado = _duplicado;
    if (duplicado != null) {
      showHexToast(context, 'Ya existe un cliente con ese documento (${duplicado.nombre})');
      return;
    }
    final ok = [_doc, _nombres, _apellidos, _telefono].every((c) => c.text.trim().isNotEmpty) && !_emailInvalido;
    if (!ok) {
      showHexToast(context, 'Completa los campos obligatorios marcados en rojo');
      return;
    }
    setState(() => _guardando = true);
    try {
      final cliente = await guardarCliente(
        tipoDocumento: TipoDocumentoSelector.tipos[_tipoDoc].split(' ').first,
        documento: _doc.text,
        nombres: _nombres.text,
        apellidos: _apellidos.text,
        telefono: _telefono.text,
        email: _email.text,
        nacimiento: fechaDesdeNumerica(_nacimiento.text),
      );
      if (!mounted) return;
      showHexToast(context, 'Cliente ${cliente.nombre} registrado');
      salirSinPreguntar();
    } on ApiException catch (e) {
      if (mounted) showHexToast(context, e.message);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _elegirNacimiento() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1920),
      lastDate: Reloj.hoy,
    );
    if (d != null) setState(() => _nacimiento.text = fechaNumerica(d));
  }

  TextStyle get _detalle => AppText.sans(16, color: AppColors.onSurfaceVariant);

  @override
  Widget build(BuildContext context) {
    return protegerSalida(Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ModalHeader(title: 'Nuevo Cliente', subtitle: 'FICHA DE TITULAR', tag: 'NUEVO'),
      bottomNavigationBar: BarraAcciones(
        child: ParAcciones(
          principal: 'Confirmar Registro',
          onPrincipal: _guardando ? null : _confirmar,
          iconoPrincipal: const Icon(Icons.check, size: 18, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AltaTitularBanner(),
            const SizedBox(height: 32),
            ..._identificacion(),
            const SizedBox(height: 12),
            ..._contacto(),
            const HabeasDataNota(),
          ],
        ),
      ),
    ));
  }

  List<Widget> _identificacion() => [
        const EncabezadoSeccion('01 · IDENTIFICACIÓN',
            marca: SvgIcon('ficha_cliente/identificacion.svg', width: 12, height: 13.3),
            dato: 'RÉCORD\nOBLIGATORIO',
            colorDato: AppColors.accent,
            subrayado: true),
        const SizedBox(height: 20),
        _campo(
          etiqueta: FieldLabel('Número de Documento', required: true, trailing: Text('Cédula Fiscal', style: _detalle)),
          antes: [
            TipoDocumentoSelector(selected: _tipoDoc, onSelect: (i) => setState(() => _tipoDoc = i)),
            const SizedBox(height: 12),
          ],
          controller: _doc,
          hint: _tipoDoc == 1 ? 'Ej: 900.123.456-7' : 'Ej: 1.020.345.981',
          icono: const SvgIcon('ficha_cliente/documento.svg', width: 16.7, height: 16.7),
          teclado: TextInputType.number,
          formato: formatoDocumento,
          errores: {
            'El número de documento es obligatorio': _vacio(_doc),
            'Ya existe un cliente con ese documento (${_duplicado?.nombre})': _duplicado != null,
          },
        ),
        _campo(
          etiqueta: const FieldLabel('Nombres del Titular', required: true),
          controller: _nombres,
          hint: 'Ej: Camilo Andrés',
          icono: const SvgIcon('ficha_cliente/persona.svg', width: 13.3, height: 13.3),
          errores: {'Ingresa los nombres del titular': _vacio(_nombres)},
        ),
        _campo(
          etiqueta: const FieldLabel('Apellidos', required: true),
          controller: _apellidos,
          hint: 'Ej: Restrepo Salazar',
          icono: const SvgIcon('ficha_cliente/persona2.svg', width: 13.3, height: 13.3),
          errores: {'Ingresa los apellidos': _vacio(_apellidos)},
        ),
      ];

  List<Widget> _contacto() => [
        const EncabezadoSeccion('02 · CONTACTO',
            marca: SvgIcon('ficha_cliente/contacto.svg', width: 16, height: 12), dato: 'AGENDA\nACTIVA', subrayado: true),
        const SizedBox(height: 20),
        TarjetaCampo(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text.rich(TextSpan(children: [
                  TextSpan(text: 'Fecha de Nacimiento ', style: AppText.sans(18, weight: FontWeight.w600)),
                  TextSpan(text: '(Opcional) ', style: _detalle),
                  TextSpan(text: 'CLUB DE BENEFICIOS', style: AppText.sans(16, color: AppColors.accentBright)),
                ])),
              ),
              GestureDetector(
                onTap: _elegirNacimiento,
                child: AbsorbPointer(
                  child: HexTextField(
                    controller: _nacimiento,
                    hint: 'dd/mm/aaaa',
                    fill: AppColors.surfaceLow,
                    prefix: const SvgIcon('ficha_cliente/calendario.svg', width: 15, height: 16.7),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              IconoTexto(const SvgIcon('ficha_cliente/perks.svg', width: 12.6, height: 12),
                  'Habilita promociones VIP de aniversario y créditos en set.',
                  estilo: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22),
                  ajuste: FlexFit.tight, arriba: true),
            ],
          ),
        ),
        _campo(
          etiqueta: FieldLabel(
            'Teléfono / WhatsApp',
            required: true,
            trailing: IconoTexto(const Dot(size: 6, color: AppColors.accentBright), 'NOTIFICACIONES',
                estilo: AppText.sans(13)),
          ),
          controller: _telefono,
          hint: '310 456 7890',
          icono: const SvgIcon('ficha_cliente/celular.svg', width: 12.5, height: 18.3),
          teclado: TextInputType.phone,
          formato: formatoTelefono,
          indicativo: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColors.surfaceHigh,
            alignment: Alignment.center,
            child: Text('🇨🇴  +57', style: AppText.sans(18, weight: FontWeight.w500)),
          ),
          errores: {'El teléfono es obligatorio para notificaciones': _vacio(_telefono)},
        ),
        _campo(
          etiqueta: FieldLabel('Correo Electrónico',
              required: true, trailing: Text('Facturación y archivos', style: _detalle)),
          controller: _email,
          hint: 'camilo.restrepo@example.com',
          icono: const SvgIcon('ficha_cliente/arroba.svg', width: 16.7, height: 16.7),
          teclado: TextInputType.emailAddress,
          errores: {'Ingresa un correo electrónico válido': _emailInvalido},
        ),
      ];

  Widget _campo({
    required Widget etiqueta,
    required TextEditingController controller,
    required String hint,
    required Widget icono,
    required Map<String, bool> errores,
    List<Widget> antes = const [],
    TextInputType? teclado,
    TextInputFormatter? formato,
    Widget? indicativo,
  }) {
    final campo = HexTextField(
      controller: controller,
      hint: hint,
      keyboardType: teclado,
      formatos: formato == null ? null : [formato],
      fill: AppColors.surfaceLow,
      error: errores.values.any((e) => e),
      prefix: icono,
      onChanged: (_) => setState(() {}),
    );
    return TarjetaCampo(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          etiqueta,
          ...antes,
          if (indicativo == null)
            campo
          else
            Row(children: [indicativo, const SizedBox(width: 6), Expanded(child: campo)]),
          for (final MapEntry(key: texto, value: visible) in errores.entries)
            MensajeCampo(texto, tipo: TipoMensaje.error, visible: visible),
        ],
      ),
    );
  }
}

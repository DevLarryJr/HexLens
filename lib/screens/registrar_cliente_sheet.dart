import 'package:flutter/material.dart';

import '../api/api.dart';
import '../core/reloj.dart';
import '../data/mock_clientes.dart';
import '../models/cliente.dart';
import '../theme/app_theme.dart';
import '../utils/formateadores.dart';
import '../utils/formato.dart';
import '../widgets/clientes/registro_cliente_widgets.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';

/// Figma: "HexLens - Registrar Nuevo Cliente (Modal)" (41:1471).
/// Hoja modal inferior para alta rápida de un cliente. Devuelve el cliente creado, o null si se descarta.
Future<Cliente?> showRegistrarClienteSheet(BuildContext context) =>
    mostrarHoja<Cliente>(context, const _RegistrarClienteSheet(), oscuro: true);

class _RegistrarClienteSheet extends StatefulWidget {
  const _RegistrarClienteSheet();

  @override
  State<_RegistrarClienteSheet> createState() => _RegistrarClienteSheetState();
}

class _RegistrarClienteSheetState extends State<_RegistrarClienteSheet> {
  final _doc = TextEditingController(text: '1.018.490.231');
  final _nombres = TextEditingController(text: 'Valentina');
  final _apellidos = TextEditingController(text: 'Rojas Restrepo');
  final _nacimiento = TextEditingController(text: '22/05/1995');
  final _telefono = TextEditingController(text: '314 892 4510');
  final _email = TextEditingController(text: 'v.rojas@email.com');

  @override
  void dispose() {
    for (final c in [_doc, _nombres, _apellidos, _nacimiento, _telefono, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  Cliente? get _duplicado => clientePorDocumento(_doc.text);

  /// El correo es opcional, pero si se escribe debe tener @ y dominio.
  bool get _emailInvalido {
    final email = _email.text.trim();
    return email.isNotEmpty && !esCorreo(email);
  }

  Future<void> _elegirNacimiento() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 5, 22),
      firstDate: DateTime(1920),
      lastDate: Reloj.hoy,
      helpText: 'Fecha de nacimiento',
    );
    if (d != null && mounted) setState(() => _nacimiento.text = fechaNumerica(d));
  }

  /// Enviando el cliente a la API.
  bool _guardando = false;

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      final cliente = await guardarCliente(
        tipoDocumento: 'C.C.',
        documento: _doc.text,
        nombres: _nombres.text,
        apellidos: _apellidos.text,
        telefono: _telefono.text,
        email: _email.text,
        nacimiento: fechaDesdeNumerica(_nacimiento.text),
      );
      if (!mounted) return;
      // El toast se muestra en el ScaffoldMessenger raíz, así que sigue visible al cerrar la hoja.
      showHexToast(context, 'Cliente ${cliente.nombre} registrado');
      Navigator.of(context).pop(cliente);
    } on ApiError catch (e) {
      if (mounted) showHexToast(context, e.mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final valido = _doc.text.trim().isNotEmpty && _nombres.text.trim().isNotEmpty && _telefono.text.trim().isNotEmpty &&
        _duplicado == null &&
        !_emailInvalido;
    final ayuda = AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22);
    void cerrar() => Navigator.of(context).pop();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.92),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SheetHandle(),
                const SizedBox(height: 18),
                const RegistroClienteCabecera(),
                const SizedBox(height: 16),
                const FieldLabel('Documento de Identidad', required: true),
                HexTextField(
                  controller: _doc,
                  fill: AppColors.surfaceLow,
                  keyboardType: TextInputType.number,
                  formatos: const [formatoDocumento],
                  prefix: const SvgIcon('reg_cliente/documento.svg', width: 38.7, height: 16.7),
                  error: _duplicado != null,
                  suffix: const SvgIcon('reg_cliente/verificado.svg', width: 16.5, height: 15.8),
                  onChanged: (_) => setState(() {}),
                ),
                MensajeCampo(
                  'Ya existe un cliente con ese documento (${_duplicado?.nombre})',
                  tipo: TipoMensaje.error,
                  visible: _duplicado != null,
                ),
                const SizedBox(height: 6),
                Text('Documento oficial para emisión de comprobante DIAN y contrato de cesión.', style: ayuda),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FieldLabel('Nombres'),
                          HexTextField(controller: _nombres, fill: AppColors.surfaceLow, onChanged: (_) => setState(() {})),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FieldLabel('Apellidos'),
                          HexTextField(controller: _apellidos, fill: AppColors.surfaceLow),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                FieldLabel('Fecha de Nacimiento',
                    trailing: Text('(Opcional)', style: AppText.sans(16, color: AppColors.onSurfaceVariant))),
                GestureDetector(
                  onTap: _elegirNacimiento,
                  child: AbsorbPointer(
                    child: HexTextField(
                      controller: _nacimiento,
                      hint: 'dd/mm/aaaa',
                      fill: AppColors.surfaceLow,
                      prefix: const SvgIcon('reg_cliente/calendario.svg', width: 25, height: 16.7),
                      suffix: const SvgIcon('reg_cliente/cake.svg', width: 13.5, height: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text('Permite programar cortesías y promociones automáticas de aniversario.', style: ayuda),
                const SizedBox(height: 18),
                FieldLabel('Teléfono / WhatsApp',
                    trailing: IconoTexto(const Icon(Icons.circle, size: 7, color: AppColors.whatsapp), 'Directo',
                        estilo: AppText.sans(16, color: AppColors.onSurfaceVariant))),
                HexTextField(
                  controller: _telefono,
                  fill: AppColors.surfaceLow,
                  keyboardType: TextInputType.phone,
                  formatos: const [formatoTelefono],
                  prefix: Tag(label: '🇨🇴 +57', background: AppColors.surfaceHigh, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      style: AppText.sans(15, weight: FontWeight.w600)),
                  suffix: const Icon(Icons.sms_outlined, color: AppColors.whatsapp),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 18),
                const FieldLabel('Correo Electrónico'),
                HexTextField(
                  controller: _email,
                  fill: AppColors.surfaceLow,
                  keyboardType: TextInputType.emailAddress,
                  prefix: const SvgIcon('reg_cliente/mail.svg', width: 26.7, height: 13.3),
                  error: _emailInvalido,
                  onChanged: (_) => setState(() {}),
                  suffix: const SvgIcon('reg_cliente/mail_ok.svg', width: 15, height: 15),
                ),
                MensajeCampo('Ingresa un correo electrónico válido', tipo: TipoMensaje.error, visible: _emailInvalido),
                const SizedBox(height: 18),
                const HabeasDataBreve(),
                const SizedBox(height: 28),
                ParAcciones(
                  secundario: 'Descartar',
                  onSecundario: cerrar,
                  principal: 'Guardar Cliente',
                  iconoPrincipal: const SvgIcon('reg_cliente/guardar.svg', width: 15.8, height: 13),
                  onPrincipal: valido && !_guardando ? _guardar : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

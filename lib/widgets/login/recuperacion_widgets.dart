import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../hex_form.dart';
import '../hex_widgets.dart';
import '../../utils/formato.dart';

/// Botón de volver y etiqueta "HEX·AUTH // REC-01".
class RecuperacionTopBar extends StatelessWidget {
  const RecuperacionTopBar({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Volver al inicio de sesión',
          excludeSemantics: true,
          child: Material(
            color: AppColors.surfaceHigh,
            borderRadius: AppRadius.xs,
            child: InkWell(
              onTap: onBack,
              child: const SizedBox(width: 58, height: 58, child: SvgIcon('recuperacion/back.svg', width: 11.3, height: 11.3)),
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: AppColors.surfaceHigh,
          child: IconoTexto(const SvgIcon('recuperacion/hex.svg', width: 16, height: 16), 'RECUPERAR ACCESO',
              estilo: AppText.sans(17, weight: FontWeight.w600, letterSpacing: 0.8), separacion: 8),
        ),
      ],
    );
  }
}

/// Franja "PROTOCOLO SEGURO", título "RECUPERACIÓN" e instrucciones.
class RecuperacionEncabezado extends StatelessWidget {
  const RecuperacionEncabezado({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: AppColors.surfaceHigh,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(top: 8), child: Dot(size: 6, color: AppColors.accent)),
              const SizedBox(width: 10),
              Expanded(
                child: Text('CONEXIÓN SEGURA · CIFRADO 256 BITS',
                    style: AppText.sans(17, color: AppColors.onSurfaceVariant, lineHeight: 24, letterSpacing: 1.6)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('RECUPERACIÓN', style: AppText.sans(36, weight: FontWeight.w700, letterSpacing: -0.4)),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.emergency, color: AppColors.accent, size: 26),
          ],
        ),
        const SizedBox(height: 6),
        Text('Ingresa tu identificador oficial de estudio o correo técnico para emitir una llave temporal OTP.',
            style: AppText.sans(19, color: AppColors.onSurfaceVariant, lineHeight: 30)),
      ],
    );
  }
}

/// Paso 1: ID de operador o correo y botón para emitir el código.
class SolicitarOtpCard extends StatelessWidget {
  const SolicitarOtpCard({
    super.key,
    required this.controller,
    required this.valido,
    this.onChanged,
    this.onEnviar,
  });

  final TextEditingController controller;
  final bool valido;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEnviar;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      radius: 8,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('ID DE OPERADOR O CORREO',
                    style: AppText.sans(16, weight: FontWeight.w600, color: AppColors.onSurfaceVariant, letterSpacing: 1.2)),
              ),
              Text('PASO 01/02', style: AppText.sans(16, color: AppColors.accent, letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 12),
          HexTextField(
            controller: controller,
            fill: AppColors.surfaceLow,
            keyboardType: TextInputType.emailAddress,
            prefix: const SvgIcon('recuperacion/operador.svg', width: 14, height: 14),
            onChanged: onChanged,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text('Staff técnico, fotógrafos o control central', style: AppText.sans(17, color: AppColors.onSurfaceVariant)),
              ),
              Icon(Icons.verified_outlined, size: 18, color: valido ? AppColors.accent : AppColors.outlineVariant),
            ],
          ),
          const SizedBox(height: 16),
          HexButton(
            label: 'Actualizar Código OTP',
            radius: 2,
            height: 62,
            onPressed: onEnviar,
            trailing: const SvgIcon('recuperacion/otp.svg', width: 11.8, height: 14),
            textStyle: AppText.sans(19, weight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Seis casillas del código OTP sobre un campo invisible que recibe el teclado.
class OtpCasillas extends StatelessWidget {
  const OtpCasillas({super.key, required this.controller, required this.focusNode, this.onChanged});

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final texto = controller.text;
    return Stack(
      children: [
        // Campo real invisible que recibe el teclado.
        Opacity(
          opacity: 0,
          child: SizedBox(
            height: 74,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: onChanged,
            ),
          ),
        ),
        GestureDetector(
          onTap: focusNode.requestFocus,
          child: Row(
            children: [
              for (var i = 0; i < 6; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 74,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLow,
                      border: focusNode.hasFocus && i == texto.length
                          ? Border.all(color: AppColors.onSurface, width: 1.5)
                          : null,
                    ),
                    child: i < texto.length
                        ? Text(texto[i], style: AppText.sans(34, weight: FontWeight.w600))
                        : const Dot(size: 8, color: AppColors.outlineVariant),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Paso 2: casillas OTP, cuenta atrás para reenviar y botón de validar.
class ValidarOtpCard extends StatelessWidget {
  const ValidarOtpCard({
    super.key,
    required this.casillas,
    required this.segundos,
    required this.completo,
    this.onReenviar,
    this.onValidar,
  });

  /// Normalmente [OtpCasillas].
  final Widget casillas;

  /// Segundos que faltan para poder reenviar.
  final int segundos;

  /// Ya hay 6 dígitos.
  final bool completo;
  final VoidCallback? onReenviar;
  final VoidCallback? onValidar;

  @override
  Widget build(BuildContext context) {
    final cuenta = '${segundos ~/ 60}:${dosCifras(segundos % 60)}';
    return HexCard(
      radius: 8,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          const Positioned(right: 0, top: 0, child: EsquinaTriangulo(size: 30, color: AppColors.accent)),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text('VALIDACIÓN OTP',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.sans(18, weight: FontWeight.w600, letterSpacing: 0.8)),
                    ),
                    const SizedBox(width: 6),
                    const Dot(size: 6, color: AppColors.accent),
                    const SizedBox(width: 8),
                    const Spacer(),
                    Tag(label: '6 DÍGITOS', background: AppColors.accentBright, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        style: AppText.sans(17, weight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Te enviamos un código de 6 dígitos. Escríbelo aquí:',
                    style: AppText.sans(17, color: AppColors.onSurfaceVariant, lineHeight: 24)),
                const SizedBox(height: 18),
                casillas,
                const SizedBox(height: 18),
                Row(
                  children: [
                    const SvgIcon('recuperacion/reloj.svg', width: 9.3, height: 11.7),
                    const SizedBox(width: 6),
                    Text.rich(TextSpan(
                      style: AppText.sans(17, color: AppColors.onSurfaceVariant),
                      children: [
                        TextSpan(text: segundos > 0 ? 'Reenviar en ' : 'Puedes reenviar '),
                        if (segundos > 0) TextSpan(text: cuenta, style: AppText.sans(17, weight: FontWeight.w600)),
                      ],
                    )),
                    const Spacer(),
                    GestureDetector(
                      onTap: segundos == 0 ? onReenviar : null,
                      child: Text('Reenviar código',
                          style: AppText.sans(17,
                                  weight: FontWeight.w600,
                                  color: segundos == 0 ? AppColors.accentBright : AppColors.outlineVariant)
                              .copyWith(decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                HexButton(
                  label: 'Validar Código y Continuar',
                  radius: 2,
                  height: 62,
                  background: completo ? Colors.black : AppColors.graphite,
                  onPressed: onValidar,
                  leading: const SvgIcon('recuperacion/validar.svg', width: 14.5, height: 14.5),
                  textStyle: AppText.sans(19, weight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "REGLA DE CADUCIDAD DE SESIÓN" del código temporal.
class CaducidadNota extends StatelessWidget {
  const CaducidadNota({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.surfaceHigh,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            color: AppColors.surfaceContainer,
            child: const SvgIcon('recuperacion/caducidad.svg', width: 11.3, height: 14),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('REGLA DE CADUCIDAD DE SESIÓN', style: AppText.sans(17, weight: FontWeight.w600, letterSpacing: 0.8)),
                const SizedBox(height: 4),
                Text(
                    'El código temporal expira automáticamente en 10 minutos. No comparta este token con asistentes o clientes fuera de cabina.',
                    style: AppText.sans(17, color: AppColors.onSurfaceVariant, lineHeight: 26)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

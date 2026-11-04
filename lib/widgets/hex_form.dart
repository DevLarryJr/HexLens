import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'hex_widgets.dart';

/// Etiqueta de campo con marcador opcional "* Requerido".
/// Etiqueta de un campo de formulario (la única de la app): texto, asterisco rojo si es
/// obligatorio, todo en rojo si el campo tiene error y un detalle opcional a la derecha.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.required = false, this.error = false, this.trailing});

  final String text;
  final bool required;
  final bool error;

  /// Detalle a la derecha: contador, etiqueta, "(Opcional)"…
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(
                text: text,
                style: AppText.sans(16,
                    weight: FontWeight.w600, color: error ? AppColors.accentBright : AppColors.onSurface, lineHeight: 22),
              ),
              if (required) TextSpan(text: ' *', style: AppText.sans(16, color: AppColors.accentBright, lineHeight: 22)),
            ])),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

enum TipoMensaje { ayuda, error, ok }

/// Mensaje bajo un campo o una validación (el único de la app): ayuda en gris, error en rojo
/// u ok en verde, con su ícono. Con [visible] en falso no ocupa espacio.
class MensajeCampo extends StatelessWidget {
  const MensajeCampo(this.texto, {super.key, this.tipo = TipoMensaje.ayuda, this.visible = true, this.margenSuperior = 6});

  final String texto;
  final TipoMensaje tipo;
  final bool visible;
  final double margenSuperior;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final (icono, color) = switch (tipo) {
      TipoMensaje.ayuda => (Icons.info_outline, AppColors.onSurfaceVariant),
      TipoMensaje.error => (Icons.error_outline, AppColors.accentBright),
      TipoMensaje.ok => (Icons.check_circle_outline, AppColors.successDark),
    };
    return Padding(
      padding: EdgeInsets.only(top: margenSuperior),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icono, size: 16, color: color)),
          const SizedBox(width: 6),
          Expanded(child: Text(texto, style: AppText.sans(14, color: color, lineHeight: 20))),
        ],
      ),
    );
  }
}

/// Campo de texto del sistema HexLens (fondo blanco, radio 2, sin borde).
class HexTextField extends StatelessWidget {
  const HexTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.hint,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.keyboardType,
    this.obscure = false,
    this.error = false,
    this.fill = Colors.white,
    this.mono = false,
    this.onChanged,
    this.formatos,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? hint;
  final Widget? prefix;
  final Widget? suffix;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool error;
  final Color fill;
  final bool mono;
  final ValueChanged<String>? onChanged;

  /// Formato mientras se escribe (p. ej. `formatoDocumento`, `formatoTelefono`).
  final List<TextInputFormatter>? formatos;

  @override
  Widget build(BuildContext context) {
    final style = mono ? AppText.mono(15, color: AppColors.onSurface) : AppText.sans(16);
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: AppRadius.xs,
          borderSide: c == Colors.transparent ? BorderSide.none : BorderSide(color: c, width: w),
        );
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xs,
        boxShadow: AppShadows.hairline,
      ),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        maxLines: maxLines,
        keyboardType: keyboardType,
        obscureText: obscure,
        onChanged: onChanged,
        inputFormatters: formatos,
        style: style,
        cursorColor: AppColors.accent,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: style.copyWith(color: AppColors.outline),
          filled: true,
          fillColor: error ? const Color(0xFFFFF5F3) : fill,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: prefix == null ? 16 : 0, vertical: 14),
          prefixIcon: prefix == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Center(widthFactor: 1, heightFactor: 1, child: prefix)),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: suffix == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(widthFactor: 1, heightFactor: 1, child: suffix)),
          border: border(error ? AppColors.accentBright : Colors.transparent, 1.5),
          enabledBorder: border(error ? AppColors.accentBright : Colors.transparent, 1.5),
          focusedBorder: border(error ? AppColors.accentBright : AppColors.onSurface, 1.5),
        ),
      ),
    );
  }
}

/// Selector desplegable con el estilo de los campos.
class HexDropdown extends StatelessWidget {
  const HexDropdown({super.key, required this.value, required this.items, required this.onChanged});

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xs,
        boxShadow: AppShadows.hairline,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          // Si el valor no está en la lista (p. ej. la lista llegó de la API), no se marca ninguno.
          value: items.contains(value) ? value : null,
          hint: Text(items.isEmpty ? 'No hay opciones' : 'Elige una opción',
              style: AppText.sans(16, color: AppColors.outline)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.onSurface),
          style: AppText.sans(16),
          dropdownColor: Colors.white,
          items: [for (final i in items) DropdownMenuItem(value: i, child: Text(i))],
          onChanged: (v) => v == null ? null : onChanged(v),
        ),
      ),
    );
  }
}

/// Selector segmentado (fondo crema, opción activa negra).
class HexSegmented extends StatelessWidget {
  const HexSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.icons,
    this.leadings,
  });

  final List<String> options;
  final List<IconData>? icons;
  final List<Widget>? leadings;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: AppRadius.xs),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: i == selected ? Colors.black : Colors.transparent,
                    borderRadius: AppRadius.xs,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (leadings != null) ...[
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                              i == selected ? Colors.white : AppColors.onSurface, BlendMode.srcIn),
                          child: leadings![i],
                        ),
                        const SizedBox(width: 6),
                      ] else if (icons != null) ...[
                        Icon(icons![i], size: 18, color: i == selected ? Colors.white : AppColors.onSurface),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(options[i],
                            textAlign: TextAlign.center,
                            style: AppText.sans(16,
                                weight: FontWeight.w500,
                                color: i == selected ? Colors.white : AppColors.onSurface,
                                lineHeight: 20)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Interruptor negro con etiqueta y descripción.
class HexSwitchRow extends StatelessWidget {
  const HexSwitchRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.sans(16, weight: FontWeight.w500, lineHeight: 22)),
              Text(subtitle, style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: Colors.black,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: AppColors.outlineVariant,
          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ],
    );
  }
}

/// Caja de nota/estado (fondo crema claro con icono).
class InfoBox extends StatelessWidget {
  const InfoBox({
    super.key,
    required this.child,
    this.icon,
    this.leading,
    this.iconColor = AppColors.onSurfaceVariant,
    this.background = AppColors.surfaceLow,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final IconData? icon;

  /// Icono personalizado (p.ej. SVG de Figma); tiene prioridad sobre [icon].
  final Widget? leading;
  final Color iconColor;
  final Color background;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(color: background, borderRadius: AppRadius.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null || icon != null) ...[
            Padding(
                padding: const EdgeInsets.only(top: 1),
                child: leading ?? Icon(icon, size: 18, color: iconColor)),
            const SizedBox(width: 10),
          ],
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Tarjeta blanca de un campo de formulario, con margen inferior de 24.
class TarjetaCampo extends StatelessWidget {
  const TarjetaCampo({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: HexCard(radius: 4, padding: const EdgeInsets.all(20), child: child),
      );
}

/// Cabecera de sección "MÓDULO // ..." con punto bermellón y versión a la derecha.
class ModuleHeader extends StatelessWidget {
  const ModuleHeader({
    super.key,
    required this.tag,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String tag;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _RedDot(),
            const SizedBox(width: 6),
            Expanded(
              child: Text(tag,
                  style: AppText.sans(14,
                      color: AppColors.onSurfaceVariant, lineHeight: 18, letterSpacing: 0.7)),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 6),
        Text(title,
            style: AppText.sans(22, weight: FontWeight.w700, lineHeight: 28, letterSpacing: -0.3)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 24)),
        ],
      ],
    );
  }
}

class _RedDot extends StatelessWidget {
  const _RedDot();

  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(color: AppColors.accentBright, shape: BoxShape.circle),
      );
}

/// Encabezado de pantalla tipo modal: botón cerrar, título, etiqueta y subtítulo.
class ModalHeader extends StatelessWidget implements PreferredSizeWidget {
  const ModalHeader({super.key, required this.title, required this.subtitle, this.tag});

  final String title;
  final String subtitle;
  final String? tag;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.glassSolid,
        boxShadow: [BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 8)],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close, color: AppColors.onSurface),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(title,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.sans(20, weight: FontWeight.w600, lineHeight: 26)),
                        ),
                        if (tag != null) ...[
                          const SizedBox(width: 6),
                          Tag(label: tag!, background: AppColors.surfaceHigh, padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              style: AppText.mono(13, color: AppColors.onSurface, letterSpacing: 1)),
                        ],
                      ],
                    ),
                    Text(subtitle, style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 20),
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: Colors.black, borderRadius: AppRadius.lg),
                child: const Icon(Icons.person_outline, size: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Encabezado de sección (el único de la app): marca opcional, título y a la derecha un
/// [dato] de texto o un widget [extra]. [subrayado] añade la línea inferior y [franja] lo
/// pone sobre fondo gris.
class EncabezadoSeccion extends StatelessWidget {
  const EncabezadoSeccion(
    this.titulo, {
    super.key,
    this.marca,
    this.dato,
    this.colorDato = AppColors.onSurfaceVariant,
    this.extra,
    this.subrayado = false,
    this.franja = false,
  });

  final String titulo;
  final Widget? marca;
  final String? dato;
  final Color colorDato;
  final Widget? extra;
  final bool subrayado;
  final bool franja;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: franja
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
          : EdgeInsets.only(bottom: subrayado ? 6 : 0),
      decoration: BoxDecoration(
        color: franja ? AppColors.surfaceHigh : null,
        border: subrayado ? const Border(bottom: BorderSide(color: AppColors.outlineVariant)) : null,
      ),
      child: Row(
        children: [
          if (marca != null) ...[marca!, const SizedBox(width: 8)],
          Expanded(
            child: Text(titulo,
                style: AppText.sans(16, weight: FontWeight.w700, lineHeight: 24, letterSpacing: 1.2)),
          ),
          if (dato != null) ...[
            const SizedBox(width: 12),
            Text(dato!, textAlign: TextAlign.end, style: AppText.sans(14, color: colorDato, lineHeight: 20)),
          ],
          if (extra != null) ...[const SizedBox(width: 12), extra!],
        ],
      ),
    );
  }
}

/// Marca cuadrada bermellón de 8 px para [EncabezadoSeccion].
class MarcaSeccion extends StatelessWidget {
  const MarcaSeccion({super.key});

  @override
  Widget build(BuildContext context) => Container(width: 8, height: 8, color: AppColors.accentBright);
}

/// Muestra un aviso negro flotante (estilo toast HexLens).
void showHexToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black,
      content: Text(message, style: AppText.sans(14, color: Colors.white)),
    ));
}

/// Pregunta antes de perder lo que se llenó. Devuelve true si el usuario elige salir.
Future<bool> confirmarSalida(
  BuildContext context, {
  String titulo = '¿Descartar los cambios?',
  String mensaje = 'Lo que llenaste en este formulario no se guardará.',
  String seguir = 'Seguir editando',
  String salir = 'Descartar',
}) async {
  final salirOk = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(seguir)),
        TextButton(
          onPressed: () => Navigator.of(c).pop(true),
          child: Text(salir, style: const TextStyle(color: AppColors.accent)),
        ),
      ],
    ),
  );
  return salirOk == true;
}

/// Formulario de pantalla completa con una sola salida: la ✕ del header (o el atrás del sistema). Si hay
/// cambios sin guardar, pregunta antes de descartarlos ([confirmarSalida]).
///
/// La pantalla define [firmaFormulario] con sus valores editables, envuelve su contenido con [protegerSalida]
/// y, después de guardar, sale con [salirSinPreguntar].
mixin ProtegeCambios<T extends StatefulWidget> on State<T> {
  /// Valores editables unidos en un texto, p. ej. `'${_nombre.text}|$_duracion'`. Si difieren de los del
  /// primer dibujo, hay cambios sin guardar.
  String get firmaFormulario;

  String? _firmaInicial;

  /// Algo es distinto a como se abrió la pantalla.
  bool get hayCambios => _firmaInicial != null && firmaFormulario != _firmaInicial;

  /// Toma los valores actuales como punto de partida (p. ej., al cargar otra semana).
  void reiniciarFirma() => _firmaInicial = firmaFormulario;

  /// Envuelve la pantalla: salir (✕ o atrás del sistema) con cambios pregunta antes.
  Widget protegerSalida(Widget child) {
    _firmaInicial ??= firmaFormulario;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (hayCambios && !await confirmarSalida(context)) return;
        if (mounted) salirSinPreguntar();
      },
      child: child,
    );
  }

  /// Cierra la pantalla sin preguntar (después de guardar o eliminar).
  void salirSinPreguntar() {
    final navegador = Navigator.of(context);
    if (navegador.canPop()) navegador.pop();
  }
}

/// Par de botones que cierra un formulario u hoja (el único de la app): secundario gris a la
/// izquierda y principal (negro por defecto) ocupando 3/5 del ancho. Sin [onPrincipal] el
/// principal se ve deshabilitado. Sin [secundario] el principal ocupa todo el ancho (en las
/// pantallas, salir sin guardar es la ✕ del header: no hace falta un "Descartar" abajo).
class ParAcciones extends StatelessWidget {
  const ParAcciones({
    super.key,
    this.secundario,
    required this.principal,
    this.onSecundario,
    this.onPrincipal,
    this.iconoSecundario,
    this.iconoPrincipal,
    this.colorPrincipal = Colors.black,
    this.insignia,
  });

  final String? secundario;
  final String principal;
  final VoidCallback? onSecundario;
  final VoidCallback? onPrincipal;
  final Widget? iconoSecundario;
  final Widget? iconoPrincipal;
  final Color colorPrincipal;

  /// Marca junto al texto principal, p. ej. "2 errores".
  final Widget? insignia;

  @override
  Widget build(BuildContext context) {
    final habilitado = onPrincipal != null;
    final secundario = this.secundario;
    return Row(
      children: [
        if (secundario != null) ...[
          Expanded(
            flex: 2,
            child: _Boton(
              texto: secundario,
              icono: iconoSecundario,
              fondo: AppColors.surfaceHigh,
              color: AppColors.onSurface,
              onTap: onSecundario,
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          flex: 3,
          child: _Boton(
            texto: principal,
            icono: iconoPrincipal,
            fondo: habilitado ? colorPrincipal : AppColors.outlineVariant,
            color: Colors.white,
            onTap: onPrincipal,
            insignia: insignia,
          ),
        ),
      ],
    );
  }
}

class _Boton extends StatelessWidget {
  const _Boton({
    required this.texto,
    required this.fondo,
    required this.color,
    this.icono,
    this.onTap,
    this.insignia,
  });

  final String texto;
  final Color fondo;
  final Color color;
  final Widget? icono;
  final VoidCallback? onTap;
  final Widget? insignia;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fondo,
      borderRadius: AppRadius.xs,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icono != null) ...[icono!, const SizedBox(width: 8)],
              Flexible(
                child: Text(texto,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: AppText.sans(17, weight: FontWeight.w600, color: color, lineHeight: 22)),
              ),
              if (insignia != null) ...[const SizedBox(width: 8), insignia!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra inferior fija (fondo crema translúcido) para un [ParAcciones].
class BarraAcciones extends StatelessWidget {
  const BarraAcciones({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.glassSolid,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SafeArea(top: false, child: child),
    );
  }
}

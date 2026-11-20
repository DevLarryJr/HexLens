import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HexSearchField extends StatelessWidget {
  const HexSearchField({
    super.key,
    required this.controller,
    this.hint,
    required this.icon,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.suffix,
    this.textStyle,
    this.hintStyle,
    this.iconPadding = const EdgeInsets.only(left: 16.5, right: 12.5),
    this.iconMinWidth = 44,
    this.radius = 4,
  });

  final TextEditingController controller;
  final String? hint;
  final Widget icon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final Widget? suffix;

  final TextStyle? textStyle;

  final TextStyle? hintStyle;
  final EdgeInsets iconPadding;

  final double iconMinWidth;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final borde = BorderRadius.circular(radius);
    return Container(
      height: 48,
      decoration: BoxDecoration(borderRadius: borde, boxShadow: AppShadows.hairline),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: textInputAction,
        style: textStyle ?? AppText.sans(16),
        cursorColor: AppColors.accent,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: hintStyle ?? AppText.sans(16, color: AppColors.outline),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
          prefixIcon: Padding(padding: iconPadding, child: icon),
          prefixIconConstraints: BoxConstraints(minWidth: iconMinWidth),
          suffixIcon: suffix,
          border: OutlineInputBorder(borderRadius: borde, borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: borde,
            borderSide: const BorderSide(color: AppColors.onSurface),
          ),
        ),
      ),
    );
  }
}

mixin ConBusqueda<T extends StatefulWidget> on State<T> {
  late final busqueda = TextEditingController(text: textoInicial);

  String get textoInicial => '';

  @override
  void dispose() {
    busqueda.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HexChip extends StatelessWidget {
  const HexChip({
    super.key,
    required this.label,
    required this.selected,
    required this.style,
    this.onTap,
    this.color = Colors.white,
    this.selectedColor = Colors.black,
    this.foreground = AppColors.onSurface,
    this.selectedForeground = Colors.white,
    this.radius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    this.height,
    this.shadow,
    this.selectedShadow,
    this.leading,
    this.leadingGap = 6,
    this.trailing,
    this.trailingGap = 6,
  });

  final String label;
  final bool selected;

  final TextStyle style;
  final VoidCallback? onTap;
  final Color color;
  final Color selectedColor;
  final Color foreground;
  final Color selectedForeground;
  final double radius;
  final EdgeInsets padding;

  final double? height;
  final List<BoxShadow>? shadow;

  final List<BoxShadow>? selectedShadow;
  final Widget? leading;
  final double leadingGap;
  final Widget? trailing;
  final double trailingGap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? selectedForeground : foreground;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: padding,
        alignment: height == null ? null : Alignment.center,
        decoration: BoxDecoration(
          color: selected ? selectedColor : color,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: selected ? (selectedShadow ?? shadow) : shadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, SizedBox(width: leadingGap)],
            Text(label, style: style.copyWith(color: fg, decorationColor: fg)),
            if (trailing != null) ...[SizedBox(width: trailingGap), trailing!],
          ],
        ),
      ),
    );
  }
}

class HexChipBar extends StatelessWidget {
  const HexChipBar({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = 8,
    this.height,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double spacing;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (height != null) {
      return SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: itemCount,
          separatorBuilder: (_, _) => SizedBox(width: spacing),
          itemBuilder: itemBuilder,
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (var i = 0; i < itemCount; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            itemBuilder(context, i),
          ],
        ],
      ),
    );
  }
}

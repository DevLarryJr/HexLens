import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

class StaffBottomNav extends StatelessWidget {
  const StaffBottomNav({super.key, required this.seleccion, this.onSelect});

  final int seleccion;
  final ValueChanged<int>? onSelect;

  static const _items = [
    ('mis_servicios/nav_servicios.svg', 18.3, 16.5, 'Mis Servicios'),
    ('mis_servicios/nav_comisiones.svg', 20.2, 14.7, 'Mis Comisiones'),
    ('mis_servicios/nav_cuenta.svg', 18.3, 18.3, 'Mi Cuenta'),
  ];

  static const _sombra = [BoxShadow(color: Color(0x0F141414), offset: Offset(0, -2), blurRadius: 12)];

  @override
  Widget build(BuildContext context) {
    return BlurBottomBar(
      blur: 12,
      padding: EdgeInsets.zero,
      shadow: _sombra,
      child: SizedBox(
        height: 72,
        child: Row(
          children: [
            for (var i = 0; i < _items.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onSelect?.call(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgIcon(_items[i].$1,
                          width: _items[i].$2,
                          height: _items[i].$3,
                          color: i == seleccion ? Colors.black : AppColors.onSurfaceVariant),
                      const SizedBox(height: 4),
                      Text(_items[i].$4,
                          style: AppText.sans(14,
                              weight: i == seleccion ? FontWeight.w500 : FontWeight.w400,
                              color: i == seleccion ? Colors.black : AppColors.onSurfaceVariant,
                              lineHeight: 18)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

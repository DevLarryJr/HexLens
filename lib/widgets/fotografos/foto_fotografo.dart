import 'package:flutter/material.dart';

import '../../models/fotografo.dart';
import '../../theme/app_theme.dart';
import '../../utils/formato.dart';

class FotoFotografo extends StatelessWidget {
  const FotoFotografo(this.fotografo, {super.key, this.tamano});

  final Fotografo fotografo;

  final double? tamano;

  @override
  Widget build(BuildContext context) {
    final foto = fotografo.foto;
    if (foto != null) {
      return Image.asset('assets/images/$foto',
          width: tamano, height: tamano, fit: BoxFit.cover, alignment: Alignment.topCenter);
    }
    return Container(
      width: tamano,
      height: tamano,
      color: AppColors.charcoal,
      alignment: Alignment.center,
      child: Text(iniciales(fotografo.nombre), style: AppText.sans(20, weight: FontWeight.w700, color: Colors.white)),
    );
  }
}

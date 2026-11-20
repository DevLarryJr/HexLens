import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/splash/splash_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..forward();

  Timer? _salida;

  @override
  void initState() {
    super.initState();
    _progress.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _salida = Timer(const Duration(milliseconds: 300), () {
          if (mounted) widget.onFinished();
        });
      }
    });
  }

  @override
  void dispose() {
    _salida?.cancel();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: Opacity(opacity: 0.25, child: SplashVisor())),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: Column(
                children: [
                  const SplashTelemetria(),
                  const Expanded(child: Center(child: SplashMarca())),
                  AnimatedBuilder(
                    animation: _progress,
                    builder: (context, _) => SplashCarga(
                      progreso: Curves.easeOutCubic.transform(_progress.value) * 0.85 + 0.15 * _progress.value,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SplashPie(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

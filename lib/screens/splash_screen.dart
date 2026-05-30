import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/app_state.dart';
import 'identity_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final hasId = await context.read<AppState>().loadSaved();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => hasId ? const HomeScreen() : const IdentityScreen()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: BahirTheme.bg,
    body: Container(
      decoration: const BoxDecoration(gradient: RadialGradient(
        center: Alignment(0,-0.3), radius: 1.2,
        colors: [Color(0xFF0D2050), BahirTheme.bg])),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [BahirTheme.blue2, BahirTheme.indigo]).createShader(b),
          child: const Text('BAHIR', style: TextStyle(
            fontSize: 52, fontWeight: FontWeight.w900,
            letterSpacing: 8, color: Colors.white)),
        ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8,0.8), duration: 600.ms),
        const SizedBox(height: 8),
        const Text('اتصال لامركزي ومشفر',
          style: TextStyle(color: BahirTheme.dim, fontSize: 13, letterSpacing: 1))
            .animate(delay: 400.ms).fadeIn(duration: 500.ms),
        const SizedBox(height: 48),
        SizedBox(width: 28, height: 28,
          child: CircularProgressIndicator(strokeWidth: 2,
            color: BahirTheme.accent.withOpacity(0.6)))
              .animate(delay: 800.ms).fadeIn(duration: 400.ms),
      ])),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/app_state.dart';
import '../widgets/bahir_button.dart';
import '../widgets/toast_overlay.dart';
import 'home_screen.dart';

class IdentityScreen extends StatefulWidget {
  const IdentityScreen({super.key});
  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> {
  bool _loading=false, _showImport=false;
  final _importCtrl = TextEditingController();

  Future<void> _createNew() async {
    setState(() => _loading=true);
    final ok = await context.read<AppState>().createIdentity();
    if (!mounted) return;
    if (ok) _go();
    else { setState(() => _loading=false); ToastOverlay.show(context, 'تعذر الاتصال بالسيرفر', isError:true); }
  }

  Future<void> _import() async {
    final txt = _importCtrl.text.trim();
    if (txt.isEmpty) return;
    setState(() => _loading=true);
    final ok = await context.read<AppState>().importIdentity(txt);
    if (!mounted) return;
    if (ok) _go();
    else { setState(() => _loading=false); ToastOverlay.show(context, 'بيانات غير صالحة', isError:true); }
  }

  void _go() => Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => const HomeScreen()));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: BahirTheme.bg,
    body: Container(
      decoration: const BoxDecoration(gradient: RadialGradient(
        center: Alignment(0,-0.5), radius: 1.0,
        colors: [Color(0xFF0D2050), BahirTheme.bg])),
      child: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: 360, padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: BahirTheme.surface,
            border: Border.all(color: BahirTheme.border),
            borderRadius: BorderRadius.circular(20)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [BahirTheme.blue2, BahirTheme.indigo]).createShader(b),
              child: const Text('BAHIR', style: TextStyle(
                fontSize: 38, fontWeight: FontWeight.w900,
                letterSpacing: 5, color: Colors.white)),
            ).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: 4),
            const Text('اتصال لامركزي ومشفر',
              style: TextStyle(color: BahirTheme.dim, fontSize: 12, letterSpacing: 1))
                .animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 28),
            if (_loading) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: BahirTheme.accent, strokeWidth: 2),
              const SizedBox(height: 16),
              const Text('جارٍ الاتصال...', style: TextStyle(color: BahirTheme.dim, fontSize: 13)),
              const SizedBox(height: 20),
            ] else if (!_showImport) ...[
              const Text('هويتك مشفرة — السيرفر لا يعرف محتوى رسائلك',
                textAlign: TextAlign.center,
                style: TextStyle(color: BahirTheme.dim, fontSize: 12)),
              const SizedBox(height: 20),
              BahirButton(label: '✨  هوية جديدة', onTap: _createNew)
                  .animate(delay: 400.ms).fadeIn(),
              const SizedBox(height: 10),
              BahirButton(label: '📥  استيراد هوية', onTap: () => setState(() => _showImport=true), outlined: true)
                  .animate(delay: 500.ms).fadeIn(),
            ] else ...[
              const Text('الصق بيانات هويتك',
                style: TextStyle(color: BahirTheme.dim, fontSize: 12)),
              const SizedBox(height: 12),
              TextField(controller: _importCtrl, maxLines: 4,
                textDirection: TextDirection.ltr,
                style: const TextStyle(fontSize: 12, color: BahirTheme.text),
                decoration: const InputDecoration(hintText: '{"did":"bahir:...","pub":"..."}')),
              const SizedBox(height: 12),
              BahirButton(label: 'استيراد', onTap: _import),
              const SizedBox(height: 8),
              BahirButton(label: 'رجوع', onTap: () => setState(() => _showImport=false), outlined: true),
            ],
          ]),
        ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
      ))),
    ),
  );
}

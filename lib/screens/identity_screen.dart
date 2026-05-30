import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../services/app_state.dart';
import '../services/api_service.dart';
import '../widgets/bahir_button.dart';
import 'home_screen.dart';

class IdentityScreen extends StatefulWidget {
  const IdentityScreen({super.key});
  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> {
  bool _loading = false, _showImport = false;
  final _importCtrl = TextEditingController();
  String _debugMsg = '';

  Future<void> _createNew() async {
    setState(() { _loading = true; _debugMsg = 'جارٍ الاتصال بـ $kApiBase'; });
    final api = ApiService();
    final result = await api.createIdentityRaw();
    if (!mounted) return;
    if (result['ok'] == true) {
      try {
        final j = jsonDecode(result['body'] as String);
        if (j['ok'] == true) {
          final ok = await context.read<AppState>().importIdentity(jsonEncode({'did': j['did'], 'pub': j['public_key'] ?? j['pub']}));
          if (ok) { _go(); return; }
        }
        setState(() { _loading = false; _debugMsg = 'Response: ${result['body']}'; });
      } catch (e) {
        setState(() { _loading = false; _debugMsg = 'Parse error: $e'; });
      }
    } else {
      setState(() { _loading = false; _debugMsg = 'Error: ${result['error']}'; });
    }
  }

  Future<void> _import() async {
    final txt = _importCtrl.text.trim();
    if (txt.isEmpty) return;
    setState(() => _loading = true);
    final ok = await context.read<AppState>().importIdentity(txt);
    if (!mounted) return;
    if (ok) _go();
    else setState(() => _loading = false);
  }

  void _go() => Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => const HomeScreen()));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: BahirTheme.bg,
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: 360, padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: BahirTheme.surface,
          border: Border.all(color: BahirTheme.border),
          borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('BAHIR', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: BahirTheme.blue2)),
          const SizedBox(height: 20),
          if (_debugMsg.isNotEmpty) Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
            child: SelectableText(_debugMsg,
              style: const TextStyle(color: Colors.greenAccent, fontSize: 10),
              textDirection: TextDirection.ltr)),
          if (_loading)
            const CircularProgressIndicator(color: BahirTheme.accent, strokeWidth: 2)
          else if (!_showImport) ...[
            BahirButton(label: '✨ هوية جديدة', onTap: _createNew),
            const SizedBox(height: 10),
            BahirButton(label: '📥 استيراد هوية', onTap: () => setState(() => _showImport = true), outlined: true),
          ] else ...[
            TextField(controller: _importCtrl, maxLines: 4,
              textDirection: TextDirection.ltr,
              style: const TextStyle(fontSize: 12, color: BahirTheme.text),
              decoration: const InputDecoration(hintText: '{"did":"...","pub":"..."}')),
            const SizedBox(height: 12),
            BahirButton(label: 'استيراد', onTap: _import),
            const SizedBox(height: 8),
            BahirButton(label: 'رجوع', onTap: () => setState(() => _showImport = false), outlined: true),
          ],
        ]),
      ),
    ))),
  );
}

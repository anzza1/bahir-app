import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/app_state.dart';
import '../widgets/toast_overlay.dart';
import 'identity_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final did=state.identity?.did??'', pub=state.identity?.pubKey??'';
    return Scaffold(
      backgroundColor: BahirTheme.bg,
      appBar: AppBar(
        backgroundColor: BahirTheme.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size:18, color: BahirTheme.dim),
          onPressed: () => Navigator.pop(context)),
        title: const Text('الإعدادات', style: TextStyle(color: BahirTheme.text, fontSize:16, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
          child: Container(height:1, color: BahirTheme.border)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _label('هويتك'),
        _card([
          _infoRow('DID', did.length>22?'${did.substring(0,22)}...':did,
            onCopy: () { Clipboard.setData(ClipboardData(text:did)); ToastOverlay.show(context,'تم نسخ الـ DID'); }),
          const Divider(color: BahirTheme.border, height:1),
          _infoRow('المفتاح العام', pub.length>22?'${pub.substring(0,22)}...':pub,
            onCopy: () { Clipboard.setData(ClipboardData(text:pub)); ToastOverlay.show(context,'تم نسخ المفتاح'); }),
        ]).animate().fadeIn(duration:300.ms),
        const SizedBox(height:16),
        _label('النسخ الاحتياطي'),
        _card([
          ListTile(
            leading: const Icon(Icons.upload_outlined, color: BahirTheme.accent, size:20),
            title: const Text('تصدير الهوية', style: TextStyle(color: BahirTheme.text, fontSize:13, fontWeight: FontWeight.w600)),
            subtitle: const Text('انسخ بيانات هويتك', style: TextStyle(color: BahirTheme.dim, fontSize:11)),
            trailing: const Icon(Icons.chevron_right, color: BahirTheme.dim, size:18),
            onTap: () { Clipboard.setData(ClipboardData(text: state.exportIdentity()));
              ToastOverlay.show(context,'تم نسخ بيانات الهوية'); },
          ),
        ]).animate(delay:100.ms).fadeIn(duration:300.ms),
        const SizedBox(height:16),
        _label('الاتصال'),
        _card([
          Padding(padding: const EdgeInsets.symmetric(horizontal:14, vertical:12),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Row(children: [Icon(Icons.wifi, color: BahirTheme.dim, size:18), SizedBox(width:10),
                Text('حالة الاتصال', style: TextStyle(color: BahirTheme.text, fontSize:13))]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal:10, vertical:3),
                decoration: BoxDecoration(
                  color: (state.wsOnline?BahirTheme.green:BahirTheme.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: (state.wsOnline?BahirTheme.green:BahirTheme.red).withOpacity(0.4))),
                child: Text(state.wsOnline?'متصل':'غير متصل',
                  style: TextStyle(color: state.wsOnline?BahirTheme.green:BahirTheme.red,
                    fontSize:11, fontWeight: FontWeight.w600))),
            ])),
        ]).animate(delay:150.ms).fadeIn(duration:300.ms),
        const SizedBox(height:16),
        _label('عن BAHIR'),
        _card([
          _infoRow('الإصدار','1.0.0'),
          const Divider(color: BahirTheme.border, height:1),
          _infoRow('البروتوكول','Post-Quantum E2E'),
          const Divider(color: BahirTheme.border, height:1),
          _infoRow('التشفير','Kyber-1024 + AES-GCM'),
        ]).animate(delay:200.ms).fadeIn(duration:300.ms),
        const SizedBox(height:24),
        GestureDetector(
          onTap: () => _confirmLogout(context, state),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical:14),
            decoration: BoxDecoration(
              color: BahirTheme.red.withOpacity(0.1),
              border: Border.all(color: BahirTheme.red.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(12)),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.logout, color: BahirTheme.red, size:18), SizedBox(width:8),
              Text('تسجيل الخروج وحذف الهوية',
                style: TextStyle(color: BahirTheme.red, fontWeight: FontWeight.w600, fontSize:13)),
            ]),
          ),
        ).animate(delay:250.ms).fadeIn(),
        const SizedBox(height:16),
        const Center(child: Text('BAHIR — اتصال لامركزي ومشفر',
          style: TextStyle(color: BahirTheme.border, fontSize:10))),
      ]),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom:8, right:4),
    child: Text(t, style: const TextStyle(color: BahirTheme.dim, fontSize:11, fontWeight: FontWeight.w600)));

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(color: BahirTheme.card,
      border: Border.all(color: BahirTheme.border), borderRadius: BorderRadius.circular(12)),
    child: Column(children: children));

  Widget _infoRow(String label, String value, {VoidCallback? onCopy}) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal:14, vertical:12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: BahirTheme.dim, fontSize:12)),
        Row(children: [
          Text(value, style: const TextStyle(color: BahirTheme.text, fontSize:12)),
          if (onCopy!=null) ...[const SizedBox(width:6),
            GestureDetector(onTap: onCopy,
              child: const Icon(Icons.copy_outlined, size:14, color: BahirTheme.dim))],
        ]),
      ]));

  void _confirmLogout(BuildContext context, AppState state) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: BahirTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: BahirTheme.border)),
      title: const Text('تسجيل الخروج', style: TextStyle(color: BahirTheme.text, fontSize:16)),
      content: const Text('سيتم حذف هويتك من الجهاز. تأكد من تصدير نسخة احتياطية أولاً.',
        style: TextStyle(color: BahirTheme.dim, fontSize:13)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
          child: const Text('إلغاء', style: TextStyle(color: BahirTheme.dim))),
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await state.logout();
            if (context.mounted) Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const IdentityScreen()), (_)=>false);
          },
          child: const Text('خروج', style: TextStyle(color: BahirTheme.red, fontWeight: FontWeight.w700))),
      ],
    ));
  }
}

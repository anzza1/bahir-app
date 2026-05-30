import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/app_state.dart';
import '../widgets/bahir_button.dart';
import '../widgets/toast_overlay.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nameCtrl = TextEditingController();
  final _didCtrl  = TextEditingController();
  bool _adding = false;

  Future<void> _addContact() async {
    final name=_nameCtrl.text.trim(), did=_didCtrl.text.trim();
    if (name.isEmpty || did.isEmpty) return;
    final ok = await context.read<AppState>().addContact(name, did);
    if (!mounted) return;
    if (ok) {
      _nameCtrl.clear(); _didCtrl.clear();
      setState(() => _adding=false);
      ToastOverlay.show(context, 'تمت الإضافة');
    } else { ToastOverlay.show(context, 'جهة الاتصال موجودة', isError:true); }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: BahirTheme.bg,
      appBar: AppBar(
        backgroundColor: BahirTheme.surface, elevation: 0,
        centerTitle: false, titleSpacing: 16,
        title: Row(children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [BahirTheme.blue2, BahirTheme.indigo]).createShader(b),
            child: const Text('BAHIR', style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 3, color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (state.wsOnline ? BahirTheme.green : BahirTheme.red).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: state.wsOnline ? BahirTheme.green : BahirTheme.red, width: 0.5)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width:6, height:6, decoration: BoxDecoration(
                color: state.wsOnline ? BahirTheme.green : BahirTheme.red, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(state.wsOnline ? 'متصل' : 'غير متصل',
                style: TextStyle(fontSize: 10,
                  color: state.wsOnline ? BahirTheme.green : BahirTheme.red)),
            ]),
          ),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.person_add_outlined, color: BahirTheme.dim, size: 20),
            onPressed: () => setState(() => _adding=!_adding)),
          IconButton(icon: const Icon(Icons.settings_outlined, color: BahirTheme.dim, size: 20),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()))),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
          child: Container(height:1, color: BahirTheme.border)),
      ),
      body: Column(children: [
        if (_adding)
          Container(
            padding: const EdgeInsets.all(16), margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: BahirTheme.card,
              border: Border.all(color: BahirTheme.border),
              borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('إضافة جهة اتصال',
                style: TextStyle(fontWeight: FontWeight.w700, color: BahirTheme.text, fontSize: 14)),
              const SizedBox(height: 10),
              TextField(controller: _nameCtrl, textDirection: TextDirection.rtl,
                decoration: const InputDecoration(hintText: 'الاسم')),
              const SizedBox(height: 8),
              TextField(controller: _didCtrl, textDirection: TextDirection.ltr,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(hintText: 'DID')),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: BahirButton(label: 'إضافة', onTap: _addContact)),
                const SizedBox(width: 8),
                Expanded(child: BahirButton(label: 'إلغاء',
                  onTap: () => setState(() => _adding=false), outlined: true)),
              ]),
            ]),
          ).animate().fadeIn(duration: 200.ms),
        Expanded(child: state.contacts.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.people_outline, size: 60, color: BahirTheme.border),
              const SizedBox(height: 12),
              const Text('لا توجد جهات اتصال', style: TextStyle(color: BahirTheme.dim, fontSize: 14)),
              const SizedBox(height: 20),
              BahirButton(label: '+ إضافة جهة اتصال',
                onTap: () => setState(() => _adding=true)),
            ]))
          : ListView.builder(
              itemCount: state.contacts.length,
              itemBuilder: (ctx, i) {
                final c=state.contacts[i];
                final msgs=state.messagesFor(c.did);
                final last=msgs.isNotEmpty ? msgs.last : null;
                final unread=state.unreadFor(c.did);
                return InkWell(
                  onTap: () {
                    state.clearUnread(c.did);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ChatScreen(contactDid: c.did, contactName: c.name)));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: BahirTheme.border, width: 0.5))),
                    child: Row(children: [
                      Container(width:46, height:46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [BahirTheme.accent, BahirTheme.indigo]),
                          borderRadius: BorderRadius.circular(23)),
                        child: Center(child: Text(
                          c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, color: BahirTheme.text, fontSize: 14)),
                          if (last!=null) Text(
                            '${last.ts.hour.toString().padLeft(2,'0')}:${last.ts.minute.toString().padLeft(2,'0')}',
                            style: const TextStyle(color: BahirTheme.dim, fontSize: 11)),
                        ]),
                        const SizedBox(height: 3),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Expanded(child: Text(last?.content ?? 'ابدأ المحادثة',
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: last!=null ? BahirTheme.dim : BahirTheme.border, fontSize: 12))),
                          if (unread>0) Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: BahirTheme.accent, borderRadius: BorderRadius.circular(10)),
                            child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
                        ]),
                      ])),
                    ]),
                  ),
                ).animate(delay: (i*60).ms).fadeIn().slideX(begin: -0.05);
              })),
      ]),
    );
  }
}

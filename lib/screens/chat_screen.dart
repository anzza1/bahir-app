import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../widgets/toast_overlay.dart';

class ChatScreen extends StatefulWidget {
  final String contactDid, contactName;
  const ChatScreen({super.key, required this.contactDid, required this.contactName});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => _scrollBottom()); }

  void _scrollBottom() {
    if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending=true);
    _ctrl.clear();
    await context.read<AppState>().sendMessage(widget.contactDid, text);
    if (mounted) { setState(() => _sending=false); WidgetsBinding.instance.addPostFrameCallback((_) => _scrollBottom()); }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final msgs  = state.messagesFor(widget.contactDid);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollBottom());
    return Scaffold(
      backgroundColor: BahirTheme.bg,
      appBar: AppBar(
        backgroundColor: BahirTheme.surface, elevation: 0, leadingWidth: 40,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size:18, color: BahirTheme.dim),
          onPressed: () => Navigator.pop(context)),
        title: Row(children: [
          Container(width:36, height:36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [BahirTheme.accent, BahirTheme.indigo]),
              borderRadius: BorderRadius.circular(18)),
            child: Center(child: Text(
              widget.contactName.isNotEmpty ? widget.contactName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.contactName, style: const TextStyle(color: BahirTheme.text, fontSize: 15, fontWeight: FontWeight.w600)),
            Text(widget.contactDid.length>18 ? '${widget.contactDid.substring(0,18)}...' : widget.contactDid,
              style: const TextStyle(color: BahirTheme.dim, fontSize: 10)),
          ]),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.copy_outlined, size:18, color: BahirTheme.dim),
            onPressed: () { Clipboard.setData(ClipboardData(text: widget.contactDid));
              ToastOverlay.show(context, 'تم نسخ الـ DID'); }),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
          child: Container(height:1, color: BahirTheme.border)),
      ),
      body: Column(children: [
        Expanded(child: msgs.isEmpty
          ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.lock_outline, size:40, color: BahirTheme.border),
              SizedBox(height:10),
              Text('لا توجد رسائل بعد', style: TextStyle(color: BahirTheme.dim, fontSize:13)),
              Text('رسائلك مشفرة', style: TextStyle(color: BahirTheme.border, fontSize:11)),
            ]))
          : ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal:12, vertical:8),
              itemCount: msgs.length,
              itemBuilder: (ctx, i) {
                final msg=msgs[i], prev=i>0?msgs[i-1]:null;
                final showTime=prev==null||msg.ts.difference(prev.ts).inMinutes>5;
                return Column(children: [
                  if (showTime) Padding(
                    padding: const EdgeInsets.symmetric(vertical:10),
                    child: Center(child: Container(
                      padding: const EdgeInsets.symmetric(horizontal:10, vertical:3),
                      decoration: BoxDecoration(color: BahirTheme.border.withOpacity(0.4), borderRadius: BorderRadius.circular(10)),
                      child: Text('${msg.ts.day}/${msg.ts.month}  ${msg.ts.hour.toString().padLeft(2,'0')}:${msg.ts.minute.toString().padLeft(2,'0')}',
                        style: const TextStyle(color: BahirTheme.dim, fontSize:10))))),
                  Align(
                    alignment: msg.fromMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom:6),
                      padding: const EdgeInsets.symmetric(horizontal:14, vertical:9),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.72),
                      decoration: BoxDecoration(
                        gradient: msg.fromMe ? const LinearGradient(
                          colors: [BahirTheme.accent, BahirTheme.accentDk],
                          begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                        color: msg.fromMe ? null : BahirTheme.card,
                        border: msg.fromMe ? null : Border.all(color: BahirTheme.border, width:0.5),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(14), topRight: const Radius.circular(14),
                          bottomLeft: Radius.circular(msg.fromMe?14:4), bottomRight: Radius.circular(msg.fromMe?4:14))),
                      child: Column(crossAxisAlignment: msg.fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                        Text(msg.content, textDirection: TextDirection.rtl,
                          style: const TextStyle(color: Colors.white, fontSize:14, height:1.4)),
                        const SizedBox(height:3),
                        Text('${msg.ts.hour.toString().padLeft(2,'0')}:${msg.ts.minute.toString().padLeft(2,'0')}',
                          style: TextStyle(color: msg.fromMe ? Colors.white.withOpacity(0.6) : BahirTheme.dim, fontSize:10)),
                      ]),
                    ),
                  ).animate(delay:(i*20).ms).fadeIn(duration:200.ms),
                ]);
              })),
        Container(padding: const EdgeInsets.symmetric(vertical:4), color: BahirTheme.surface,
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.lock_outline, size:11, color: BahirTheme.green),
            SizedBox(width:4),
            Text('مشفر من طرف إلى طرف', style: TextStyle(color: BahirTheme.green, fontSize:10)),
          ])),
        Container(
          padding: const EdgeInsets.fromLTRB(12,8,12,12),
          decoration: const BoxDecoration(color: BahirTheme.surface,
            border: Border(top: BorderSide(color: BahirTheme.border))),
          child: Row(children: [
            Expanded(child: TextField(controller: _ctrl, textDirection: TextDirection.rtl,
              maxLines: null, style: const TextStyle(color: BahirTheme.text, fontSize:14),
              decoration: const InputDecoration(hintText: 'اكتب رسالتك...'),
              onSubmitted: (_) => _send())),
            const SizedBox(width:8),
            GestureDetector(onTap: _send,
              child: AnimatedContainer(duration: const Duration(milliseconds:200),
                width:44, height:44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _sending
                    ? [BahirTheme.border, BahirTheme.border]
                    : [BahirTheme.accent, BahirTheme.accentDk]),
                  borderRadius: BorderRadius.circular(22)),
                child: _sending
                  ? const Padding(padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth:2, color: Colors.white))
                  : const Icon(Icons.send_rounded, color: Colors.white, size:20))),
          ]),
        ),
      ]),
    );
  }
}

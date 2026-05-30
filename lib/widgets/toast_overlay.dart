import 'package:flutter/material.dart';
import '../core/theme.dart';

class ToastOverlay {
  static void show(BuildContext context, String message, {bool isError=false}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(builder: (_) => _Toast(
      message: message, isError: isError, onDone: () => entry.remove()));
    overlay.insert(entry);
  }
}

class _Toast extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDone;
  const _Toast({required this.message, required this.isError, required this.onDone});
  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2000), () async {
      if (mounted) { await _ctrl.reverse(); widget.onDone(); }
    });
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Positioned(
    top: MediaQuery.of(context).padding.top + 60,
    left: 0, right: 0,
    child: FadeTransition(opacity: _opacity, child: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: widget.isError ? BahirTheme.red.withOpacity(0.9) : BahirTheme.green.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0,4))],
        ),
        child: Text(widget.message, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ),
    )),
  );
}

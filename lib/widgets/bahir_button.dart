import 'package:flutter/material.dart';
import '../core/theme.dart';

class BahirButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  const BahirButton({super.key, required this.label, required this.onTap, this.outlined=false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        gradient: outlined ? null : const LinearGradient(
          colors: [BahirTheme.accent, BahirTheme.accentDk],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        color: outlined ? Colors.transparent : null,
        border: outlined ? Border.all(color: BahirTheme.border) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: Text(label, style: TextStyle(
        color: outlined ? BahirTheme.dim : Colors.white,
        fontWeight: FontWeight.w600, fontSize: 14))),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BahirTheme {
  static const Color bg       = Color(0xFF060C18);
  static const Color surface  = Color(0xFF0D1626);
  static const Color card     = Color(0xFF111B2E);
  static const Color border   = Color(0xFF1E2D47);
  static const Color accent   = Color(0xFF3B82F6);
  static const Color accentDk = Color(0xFF2563EB);
  static const Color green    = Color(0xFF22C55E);
  static const Color red      = Color(0xFFEF4444);
  static const Color text     = Color(0xFFE2E8F0);
  static const Color dim      = Color(0xFF64748B);
  static const Color blue2    = Color(0xFF60A5FA);
  static const Color indigo   = Color(0xFF818CF8);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      surface: surface, primary: accent,
      onPrimary: Colors.white, onSurface: text,
    ),
    textTheme: GoogleFonts.cairoTextTheme(const TextTheme(
      bodyLarge:   TextStyle(color: text, fontSize: 14),
      bodyMedium:  TextStyle(color: text, fontSize: 13),
      bodySmall:   TextStyle(color: dim,  fontSize: 11),
      titleMedium: TextStyle(color: text, fontSize: 15, fontWeight: FontWeight.w600),
      titleLarge:  TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w700),
    )),
    dividerColor: border,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0A1322),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: accent)),
      hintStyle: const TextStyle(color: dim, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}

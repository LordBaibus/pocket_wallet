import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

const kAccent = Color(0xFFFF4A1C);
const kTile = Color(0xFF161618);
const kTileHi = Color(0xFF212125);
const kInk = Color(0xFFF4F1EE);
const kMuted = Color(0xFF8C8C94);
const kLine = Color(0x1AFFFFFF);

/// Dot-matrix display face (falls back to a mono face if unavailable).
TextStyle dot(double size, {Color color = kInk, double spacing = 1}) {
  try {
    return GoogleFonts.getFont(
      'Doto',
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w700,
      letterSpacing: spacing,
    );
  } catch (_) {
    return TextStyle(
      fontFamily: 'Courier',
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w700,
      letterSpacing: spacing,
    );
  }
}

/// Small technical label face.
TextStyle mono(double size, {Color color = kMuted, double spacing = 0.8}) {
  try {
    return GoogleFonts.getFont(
      'Space Mono',
      fontSize: size,
      color: color,
      letterSpacing: spacing,
    );
  } catch (_) {
    return TextStyle(
      fontFamily: 'Courier',
      fontSize: size,
      color: color,
      letterSpacing: spacing,
    );
  }
}

Color hexToColor(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

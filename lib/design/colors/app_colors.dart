import 'package:flutter/material.dart';
import '../themes/app_themes.dart';

class AppColors {
  // Paleta Principal
  static Color get primary =>
      AppThemes.select(const Color(0xFF9333EA), const Color(0xFFA855F7));
  static Color get primaryVariant =>
      AppThemes.select(const Color(0xFF7E22CE), const Color(0xFF9333EA));
  static Color get secondary =>
      AppThemes.select(const Color(0xFFD946EF), const Color(0xFFE879F9));
  static Color get secondaryVariant =>
      AppThemes.select(const Color(0xFFEC4899), const Color(0xFFF472B6));

  // Fondos
  static Color get background =>
      AppThemes.select(Colors.white, const Color(0xFF131524));
  static Color get backgroundAlternate =>
      AppThemes.select(const Color(0xFFFAF5FF), const Color(0xFF2A2D3A));
  static Color get backgroundGrey =>
      AppThemes.select(const Color(0xFFF9FAFB), const Color(0xFF374151));
  static Color get backgroundDisabled =>
      AppThemes.select(const Color(0xFFF3F4F6), const Color(0xFF4B5563));

  // Componentes
  static Color get appBarBackground =>
      AppThemes.select(Colors.white, const Color(0xFF131524));
  static Color get card =>
      AppThemes.select(const Color(0xFFFDFDFD), const Color(0xFF2A2D3A));
  static Color get inputBackground =>
      AppThemes.select(const Color(0xFFFAF5FF), const Color(0xFF374151));
  static Color get inputBorder =>
      AppThemes.select(const Color(0xFFE9D5FF), const Color(0xFF4B5563));
  static Color get inputFocusedBorder =>
      AppThemes.select(const Color(0xFF9333EA), const Color(0xFFA855F7));
  static Color get borderSubtle => AppThemes.select(
    const Color(0xFF1F2937).withValues(alpha: 0.08),
    Colors.transparent,
  );
  // Fondo para elementos pequeños (iconos, badges)
  static Color get surfaceElement =>
      AppThemes.select(const Color(0xFFF3F4F6), const Color(0xFF3D4150));

  // Textos
  static Color get textPrimary =>
      AppThemes.select(const Color(0xFF111827), const Color(0xFFF9FAFB));
  static Color get textSecondary =>
      AppThemes.select(const Color(0xFF4B5563), const Color(0xFFD1D5DB));
  static Color get textMuted =>
      AppThemes.select(const Color(0xFF6B7280), const Color(0xFF9CA3AF));
  static Color get textHint =>
      AppThemes.select(const Color(0xFF9CA3AF), const Color(0xFF6B7280));
  static const Color textOnPrimary = Colors.white;

  // Iconos
  static Color get icon =>
      AppThemes.select(const Color(0xFF6B7280), const Color(0xFF9CA3AF));
  static Color get iconMuted =>
      AppThemes.select(const Color(0xFF9CA3AF), const Color(0xFF6B7280));
  static const Color iconOnPrimary = Colors.white;

  // Varios
  static const Color transparent = Colors.transparent;
  static Color get shadow => AppThemes.select(
    Colors.black.withValues(alpha: 0.08),
    Colors.black.withValues(alpha: 0.2),
  );
  static Color get shadowPurple => AppThemes.select(
    const Color(0xFF9333EA).withValues(alpha: 0.08),
    const Color(0xFF9333EA).withValues(alpha: 0.15),
  );
  static Color get success =>
      AppThemes.select(const Color(0xFF10B981), const Color(0xFF34D399));
  static Color get successVariant =>
      AppThemes.select(const Color(0xFF34D399), const Color(0xFF6EE7B7));
  static Color get error =>
      AppThemes.select(const Color(0xFFEF4444), const Color(0xFFF87171));
  static Color get warning =>
      AppThemes.select(const Color(0xFFF59E0B), const Color(0xFFFBBF24));
  static Color get info =>
      AppThemes.select(const Color(0xFF3B82F6), const Color(0xFF60A5FA));
  static Color get infoVariant =>
      AppThemes.select(const Color(0xFF60A5FA), const Color(0xFF93C5FD));

  // Dinero/Ganancias
  static Color get money =>
      AppThemes.select(const Color(0xFF16A34A), const Color(0xFF22C55E));
  static Color get moneyVariant =>
      AppThemes.select(const Color(0xFF22C55E), const Color(0xFF4ADE80));
}

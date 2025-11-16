import 'package:flutter/material.dart';
import '../themes/app_themes.dart';

class StatusColors {
  // Disponible
  static Color get availableBackground => AppThemes.select(const Color(0xFFE8F5E9), const Color(0xFF1B3D1F));
  static Color get availableBorder => AppThemes.select(const Color(0xFF81C784), const Color(0xFF81C784));
  static Color get availableText => AppThemes.select(const Color(0xFF2E7D32), const Color(0xFF81C784));
  static const Color availableDot = Color(0xFF4CAF50);

  // Ocupado
  static Color get occupiedBackground => AppThemes.select(const Color(0xFFFFF3E0), const Color(0xFF4A2F0F));
  static Color get occupiedBorder => AppThemes.select(const Color(0xFFFFB74D), const Color(0xFFFD8F1E));
  static Color get occupiedText => AppThemes.select(const Color(0xFFFD8F1E), const Color(0xFFFFB74D));
  static const Color occupiedDot = Color(0xFFFF9800);

  // Reservado
  static Color get reservedBackground => AppThemes.select(const Color(0xFFE1F5FE), const Color(0xFF0D3B54));
  static Color get reservedBorder => AppThemes.select(const Color(0xFF4FC3F7), const Color(0xFF4FC3F7));
  static Color get reservedText => AppThemes.select(const Color(0xFF0277BD), const Color(0xFF4FC3F7));
  static const Color reservedDot = Color(0xFF03A9F4);

  // Pendiente
  static Color get pendingBackground => AppThemes.select(const Color(0xFFFFF3E0), const Color(0xFF4A2F0F));
  static Color get pendingBorder => AppThemes.select(const Color(0xFFFFB74D), const Color(0xFFF57C00));
  static Color get pendingText => AppThemes.select(const Color(0xFFF57C00), const Color(0xFFFFB74D));
  static const Color pendingDot = Color(0xFFFF9800);

  // Preparando
  static Color get preparingBackground => AppThemes.select(const Color(0xFFE3F2FD), const Color(0xFF0A3A61));
  static Color get preparingBorder => AppThemes.select(const Color(0xFF64B5F6), const Color(0xFF1976D2));
  static Color get preparingText => AppThemes.select(const Color(0xFF1976D2), const Color(0xFF64B5F6));
  static const Color preparingDot = Color(0xFF2196F3);

  // Completado
  static Color get readyBackground => AppThemes.select(const Color(0xFFE8F5E9), const Color(0xFF1B3D1F));
  static Color get readyBorder => AppThemes.select(const Color(0xFF81C784), const Color(0xFF388E3C));
  static Color get readyText => AppThemes.select(const Color(0xFF388E3C), const Color(0xFF81C784));
  static const Color readyDot = Color(0xFF4CAF50);

  // Entregado
  static Color get deliveredBackground => AppThemes.select(const Color(0xFFEDE7F6), const Color(0xFF2E1A47));
  static Color get deliveredBorder => AppThemes.select(const Color(0xFFBA68C8), const Color(0xFF9C27B0));
  static Color get deliveredText => AppThemes.select(const Color(0xFF7B1FA2), const Color(0xFFBA68C8));
  static const Color deliveredDot = Color(0xFF9C27B0);

  // No disponible
  static Color get unavailableBackground => AppThemes.select(Colors.red[50]!, const Color(0xFF431414));
  static Color get unavailableText => AppThemes.select(Colors.red[700]!, const Color(0xFFF87171));

  // Desconocido
  static Color get unknownBackground => AppThemes.select(Colors.grey[100]!, const Color(0xFF374151));
  static Color get unknownBorder => AppThemes.select(Colors.grey[300]!, const Color(0xFF4B5563));
  static Color get unknownText => AppThemes.select(Colors.grey[700]!, const Color(0xFFD1D5DB));
  static Color get unknownDot => AppThemes.select(Colors.grey[500]!, Colors.grey[500]!);
}
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {

  // Botón principal actualizado
  static LinearGradient get primaryButton => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: const [0.0, 0.5, 1.0],
    colors: [
      AppColors.primary,
      AppColors.secondary,
      AppColors.secondaryVariant,
    ],
  );

  // Header con gradiente
  static LinearGradient get headerText => LinearGradient(
    colors: [
      AppColors.primaryVariant,
      AppColors.secondary,
    ],
  );

  // Icono de autenticación
  static LinearGradient get authIcon => LinearGradient(
    colors: [
      AppColors.primary,
      AppColors.secondary,
    ],
  );

  // Fondo para totales
  static LinearGradient get totalAmountBackground => LinearGradient(
    colors: [
      AppColors.background,
      AppColors.background,
    ],
  );

  // Texto con gradiente
  static Paint get totalAmountText => Paint()
    ..shader = LinearGradient(
      colors: [
        AppColors.primary,
        AppColors.secondary,
      ],
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 100.0, 70.0));

  // Gradiente success
  static LinearGradient get success => LinearGradient(
    colors: [
      AppColors.success,
      AppColors.successVariant,
    ],
  );

  // Gradiente info
  static LinearGradient get info => LinearGradient(
    colors: [
      AppColors.info,
      AppColors.infoVariant,
    ],
  );
}
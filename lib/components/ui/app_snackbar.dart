import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../design/colors/app_colors.dart';
import '../../design/responsive/responsive_scaler.dart';

enum SnackbarType {
  success,
  error,
  warning,
  info,
}

class AppSnackbar {
  // Método principal simple para mostrar snackbars
  static void show({
    required BuildContext context,
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    ResponsiveScaler.init(context);

    // Obtener color según el tipo
    final Color backgroundColor = _getBackgroundColor(type);

    // Cerrar cualquier snackbar anterior
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Mostrar el nuevo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveScaler.font(14),
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(12)),
        ),
        margin: ResponsiveScaler.margin(
          const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        ),
      ),
    );
  }

  // Método rápido para éxito
  static void success(BuildContext context, String message) {
    show(context: context, message: message, type: SnackbarType.success);
  }

  // Método rápido para error
  static void error(BuildContext context, String message) {
    show(context: context, message: message, type: SnackbarType.error);
  }

  // Método rápido para advertencia
  static void warning(BuildContext context, String message) {
    show(context: context, message: message, type: SnackbarType.warning);
  }

  // Método rápido para información
  static void info(BuildContext context, String message) {
    show(context: context, message: message, type: SnackbarType.info);
  }

  // Cerrar snackbar actual
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  // Obtener color de fondo según tipo
  static Color _getBackgroundColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return AppColors.success;
      case SnackbarType.error:
        return AppColors.error;
      case SnackbarType.warning:
        return AppColors.warning;
      case SnackbarType.info:
        return AppColors.info;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../design/colors/app_colors.dart';
import '../../design/colors/app_gradients.dart';
import '../../design/responsive/responsive_scaler.dart';

enum ConfirmDialogType { delete, warning, info }

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final ConfirmDialogType type;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.type = ConfirmDialogType.warning,
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  // Muestra el diálogo y retorna true si se confirma
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    ConfirmDialogType type = ConfirmDialogType.warning,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        type: type,
      ),
    );
    return result ?? false;
  }

  // Atajo para diálogo de eliminación
  static Future<bool> showDelete(
    BuildContext context, {
    required String itemName,
    String? customMessage,
  }) {
    return show(
      context,
      title: '¿Eliminar $itemName?',
      message:
          customMessage ??
          '¿Estás seguro de eliminar este elemento? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
      type: ConfirmDialogType.delete,
    );
  }

  // Colores según el tipo de diálogo
  Color get _accentColor {
    switch (type) {
      case ConfirmDialogType.delete:
        return AppColors.error;
      case ConfirmDialogType.warning:
        return Colors.orange;
      case ConfirmDialogType.info:
        return AppColors.primary;
    }
  }

  // Icono según el tipo
  IconData get _icon {
    switch (type) {
      case ConfirmDialogType.delete:
        return Icons.delete_outline_rounded;
      case ConfirmDialogType.warning:
        return Icons.warning_amber_rounded;
      case ConfirmDialogType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: ResponsiveScaler.padding(
        const EdgeInsets.symmetric(horizontal: 24),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: ResponsiveScaler.width(340)),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.3),
              blurRadius: 30,
              offset: Offset(0, ResponsiveScaler.height(15)),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildHeader(), _buildContent(context)],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: ResponsiveScaler.padding(
        const EdgeInsets.symmetric(vertical: 24),
      ),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveScaler.radius(24)),
        ),
      ),
      child: Column(
        children: [
          // Icono
          Container(
            width: ResponsiveScaler.width(64),
            height: ResponsiveScaler.height(64),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                _icon,
                color: _accentColor,
                size: ResponsiveScaler.icon(32),
              ),
            ),
          ),
          SizedBox(height: ResponsiveScaler.height(16)),
          // Título
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(18),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: ResponsiveScaler.padding(
        const EdgeInsets.fromLTRB(24, 16, 24, 24),
      ),
      child: Column(
        children: [
          // Mensaje
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(14),
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: ResponsiveScaler.height(24)),
          // Botones
          Row(
            children: [
              // Botón cancelar
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onCancel?.call();
                    Navigator.pop(context, false);
                  },
                  child: Container(
                    padding: ResponsiveScaler.padding(
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGrey,
                      borderRadius: BorderRadius.circular(
                        ResponsiveScaler.radius(14),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cancelText,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveScaler.font(14),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveScaler.width(12)),
              // Botón confirmar
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onConfirm?.call();
                    Navigator.pop(context, true);
                  },
                  child: Container(
                    padding: ResponsiveScaler.padding(
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                    decoration: BoxDecoration(
                      gradient: type == ConfirmDialogType.delete
                          ? LinearGradient(
                              colors: [
                                AppColors.error,
                                AppColors.error.withOpacity(0.8),
                              ],
                            )
                          : AppGradients.primaryButton,
                      borderRadius: BorderRadius.circular(
                        ResponsiveScaler.radius(14),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (type == ConfirmDialogType.delete
                                      ? AppColors.error
                                      : AppColors.primary)
                                  .withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, ResponsiveScaler.height(4)),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        confirmText,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveScaler.font(14),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

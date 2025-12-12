import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/ui/app_loader.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/app_gradients.dart';
import '../../../../design/responsive/responsive_scaler.dart';
import 'cancel_preparation_dialog.dart';

class KitchenActionButtons extends StatelessWidget {
  final String orderStatus;
  final bool allItemsCompleted;
  final bool isLoading;
  final Function(String newStatus) onStatusUpdate;

  const KitchenActionButtons({
    Key? key,
    required this.orderStatus,
    required this.allItemsCompleted,
    required this.onStatusUpdate,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveScaler.padding(const EdgeInsets.all(20)),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveScaler.radius(30)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, ResponsiveScaler.height(-4)),
          ),
        ],
      ),
      child: Row(
        children: [
          if (orderStatus == 'pending')
            Expanded(
              child: _buildButton(
                onTap: isLoading ? null : () => onStatusUpdate('preparing'),
                gradient: AppGradients.info,
                text: 'Comenzar Preparación',
                shadowColor: AppColors.info.withOpacity(0.3),
              ),
            ),

          if (orderStatus == 'preparing') ...[
            Expanded(
              child: _buildButton(
                onTap: isLoading
                    ? null
                    : () => _handleCancelPreparation(context),
                text: 'Cancelar',
                color: AppColors.backgroundGrey,
                textColor: AppColors.textSecondary,
              ),
            ),
            SizedBox(width: ResponsiveScaler.width(12)),
            Expanded(
              flex: 2,
              child: _buildButton(
                onTap: (!allItemsCompleted || isLoading)
                    ? null
                    : () => onStatusUpdate('completed'),
                gradient: allItemsCompleted ? AppGradients.success : null,
                color: !allItemsCompleted ? AppColors.backgroundDisabled : null,
                text: 'Marcar como Listo',
                shadowColor: allItemsCompleted
                    ? AppColors.success.withOpacity(0.3)
                    : null,
                icon: Icons.check_circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButton({
    VoidCallback? onTap,
    required String text,
    Gradient? gradient,
    Color? color,
    Color? shadowColor,
    Color? textColor,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: ResponsiveScaler.padding(
          const EdgeInsets.symmetric(vertical: 16),
        ),
        decoration: BoxDecoration(
          gradient: gradient,
          color: color,
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(16)),
          boxShadow: shadowColor != null
              ? [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 12,
                    offset: Offset(0, ResponsiveScaler.height(4)),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? AppLoader(size: 24)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: AppColors.iconOnPrimary,
                        size: ResponsiveScaler.icon(20),
                      ),
                      SizedBox(width: ResponsiveScaler.width(8)),
                    ],
                    Text(
                      text,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveScaler.font(16),
                        fontWeight: FontWeight.bold,
                        color: textColor ?? AppColors.textOnPrimary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _handleCancelPreparation(BuildContext context) {
    CancelPreparationDialog.show(
      context,
      onConfirm: () => onStatusUpdate('pending'),
    );
  }
}

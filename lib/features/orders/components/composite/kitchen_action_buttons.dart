import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/ui/app_loader.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/app_gradients.dart';
import '../../../../design/responsive/responsive_scaler.dart';
import '../../../../utils/app_logger.dart';
import 'cancel_preparation_dialog.dart';

class KitchenActionButtons extends StatefulWidget {
  final String orderStatus;
  final bool allItemsCompleted;
  final Function(String newStatus) onStatusUpdate;

  const KitchenActionButtons({
    Key? key,
    required this.orderStatus,
    required this.allItemsCompleted,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  State<KitchenActionButtons> createState() => _KitchenActionButtonsState();
}

class _KitchenActionButtonsState extends State<KitchenActionButtons> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveSize.padding(const EdgeInsets.all(20)),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveSize.radius(30)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, ResponsiveSize.height(-4)),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón para comenzar preparación cuando el estado es "pending"
          if (widget.orderStatus == 'pending')
            Expanded(
              child: _buildButton(
                onTap: () => _handleStatusUpdate('preparing'),
                gradient: AppGradients.info,
                text: 'Comenzar Preparación',
                shadowColor: AppColors.info.withOpacity(0.3),
              ),
            ),

          // Botones cuando el estado es "preparing"
          if (widget.orderStatus == 'preparing') ...[
            Expanded(
              child: _buildButton(
                onTap: _handleCancelPreparation,
                text: 'Cancelar',
                color: AppColors.backgroundGrey,
                textColor: AppColors.textSecondary,
              ),
            ),
            SizedBox(width: ResponsiveSize.width(12)),
            Expanded(
              flex: 2,
              child: _buildButton(
                onTap: !widget.allItemsCompleted ? null : () => _handleStatusUpdate('completed'),
                gradient: widget.allItemsCompleted ? AppGradients.success : null,
                color: !widget.allItemsCompleted ? AppColors.backgroundDisabled : null,
                text: 'Marcar como Listo',
                shadowColor: widget.allItemsCompleted ? AppColors.success.withOpacity(0.3) : null,
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
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: ResponsiveSize.padding(const EdgeInsets.symmetric(vertical: 16)),
        decoration: BoxDecoration(
          gradient: gradient,
          color: color,
          borderRadius: BorderRadius.circular(ResponsiveSize.radius(16)),
          boxShadow: shadowColor != null
              ? [
            BoxShadow(
              color: shadowColor,
              blurRadius: 12,
              offset: Offset(0, ResponsiveSize.height(4)),
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
                  size: ResponsiveSize.icon(20),
                ),
                SizedBox(width: ResponsiveSize.width(8)),
              ],
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveSize.font(16),
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

  void _handleStatusUpdate(String newStatus) async {
    setState(() => isLoading = true);

    // Simulación de llamada a API
    await Future.delayed(const Duration(seconds: 2));

    setState(() => isLoading = false);

    AppLogger.log('Estado actualizado a: $newStatus', prefix: 'COCINA:');

    // Muestra mensaje de confirmación
    if (mounted) {
      String message;
      if (newStatus == 'preparing') {
        message = 'Preparación iniciada';
      } else if (newStatus == 'completed') {
        message = 'Orden marcada como completada';
      } else {
        message = 'Orden devuelta a pendiente';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.poppins()),
          backgroundColor: AppColors.success,
        ),
      );

      // Llama al callback para actualizar el estado en el padre
      widget.onStatusUpdate(newStatus);
    }
  }

  void _handleCancelPreparation() {
    CancelPreparationDialog.show(
      context,
      onConfirm: () => _handleStatusUpdate('pending'),
    );
  }
}
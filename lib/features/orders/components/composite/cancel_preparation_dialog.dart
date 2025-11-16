import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class CancelPreparationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const CancelPreparationDialog({
    Key? key,
    required this.onConfirm,
  }) : super(key: key);

  static void show(BuildContext context, {required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CancelPreparationDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveSize.radius(20)),
      ),
      title: Text(
        'Cancelar preparación',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: ResponsiveSize.font(18),
          color: AppColors.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: ResponsiveSize.icon(50),
          ),
          SizedBox(height: ResponsiveSize.height(16)),
          Text(
            '¿Estás seguro de que deseas cancelar la preparación de esta orden?',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveSize.font(14),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: EdgeInsets.only(
        left: ResponsiveSize.width(24),
        right: ResponsiveSize.width(24),
        bottom: ResponsiveSize.height(24),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: ResponsiveSize.height(12)),
                  side: BorderSide(color: AppColors.textMuted.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveSize.radius(12)),
                  ),
                ),
                child: Text(
                  'No',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveSize.width(12)),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: ResponsiveSize.height(12)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveSize.radius(12)),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Sí, cancelar',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
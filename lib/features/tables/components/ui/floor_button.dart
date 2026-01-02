import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/app_gradients.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class FloorButton extends StatelessWidget {
  final String floorId;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FloorButton({
    Key? key,
    required this.floorId,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: isSelected ? AppGradients.primaryButton : null,
            color: isSelected ? null : AppColors.backgroundGrey,
            borderRadius: BorderRadius.circular(ResponsiveScaler.radius(12)),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.shadowPurple,
                      blurRadius: 8,
                      offset: Offset(0, ResponsiveScaler.height(2)),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected
                    ? AppColors.textOnPrimary
                    : AppColors.textMuted,
                fontSize: ResponsiveScaler.font(14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

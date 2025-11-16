import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/app_gradients.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class FilterChip extends StatelessWidget {
  final String id;
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChip({
    Key? key,
    required this.id,
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: ResponsiveSize.margin(const EdgeInsets.only(right: 12)),
        padding: ResponsiveSize.padding(
          const EdgeInsets.symmetric(horizontal: 16),
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.primaryButton : null,
          color: isSelected ? null : AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(ResponsiveSize.radius(25)),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.shadowPurple,
              blurRadius: 8,
              offset: Offset(0, ResponsiveSize.height(2)),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveSize.font(14),
                color: isSelected
                    ? AppColors.textOnPrimary
                    : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count != null) ...[
              SizedBox(width: ResponsiveSize.width(6)),
              Container(
                padding: ResponsiveSize.padding(
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.background.withOpacity(0.2)
                      : AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(ResponsiveSize.radius(10)),
                ),
                child: Text(
                  count.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveSize.font(11),
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
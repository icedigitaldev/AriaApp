import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color? backgroundColor;
  final bool compact;
  final bool showBackground;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.backgroundColor,
    this.compact = false,
    this.showBackground = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? color.withOpacity(0.1);

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: ResponsiveSize.padding(
              EdgeInsets.all(compact ? 6.0 : 10.0)
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(
                ResponsiveSize.radius(compact ? 8 : 12)
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: ResponsiveSize.icon(compact ? 20 : 24),
          ),
        ),
        SizedBox(height: ResponsiveSize.height(compact ? 6 : 10)),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveSize.font(compact ? 16 : 20),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: ResponsiveSize.height(2)),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveSize.font(compact ? 10 : 12),
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (!showBackground) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: ResponsiveSize.padding(
          EdgeInsets.all(compact ? 12.0 : 16.0),
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(ResponsiveSize.radius(16)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, ResponsiveSize.height(4)),
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}
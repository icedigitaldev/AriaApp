import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class HoursStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? accentColor;

  const HoursStatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

    return Container(
      padding: ResponsiveScaler.padding(EdgeInsets.all(14)),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(ResponsiveScaler.radius(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, ResponsiveScaler.height(4)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: ResponsiveScaler.padding(EdgeInsets.all(8)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveScaler.radius(10)),
            ),
            child: Icon(icon, size: ResponsiveScaler.icon(20), color: color),
          ),
          SizedBox(height: ResponsiveScaler.height(12)),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(22),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveScaler.height(2)),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(12),
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

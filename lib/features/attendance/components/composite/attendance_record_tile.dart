import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class AttendanceRecordTile extends StatelessWidget {
  final String date;
  final String checkIn;
  final String? checkOut;
  final String totalHours;

  const AttendanceRecordTile({
    Key? key,
    required this.date,
    required this.checkIn,
    this.checkOut,
    required this.totalHours,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isActive = checkOut == null;

    return Container(
      margin: ResponsiveScaler.margin(EdgeInsets.only(bottom: 10)),
      padding: ResponsiveScaler.padding(EdgeInsets.all(14)),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(ResponsiveScaler.radius(14)),
        border: isActive
            ? Border.all(
                color: AppColors.success.withValues(alpha: 0.5),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        children: [
          // Indicador de estado
          Container(
            width: ResponsiveScaler.width(4),
            height: ResponsiveScaler.height(44),
            decoration: BoxDecoration(
              color: isActive ? AppColors.success : AppColors.primary,
              borderRadius: BorderRadius.circular(ResponsiveScaler.radius(2)),
            ),
          ),
          SizedBox(width: ResponsiveScaler.width(14)),
          // Fecha
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveScaler.font(14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: ResponsiveScaler.height(2)),
                Row(
                  children: [
                    Icon(
                      Icons.login_rounded,
                      size: ResponsiveScaler.icon(12),
                      color: AppColors.success,
                    ),
                    SizedBox(width: ResponsiveScaler.width(4)),
                    Text(
                      checkIn,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveScaler.font(12),
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(width: ResponsiveScaler.width(12)),
                    Icon(
                      Icons.logout_rounded,
                      size: ResponsiveScaler.icon(12),
                      color: checkOut != null
                          ? AppColors.error
                          : AppColors.iconMuted,
                    ),
                    SizedBox(width: ResponsiveScaler.width(4)),
                    Text(
                      checkOut ?? '--:--',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveScaler.font(12),
                        color: checkOut != null
                            ? AppColors.textMuted
                            : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Total horas
          Container(
            padding: ResponsiveScaler.padding(
              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            decoration: BoxDecoration(
              color: (isActive ? AppColors.success : AppColors.primary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveScaler.radius(8)),
            ),
            child: Text(
              isActive ? 'En turno' : totalHours,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(13),
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

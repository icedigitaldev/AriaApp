import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class TimeIndicator extends StatelessWidget {
  final DateTime orderTime;
  final DateTime? endTime;
  final String? displayTime;
  final bool showIcon;
  final bool compact;
  final int warningMinutes;

  const TimeIndicator({
    Key? key,
    required this.orderTime,
    this.endTime,
    this.displayTime,
    this.showIcon = true,
    this.compact = false,
    this.warningMinutes = 15,
  }) : super(key: key);

  String _getTimeDifference() {
    // Si hay endTime, calcular diferencia fija (tiempo de preparación)
    final referenceTime = endTime ?? DateTime.now();
    final difference = referenceTime.difference(orderTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    }
    return '${difference.inHours}h ${difference.inMinutes % 60}min';
  }

  Color _getTimeColor(String timeDiff) {
    if (timeDiff.contains('min')) {
      final minutes = int.tryParse(timeDiff.split(' ')[0]) ?? 0;
      if (minutes > warningMinutes) return AppColors.error;
    }
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final timeDiff = _getTimeDifference();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon)
              Icon(
                Icons.access_time,
                size: ResponsiveScaler.icon(compact ? 14 : 16),
                color: _getTimeColor(timeDiff),
              ),
            if (showIcon) SizedBox(width: ResponsiveScaler.width(4)),
            Text(
              timeDiff,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(compact ? 14 : 16),
                fontWeight: FontWeight.bold,
                color: _getTimeColor(timeDiff),
              ),
            ),
          ],
        ),
        if (displayTime != null)
          Text(
            displayTime!,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(compact ? 10 : 12),
              color: AppColors.textMuted,
            ),
          ),
      ],
    );
  }
}

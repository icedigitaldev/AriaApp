import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class ResendCodeSection extends StatelessWidget {
  final int resendTimer;
  final bool canResend;
  final VoidCallback onResend;

  const ResendCodeSection({
    Key? key,
    required this.resendTimer,
    required this.canResend,
    required this.onResend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '¿No recibiste el código?',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveScaler.font(15),
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: ResponsiveScaler.height(12)),
        // Animación entre timer y botón de reenvío
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: !canResend
              ? Container(
            key: const ValueKey('timer'),
            padding: ResponsiveScaler.padding(const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(ResponsiveScaler.radius(12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: ResponsiveScaler.icon(20),
                  color: AppColors.iconMuted,
                ),
                SizedBox(width: ResponsiveScaler.width(8)),
                Text(
                  'Reenviar en $resendTimer segundos',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveScaler.font(15),
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
              : TextButton(
            key: const ValueKey('resend'),
            onPressed: onResend,
            style: TextButton.styleFrom(
              padding: ResponsiveScaler.padding(const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: AppColors.primary,
                  size: ResponsiveScaler.icon(24),
                ),
                SizedBox(width: ResponsiveScaler.width(8)),
                Text(
                  'Reenviar código',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveScaler.font(16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
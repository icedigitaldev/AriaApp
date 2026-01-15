import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/app_gradients.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class ClockInButton extends StatelessWidget {
  final bool isClockedIn;
  final VoidCallback? onTap;

  const ClockInButton({Key? key, required this.isClockedIn, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ResponsiveScaler.width(140),
        height: ResponsiveScaler.width(140),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isClockedIn
              ? AppGradients.success
              : AppGradients.primaryButton,
          boxShadow: [
            BoxShadow(
              color: (isClockedIn ? AppColors.success : AppColors.primary)
                  .withValues(alpha: 0.4),
              blurRadius: 24,
              offset: Offset(0, ResponsiveScaler.height(8)),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isClockedIn ? Icons.logout_rounded : Icons.login_rounded,
              size: ResponsiveScaler.icon(48),
              color: Colors.white,
            ),
            SizedBox(height: ResponsiveScaler.height(8)),
            Text(
              isClockedIn ? 'Salir' : 'Entrar',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(16),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

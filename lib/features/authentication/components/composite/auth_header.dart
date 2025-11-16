import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/app_gradients.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class AuthHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? phoneNumber;

  const AuthHeader({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icono principal con animación Hero
        Hero(
          tag: 'auth-icon',
          child: Container(
            width: ResponsiveSize.width(100),
            height: ResponsiveSize.height(100),
            decoration: BoxDecoration(
              gradient: AppGradients.authIcon,
              borderRadius: BorderRadius.circular(ResponsiveSize.radius(30)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowPurple,
                  blurRadius: 30,
                  offset: Offset(0, ResponsiveSize.height(15)),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.iconOnPrimary,
              size: ResponsiveSize.icon(50),
            ),
          ),
        ),
        SizedBox(height: ResponsiveSize.height(32)),
        // Título con gradiente
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveSize.font(32),
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = AppGradients.headerText
                  .createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
          ),
        ),
        SizedBox(height: ResponsiveSize.height(12)),
        // Subtítulo descriptivo
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveSize.font(17),
            color: AppColors.textSecondary,
            height: 1.5,
            letterSpacing: 0.3,
          ),
        ),
        // Número de teléfono opcional
        if (phoneNumber != null) ...[
          SizedBox(height: ResponsiveSize.height(8)),
          Container(
            padding: ResponsiveSize.padding(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveSize.radius(12)),
            ),
            child: Text(
              phoneNumber!,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveSize.font(18),
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
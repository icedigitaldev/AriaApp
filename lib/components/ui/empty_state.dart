import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../design/colors/app_colors.dart';
import '../../design/responsive/responsive_scaler.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveScaler.padding(
          const EdgeInsets.symmetric(horizontal: 32),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Contenedor del icono con sombra difusa
            Container(
              width: ResponsiveScaler.width(100),
              height: ResponsiveScaler.height(100),
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: ResponsiveScaler.icon(42),
                color: AppColors.iconMuted,
              ),
            ),

            SizedBox(height: ResponsiveScaler.height(28)),

            // Titulo principal
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(20),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: ResponsiveScaler.height(10)),

            // Descripcion secundaria
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(14),
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

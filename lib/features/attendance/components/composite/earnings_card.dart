import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class EarningsCard extends StatelessWidget {
  final String label;
  final double amount;

  const EarningsCard({Key? key, required this.label, required this.amount})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveScaler.padding(EdgeInsets.all(16)),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(ResponsiveScaler.radius(16)),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
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
          // Icono y Label en row superior para ahorrar espacio vertical si es necesario
          // O mantener estructura limpia
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: ResponsiveScaler.padding(EdgeInsets.all(8)),
                decoration: BoxDecoration(
                  color: AppColors.money.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveScaler.radius(10),
                  ),
                ),
                child: Icon(
                  Icons.attach_money_rounded,
                  size: ResponsiveScaler.icon(20),
                  color: AppColors.money,
                ),
              ),
              // Label sutil a la derecha
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveScaler.font(12),
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveScaler.height(12)),

          // Monto (Principal)
          Text(
            'S/ ${amount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(22),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

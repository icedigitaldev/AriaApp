import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/status_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class TableCard extends StatelessWidget {
  final Map<String, dynamic> table;
  final VoidCallback onTap;
  final bool isLeftColumn;

  const TableCard({
    Key? key,
    required this.table,
    required this.onTap,
    required this.isLeftColumn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = table['status'];
    final statusConfig = _getStatusConfig(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: ResponsiveScaler.height(140),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(0.9),
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, ResponsiveScaler.height(4)),
            ),
          ],
        ),
        child: Row(
          children: [
            if (isLeftColumn)
              Container(
                width: ResponsiveScaler.width(24),
                decoration: BoxDecoration(
                  color: statusConfig['borderColor'],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ResponsiveScaler.radius(20)),
                    bottomLeft: Radius.circular(ResponsiveScaler.radius(20)),
                  ),
                ),
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      statusConfig['text']!,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveScaler.font(10),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: ResponsiveScaler.width(isLeftColumn ? 12 : 16),
                  right: ResponsiveScaler.width(!isLeftColumn ? 12 : 16),
                  top: ResponsiveScaler.height(20),
                  bottom: ResponsiveScaler.height(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: ResponsiveScaler.height(2)),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: ResponsiveScaler.icon(32),
                          color: statusConfig['iconColor'] ?? AppColors.iconMuted,
                        ),
                        SizedBox(height: ResponsiveScaler.height(8)),
                        Text(
                          'Mesa ${table['number']}',
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveScaler.font(22),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveScaler.height(8)),
                    _buildBottomInfo(statusConfig),
                  ],
                ),
              ),
            ),
            if (!isLeftColumn)
              Container(
                width: ResponsiveScaler.width(24),
                decoration: BoxDecoration(
                  color: statusConfig['borderColor'],
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(ResponsiveScaler.radius(20)),
                    bottomRight: Radius.circular(ResponsiveScaler.radius(20)),
                  ),
                ),
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      statusConfig['text']!,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveScaler.font(10),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInfo(Map<String, dynamic> statusConfig) {
    if (table['status'] == 'occupied' && table['orderTotal'] != null) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveScaler.width(10),
          vertical: ResponsiveScaler.height(6),
        ),
        decoration: BoxDecoration(
          color: statusConfig['textColor']?.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_money,
              size: ResponsiveScaler.icon(16),
              color: statusConfig['textColor'],
            ),
            Text(
              '${table['orderTotal'].toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(16),
                fontWeight: FontWeight.w600,
                color: statusConfig['textColor'],
                height: 1.1,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.people,
          size: ResponsiveScaler.icon(14),
          color: AppColors.textMuted,
        ),
        SizedBox(width: ResponsiveScaler.width(6)),
        Text(
          '${table['capacity']} personas',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveScaler.font(12),
            color: AppColors.textMuted,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'available':
        return {
          'borderColor': StatusColors.availableBorder,
          'textColor': StatusColors.availableText,
          'iconColor': StatusColors.availableText,
          'text': 'DISPONIBLE',
        };
      case 'occupied':
        return {
          'borderColor': StatusColors.occupiedBorder,
          'textColor': StatusColors.occupiedText,
          'iconColor': StatusColors.occupiedText,
          'text': 'OCUPADA',
        };
      case 'reserved':
        return {
          'borderColor': StatusColors.reservedBorder,
          'textColor': StatusColors.reservedText,
          'iconColor': StatusColors.reservedText,
          'text': 'RESERVADA',
        };
      default:
        return {
          'borderColor': StatusColors.unknownBorder,
          'textColor': StatusColors.unknownText,
          'iconColor': AppColors.textMuted,
          'text': 'DESCONOCIDO',
        };
    }
  }
}
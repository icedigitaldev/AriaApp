import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class InfoChip extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color color;

  const InfoChip({
    Key? key,
    this.icon,
    required this.text,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveScaler.padding(
        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveScaler.radius(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: ResponsiveScaler.icon(12), color: color),
            SizedBox(width: ResponsiveScaler.width(4)),
          ],
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(12),
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
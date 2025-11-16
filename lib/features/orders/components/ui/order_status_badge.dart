import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/status_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;
  final bool showDot;
  final bool compact;

  const OrderStatusBadge({
    Key? key,
    required this.status,
    this.showDot = true,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: ResponsiveSize.padding(
        EdgeInsets.symmetric(
          horizontal: compact ? 8.0 : 12.0,
          vertical: compact ? 4.0 : 6.0,
        ),
      ),
      decoration: BoxDecoration(
        color: config['backgroundColor'],
        borderRadius: BorderRadius.circular(ResponsiveSize.radius(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: ResponsiveSize.width(8),
              height: ResponsiveSize.height(8),
              decoration: BoxDecoration(
                color: config['dotColor'],
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: ResponsiveSize.width(6)),
          ],
          Text(
            config['text']!,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveSize.font(compact ? 11 : 12),
              fontWeight: FontWeight.w600,
              color: config['textColor'],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'pending':
        return {
          'backgroundColor': StatusColors.pendingBackground,
          'textColor': StatusColors.pendingText,
          'dotColor': StatusColors.pendingDot,
          'text': 'Pendiente'
        };
      case 'preparing':
        return {
          'backgroundColor': StatusColors.preparingBackground,
          'textColor': StatusColors.preparingText,
          'dotColor': StatusColors.preparingDot,
          'text': 'Preparando'
        };
      case 'completed':
        return {
          'backgroundColor': StatusColors.readyBackground,
          'textColor': StatusColors.readyText,
          'dotColor': StatusColors.readyDot,
          'text': 'Listo'
        };
      case 'delivered':
        return {
          'backgroundColor': StatusColors.deliveredBackground,
          'textColor': StatusColors.deliveredText,
          'dotColor': StatusColors.deliveredDot,
          'text': 'Entregado'
        };
      default:
        return {
          'backgroundColor': StatusColors.unknownBackground,
          'textColor': StatusColors.unknownText,
          'dotColor': StatusColors.unknownDot,
          'text': 'Desconocido'
        };
    }
  }
}
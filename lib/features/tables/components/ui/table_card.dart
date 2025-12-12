import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/status_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class TableCard extends StatefulWidget {
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
  State<TableCard> createState() => _TableCardState();
}

class _TableCardState extends State<TableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    // Controlador para animación de glow pulsante
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(TableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimation();
  }

  void _updateAnimation() {
    final orderStatus = widget.table['orderStatus']?.toString();
    if (orderStatus == 'completed') {
      _glowController.repeat(reverse: true);
    } else {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.table['status'];
    final orderStatus = widget.table['orderStatus']?.toString();
    final statusConfig = _getStatusConfig(status);
    final isReadyToServe = orderStatus == 'completed';

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          final glowValue = _glowAnimation.value;
          return Container(
            height: ResponsiveScaler.height(140),
            decoration: BoxDecoration(
              color: AppColors.card.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(ResponsiveScaler.radius(20)),
              border: isReadyToServe
                  ? Border.all(
                      color: StatusColors.readyDot.withValues(alpha: glowValue),
                      width: 2.5,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: Offset(0, ResponsiveScaler.height(4)),
                ),
                // Glow pulsante cuando está listo
                if (isReadyToServe)
                  BoxShadow(
                    color: StatusColors.readyDot.withValues(
                      alpha: glowValue * 0.5,
                    ),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: child,
          );
        },
        child: Row(
          children: [
            if (widget.isLeftColumn)
              Container(
                width: ResponsiveScaler.width(24),
                decoration: BoxDecoration(
                  color: statusConfig['borderColor'],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ResponsiveScaler.radius(18)),
                    bottomLeft: Radius.circular(ResponsiveScaler.radius(18)),
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
                  left: ResponsiveScaler.width(widget.isLeftColumn ? 12 : 16),
                  right: ResponsiveScaler.width(!widget.isLeftColumn ? 12 : 16),
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
                          color:
                              statusConfig['iconColor'] ?? AppColors.iconMuted,
                        ),
                        SizedBox(height: ResponsiveScaler.height(8)),
                        Text(
                          'Mesa ${widget.table['number']}',
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
            if (!widget.isLeftColumn)
              Container(
                width: ResponsiveScaler.width(24),
                decoration: BoxDecoration(
                  color: statusConfig['borderColor'],
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(ResponsiveScaler.radius(18)),
                    bottomRight: Radius.circular(ResponsiveScaler.radius(18)),
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
    final orderStatus = widget.table['orderStatus']?.toString();

    // Orden en preparación
    if (widget.table['status'] == 'occupied' && orderStatus == 'preparing') {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveScaler.width(10),
          vertical: ResponsiveScaler.height(6),
        ),
        decoration: BoxDecoration(
          color: StatusColors.preparingBackground,
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: ResponsiveScaler.width(12),
              height: ResponsiveScaler.height(12),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  StatusColors.preparingText,
                ),
              ),
            ),
            SizedBox(width: ResponsiveScaler.width(6)),
            Text(
              'Preparando',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(11),
                fontWeight: FontWeight.w500,
                color: StatusColors.preparingText,
              ),
            ),
          ],
        ),
      );
    }

    // Total de orden si existe
    if (widget.table['status'] == 'occupied' &&
        widget.table['orderTotal'] != null) {
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
              '${widget.table['orderTotal'].toStringAsFixed(2)}',
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
          '${widget.table['capacity']} personas',
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

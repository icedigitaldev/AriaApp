import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/status_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';
import '../ui/order_status_badge.dart';
import '../ui/order_item_tile.dart';
import '../ui/time_indicator.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;
  final bool showWaiterInfo;
  final bool showTableNumber;
  final bool showTimer;
  final bool showItems;
  final int maxItemsToShow;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onTap,
    this.showWaiterInfo = true,
    this.showTableNumber = true,
    this.showTimer = true,
    this.showItems = true,
    this.maxItemsToShow = 3,
  }) : super(key: key);

  Color _getStatusBorderColor(String status) {
    switch (status) {
      case 'pending': return StatusColors.pendingBorder;
      case 'preparing': return StatusColors.preparingBorder;
      case 'ready': return StatusColors.readyBorder;
      default: return StatusColors.unknownBorder;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'pending': return StatusColors.pendingBackground;
      case 'preparing': return StatusColors.preparingBackground;
      case 'ready': return StatusColors.readyBackground;
      default: return StatusColors.unknownBackground;
    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: ResponsiveScaler.margin(const EdgeInsets.only(bottom: 16)),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(20)),
          border: Border.all(
            color: _getStatusBorderColor(order['status']),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, ResponsiveScaler.height(4)),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            if (showItems || showWaiterInfo) _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: ResponsiveScaler.padding(const EdgeInsets.all(16)),
      decoration: BoxDecoration(
        color: _getStatusBackgroundColor(order['status']).withOpacity(0.3),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveScaler.radius(18)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              OrderStatusBadge(status: order['status']),
              if (showTableNumber) ...[
                SizedBox(width: ResponsiveScaler.width(12)),
                Text(
                  'Mesa ${order['tableNumber']}',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveScaler.font(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
          if (showTimer && order['orderTime'] != null)
            TimeIndicator(
              orderTime: order['orderTime'],
              displayTime: order['time'],
              compact: true,
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final items = order['items'] as List;
    final itemsToShow = items.take(maxItemsToShow).toList();
    final remainingItems = items.length - maxItemsToShow;

    return Padding(
      padding: ResponsiveScaler.padding(const EdgeInsets.all(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showWaiterInfo && order['waiter'] != null)
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: ResponsiveScaler.icon(16),
                  color: AppColors.iconMuted,
                ),
                SizedBox(width: ResponsiveScaler.width(4)),
                Text(
                  order['waiter'],
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveScaler.font(14),
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          if (showWaiterInfo && showItems)
            SizedBox(height: ResponsiveScaler.height(12)),
          if (showItems) ...[
            ...itemsToShow.map<Widget>(
                  (item) => OrderItemTile(
                item: item,
                compact: true,
              ),
            ).toList(),
            if (remainingItems > 0)
              Container(
                padding: ResponsiveScaler.padding(
                  const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  '+ $remainingItems elementos más',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveScaler.font(14),
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
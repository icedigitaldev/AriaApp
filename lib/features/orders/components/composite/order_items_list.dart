import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/app_gradients.dart';
import '../../../../design/colors/status_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';
import '../ui/order_item_tile.dart';

class OrderItemsList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool showCheckboxes;
  final bool showNotes;
  final bool showPrice;
  final Function(int, bool)? onItemChecked;
  final Map<int, bool> itemStatus;
  final String orderStatus;

  const OrderItemsList({
    Key? key,
    required this.items,
    this.showCheckboxes = false,
    this.showNotes = true,
    this.showPrice = false,
    this.onItemChecked,
    this.itemStatus = const {},
    required this.orderStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOrderFinalized = orderStatus == 'completed';

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isCompleted = itemStatus[index] ?? false;

        if (!showCheckboxes) {
          return OrderItemTile(
            item: item,
            showPrice: showPrice,
          );
        }

        Color getBorderColor() {
          if (!isCompleted) return AppColors.inputBorder;
          if (isOrderFinalized) return StatusColors.readyBorder; // Verde
          return AppColors.info; // Azul
        }

        Gradient getQuantityGradient() {
          if (!isCompleted) return AppGradients.totalAmountBackground;
          if (isOrderFinalized) return AppGradients.success; // Verde
          return AppGradients.info; // Azul
        }

        Color getCheckIconColor() {
          if (!isCompleted) return AppColors.iconMuted;
          if (isOrderFinalized) return StatusColors.readyDot; // Verde
          return AppColors.info; // Azul
        }

        return Container(
          margin: ResponsiveSize.margin(const EdgeInsets.only(bottom: 16)),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(ResponsiveSize.radius(16)),
            border: Border.all(
              color: getBorderColor(),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, ResponsiveSize.height(4)),
              ),
            ],
          ),
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: isOrderFinalized ? null : () { // Bloquea el tap si la orden está finalizada
                onItemChecked?.call(index, !isCompleted);
              },
              borderRadius: BorderRadius.circular(ResponsiveSize.radius(16)),
              child: Padding(
                padding: ResponsiveSize.padding(const EdgeInsets.all(16)),
                child: Row(
                  children: [
                    Container(
                      width: ResponsiveSize.width(48),
                      height: ResponsiveSize.height(48),
                      decoration: BoxDecoration(
                        gradient: getQuantityGradient(),
                        borderRadius: BorderRadius.circular(ResponsiveSize.radius(12)),
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                          Icons.check,
                          color: AppColors.iconOnPrimary,
                          size: ResponsiveSize.icon(24),
                        )
                            : Text(
                          item['quantity'].toString(),
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveSize.font(20),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveSize.width(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveSize.font(18),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: AppColors.textMuted,
                            ),
                          ),
                          if (showNotes &&
                              item['notes'] != null &&
                              item['notes'].toString().isNotEmpty) ...[
                            SizedBox(height: ResponsiveSize.height(4)),
                            Container(
                              padding: ResponsiveSize.padding(
                                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              decoration: BoxDecoration(
                                color: StatusColors.pendingBackground,
                                borderRadius: BorderRadius.circular(ResponsiveSize.radius(8)),
                                border: Border.all(color: StatusColors.pendingBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: ResponsiveSize.icon(16),
                                    color: StatusColors.pendingText,
                                  ),
                                  SizedBox(width: ResponsiveSize.width(6)),
                                  Text(
                                    item['notes'],
                                    style: GoogleFonts.poppins(
                                      fontSize: ResponsiveSize.font(14),
                                      color: StatusColors.pendingText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (showPrice && item['price'] != null)
                            Text(
                              '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveSize.font(14),
                                color: AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: getCheckIconColor(),
                      size: ResponsiveSize.icon(28),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
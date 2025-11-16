import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class OrderItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool compact;
  final bool showImage;
  final bool showPrice;
  final VoidCallback? onTap;
  final Widget? trailing;

  const OrderItemTile({
    Key? key,
    required this.item,
    this.compact = false,
    this.showImage = false,
    this.showPrice = false,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: ResponsiveSize.margin(
          EdgeInsets.only(bottom: compact ? 8.0 : 12.0),
        ),
        padding: ResponsiveSize.padding(
          EdgeInsets.all(compact ? 10.0 : 12.0),
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(ResponsiveSize.radius(12)),
        ),
        child: Row(
          children: [
            // Imagen opcional
            if (showImage && item['image'] != null) ...[
              Container(
                width: ResponsiveSize.width(50),
                height: ResponsiveSize.height(50),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ResponsiveSize.radius(8)),
                  image: DecorationImage(
                    image: NetworkImage(item['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: ResponsiveSize.width(12)),
            ],

            // Cantidad
            Container(
              width: ResponsiveSize.width(compact ? 28 : 32),
              height: ResponsiveSize.height(compact ? 28 : 32),
              decoration: BoxDecoration(
                color: AppColors.backgroundAlternate,
                borderRadius: BorderRadius.circular(ResponsiveSize.radius(8)),
              ),
              child: Center(
                child: Text(
                  item['quantity'].toString(),
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveSize.font(compact ? 14 : 16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveSize.width(12)),

            // Información del item
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveSize.font(compact ? 14 : 16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item['notes'] != null && item['notes'].toString().isNotEmpty)
                    Text(
                      item['notes'],
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveSize.font(compact ? 12 : 14),
                        color: AppColors.warning,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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

            // Widget personalizado al final
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
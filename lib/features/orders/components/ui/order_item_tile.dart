import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/ui/cached_network_image.dart';
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
        margin: ResponsiveScaler.margin(
          EdgeInsets.only(bottom: compact ? 8.0 : 12.0),
        ),
        padding: ResponsiveScaler.padding(
          EdgeInsets.all(compact ? 10.0 : 12.0),
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(12)),
        ),
        child: Row(
          children: [
            // Imagen opcional usando CachedNetworkImage
            if (showImage && item['image'] != null) ...[
              CachedNetworkImage(
                imageUrl: item['image'],
                width: ResponsiveScaler.width(50),
                height: ResponsiveScaler.height(50),
                borderRadius: BorderRadius.circular(ResponsiveScaler.radius(8)),
                placeholder: Container(
                  width: ResponsiveScaler.width(50),
                  height: ResponsiveScaler.height(50),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundAlternate,
                    borderRadius: BorderRadius.circular(
                      ResponsiveScaler.radius(8),
                    ),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                errorWidget: Container(
                  width: ResponsiveScaler.width(50),
                  height: ResponsiveScaler.height(50),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundAlternate,
                    borderRadius: BorderRadius.circular(
                      ResponsiveScaler.radius(8),
                    ),
                  ),
                  child: Icon(
                    Icons.image_not_supported,
                    color: AppColors.iconMuted,
                    size: ResponsiveScaler.icon(20),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveScaler.width(12)),
            ],

            // Cantidad
            Container(
              width: ResponsiveScaler.width(compact ? 28 : 32),
              height: ResponsiveScaler.height(compact ? 28 : 32),
              decoration: BoxDecoration(
                color: AppColors.backgroundAlternate,
                borderRadius: BorderRadius.circular(ResponsiveScaler.radius(8)),
              ),
              child: Center(
                child: Text(
                  item['quantity'].toString(),
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveScaler.font(compact ? 14 : 16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveScaler.width(12)),

            // Información del item
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveScaler.font(compact ? 14 : 16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item['notes'] != null &&
                      item['notes'].toString().isNotEmpty)
                    Text(
                      item['notes'],
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveScaler.font(compact ? 12 : 14),
                        color: AppColors.warning,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  if (showPrice && item['price'] != null)
                    Text(
                      '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveScaler.font(14),
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

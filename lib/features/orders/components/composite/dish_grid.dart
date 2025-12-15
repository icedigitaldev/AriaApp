import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ice_storage/ice_storage.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/app_gradients.dart';
import '../../../../design/colors/status_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';
import 'customer_name_sheet.dart';
import 'variant_selection_sheet.dart';

class DishGrid extends StatelessWidget {
  final List<Map<String, dynamic>> dishes;
  final Map<int, int> orderQuantities;
  final Function(Map<String, dynamic>) onAddDish;
  final Function(int, int) onUpdateQuantity;
  final Function(Map<String, dynamic> orderItem)? onAddVariantItem;
  final bool showRating;
  final bool showCategory;
  final double bottomPadding;

  const DishGrid({
    Key? key,
    required this.dishes,
    required this.orderQuantities,
    required this.onAddDish,
    required this.onUpdateQuantity,
    this.onAddVariantItem,
    this.showRating = true,
    this.showCategory = true,
    this.bottomPadding = 100,
  }) : super(key: key);

  // Formatea el precio considerando variantes
  String _formatPrice(Map<String, dynamic> dish) {
    final hasVariants = dish['hasVariants'] == true;
    final variants = dish['variants'] as List<dynamic>?;

    if (hasVariants && variants != null && variants.isNotEmpty) {
      // Obtener precios de las variantes
      final prices = variants
          .map((v) => (v['price'] as num?)?.toDouble() ?? 0.0)
          .where((p) => p > 0)
          .toList();

      if (prices.isEmpty) return 'S/ --';

      prices.sort();
      if (prices.length == 1) {
        return 'S/ ${prices.first.toStringAsFixed(2)}';
      }
      // Mostrar rango de precios
      return 'S/ ${prices.first.toStringAsFixed(2)} - ${prices.last.toStringAsFixed(2)}';
    }

    // Precio único
    final price = (dish['price'] as num?)?.toDouble();
    if (price == null) return 'S/ --';
    return 'S/ ${price.toStringAsFixed(2)}';
  }

  // Obtiene imagen desde caché o la descarga
  Future<Uint8List?> _getCachedImage(String url) async {
    final isCached = await IceStorage.instance.images.isImageCached(url);
    if (isCached) {
      return await IceStorage.instance.images.getCachedImage(url);
    }
    return await IceStorage.instance.images.downloadAndCacheImage(url);
  }

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      padding: ResponsiveScaler.padding(
        EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
      ),
      crossAxisCount: 2,
      mainAxisSpacing: ResponsiveScaler.height(16),
      crossAxisSpacing: ResponsiveScaler.width(16),
      itemCount: dishes.length,
      itemBuilder: (context, index) {
        final dish = dishes[index];
        final quantity = orderQuantities[dish['id']] ?? 0;
        return _buildDishCard(context, dish, quantity);
      },
    );
  }

  Widget _buildDishCard(
    BuildContext context,
    Map<String, dynamic> dish,
    int quantity,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(ResponsiveScaler.radius(20)),
        border: Border.all(color: AppColors.inputBorder),
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
          _buildDishImage(dish),
          _buildDishContent(context, dish, quantity),
        ],
      ),
    );
  }

  Widget _buildDishImage(Map<String, dynamic> dish) {
    final imageUrl = dish['imageUrl'] ?? dish['image'];
    final hasImage = imageUrl != null && imageUrl.toString().isNotEmpty;

    final borderRadius = BorderRadius.vertical(
      top: Radius.circular(ResponsiveScaler.radius(20)),
    );

    // Widget placeholder/error
    Widget placeholderIcon = Center(
      child: Icon(
        Icons.restaurant,
        size: ResponsiveScaler.icon(48),
        color: AppColors.iconMuted,
      ),
    );

    return Stack(
      children: [
        Container(
          height: ResponsiveScaler.height(140),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: AppColors.backgroundGrey,
          ),
          child: hasImage
              ? FutureBuilder<Uint8List?>(
                  future: _getCachedImage(imageUrl),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(
                          width: ResponsiveScaler.width(20),
                          height: ResponsiveScaler.width(20),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      return placeholderIcon;
                    }
                    return ClipRRect(
                      borderRadius: borderRadius,
                      child: Image.memory(
                        snapshot.data!,
                        width: double.infinity,
                        height: ResponsiveScaler.height(140),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                )
              : placeholderIcon,
        ),
        if (showRating && dish['rating'] != null)
          Positioned(
            bottom: ResponsiveScaler.height(10),
            left: ResponsiveScaler.width(10),
            child: Container(
              padding: ResponsiveScaler.padding(
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(
                  ResponsiveScaler.radius(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: ResponsiveScaler.icon(14),
                  ),
                  SizedBox(width: ResponsiveScaler.width(4)),
                  Text(
                    dish['rating'].toString(),
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveScaler.font(12),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDishContent(
    BuildContext context,
    Map<String, dynamic> dish,
    int quantity,
  ) {
    return Padding(
      padding: ResponsiveScaler.padding(const EdgeInsets.all(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dish['name'],
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(16),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (dish['description'] != null) ...[
            SizedBox(height: ResponsiveScaler.height(4)),
            Text(
              dish['description'],
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(12),
                color: AppColors.textMuted,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (showCategory && dish['category'] != null) ...[
            SizedBox(height: ResponsiveScaler.height(8)),
            Container(
              padding: ResponsiveScaler.padding(
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(
                  ResponsiveScaler.radius(12),
                ),
              ),
              child: Text(
                dish['category'],
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveScaler.font(10),
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
          SizedBox(height: ResponsiveScaler.height(12)),
          Text(
            _formatPrice(dish),
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(18),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveScaler.height(12)),
          _buildActionButton(context, dish, quantity),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    Map<String, dynamic> dish,
    int quantity,
  ) {
    if (dish['status'] == 'unavailable') {
      return Container(
        padding: ResponsiveScaler.padding(
          const EdgeInsets.symmetric(vertical: 12),
        ),
        decoration: BoxDecoration(
          color: StatusColors.unavailableBackground,
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(12)),
        ),
        child: Center(
          child: Text(
            'No disponible',
            style: GoogleFonts.poppins(
              color: StatusColors.unavailableText,
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveScaler.font(14),
            ),
          ),
        ),
      );
    }

    if (quantity == 0) {
      final hasVariants = dish['hasVariants'] == true;
      return GestureDetector(
        onTap: () {
          if (hasVariants && onAddVariantItem != null) {
            VariantSelectionSheet.show(
              context,
              dish: dish,
              onAddToOrder: onAddVariantItem!,
            );
          } else if (onAddVariantItem != null) {
            // Plato sin variantes - mostrar sheet para nombre cliente
            CustomerNameSheet.show(
              context,
              dish: dish,
              onAddToOrder: onAddVariantItem!,
            );
          } else {
            onAddDish(dish);
          }
        },
        child: Container(
          padding: ResponsiveScaler.padding(
            const EdgeInsets.symmetric(vertical: 12),
          ),
          decoration: BoxDecoration(
            gradient: AppGradients.primaryButton,
            borderRadius: BorderRadius.circular(ResponsiveScaler.radius(12)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, ResponsiveScaler.height(2)),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Agregar',
              style: GoogleFonts.poppins(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveScaler.font(14),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundAlternate,
        borderRadius: BorderRadius.circular(ResponsiveScaler.radius(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => onUpdateQuantity(dish['id'], quantity - 1),
            icon: Icon(
              Icons.remove,
              size: ResponsiveScaler.icon(20),
              color: AppColors.primary,
            ),
          ),
          Text(
            quantity.toString(),
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(16),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          IconButton(
            onPressed: () => onUpdateQuantity(dish['id'], quantity + 1),
            icon: Icon(
              Icons.add,
              size: ResponsiveScaler.icon(20),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

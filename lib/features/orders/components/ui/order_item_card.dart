import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/ui/cached_network_image.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class OrderItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDismissed;

  const OrderItemCard({
    Key? key,
    required this.item,
    required this.index,
    required this.isExpanded,
    required this.onTap,
    required this.onDecrement,
    required this.onIncrement,
    required this.onDismissed,
  }) : super(key: key);

  String _formatItemPrice() {
    final variantPrice = item['variantPrice'];
    final price = item['price'];
    final quantity = item['quantity'] ?? 1;

    double itemPrice = 0.0;
    if (variantPrice != null) {
      itemPrice = (variantPrice as num).toDouble();
    } else if (price != null) {
      itemPrice = (price as num).toDouble();
    }

    final variantName = item['variantName'];

    String text = 'S/ ${itemPrice.toStringAsFixed(2)} x $quantity';
    if (variantName != null && variantName.toString().isNotEmpty) {
      text = '$variantName - $text';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final itemId = item['id']?.toString() ?? index.toString();
    final imageUrl = item['dishImage'] ?? item['imageUrl'] ?? item['image'];
    final hasImage = imageUrl != null && imageUrl.toString().isNotEmpty;
    final borderRadius = BorderRadius.circular(ResponsiveScaler.radius(12));

    return Dismissible(
      key: Key('$itemId-$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: ResponsiveScaler.margin(const EdgeInsets.only(bottom: 12)),
        padding: ResponsiveScaler.padding(const EdgeInsets.only(right: 20)),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(16)),
        ),
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: ResponsiveScaler.icon(28),
        ),
      ),
      onDismissed: (direction) => onDismissed(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: ResponsiveScaler.margin(const EdgeInsets.only(bottom: 12)),
          padding: ResponsiveScaler.padding(const EdgeInsets.all(12)),
          decoration: BoxDecoration(
            color: isExpanded
                ? AppColors.backgroundAlternate
                : AppColors.backgroundGrey,
            borderRadius: BorderRadius.circular(ResponsiveScaler.radius(16)),
            border: isExpanded
                ? Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  )
                : null,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildImage(imageUrl, hasImage, borderRadius),
                  Expanded(child: _buildItemInfo()),
                  _buildQuantityControls(),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.iconMuted,
                    size: ResponsiveScaler.icon(22),
                  ),
                ],
              ),
              if (isExpanded) _buildExpandedDetails(),
            ],
          ),
        ),
      ),
    );
  }

  // Imagen del producto
  Widget _buildImage(
    String? imageUrl,
    bool hasImage,
    BorderRadius borderRadius,
  ) {
    return Container(
      width: ResponsiveScaler.width(56),
      height: ResponsiveScaler.height(56),
      margin: ResponsiveScaler.margin(const EdgeInsets.only(right: 12)),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: AppColors.inputBorder,
      ),
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              width: ResponsiveScaler.width(56),
              height: ResponsiveScaler.height(56),
              borderRadius: borderRadius,
              placeholder: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              errorWidget: Icon(
                Icons.restaurant,
                color: AppColors.iconMuted,
                size: ResponsiveScaler.icon(22),
              ),
            )
          : Icon(
              Icons.restaurant,
              color: AppColors.iconMuted,
              size: ResponsiveScaler.icon(22),
            ),
    );
  }

  // Información del producto
  Widget _buildItemInfo() {
    return SizedBox(
      height: ResponsiveScaler.height(56),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['dishName'] ?? item['name'] ?? '',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(15),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: ResponsiveScaler.height(2)),
          Text(
            _formatItemPrice(),
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(13),
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Controles para modificar cantidad
  Widget _buildQuantityControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onDecrement,
          child: Container(
            padding: ResponsiveScaler.padding(const EdgeInsets.all(6)),
            child: Icon(
              Icons.remove_circle_outline,
              size: ResponsiveScaler.icon(22),
              color: AppColors.primary,
            ),
          ),
        ),
        Container(
          width: ResponsiveScaler.width(32),
          padding: ResponsiveScaler.padding(
            const EdgeInsets.symmetric(vertical: 4),
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundAlternate,
            borderRadius: BorderRadius.circular(ResponsiveScaler.radius(6)),
          ),
          child: Center(
            child: Text(
              item['quantity'].toString(),
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(14),
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            padding: ResponsiveScaler.padding(const EdgeInsets.all(6)),
            child: Icon(
              Icons.add_circle_outline,
              size: ResponsiveScaler.icon(22),
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  // Detalles expandidos del producto
  Widget _buildExpandedDetails() {
    final variantName = item['variantName'];
    final customerName = item['customerName'];
    final category = item['category'];
    final description = item['description'];

    return Container(
      margin: ResponsiveScaler.margin(const EdgeInsets.only(top: 10)),
      padding: ResponsiveScaler.padding(const EdgeInsets.all(10)),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(ResponsiveScaler.radius(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (customerName != null && customerName.toString().isNotEmpty)
            _buildDetailRow(Icons.person, 'Cliente', customerName.toString()),
          if (variantName != null && variantName.toString().isNotEmpty)
            _buildDetailRow(
              Icons.local_offer,
              'Variante',
              variantName.toString(),
            ),
          if (category != null && category.toString().isNotEmpty)
            _buildDetailRow(Icons.category, 'Categoría', category.toString()),
          if (description != null && description.toString().isNotEmpty)
            Text(
              description.toString(),
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(12),
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (customerName == null &&
              variantName == null &&
              category == null &&
              description == null)
            Text(
              'Sin detalles adicionales',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(12),
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }

  // Fila de detalle con icono
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: ResponsiveScaler.padding(const EdgeInsets.only(bottom: 4)),
      child: Row(
        children: [
          Icon(icon, size: ResponsiveScaler.icon(14), color: AppColors.primary),
          SizedBox(width: ResponsiveScaler.width(6)),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(12),
              color: AppColors.textMuted,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(12),
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

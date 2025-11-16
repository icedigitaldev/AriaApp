import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/app_gradients.dart';
import '../../../../design/colors/status_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class DishGrid extends StatelessWidget {
  final List<Map<String, dynamic>> dishes;
  final Map<int, int> orderQuantities;
  final Function(Map<String, dynamic>) onAddDish;
  final Function(int, int) onUpdateQuantity;
  final bool showRating;
  final bool showCategory;

  const DishGrid({
    Key? key,
    required this.dishes,
    required this.orderQuantities,
    required this.onAddDish,
    required this.onUpdateQuantity,
    this.showRating = true,
    this.showCategory = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      padding: ResponsiveSize.padding(
        const EdgeInsets.fromLTRB(20, 0, 20, 80),
      ),
      crossAxisCount: 2,
      mainAxisSpacing: ResponsiveSize.height(16),
      crossAxisSpacing: ResponsiveSize.width(16),
      itemCount: dishes.length,
      itemBuilder: (context, index) {
        final dish = dishes[index];
        final quantity = orderQuantities[dish['id']] ?? 0;
        return _buildDishCard(dish, quantity);
      },
    );
  }

  Widget _buildDishCard(Map<String, dynamic> dish, int quantity) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(ResponsiveSize.radius(20)),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, ResponsiveSize.height(4)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDishImage(dish),
          _buildDishContent(dish, quantity),
        ],
      ),
    );
  }

  Widget _buildDishImage(Map<String, dynamic> dish) {
    return Stack(
      children: [
        Container(
          height: ResponsiveSize.height(140),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveSize.radius(20)),
            ),
            image: DecorationImage(
              image: NetworkImage(dish['image'] ?? ''),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (showRating && dish['rating'] != null)
          Positioned(
            bottom: ResponsiveSize.height(10),
            left: ResponsiveSize.width(10),
            child: Container(
              padding: ResponsiveSize.padding(
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(ResponsiveSize.radius(12)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: ResponsiveSize.icon(14),
                  ),
                  SizedBox(width: ResponsiveSize.width(4)),
                  Text(
                    dish['rating'].toString(),
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveSize.font(12),
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

  Widget _buildDishContent(Map<String, dynamic> dish, int quantity) {
    return Padding(
      padding: ResponsiveSize.padding(const EdgeInsets.all(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dish['name'],
            style: GoogleFonts.poppins(
              fontSize: ResponsiveSize.font(16),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (dish['description'] != null) ...[
            SizedBox(height: ResponsiveSize.height(4)),
            Text(
              dish['description'],
              style: GoogleFonts.poppins(
                fontSize: ResponsiveSize.font(12),
                color: AppColors.textMuted,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (showCategory && dish['category'] != null) ...[
            SizedBox(height: ResponsiveSize.height(8)),
            Container(
              padding: ResponsiveSize.padding(
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(ResponsiveSize.radius(12)),
              ),
              child: Text(
                dish['category'],
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveSize.font(10),
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
          SizedBox(height: ResponsiveSize.height(12)),
          Text(
            '\$${dish['price']}',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveSize.font(20),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveSize.height(12)),
          _buildActionButton(dish, quantity),
        ],
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> dish, int quantity) {
    if (dish['status'] == 'unavailable') {
      return Container(
        padding: ResponsiveSize.padding(
          const EdgeInsets.symmetric(vertical: 12),
        ),
        decoration: BoxDecoration(
          color: StatusColors.unavailableBackground,
          borderRadius: BorderRadius.circular(ResponsiveSize.radius(12)),
        ),
        child: Center(
          child: Text(
            'No disponible',
            style: GoogleFonts.poppins(
              color: StatusColors.unavailableText,
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveSize.font(14),
            ),
          ),
        ),
      );
    }

    if (quantity == 0) {
      return GestureDetector(
        onTap: () => onAddDish(dish),
        child: Container(
          padding: ResponsiveSize.padding(
            const EdgeInsets.symmetric(vertical: 12),
          ),
          decoration: BoxDecoration(
            gradient: AppGradients.primaryButton,
            borderRadius: BorderRadius.circular(ResponsiveSize.radius(12)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, ResponsiveSize.height(2)),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Agregar',
              style: GoogleFonts.poppins(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveSize.font(14),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundAlternate,
        borderRadius: BorderRadius.circular(ResponsiveSize.radius(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => onUpdateQuantity(dish['id'], quantity - 1),
            icon: Icon(
              Icons.remove,
              size: ResponsiveSize.icon(20),
              color: AppColors.primary,
            ),
          ),
          Text(
            quantity.toString(),
            style: GoogleFonts.poppins(
              fontSize: ResponsiveSize.font(16),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          IconButton(
            onPressed: () => onUpdateQuantity(dish['id'], quantity + 1),
            icon: Icon(
              Icons.add,
              size: ResponsiveSize.icon(20),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
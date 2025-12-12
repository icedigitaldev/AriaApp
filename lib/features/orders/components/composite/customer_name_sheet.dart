import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/app_gradients.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class CustomerNameSheet extends StatefulWidget {
  final Map<String, dynamic> dish;
  final Function(Map<String, dynamic> orderItem) onAddToOrder;

  const CustomerNameSheet({
    Key? key,
    required this.dish,
    required this.onAddToOrder,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required Map<String, dynamic> dish,
    required Function(Map<String, dynamic> orderItem) onAddToOrder,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          CustomerNameSheet(dish: dish, onAddToOrder: onAddToOrder),
    );
  }

  @override
  State<CustomerNameSheet> createState() => _CustomerNameSheetState();
}

class _CustomerNameSheetState extends State<CustomerNameSheet> {
  final _customerNameController = TextEditingController();

  @override
  void dispose() {
    _customerNameController.dispose();
    super.dispose();
  }

  void _handleAddToOrder() {
    final price = (widget.dish['price'] as num?)?.toDouble() ?? 0.0;
    final orderItem = {
      'dishId': widget.dish['id'],
      'dishName': widget.dish['name'],
      'dishImage': widget.dish['imageUrl'] ?? widget.dish['image'],
      'category': widget.dish['category'],
      'description': widget.dish['description'],
      'price': price,
      'variantName': null,
      'customerName': _customerNameController.text.trim(),
      'quantity': 1,
    };

    widget.onAddToOrder(orderItem);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final price = (widget.dish['price'] as num?)?.toDouble() ?? 0.0;
    final imageUrl = widget.dish['imageUrl'] ?? widget.dish['image'];
    final hasImage = imageUrl != null && imageUrl.toString().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveScaler.radius(24)),
        ),
      ),
      child: Padding(
        padding: ResponsiveScaler.padding(
          EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: ResponsiveScaler.width(40),
                height: ResponsiveScaler.height(4),
                decoration: BoxDecoration(
                  color: AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: ResponsiveScaler.height(20)),

            // Plato info
            Row(
              children: [
                Container(
                  width: ResponsiveScaler.width(60),
                  height: ResponsiveScaler.height(60),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      ResponsiveScaler.radius(12),
                    ),
                    color: hasImage ? null : AppColors.backgroundGrey,
                    image: hasImage
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: !hasImage
                      ? Icon(
                          Icons.restaurant,
                          color: AppColors.iconMuted,
                          size: ResponsiveScaler.icon(28),
                        )
                      : null,
                ),
                SizedBox(width: ResponsiveScaler.width(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.dish['name'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveScaler.font(18),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: ResponsiveScaler.height(4)),
                      Text(
                        'S/ ${price.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveScaler.font(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveScaler.height(24)),

            // Campo nombre del cliente
            Text(
              'Nombre del cliente (opcional)',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(14),
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: ResponsiveScaler.height(8)),
            TextField(
              controller: _customerNameController,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(16),
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Ej: Juan',
                hintStyle: GoogleFonts.poppins(color: AppColors.textMuted),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: ResponsiveScaler.icon(22),
                ),
                filled: true,
                fillColor: AppColors.backgroundGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveScaler.radius(12),
                  ),
                  borderSide: BorderSide.none,
                ),
                contentPadding: ResponsiveScaler.padding(
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            SizedBox(height: ResponsiveScaler.height(24)),

            // Botón agregar pedido
            GestureDetector(
              onTap: _handleAddToOrder,
              child: Container(
                width: double.infinity,
                padding: ResponsiveScaler.padding(
                  const EdgeInsets.symmetric(vertical: 14),
                ),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryButton,
                  borderRadius: BorderRadius.circular(
                    ResponsiveScaler.radius(12),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Agregar al pedido',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveScaler.font(15),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textOnPrimary,
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
}

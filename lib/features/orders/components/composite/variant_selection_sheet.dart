import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/app_gradients.dart';
import '../../../../design/responsive/responsive_scaler.dart';

class VariantSelectionSheet extends StatefulWidget {
  final Map<String, dynamic> dish;
  final Function(Map<String, dynamic> orderItem) onAddToOrder;

  const VariantSelectionSheet({
    Key? key,
    required this.dish,
    required this.onAddToOrder,
  }) : super(key: key);

  // Muestra el bottom sheet
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
          VariantSelectionSheet(dish: dish, onAddToOrder: onAddToOrder),
    );
  }

  @override
  State<VariantSelectionSheet> createState() => _VariantSelectionSheetState();
}

class _VariantSelectionSheetState extends State<VariantSelectionSheet> {
  int? selectedVariantIndex;
  final _customerNameController = TextEditingController();

  List<dynamic> get variants => widget.dish['variants'] as List<dynamic>? ?? [];

  @override
  void dispose() {
    _customerNameController.dispose();
    super.dispose();
  }

  void _handleAddToOrder() {
    if (selectedVariantIndex == null) return;

    final variant = variants[selectedVariantIndex!];
    final orderItem = {
      'dishId': widget.dish['id'],
      'dishName': widget.dish['name'],
      'dishImage': widget.dish['imageUrl'] ?? widget.dish['image'],
      'variantName': variant['name'],
      'variantPrice': (variant['price'] as num).toDouble(),
      'customerName': _customerNameController.text.trim(),
      'quantity': 1,
    };

    widget.onAddToOrder(orderItem);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveScaler.radius(24)),
        ),
      ),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: ResponsiveScaler.height(16)),
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
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              padding: ResponsiveScaler.padding(
                const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ResponsiveScaler.height(20)),
                  Text(
                    widget.dish['name'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveScaler.font(20),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: ResponsiveScaler.height(4)),
                  Text(
                    'Selecciona una opción',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveScaler.font(14),
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: ResponsiveScaler.height(20)),
                  ...variants.asMap().entries.map((entry) {
                    final index = entry.key;
                    final variant = entry.value;
                    final isSelected = selectedVariantIndex == index;
                    final price = (variant['price'] as num).toDouble();

                    return GestureDetector(
                      onTap: () => setState(() => selectedVariantIndex = index),
                      child: Container(
                        margin: ResponsiveScaler.margin(
                          const EdgeInsets.only(bottom: 12),
                        ),
                        padding: ResponsiveScaler.padding(
                          const EdgeInsets.all(16),
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.backgroundGrey,
                          borderRadius: BorderRadius.circular(
                            ResponsiveScaler.radius(12),
                          ),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: ResponsiveScaler.width(24),
                                  height: ResponsiveScaler.height(24),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.inputBorder,
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: ResponsiveScaler.icon(16),
                                          color: AppColors.iconOnPrimary,
                                        )
                                      : null,
                                ),
                                SizedBox(width: ResponsiveScaler.width(12)),
                                Text(
                                  variant['name'] ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: ResponsiveScaler.font(16),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'S/ ${price.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveScaler.font(16),
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: ResponsiveScaler.padding(const EdgeInsets.all(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                GestureDetector(
                  onTap: selectedVariantIndex != null
                      ? _handleAddToOrder
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: ResponsiveScaler.padding(
                      const EdgeInsets.symmetric(vertical: 16),
                    ),
                    decoration: BoxDecoration(
                      gradient: selectedVariantIndex != null
                          ? AppGradients.primaryButton
                          : null,
                      color: selectedVariantIndex == null
                          ? AppColors.inputBorder
                          : null,
                      borderRadius: BorderRadius.circular(
                        ResponsiveScaler.radius(12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Agregar al pedido',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveScaler.font(16),
                          fontWeight: FontWeight.w600,
                          color: selectedVariantIndex != null
                              ? AppColors.textOnPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

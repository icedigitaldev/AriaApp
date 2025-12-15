import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ice_storage/ice_storage.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/app_gradients.dart';
import '../../../../design/responsive/responsive_scaler.dart';
import '../../../../components/ui/app_loader.dart';

class OrderSummaryModal extends StatefulWidget {
  final List<Map<String, dynamic>> orderItems;
  final Function(int, int) onUpdateQuantity;
  final Future<bool> Function(String responsibleName, bool specialEvent)
  onConfirm;
  final double totalAmount;

  const OrderSummaryModal({
    Key? key,
    required this.orderItems,
    required this.onUpdateQuantity,
    required this.onConfirm,
    required this.totalAmount,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required List<Map<String, dynamic>> orderItems,
    required Function(int, int) onUpdateQuantity,
    required Future<bool> Function(String responsibleName, bool specialEvent)
    onConfirm,
    required double totalAmount,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => OrderSummaryModal(
        orderItems: orderItems,
        onUpdateQuantity: onUpdateQuantity,
        onConfirm: onConfirm,
        totalAmount: totalAmount,
      ),
    );
  }

  @override
  State<OrderSummaryModal> createState() => _OrderSummaryModalState();
}

class _OrderSummaryModalState extends State<OrderSummaryModal> {
  bool isLoading = false;
  bool _isSpecialEvent = false;
  String? expandedItemId;
  final _responsibleController = TextEditingController();

  @override
  void dispose() {
    _responsibleController.dispose();
    super.dispose();
  }

  String _formatItemPrice(Map<String, dynamic> item) {
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

  // Obtiene imagen desde caché o la descarga
  Future<Uint8List?> _getCachedImage(String url) async {
    final isCached = await IceStorage.instance.images.isImageCached(url);
    if (isCached) {
      return await IceStorage.instance.images.getCachedImage(url);
    }
    return await IceStorage.instance.images.downloadAndCacheImage(url);
  }

  void _handleConfirm() async {
    setState(() => isLoading = true);

    final success = await widget.onConfirm(
      _responsibleController.text.trim(),
      _isSpecialEvent,
    );

    if (mounted) {
      setState(() => isLoading = false);
      if (!success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveScaler.radius(30)),
        ),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          Expanded(child: _buildItemsList()),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: ResponsiveScaler.width(40),
      height: ResponsiveScaler.height(4),
      margin: ResponsiveScaler.margin(
        const EdgeInsets.only(top: 12, bottom: 16),
      ),
      decoration: BoxDecoration(
        color: AppColors.inputBorder,
        borderRadius: BorderRadius.circular(ResponsiveScaler.radius(2)),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: ResponsiveScaler.padding(
        const EdgeInsets.symmetric(horizontal: 20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Resumen del Pedido',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(22),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '${widget.orderItems.length} items',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(16),
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: ResponsiveScaler.padding(const EdgeInsets.all(20)),
      itemCount: widget.orderItems.length,
      itemBuilder: (context, index) {
        final item = widget.orderItems[index];
        return _buildOrderItem(item, index);
      },
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item, int index) {
    final itemId = item['id']?.toString() ?? index.toString();
    final isExpanded = expandedItemId == itemId;
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
      onDismissed: (direction) {
        widget.onUpdateQuantity(index, 0);
        setState(() {});
        if (widget.orderItems.isEmpty) Navigator.pop(context);
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (expandedItemId == itemId) {
              expandedItemId = null;
            } else {
              expandedItemId = itemId;
            }
          });
        },
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
                  // Imagen con caché
                  Container(
                    width: ResponsiveScaler.width(56),
                    height: ResponsiveScaler.height(56),
                    margin: ResponsiveScaler.margin(
                      const EdgeInsets.only(right: 12),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      color: AppColors.inputBorder,
                    ),
                    child: hasImage
                        ? FutureBuilder<Uint8List?>(
                            future: _getCachedImage(imageUrl),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                );
                              }
                              if (snapshot.hasError || snapshot.data == null) {
                                return Icon(
                                  Icons.restaurant,
                                  color: AppColors.iconMuted,
                                  size: ResponsiveScaler.icon(22),
                                );
                              }
                              return ClipRRect(
                                borderRadius: borderRadius,
                                child: Image.memory(
                                  snapshot.data!,
                                  width: ResponsiveScaler.width(56),
                                  height: ResponsiveScaler.height(56),
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          )
                        : Icon(
                            Icons.restaurant,
                            color: AppColors.iconMuted,
                            size: ResponsiveScaler.icon(22),
                          ),
                  ),
                  Expanded(
                    child: SizedBox(
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
                            _formatItemPrice(item),
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveScaler.font(13),
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildQuantityControls(item, index),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.iconMuted,
                    size: ResponsiveScaler.icon(22),
                  ),
                ],
              ),
              if (isExpanded) _buildExpandedDetails(item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedDetails(Map<String, dynamic> item) {
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

  Widget _buildQuantityControls(Map<String, dynamic> item, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            widget.onUpdateQuantity(index, item['quantity'] - 1);
            setState(() {});
            if (widget.orderItems.isEmpty) Navigator.pop(context);
          },
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
          onTap: () {
            widget.onUpdateQuantity(index, item['quantity'] + 1);
            setState(() {});
          },
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

  Widget _buildFooter() {
    return Container(
      padding: ResponsiveScaler.padding(
        EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveScaler.radius(20)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, ResponsiveScaler.height(-4)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Campo responsable de pago
          TextField(
            controller: _responsibleController,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(15),
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Responsable del pago (opcional)',
              hintStyle: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(14),
                color: AppColors.textMuted,
              ),
              prefixIcon: Icon(
                Icons.account_circle_outlined,
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
          SizedBox(height: ResponsiveScaler.height(12)),
          // Toggle de evento especial
          GestureDetector(
            onTap: () => setState(() => _isSpecialEvent = !_isSpecialEvent),
            child: Container(
              padding: ResponsiveScaler.padding(
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              decoration: BoxDecoration(
                color: _isSpecialEvent
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(
                  ResponsiveScaler.radius(12),
                ),
                border: _isSpecialEvent
                    ? Border.all(color: AppColors.primary.withOpacity(0.3))
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    _isSpecialEvent
                        ? Icons.celebration
                        : Icons.celebration_outlined,
                    color: _isSpecialEvent
                        ? AppColors.primary
                        : AppColors.iconMuted,
                    size: ResponsiveScaler.icon(20),
                  ),
                  SizedBox(width: ResponsiveScaler.width(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evento especial',
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveScaler.font(14),
                            fontWeight: FontWeight.w500,
                            color: _isSpecialEvent
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Concierto, partido, feria u otro evento cercano',
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveScaler.font(11),
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isSpecialEvent,
                    onChanged: (value) =>
                        setState(() => _isSpecialEvent = value),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: ResponsiveScaler.height(16)),
          // Total
          Container(
            padding: ResponsiveScaler.padding(
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            decoration: BoxDecoration(
              gradient: AppGradients.totalAmountBackground,
              borderRadius: BorderRadius.circular(ResponsiveScaler.radius(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveScaler.font(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'S/ ${widget.totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveScaler.font(24),
                    fontWeight: FontWeight.bold,
                    foreground: AppGradients.totalAmountText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveScaler.height(16)),
          // Botón confirmar
          GestureDetector(
            onTap: isLoading ? null : _handleConfirm,
            child: Container(
              width: double.infinity,
              padding: ResponsiveScaler.padding(
                const EdgeInsets.symmetric(vertical: 16),
              ),
              decoration: BoxDecoration(
                gradient: isLoading ? null : AppGradients.primaryButton,
                color: isLoading ? AppColors.backgroundDisabled : null,
                borderRadius: BorderRadius.circular(
                  ResponsiveScaler.radius(14),
                ),
                boxShadow: !isLoading
                    ? [
                        BoxShadow(
                          color: AppColors.shadowPurple,
                          blurRadius: 12,
                          offset: Offset(0, ResponsiveScaler.height(4)),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isLoading
                    ? AppLoader(size: 22)
                    : Text(
                        'Confirmar Pedido',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveScaler.font(16),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

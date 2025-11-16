import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/app_gradients.dart';
import '../../../../design/responsive/responsive_scaler.dart';
import '../../../../components/ui/app_loader.dart';

class OrderSummaryModal extends StatefulWidget {
  final List<Map<String, dynamic>> orderItems;
  final Function(int, int) onUpdateQuantity;
  final VoidCallback onConfirm;
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
        required VoidCallback onConfirm,
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

  void _handleConfirm() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    widget.onConfirm();
    if (mounted) {
      setState(() => isLoading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveSize.radius(30)),
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
      width: ResponsiveSize.width(40),
      height: ResponsiveSize.height(4),
      margin: ResponsiveSize.margin(
        const EdgeInsets.only(top: 12, bottom: 20),
      ),
      decoration: BoxDecoration(
        color: AppColors.inputBorder,
        borderRadius: BorderRadius.circular(ResponsiveSize.radius(2)),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: ResponsiveSize.padding(
        const EdgeInsets.symmetric(horizontal: 20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Resumen del Pedido',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveSize.font(22),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '${widget.orderItems.length} items',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveSize.font(16),
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: ResponsiveSize.padding(
        const EdgeInsets.all(20),
      ),
      itemCount: widget.orderItems.length,
      itemBuilder: (context, index) {
        final item = widget.orderItems[index];
        return _buildOrderItem(item);
      },
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Container(
      margin: ResponsiveSize.margin(const EdgeInsets.only(bottom: 16)),
      padding: ResponsiveSize.padding(const EdgeInsets.all(12)),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(ResponsiveSize.radius(16)),
      ),
      child: Row(
        children: [
          if (item['image'] != null)
            Container(
              width: ResponsiveSize.width(60),
              height: ResponsiveSize.height(60),
              margin: ResponsiveSize.margin(
                const EdgeInsets.only(right: 12),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ResponsiveSize.radius(12)),
                image: DecorationImage(
                  image: NetworkImage(item['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveSize.font(16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: ResponsiveSize.height(4)),
                Text(
                  '\$${item['price']} x ${item['quantity']}',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveSize.font(14),
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _buildQuantityControls(item),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(Map<String, dynamic> item) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            widget.onUpdateQuantity(item['id'], item['quantity'] - 1);
            setState(() {});
            if (widget.orderItems.isEmpty) Navigator.pop(context);
          },
          icon: Icon(
            Icons.remove_circle_outline,
            size: ResponsiveSize.icon(24),
            color: AppColors.primary,
          ),
        ),
        Container(
          width: ResponsiveSize.width(40),
          padding: ResponsiveSize.padding(const EdgeInsets.symmetric(vertical: 4)),
          decoration: BoxDecoration(
            color: AppColors.backgroundAlternate,
            borderRadius: BorderRadius.circular(ResponsiveSize.radius(8)),
          ),
          child: Center(
            child: Text(
              item['quantity'].toString(),
              style: GoogleFonts.poppins(
                fontSize: ResponsiveSize.font(16),
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            widget.onUpdateQuantity(item['id'], item['quantity'] + 1);
            setState(() {});
          },
          icon: Icon(
            Icons.add_circle_outline,
            size: ResponsiveSize.icon(24),
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: ResponsiveSize.padding(const EdgeInsets.all(20)),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveSize.radius(20)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, ResponsiveSize.height(-4)),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: ResponsiveSize.padding(const EdgeInsets.all(20)),
            decoration: BoxDecoration(
              gradient: AppGradients.totalAmountBackground,
              borderRadius: BorderRadius.circular(ResponsiveSize.radius(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveSize.font(20),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '\$${widget.totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveSize.font(28),
                    fontWeight: FontWeight.bold,
                    foreground: AppGradients.totalAmountText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveSize.height(20)),
          GestureDetector(
            onTap: isLoading ? null : _handleConfirm,
            child: Container(
              padding: ResponsiveSize.padding(
                const EdgeInsets.symmetric(vertical: 18),
              ),
              decoration: BoxDecoration(
                gradient: isLoading ? null : AppGradients.primaryButton,
                color: isLoading ? AppColors.backgroundDisabled : null,
                borderRadius: BorderRadius.circular(ResponsiveSize.radius(16)),
                boxShadow: !isLoading
                    ? [
                  BoxShadow(
                    color: AppColors.shadowPurple,
                    blurRadius: 12,
                    offset: Offset(0, ResponsiveSize.height(4)),
                  ),
                ]
                    : null,
              ),
              child: Center(
                child: isLoading
                    ? AppLoader(size: 24)
                    : Text(
                  'Confirmar Pedido',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveSize.font(18),
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
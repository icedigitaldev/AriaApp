import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';
import '../ui/order_item_card.dart';
import 'order_summary_footer.dart';

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
  bool _isLoading = false;
  String? _expandedItemId;

  // Valores del footer
  String _responsibleName = '';
  bool _isSpecialEvent = false;

  void _handleConfirm() async {
    setState(() => _isLoading = true);

    final success = await widget.onConfirm(_responsibleName, _isSpecialEvent);

    if (mounted) {
      setState(() => _isLoading = false);
      if (!success) {
        Navigator.pop(context);
      }
    }
  }

  void _handleFooterValuesChanged(String responsibleName, bool isSpecialEvent) {
    _responsibleName = responsibleName;
    _isSpecialEvent = isSpecialEvent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
          OrderSummaryFooter(
            totalAmount: widget.totalAmount,
            isLoading: _isLoading,
            onConfirm: _handleConfirm,
            onValuesChanged: _handleFooterValuesChanged,
          ),
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
        final itemId = item['id']?.toString() ?? index.toString();

        return OrderItemCard(
          item: item,
          index: index,
          isExpanded: _expandedItemId == itemId,
          onTap: () {
            setState(() {
              _expandedItemId = _expandedItemId == itemId ? null : itemId;
            });
          },
          onDecrement: () {
            widget.onUpdateQuantity(index, item['quantity'] - 1);
            setState(() {});
            if (widget.orderItems.isEmpty) Navigator.pop(context);
          },
          onIncrement: () {
            widget.onUpdateQuantity(index, item['quantity'] + 1);
            setState(() {});
          },
          onDismissed: () {
            widget.onUpdateQuantity(index, 0);
            setState(() {});
            if (widget.orderItems.isEmpty) Navigator.pop(context);
          },
        );
      },
    );
  }
}

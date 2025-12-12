import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ice_storage/ice_storage.dart';
import '../components/composite/transparent_app_bar.dart';
import '../components/ui/app_loader.dart';
import '../design/colors/app_colors.dart';
import '../design/colors/app_gradients.dart';
import '../design/responsive/responsive_scaler.dart';
import '../design/themes/app_themes.dart';
import '../auth/current_user.dart';
import '../utils/app_logger.dart';

class OrderDetailsView extends StatefulWidget {
  const OrderDetailsView({Key? key}) : super(key: key);

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  Map<String, dynamic>? _table;
  Map<String, dynamic>? _order;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && _table == null) {
      _table = args;
      _loadOrder();
    }
  }

  Future<void> _loadOrder() async {
    if (_table == null) return;

    final gateway = IceStorage.instance.gateway;
    if (gateway == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final businessId = CurrentUserAuth.instance.businessId;
      final query = FirebaseFirestore.instance
          .collection('orders')
          .where('businessId', isEqualTo: businessId)
          .where('tableId', isEqualTo: _table!['id'])
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .limit(1);

      final snapshot = await gateway.getDocuments(query: query);

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        data['id'] = doc.id;
        setState(() {
          _order = data;
          _isLoading = false;
        });
        AppLogger.log('Orden cargada: ${doc.id}', prefix: 'ORDEN:');
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      AppLogger.log('Error cargando orden: $e', prefix: 'ORDEN_ERROR:');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToAddItems() {
    Navigator.pushNamed(context, '/new-order', arguments: _table);
  }

  @override
  Widget build(BuildContext context) {
    AppThemes.init(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TransparentAppBar(backgroundColor: AppColors.appBarBackground),
      body: Container(
        decoration: BoxDecoration(color: AppColors.background),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? Center(child: AppLoader(size: ResponsiveScaler.width(40)))
                    : _order == null
                    ? _buildNoOrderView()
                    : _buildOrderContent(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _order != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildHeader() {
    final items = _order?['items'] as List<dynamic>? ?? [];
    final status = _order?['status']?.toString() ?? 'pending';

    return Container(
      padding: ResponsiveScaler.padding(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: ResponsiveScaler.padding(const EdgeInsets.all(10)),
              decoration: BoxDecoration(
                color: AppColors.card.withOpacity(0.9),
                borderRadius: BorderRadius.circular(
                  ResponsiveScaler.radius(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: Offset(0, ResponsiveScaler.height(2)),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: ResponsiveScaler.icon(22),
              ),
            ),
          ),
          SizedBox(width: ResponsiveScaler.width(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Mesa ${_table?['number'] ?? ''}',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveScaler.font(24),
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = AppGradients.headerText.createShader(
                            const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                          ),
                      ),
                    ),
                    if (_order != null) ...[
                      SizedBox(width: ResponsiveScaler.width(10)),
                      Container(
                        padding: ResponsiveScaler.padding(
                          const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(
                            ResponsiveScaler.radius(8),
                          ),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveScaler.font(10),
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (_order != null)
                  Text(
                    '${items.length} items • ${_order!['staffName'] ?? 'Sin asignar'}',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveScaler.font(13),
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          if (_order != null)
            GestureDetector(
              onTap: _navigateToAddItems,
              child: Container(
                padding: ResponsiveScaler.padding(const EdgeInsets.all(10)),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryButton,
                  borderRadius: BorderRadius.circular(
                    ResponsiveScaler.radius(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, ResponsiveScaler.height(2)),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_shopping_cart,
                  color: AppColors.iconOnPrimary,
                  size: ResponsiveScaler.icon(22),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoOrderView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: ResponsiveScaler.icon(64),
            color: AppColors.iconMuted,
          ),
          SizedBox(height: ResponsiveScaler.height(16)),
          Text(
            'No hay orden activa',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(18),
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: ResponsiveScaler.height(24)),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/new-order',
                arguments: _table,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: ResponsiveScaler.padding(
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveScaler.radius(16),
                ),
              ),
            ),
            child: Text(
              'Crear Nueva Orden',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderContent() {
    final items = _order!['items'] as List<dynamic>? ?? [];

    return ListView(
      padding: ResponsiveScaler.padding(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      children: [
        ...items.map((item) => _buildOrderItem(item as Map<String, dynamic>)),
        SizedBox(height: ResponsiveScaler.height(80)),
      ],
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final variantName = item['variantName'];
    final customerName = item['customerName'];
    final price = (item['price'] as num?)?.toDouble() ?? 0.0;
    final quantity = item['quantity'] ?? 1;
    final subtotal = price * quantity;
    final hasVariant = variantName != null && variantName.toString().isNotEmpty;
    final hasCustomer =
        customerName != null && customerName.toString().isNotEmpty;

    return Container(
      margin: ResponsiveScaler.margin(const EdgeInsets.only(bottom: 10)),
      padding: ResponsiveScaler.padding(
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(ResponsiveScaler.radius(14)),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveScaler.width(36),
            height: ResponsiveScaler.height(36),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveScaler.radius(10)),
            ),
            child: Center(
              child: Text(
                'x$quantity',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveScaler.font(14),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveScaler.width(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveScaler.font(15),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (hasVariant) ...[
                  SizedBox(height: ResponsiveScaler.height(2)),
                  Row(
                    children: [
                      Icon(
                        Icons.local_offer,
                        size: ResponsiveScaler.icon(12),
                        color: AppColors.primary,
                      ),
                      SizedBox(width: ResponsiveScaler.width(4)),
                      Text(
                        variantName.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveScaler.font(12),
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (hasCustomer) ...[
                  SizedBox(height: ResponsiveScaler.height(2)),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: ResponsiveScaler.icon(12),
                        color: AppColors.textMuted,
                      ),
                      SizedBox(width: ResponsiveScaler.width(4)),
                      Text(
                        customerName.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveScaler.font(12),
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Text(
            'S/ ${subtotal.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(15),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final total = (_order!['totalAmount'] as num?)?.toDouble() ?? 0.0;

    return Container(
      padding: ResponsiveScaler.padding(
        EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveScaler.radius(24)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, ResponsiveScaler.height(-4)),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total a pagar',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(16),
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          Text(
            'S/ ${total.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveScaler.font(28),
              fontWeight: FontWeight.bold,
              foreground: AppGradients.totalAmountText,
            ),
          ),
          // TODO: Agregar opción para imprimir cuenta
        ],
      ),
    );
  }
}

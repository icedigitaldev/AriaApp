import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ice_storage/ice_storage.dart';
import '../components/composite/confirm_dialog.dart';
import '../components/composite/transparent_app_bar.dart';
import '../components/ui/app_loader.dart';
import '../design/colors/app_colors.dart';
import '../design/colors/app_gradients.dart';
import '../design/responsive/responsive_scaler.dart';
import '../design/themes/app_themes.dart';
import '../auth/current_user.dart';
import '../features/orders/services/orders_service.dart';
import '../features/tables/services/tables_service.dart';
import '../router/app_router.dart';
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
  StreamSubscription? _orderSubscription;

  final OrdersService _ordersService = OrdersService();
  final TablesService _tablesService = TablesService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && _table == null) {
      _table = args;
      _subscribeToOrder();
    }
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }

  // Suscribe a cambios de la orden en tiempo real
  void _subscribeToOrder() {
    if (_table == null) return;

    final gateway = IceStorage.instance.gateway;
    if (gateway == null) {
      setState(() => _isLoading = false);
      return;
    }

    final businessId = CurrentUserAuth.instance.businessId;

    // Busca órdenes activas (pending, preparing, completed)
    final query = FirebaseFirestore.instance
        .collection('orders')
        .where('businessId', isEqualTo: businessId)
        .where('tableId', isEqualTo: _table!['id'])
        .where('status', whereIn: ['pending', 'preparing', 'completed'])
        .orderBy('createdAt', descending: true)
        .limit(1);

    _orderSubscription = gateway
        .streamDocuments(query: query)
        .listen(
          (snapshot) {
            if (snapshot.docs.isNotEmpty) {
              final doc = snapshot.docs.first;
              final data = doc.data();
              data['id'] = doc.id;
              setState(() {
                _order = data;
                _isLoading = false;
              });
              AppLogger.log(
                'Orden actualizada: ${doc.id} - Estado: ${data['status']}',
                prefix: 'ORDEN:',
              );
            } else {
              setState(() {
                _order = null;
                _isLoading = false;
              });
            }
          },
          onError: (e) {
            AppLogger.log(
              'Error en stream de orden: $e',
              prefix: 'ORDEN_ERROR:',
            );
            setState(() => _isLoading = false);
          },
        );
  }

  // Elimina un item de la orden
  Future<void> _removeItem(int index) async {
    if (_order == null) return;

    final items = List<dynamic>.from(_order!['items'] ?? []);
    if (index < 0 || index >= items.length) return;

    final removedItem = items[index];
    final price = (removedItem['price'] as num?)?.toDouble() ?? 0.0;
    final quantity = removedItem['quantity'] ?? 1;
    final amountToSubtract = price * quantity;

    items.removeAt(index);

    final currentTotal = (_order!['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final newTotal = (currentTotal - amountToSubtract).clamp(
      0.0,
      double.infinity,
    );

    try {
      if (items.isEmpty) {
        // Si no quedan items, cancela orden y libera mesa
        await _ordersService.changeOrderStatus(_order!['id'], 'cancelled');
        await _tablesService.changeTableStatus(_table!['id'], 'available');

        if (mounted) {
          AppRouter.navigateToHome(context);
        }
      } else {
        await _ordersService.updateOrderItems(
          _order!['id'],
          items.map((e) => Map<String, dynamic>.from(e)).toList(),
        );

        // Actualiza el total
        final gateway = IceStorage.instance.gateway;
        if (gateway != null) {
          final docRef = FirebaseFirestore.instance
              .collection('orders')
              .doc(_order!['id']);
          await gateway.updateDocument(
            docRef: docRef,
            data: {'totalAmount': newTotal},
          );
        }

        setState(() {
          _order!['items'] = items;
          _order!['totalAmount'] = newTotal;
        });
      }

      AppLogger.log('Item eliminado de la orden', prefix: 'ORDEN:');
    } catch (e) {
      AppLogger.log('Error eliminando item: $e', prefix: 'ORDEN_ERROR:');
    }
  }

  void _navigateToAddItems() {
    Navigator.pushNamed(context, '/new-order', arguments: _table);
  }

  // Obtiene color según el estado de la orden
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'preparing':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      default:
        return AppColors.textMuted;
    }
  }

  // Obtiene texto del estado en español
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'PENDIENTE';
      case 'preparing':
        return 'EN PREPARACIÓN';
      case 'completed':
        return 'LISTO PARA SERVIR';
      default:
        return status.toUpperCase();
    }
  }

  // Obtiene icono según el estado
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'preparing':
        return Icons.restaurant;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
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
              // Banner de estado cuando la orden está en preparación o lista
              if (_order != null &&
                  (_order!['status'] == 'preparing' ||
                      _order!['status'] == 'completed'))
                _buildStatusBanner(_order!['status']),
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

  // Banner que muestra el estado actual de la orden
  Widget _buildStatusBanner(String status) {
    final color = _getStatusColor(status);
    final text = _getStatusText(status);
    final icon = _getStatusIcon(status);

    return Container(
      margin: ResponsiveScaler.margin(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      padding: ResponsiveScaler.padding(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(ResponsiveScaler.radius(12)),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: ResponsiveScaler.icon(24)),
          SizedBox(width: ResponsiveScaler.width(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveScaler.font(14),
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (status == 'completed')
                  Text(
                    'El pedido está listo para ser entregado al cliente',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveScaler.font(12),
                      color: color.withOpacity(0.8),
                    ),
                  ),
                if (status == 'preparing')
                  Text(
                    'La cocina está preparando el pedido',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveScaler.font(12),
                      color: color.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final items = _order?['items'] as List<dynamic>? ?? [];
    final status = _order?['status']?.toString() ?? 'pending';
    final statusColor = _getStatusColor(status);

    return Container(
      padding: ResponsiveScaler.padding(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => AppRouter.navigateToHome(context),
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
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(
                            ResponsiveScaler.radius(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(status),
                              size: ResponsiveScaler.icon(12),
                              color: statusColor,
                            ),
                            SizedBox(width: ResponsiveScaler.width(4)),
                            Text(
                              _getStatusText(status),
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveScaler.font(10),
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
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
          // Solo muestra botón de agregar si la orden está pendiente
          if (_order != null && _order!['status'] == 'pending')
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
    final status = _order!['status']?.toString() ?? 'pending';
    // Solo permite eliminar items si la orden está pendiente
    final canDeleteItems = status == 'pending';

    return ListView.builder(
      padding: ResponsiveScaler.padding(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return SizedBox(height: ResponsiveScaler.height(80));
        }
        return _buildOrderItem(
          items[index] as Map<String, dynamic>,
          index,
          canDeleteItems,
        );
      },
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item, int index, bool canDelete) {
    final variantName = item['variantName'];
    final customerName = item['customerName'];
    final price = (item['price'] as num?)?.toDouble() ?? 0.0;
    final quantity = item['quantity'] ?? 1;
    final subtotal = price * quantity;
    final hasVariant = variantName != null && variantName.toString().isNotEmpty;
    final hasCustomer =
        customerName != null && customerName.toString().isNotEmpty;

    final child = Container(
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

    // Solo permite deslizar para eliminar si la orden está pendiente
    if (!canDelete) return child;

    return Dismissible(
      key: Key('item-$index-${item['name']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: ResponsiveScaler.margin(const EdgeInsets.only(bottom: 10)),
        padding: ResponsiveScaler.padding(const EdgeInsets.only(right: 20)),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(14)),
        ),
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: ResponsiveScaler.icon(28),
        ),
      ),
      confirmDismiss: (direction) async {
        return await ConfirmDialog.showDelete(
          context,
          itemName: 'item',
          customMessage: '¿Deseas eliminar "${item['name']}" del pedido?',
        );
      },
      onDismissed: (direction) => _removeItem(index),
      child: child,
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
        ],
      ),
    );
  }
}

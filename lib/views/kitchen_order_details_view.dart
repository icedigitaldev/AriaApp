import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refena_flutter/refena_flutter.dart';
import '../components/composite/transparent_app_bar.dart';
import '../components/ui/app_snackbar.dart';
import '../design/colors/app_colors.dart';
import '../design/responsive/responsive_scaler.dart';
import '../design/themes/app_themes.dart';
import '../features/orders/components/composite/order_header.dart';
import '../features/orders/components/composite/order_items_list.dart';
import '../features/orders/components/composite/kitchen_action_buttons.dart';
import '../features/orders/components/ui/order_status_badge.dart';
import '../features/orders/components/ui/time_indicator.dart';
import '../features/orders/controllers/orders_controller.dart';
import '../features/orders/services/orders_service.dart';
import '../utils/app_logger.dart';

class KitchenOrderDetailsView extends StatefulWidget {
  const KitchenOrderDetailsView({Key? key}) : super(key: key);

  @override
  State<KitchenOrderDetailsView> createState() =>
      _KitchenOrderDetailsViewState();
}

class _KitchenOrderDetailsViewState extends State<KitchenOrderDetailsView> {
  Map<int, bool> _itemStatus = {};
  String? _currentOrderStatus;
  bool _isInitialized = false;
  bool _isUpdatingStatus = false;

  @override
  Widget build(BuildContext context) {
    AppThemes.init(context);

    final order =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (order == null) {
      return const Scaffold(
        body: Center(child: Text('No se encontró información de la orden')),
      );
    }

    // Inicializa el estado local de la orden
    if (!_isInitialized) {
      _currentOrderStatus = order['status'];
      // Marca todos los items como completados si la orden ya está en progreso o finalizada
      if (_currentOrderStatus == 'preparing' ||
          _currentOrderStatus == 'completed' ||
          _currentOrderStatus == 'paid') {
        final items = order['items'] as List;
        for (var i = 0; i < items.length; i++) {
          _itemStatus[i] = true;
        }
      }
      _isInitialized = true;
    }

    final allItemsCompleted = order['items'].asMap().entries.every(
      (e) => _itemStatus[e.key] ?? false,
    );

    // Orden finalizada si está completada o pagada (solo lectura)
    final isOrderFinalized =
        _currentOrderStatus == 'completed' || _currentOrderStatus == 'paid';

    return Consumer(
      builder: (context, ref) {
        final ordersController = ref.notifier(ordersControllerProvider);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: TransparentAppBar(
            backgroundColor: AppColors.appBarBackground,
          ),
          body: Container(
            color: AppColors.background,
            child: SafeArea(
              child: Column(
                children: [
                  OrderHeader(
                    title:
                        'Orden #${order['orderNumber'] != null ? OrdersService.formatOrderNumber(order['orderNumber']) : order['id'].toString().substring(0, 6)}',
                    subtitle:
                        'Mesa ${order['tableNumber'] ?? '--'} • ${order['staffName'] ?? 'Sin asignar'}',
                    onBack: () => Navigator.pop(context),
                    actions: [
                      OrderStatusBadge(
                        status: _currentOrderStatus!,
                        compact: false,
                      ),
                    ],
                  ),

                  _buildTimeInfo(order),

                  Expanded(
                    child: Padding(
                      padding: ResponsiveScaler.padding(
                        const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: ResponsiveScaler.padding(
                              const EdgeInsets.only(left: 4.0, bottom: 16.0),
                            ),
                            child: Text(
                              'Elementos del pedido',
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveScaler.font(20),
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: OrderItemsList(
                              items: (order['items'] as List)
                                  .map((item) => item as Map<String, dynamic>)
                                  .toList(),
                              showCheckboxes: true,
                              showNotes: true,
                              itemStatus: _itemStatus,
                              orderStatus: _currentOrderStatus!,
                              onItemChecked: (index, isChecked) {
                                if (isOrderFinalized) return;
                                setState(() => _itemStatus[index] = isChecked);
                                AppLogger.log(
                                  'Item ${isChecked ? "marcado" : "desmarcado"}: ${order['items'][index]['name']}',
                                  prefix: 'COCINA:',
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (!isOrderFinalized)
                    KitchenActionButtons(
                      orderStatus: _currentOrderStatus!,
                      allItemsCompleted: allItemsCompleted,
                      isLoading: _isUpdatingStatus,
                      onStatusUpdate: (newStatus) => _handleStatusUpdate(
                        ordersController,
                        order['id'],
                        newStatus,
                        order['items'] as List,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleStatusUpdate(
    OrdersController controller,
    String orderId,
    String newStatus,
    List items,
  ) async {
    setState(() => _isUpdatingStatus = true);

    try {
      await controller.changeStatus(orderId, newStatus);

      setState(() {
        _currentOrderStatus = newStatus;
        if (newStatus == 'preparing') {
          for (var i = 0; i < items.length; i++) {
            _itemStatus[i] = true;
          }
        }
      });
    } catch (e) {
      AppLogger.log('Error actualizando estado: $e', prefix: 'COCINA_ERROR:');
      if (mounted) {
        AppSnackbar.error(context, 'Error al actualizar el estado');
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  Widget _buildTimeInfo(Map<String, dynamic> order) {
    DateTime? createdAt;
    if (order['createdAt'] != null) {
      final timestamp = order['createdAt'];
      if (timestamp is DateTime) {
        createdAt = timestamp;
      } else if (timestamp.toDate != null) {
        createdAt = timestamp.toDate();
      }
    }

    String formattedTime = '--:--';
    if (createdAt != null) {
      final hour = createdAt.hour.toString().padLeft(2, '0');
      final minute = createdAt.minute.toString().padLeft(2, '0');
      formattedTime = '$hour:$minute';
    }

    return Container(
      margin: ResponsiveScaler.margin(const EdgeInsets.all(16)),
      padding: ResponsiveScaler.padding(const EdgeInsets.all(16)),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.9),
        borderRadius: BorderRadius.circular(ResponsiveScaler.radius(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            icon: Icons.access_time,
            label: 'Hora de pedido',
            value: formattedTime,
          ),
          Container(
            height: ResponsiveScaler.height(40),
            width: 1,
            color: AppColors.inputBorder,
          ),
          Column(
            children: [
              Icon(
                Icons.timer,
                color: AppColors.iconMuted,
                size: ResponsiveScaler.icon(20),
              ),
              SizedBox(height: ResponsiveScaler.height(4)),
              Text(
                'Tiempo transcurrido',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveScaler.font(12),
                  color: AppColors.textMuted,
                ),
              ),
              if (createdAt != null)
                TimeIndicator(
                  orderTime: createdAt,
                  showIcon: false,
                  compact: true,
                )
              else
                Text(
                  '--:--',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveScaler.font(14),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.iconMuted, size: ResponsiveScaler.icon(20)),
        SizedBox(height: ResponsiveScaler.height(4)),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveScaler.font(12),
            color: AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveScaler.font(16),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

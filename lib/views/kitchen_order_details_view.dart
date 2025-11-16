import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/composite/transparent_app_bar.dart';
import '../design/colors/app_colors.dart';
import '../design/responsive/responsive_scaler.dart';
import '../design/themes/app_themes.dart';
import '../features/orders/components/composite/order_header.dart';
import '../features/orders/components/composite/order_items_list.dart';
import '../features/orders/components/composite/kitchen_action_buttons.dart';
import '../features/orders/components/ui/order_status_badge.dart';
import '../features/orders/components/ui/time_indicator.dart';
import '../utils/app_logger.dart';

class KitchenOrderDetailsView extends StatefulWidget {
  const KitchenOrderDetailsView({Key? key}) : super(key: key);

  @override
  State<KitchenOrderDetailsView> createState() => _KitchenOrderDetailsViewState();
}

class _KitchenOrderDetailsViewState extends State<KitchenOrderDetailsView> {
  Map<int, bool> itemStatus = {};
  String? _currentOrderStatus;
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    AppThemes.init(context);
    ResponsiveSize.init(context);

    final order = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (order == null) {
      return const Scaffold(
        body: Center(child: Text('No se encontró información de la orden')),
      );
    }

    if (!_isInitialized) {
      _currentOrderStatus = order['status'];
      // Si la orden ya está en preparación o completada, marca todos los items.
      if (_currentOrderStatus == 'preparing' || _currentOrderStatus == 'completed') {
        final items = order['items'] as List;
        for (var i = 0; i < items.length; i++) {
          itemStatus[i] = true;
        }
      }
      _isInitialized = true;
    }

    // Verifica si todos los items están completados
    final allItemsCompleted = order['items'].asMap().entries.every(
          (e) => itemStatus[e.key] ?? false,
    );

    final isOrderFinalized = _currentOrderStatus == 'completed';

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
              // Header con componente compartido
              OrderHeader(
                title: 'Orden #${order['id']}',
                subtitle: 'Mesa ${order['tableNumber']} • ${order['waiter']}',
                onBack: () => Navigator.pop(context),
                actions: [
                  OrderStatusBadge(
                    status: _currentOrderStatus!,
                    compact: false,
                  ),
                ],
              ),

              // Información de tiempo
              _buildTimeInfo(order),

              // Lista de items con componente compartido
              Expanded(
                child: Padding(
                  padding: ResponsiveSize.padding(
                    const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: ResponsiveSize.padding(
                          const EdgeInsets.only(left: 4.0, bottom: 16.0),
                        ),
                        child: Text(
                          'Elementos del pedido',
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveSize.font(20),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: OrderItemsList(
                          items: order['items'],
                          showCheckboxes: true,
                          showNotes: true,
                          itemStatus: itemStatus,
                          orderStatus: _currentOrderStatus!,
                          onItemChecked: (index, isChecked) {
                            // Bloquea la interacción si la orden ya está completada
                            if (isOrderFinalized) return;

                            setState(() => itemStatus[index] = isChecked);
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

              // Botones de acción usando el nuevo componente
              if (!isOrderFinalized)
                KitchenActionButtons(
                  orderStatus: _currentOrderStatus!,
                  allItemsCompleted: allItemsCompleted,
                  onStatusUpdate: (newStatus) {
                    setState(() {
                      _currentOrderStatus = newStatus;
                      // Si se comienza la preparación, marca todos los items
                      if (newStatus == 'preparing') {
                        final items = order['items'] as List;
                        for (var i = 0; i < items.length; i++) {
                          itemStatus[i] = true;
                        }
                      }
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo(Map<String, dynamic> order) {
    return Container(
      margin: ResponsiveSize.margin(const EdgeInsets.all(20)),
      padding: ResponsiveSize.padding(const EdgeInsets.all(16)),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.9),
        borderRadius: BorderRadius.circular(ResponsiveSize.radius(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            icon: Icons.access_time,
            label: 'Hora de pedido',
            value: order['time'],
          ),
          Container(
            height: ResponsiveSize.height(40),
            width: 1,
            color: AppColors.inputBorder,
          ),
          Column(
            children: [
              Icon(
                Icons.timer,
                color: AppColors.iconMuted,
                size: ResponsiveSize.icon(20),
              ),
              SizedBox(height: ResponsiveSize.height(4)),
              Text(
                'Tiempo transcurrido',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveSize.font(12),
                  color: AppColors.textMuted,
                ),
              ),
              TimeIndicator(
                orderTime: order['orderTime'],
                showIcon: false,
                compact: true,
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
        Icon(icon, color: AppColors.iconMuted, size: ResponsiveSize.icon(20)),
        SizedBox(height: ResponsiveSize.height(4)),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveSize.font(12),
            color: AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveSize.font(16),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refena_flutter/refena_flutter.dart';
import '../components/composite/transparent_app_bar.dart';
import '../components/ui/app_loader.dart';
import '../design/colors/app_colors.dart';
import '../design/colors/app_gradients.dart';
import '../design/responsive/responsive_scaler.dart';
import '../design/themes/app_themes.dart';
import '../features/orders/components/composite/order_header.dart';
import '../features/orders/components/composite/date_selector.dart';
import '../features/orders/components/ui/info_chip.dart';
import '../features/orders/controllers/orders-history-controller.dart';
import '../features/orders/states/orders-history-state.dart';
import '../features/orders/services/orders_service.dart';

class KitchenHistoryView extends StatefulWidget {
  const KitchenHistoryView({Key? key}) : super(key: key);

  @override
  State<KitchenHistoryView> createState() => _KitchenHistoryViewState();
}

class _KitchenHistoryViewState extends State<KitchenHistoryView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Inicializa el controlador después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.notifier(ordersHistoryControllerProvider).initialize();
    });

    // Detecta cuando el usuario llega al final de la lista
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Carga más órdenes cuando el usuario está cerca del final
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.notifier(ordersHistoryControllerProvider).loadMoreOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    AppThemes.init(context);

    return Consumer(
      builder: (context, ref) {
        final historyState = ref.watch(ordersHistoryControllerProvider);
        final historyController = ref.notifier(ordersHistoryControllerProvider);

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
                    title: 'Historial de Órdenes',
                    subtitle: 'Órdenes completadas',
                    onBack: () => Navigator.pop(context),
                  ),

                  // Selector de fecha
                  Container(
                    margin: ResponsiveScaler.margin(
                      const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: DateSelector(
                      selectedDate: historyState.selectedDate,
                      onDateChanged: (date) =>
                          historyController.changeDate(date),
                    ),
                  ),

                  SizedBox(height: ResponsiveScaler.height(12)),

                  // Resumen de estadísticas del día
                  if (!historyState.isLoading && historyState.orders.isNotEmpty)
                    _buildDayStats(historyState),

                  // Lista de órdenes con carga infinita
                  Expanded(child: _buildOrdersList(historyState)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Estadísticas resumidas del día seleccionado
  Widget _buildDayStats(OrdersHistoryState historyState) {
    return Container(
      margin: ResponsiveScaler.margin(
        const EdgeInsets.symmetric(horizontal: 16),
      ),
      padding: ResponsiveScaler.padding(
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.totalAmountBackground,
        borderRadius: BorderRadius.circular(ResponsiveScaler.radius(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.receipt_long,
            value: '${historyState.totalOrders}',
            label: 'Órdenes',
          ),
          _buildStatItem(
            icon: Icons.restaurant_menu,
            value: '${historyState.totalItems}',
            label: 'Items',
          ),
          _buildStatItem(
            icon: Icons.attach_money,
            value: '\$${historyState.totalAmount.toStringAsFixed(2)}',
            label: 'Total',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: ResponsiveScaler.icon(20), color: AppColors.primary),
        SizedBox(height: ResponsiveScaler.height(4)),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveScaler.font(16),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveScaler.font(12),
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList(OrdersHistoryState historyState) {
    // Estado de carga inicial
    if (historyState.isLoading) {
      return Center(
        child: AppLoader(
          size: ResponsiveScaler.width(40),
          message: 'Cargando historial...',
        ),
      );
    }

    // Sin órdenes para la fecha seleccionada
    if (historyState.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: ResponsiveScaler.icon(64),
              color: AppColors.iconMuted,
            ),
            SizedBox(height: ResponsiveScaler.height(16)),
            Text(
              'No hay órdenes completadas',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(16),
                color: AppColors.textMuted,
              ),
            ),
            Text(
              'para esta fecha',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(14),
                color: AppColors.textMuted.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: ResponsiveScaler.padding(
        const EdgeInsets.fromLTRB(16, 12, 16, 16),
      ),
      // Agrega un item extra si está cargando más
      itemCount:
          historyState.orders.length + (historyState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Indicador de carga al final de la lista
        if (index >= historyState.orders.length) {
          return _buildLoadingIndicator();
        }

        return _buildOrderCard(historyState.orders[index]);
      },
    );
  }

  // Indicador de carga para scroll infinito
  Widget _buildLoadingIndicator() {
    return Container(
      padding: ResponsiveScaler.padding(
        const EdgeInsets.symmetric(vertical: 20),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLoader(size: ResponsiveScaler.width(24)),
            SizedBox(width: ResponsiveScaler.width(12)),
            Text(
              'Cargando más órdenes...',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(14),
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final controller = context.notifier(ordersHistoryControllerProvider);
    final completedTime = controller.getCompletedTime(order);
    final prepTime = controller.getPreparationTime(order);
    final items = order['items'] as List? ?? [];
    final total = (order['totalAmount'] as num?)?.toDouble() ?? 0;

    return GestureDetector(
      onTap: () {
        // Navega al detalle de la orden
        Navigator.pushNamed(
          context,
          '/kitchen-order-details',
          arguments: order,
        );
      },
      child: Container(
        margin: ResponsiveScaler.margin(const EdgeInsets.only(bottom: 16)),
        padding: ResponsiveScaler.padding(const EdgeInsets.all(16)),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(16)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, ResponsiveScaler.height(4)),
            ),
          ],
        ),
        child: Row(
          children: [
            // Indicador de completado con hora
            Container(
              width: ResponsiveScaler.width(60),
              height: ResponsiveScaler.height(60),
              decoration: BoxDecoration(
                gradient: AppGradients.success,
                borderRadius: BorderRadius.circular(
                  ResponsiveScaler.radius(16),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.textOnPrimary,
                    size: ResponsiveScaler.icon(24),
                  ),
                  Text(
                    completedTime,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveScaler.font(9),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: ResponsiveScaler.width(16)),

            // Información de la orden
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order['orderNumber'] != null
                            ? '#${OrdersService.formatOrderNumber(order['orderNumber'])}'
                            : 'Orden',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveScaler.font(16),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveScaler.font(16),
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveScaler.height(4)),

                  // Mesa y mesero
                  Row(
                    children: [
                      Icon(
                        Icons.table_bar,
                        size: ResponsiveScaler.icon(14),
                        color: AppColors.iconMuted,
                      ),
                      SizedBox(width: ResponsiveScaler.width(4)),
                      Text(
                        'Mesa ${order['tableNumber'] ?? '--'}',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveScaler.font(14),
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (order['staffName'] != null) ...[
                        SizedBox(width: ResponsiveScaler.width(12)),
                        Icon(
                          Icons.person,
                          size: ResponsiveScaler.icon(14),
                          color: AppColors.iconMuted,
                        ),
                        SizedBox(width: ResponsiveScaler.width(4)),
                        Text(
                          order['staffName'],
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveScaler.font(14),
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: ResponsiveScaler.height(8)),

                  // Chips de información
                  Row(
                    children: [
                      InfoChip(
                        icon: Icons.timer,
                        text: prepTime,
                        color: AppColors.info,
                      ),
                      SizedBox(width: ResponsiveScaler.width(8)),
                      InfoChip(
                        text: '${items.length} items',
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

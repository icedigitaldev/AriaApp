import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refena_flutter/refena_flutter.dart';
import '../components/composite/transparent_app_bar.dart';
import '../components/ui/app_loader.dart';
import '../components/ui/empty_state.dart';
import '../design/colors/app_colors.dart';
import '../design/responsive/responsive_scaler.dart';
import '../design/themes/app_themes.dart';
import '../features/orders/components/composite/order_header.dart';
import '../features/orders/components/composite/date_selector.dart';
import '../features/orders/controllers/orders-history-controller.dart';
import '../features/orders/services/orders_service.dart';

class OrdersHistoryView extends StatefulWidget {
  const OrdersHistoryView({Key? key}) : super(key: key);

  @override
  State<OrdersHistoryView> createState() => _OrdersHistoryViewState();
}

class _OrdersHistoryViewState extends State<OrdersHistoryView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.notifier(ordersHistoryControllerProvider).initialize();
    });
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchFocusChange() {
    setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
  }

  // Cierra el teclado y quita el focus del buscador
  void _unfocusSearch() {
    _searchFocusNode.unfocus();
  }

  // Filtra las órdenes localmente sin consultar Firebase
  List<Map<String, dynamic>> _filterOrders(List<Map<String, dynamic>> orders) {
    if (_searchQuery.isEmpty) return orders;

    final query = _searchQuery.toLowerCase();
    return orders.where((order) {
      final tableNumber = order['tableNumber']?.toString().toLowerCase() ?? '';
      final staffName = order['staffName']?.toString().toLowerCase() ?? '';
      final orderNumber = order['orderNumber']?.toString() ?? '';

      return tableNumber.contains(query) ||
          staffName.contains(query) ||
          orderNumber.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    AppThemes.init(context);

    return Consumer(
      builder: (context, ref) {
        final historyState = ref.watch(ordersHistoryControllerProvider);
        final historyController = ref.notifier(ordersHistoryControllerProvider);

        return GestureDetector(
          // Cierra el teclado al tocar fuera del buscador
          onTap: _unfocusSearch,
          child: Scaffold(
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
                    // Buscador local
                    _buildSearchBar(),
                    Expanded(child: _buildOrdersList(historyState)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    // Colores según estado de focus
    final borderColor = _isSearchFocused
        ? AppColors.primary
        : AppColors.inputBorder;
    final iconColor = _isSearchFocused
        ? AppColors.primary
        : AppColors.iconMuted;

    return Container(
      margin: ResponsiveScaler.margin(const EdgeInsets.fromLTRB(16, 12, 16, 8)),
      padding: ResponsiveScaler.padding(
        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(ResponsiveScaler.radius(12)),
        border: Border.all(
          color: borderColor,
          width: _isSearchFocused ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: iconColor, size: ResponsiveScaler.icon(20)),
          SizedBox(width: ResponsiveScaler.width(10)),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveScaler.font(14),
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar por mesa, mesero u orden...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: ResponsiveScaler.font(14),
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: ResponsiveScaler.height(10),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Icon(
                Icons.close,
                color: iconColor,
                size: ResponsiveScaler.icon(18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(historyState) {
    if (historyState.isLoading) {
      return Center(
        child: AppLoader(
          size: ResponsiveScaler.width(40),
          message: 'Cargando historial...',
        ),
      );
    }

    if (historyState.orders.isEmpty) {
      return const EmptyState(
        icon: Icons.history,
        title: 'Sin órdenes',
        description: 'No hay órdenes completadas para esta fecha.',
      );
    }

    // Filtra las órdenes localmente según la búsqueda
    final filteredOrders = _filterOrders(
      List<Map<String, dynamic>>.from(historyState.orders),
    );

    if (filteredOrders.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'Sin resultados',
        description: 'No se encontraron órdenes con ese criterio.',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: ResponsiveScaler.padding(
        const EdgeInsets.fromLTRB(16, 8, 16, 16),
      ),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(filteredOrders[index]);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final controller = context.notifier(ordersHistoryControllerProvider);
    final status = order['status']?.toString() ?? 'completed';
    final isPaid = status == 'paid';
    final displayTime = controller.getCompletedTime(order);
    final prepTime = controller.getPreparationTime(order);
    final total = (order['totalAmount'] as num?)?.toDouble() ?? 0;

    // Color del estado
    final statusColor = isPaid ? AppColors.primary : AppColors.success;
    final statusText = isPaid ? 'Pagado' : 'Completado';

    return GestureDetector(
      onTap: () {
        _unfocusSearch();
        Navigator.pushNamed(
          context,
          '/kitchen-order-details',
          arguments: order,
        );
      },
      child: Container(
        margin: ResponsiveScaler.margin(const EdgeInsets.only(bottom: 12)),
        padding: ResponsiveScaler.padding(const EdgeInsets.all(14)),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(ResponsiveScaler.radius(14)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, ResponsiveScaler.height(2)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Número de orden + Estado y Precio
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Número de orden
                Expanded(
                  child: Text(
                    order['orderNumber'] != null
                        ? 'Orden #${OrdersService.formatOrderNumber(order['orderNumber'])}'
                        : 'Orden',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveScaler.font(16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Estado y precio
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: ResponsiveScaler.padding(
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          ResponsiveScaler.radius(8),
                        ),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveScaler.font(11),
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: ResponsiveScaler.height(10)),
            // Contenido: Precio circular + Datos
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Precio (contenedor adaptable)
                Container(
                  padding: ResponsiveScaler.padding(
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      ResponsiveScaler.radius(12),
                    ),
                  ),
                  child: Text(
                    'S/${total.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveScaler.font(14),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveScaler.width(12)),
                // Datos a la derecha del precio
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hora y Tiempo de preparación
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: ResponsiveScaler.icon(14),
                            color: AppColors.iconMuted,
                          ),
                          SizedBox(width: ResponsiveScaler.width(4)),
                          Text(
                            displayTime,
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveScaler.font(13),
                              color: AppColors.textMuted,
                            ),
                          ),
                          SizedBox(width: ResponsiveScaler.width(12)),
                          Icon(
                            Icons.timer_outlined,
                            size: ResponsiveScaler.icon(14),
                            color: AppColors.info,
                          ),
                          SizedBox(width: ResponsiveScaler.width(4)),
                          Text(
                            'Prep: $prepTime',
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveScaler.font(13),
                              fontWeight: FontWeight.w500,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveScaler.height(4)),
                      // Mesa
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
                              fontSize: ResponsiveScaler.font(13),
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      // Mesero
                      if (order['staffName'] != null) ...[
                        SizedBox(height: ResponsiveScaler.height(4)),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: ResponsiveScaler.icon(14),
                              color: AppColors.iconMuted,
                            ),
                            SizedBox(width: ResponsiveScaler.width(4)),
                            Expanded(
                              child: Text(
                                order['staffName'],
                                style: GoogleFonts.poppins(
                                  fontSize: ResponsiveScaler.font(13),
                                  color: AppColors.textMuted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Flecha de navegación
                Icon(
                  Icons.chevron_right,
                  color: AppColors.iconMuted,
                  size: ResponsiveScaler.icon(22),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

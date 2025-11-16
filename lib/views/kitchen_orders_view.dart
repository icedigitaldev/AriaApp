import 'package:flutter/material.dart';
import '../components/composite/transparent_app_bar.dart';
import '../design/colors/app_colors.dart';
import '../design/colors/app_gradients.dart';
import '../design/responsive/responsive_scaler.dart';
import '../design/themes/app_themes.dart';
import '../features/orders/components/composite/order_header.dart';
import '../features/orders/components/composite/order_card.dart';
import '../features/orders/components/composite/order_filters_bar.dart';
import '../features/orders/components/composite/order_stats_container.dart';
import '../utils/app_logger.dart';

class KitchenOrdersView extends StatefulWidget {
  const KitchenOrdersView({Key? key}) : super(key: key);

  @override
  State<KitchenOrdersView> createState() => _KitchenOrdersViewState();
}

class _KitchenOrdersViewState extends State<KitchenOrdersView> {
  String selectedFilter = 'pending';
  late PageController _pageController;
  final GlobalKey<OrderFiltersBarState> _filtersBarKey = GlobalKey();

  final List<String> filterIds = ['all', 'pending', 'preparing', 'completed'];

  final List<Map<String, dynamic>> orders = [
    {
      'id': 1,
      'tableNumber': 2,
      'waiter': 'Carlos M.',
      'time': '10:35 AM',
      'status': 'pending',
      'items': [
        {'name': 'Ceviche Clásico', 'quantity': 2, 'notes': 'Sin cebolla'},
        {'name': 'Arroz con Mariscos', 'quantity': 1, 'notes': ''},
      ],
      'orderTime': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'id': 2,
      'tableNumber': 5,
      'waiter': 'María L.',
      'time': '10:42 AM',
      'status': 'preparing',
      'items': [
        {'name': 'Ceviche Mixto', 'quantity': 1, 'notes': ''},
        {'name': 'Chaufa de Mariscos', 'quantity': 2, 'notes': 'Extra picante'},
      ],
      'orderTime': DateTime.now().subtract(const Duration(minutes: 12)),
    },
    {
      'id': 3,
      'tableNumber': 7,
      'waiter': 'Juan P.',
      'time': '10:48 AM',
      'status': 'pending',
      'items': [
        {'name': 'Seco de Cabrito', 'quantity': 3, 'notes': ''},
      ],
      'orderTime': DateTime.now().subtract(const Duration(minutes: 2)),
    },
    {
      'id': 4,
      'tableNumber': 1,
      'waiter': 'Ana G.',
      'time': '10:25 AM',
      'status': 'completed',
      'items': [
        {'name': 'Ceviche Clásico', 'quantity': 1, 'notes': ''},
        {'name': 'Arroz con Mariscos', 'quantity': 1, 'notes': ''},
      ],
      'orderTime': DateTime.now().subtract(const Duration(minutes: 25)),
    },
  ];

  List<Map<String, dynamic>> getFilteredOrders(String filter) {
    if (filter == 'all') return orders;
    return orders.where((o) => o['status'] == filter).toList();
  }

  @override
  void initState() {
    super.initState();
    final initialPage = filterIds.indexOf(selectedFilter);
    _pageController = PageController(initialPage: initialPage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filtersBarKey.currentState?.scrollToSelectedFilter();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      selectedFilter = filterIds[index];
    });
    AppLogger.log('Filtro cambiado por deslizamiento: $selectedFilter', prefix: 'COCINA:');
  }

  void _onFilterChanged(String filter) {
    setState(() {
      selectedFilter = filter;
    });
    final pageIndex = filterIds.indexOf(filter);
    if (pageIndex != -1 && _pageController.hasClients) {
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    AppLogger.log('Filtro seleccionado: $filter', prefix: 'COCINA:');
  }

  @override
  Widget build(BuildContext context) {
    AppThemes.init(context);
    ResponsiveSize.init(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TransparentAppBar(
        backgroundColor: AppColors.appBarBackground,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con componente compartido
              OrderHeader(
                title: 'ARIA Cocina',
                subtitle: 'Gestión de pedidos',
                showBackButton: false,
                leadingIcon: Container(
                  width: ResponsiveSize.width(48),
                  height: ResponsiveSize.height(48),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryButton,
                    borderRadius: BorderRadius.circular(ResponsiveSize.radius(16)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowPurple,
                        blurRadius: 12,
                        offset: Offset(0, ResponsiveSize.height(4)),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    color: AppColors.iconOnPrimary,
                    size: ResponsiveSize.icon(28),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      AppLogger.log('Historial de pedidos', prefix: 'COCINA:');
                      Navigator.pushNamed(context, '/kitchen-history');
                    },
                    icon: Container(
                      padding: ResponsiveSize.padding(const EdgeInsets.all(8)),
                      decoration: BoxDecoration(
                        color: AppColors.card.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(ResponsiveSize.radius(12)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 10,
                            offset: Offset(0, ResponsiveSize.height(4)),
                          ),
                        ],
                      ),
                      child: Icon(Icons.history, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),

              // Filtros con componente compartido
              OrderFiltersBar(
                key: _filtersBarKey,
                selectedFilter: selectedFilter,
                onFilterChanged: _onFilterChanged,
                orders: orders,
                pageController: _pageController,
              ),

              // Estadísticas con componente compartido
              OrderStatsContainer(
                orders: getFilteredOrders(selectedFilter),
                showPending: true,
                showPreparing: true,
                showAverageTime: true,
                averageTime: '12 min',
              ),

              // Lista de órdenes con PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: filterIds.length,
                  itemBuilder: (context, pageIndex) {
                    final currentFilter = filterIds[pageIndex];
                    final filteredOrders = getFilteredOrders(currentFilter);

                    return ListView.builder(
                      padding: ResponsiveSize.padding(
                        const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      ),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) => OrderCard(
                        order: filteredOrders[index],
                        onTap: () {
                          AppLogger.log(
                            'Orden seleccionada: ${filteredOrders[index]['id']}',
                            prefix: 'COCINA:',
                          );
                          Navigator.pushNamed(
                            context,
                            '/kitchen-order-details',
                            arguments: filteredOrders[index],
                          );
                        },
                        showWaiterInfo: true,
                        showTableNumber: true,
                        showTimer: true,
                        showItems: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
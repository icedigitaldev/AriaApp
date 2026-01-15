import 'package:flutter/material.dart';
import 'package:refena_flutter/refena_flutter.dart';
import '../components/ui/status_app_bar.dart';
import '../components/ui/app_loader.dart';
import '../components/ui/cached_network_image.dart';
import '../components/ui/empty_state.dart';
import '../design/colors/app_colors.dart';
import '../design/colors/app_gradients.dart';
import '../design/responsive/responsive_scaler.dart';
import '../design/themes/app_themes.dart';
import '../components/ui/app_header.dart';
import '../features/orders/components/composite/order_card.dart';
import '../features/orders/components/composite/order_filters_bar.dart';
import '../features/orders/components/composite/order_stats_container.dart';
import '../features/orders/controllers/orders_controller.dart';
import '../utils/app_logger.dart';
import '../auth/current_user.dart';

class KitchenOrdersView extends StatefulWidget {
  KitchenOrdersView({Key? key}) : super(key: key);

  @override
  State<KitchenOrdersView> createState() => _KitchenOrdersViewState();
}

class _KitchenOrdersViewState extends State<KitchenOrdersView> {
  late PageController _pageController;
  final GlobalKey<OrderFiltersBarState> _filtersBarKey = GlobalKey();
  final List<String> filterIds = ['all', 'pending', 'preparing', 'completed'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.notifier(ordersControllerProvider).initialize();
      _filtersBarKey.currentState?.scrollToSelectedFilter();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, OrdersController controller) {
    controller.selectFilter(filterIds[index]);
    AppLogger.log(
      'Filtro cambiado por deslizamiento: ${filterIds[index]}',
      prefix: 'COCINA:',
    );
  }

  void _onFilterChanged(String filter, OrdersController controller) {
    controller.selectFilter(filter);
    final pageIndex = filterIds.indexOf(filter);
    if (pageIndex != -1 && _pageController.hasClients) {
      _pageController.animateToPage(
        pageIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    AppLogger.log('Filtro seleccionado: $filter', prefix: 'COCINA:');
  }

  @override
  Widget build(BuildContext context) {
    AppThemes.init(context);

    return Consumer(
      builder: (context, ref) {
        final ordersState = ref.watch(ordersControllerProvider);
        final ordersController = ref.notifier(ordersControllerProvider);

        // Filtra órdenes por estado
        List<Map<String, dynamic>> getFilteredOrders(String filter) {
          if (filter == 'all') return ordersState.orders;
          return ordersState.orders
              .where((o) => o['status'] == filter)
              .toList();
        }

        // Calcula el tiempo promedio de preparación basado en órdenes completadas
        String getAverageTime() {
          final completedOrders = ordersState.orders
              .where((o) => o['status'] == 'completed')
              .toList();

          if (completedOrders.isEmpty) return '--';

          int totalMinutes = 0;
          int validOrders = 0;

          for (final order in completedOrders) {
            final createdAt = order['createdAt'];
            final completedAt = order['completedAt'];

            if (createdAt != null && completedAt != null) {
              DateTime? start;
              DateTime? end;

              if (createdAt is DateTime) {
                start = createdAt;
              } else if (createdAt.toDate != null) {
                start = createdAt.toDate();
              }

              if (completedAt is DateTime) {
                end = completedAt;
              } else if (completedAt.toDate != null) {
                end = completedAt.toDate();
              }

              if (start != null && end != null) {
                totalMinutes += end.difference(start).inMinutes;
                validOrders++;
              }
            }
          }

          if (validOrders == 0) return '--';

          final avgMinutes = (totalMinutes / validOrders).round();
          return '$avgMinutes min';
        }

        if (ordersState.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: AppLoader(size: ResponsiveScaler.width(40))),
          );
        }

        // Lógica de selección de imagen (Prioridad: imageUrl > avatarUrl)
        final String? imageUrl = CurrentUserAuth.instance.imageUrl;
        final String? avatarUrl = CurrentUserAuth.instance.avatarUrl;
        final String? displayImage = (imageUrl != null && imageUrl.isNotEmpty)
            ? imageUrl
            : (avatarUrl != null && avatarUrl.isNotEmpty ? avatarUrl : null);
        final borderRadius = BorderRadius.circular(ResponsiveScaler.radius(16));

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: StatusAppBar(backgroundColor: AppColors.appBarBackground),
          body: Container(
            decoration: BoxDecoration(color: AppColors.background),
            child: SafeArea(
              child: Column(
                children: [
                  AppHeader(
                    title: 'ARIA Cocina',
                    subtitle: 'Gestión de pedidos',
                    showBackButton: false,
                    leadingIcon: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                      child: Container(
                        width: ResponsiveScaler.width(48),
                        height: ResponsiveScaler.height(48),
                        decoration: BoxDecoration(
                          gradient: (displayImage == null)
                              ? AppGradients.primaryButton
                              : null,
                          color: (displayImage != null) ? AppColors.card : null,
                          borderRadius: borderRadius,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowPurple,
                              blurRadius: 12,
                              offset: Offset(0, ResponsiveScaler.height(4)),
                            ),
                          ],
                        ),
                        child: (displayImage != null)
                            ? CachedNetworkImage(
                                imageUrl: displayImage,
                                width: ResponsiveScaler.width(48),
                                height: ResponsiveScaler.height(48),
                                borderRadius: borderRadius,
                                placeholder: Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                errorWidget: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveScaler.radius(12),
                                  ),
                                  child: Image.asset(
                                    'assets/images/aria-logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveScaler.radius(12),
                                ),
                                child: Image.asset(
                                  'assets/images/aria-logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          AppLogger.log(
                            'Historial de pedidos',
                            prefix: 'COCINA:',
                          );
                          Navigator.pushNamed(context, '/orders-history');
                        },
                        icon: Container(
                          padding: ResponsiveScaler.padding(EdgeInsets.all(8)),
                          decoration: BoxDecoration(
                            color: AppColors.card.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(
                              ResponsiveScaler.radius(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 10,
                                offset: Offset(0, ResponsiveScaler.height(4)),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.history,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  OrderFiltersBar(
                    key: _filtersBarKey,
                    selectedFilter: ordersState.selectedFilter,
                    onFilterChanged: (filter) =>
                        _onFilterChanged(filter, ordersController),
                    orders: ordersState.orders,
                    pageController: _pageController,
                  ),

                  OrderStatsContainer(
                    orders: getFilteredOrders(ordersState.selectedFilter),
                    showPending: true,
                    showPreparing: true,
                    showAverageTime: true,
                    averageTime: getAverageTime(),
                  ),

                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) =>
                          _onPageChanged(index, ordersController),
                      itemCount: filterIds.length,
                      itemBuilder: (context, pageIndex) {
                        final currentFilter = filterIds[pageIndex];
                        final filteredOrders = getFilteredOrders(currentFilter);

                        if (filteredOrders.isEmpty) {
                          return EmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: 'No hay órdenes',
                            description: 'No hay órdenes en esta categoría.',
                          );
                        }

                        return ListView.builder(
                          padding: ResponsiveScaler.padding(
                            EdgeInsets.fromLTRB(16, 0, 16, 16),
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
      },
    );
  }
}

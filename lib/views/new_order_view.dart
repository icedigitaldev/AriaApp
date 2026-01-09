import 'package:flutter/material.dart' hide SearchBar;
import 'package:google_fonts/google_fonts.dart';
import 'package:refena_flutter/refena_flutter.dart';
import '../auth/current_user.dart';
import '../components/composite/transparent_app_bar.dart';
import '../components/ui/app_snackbar.dart';
import '../components/ui/app_loader.dart';
import '../components/ui/empty_state.dart';
import '../design/colors/app_colors.dart';
import '../design/responsive/responsive_scaler.dart';
import '../design/themes/app_themes.dart';
import '../features/dishes/controllers/dishes_controller.dart';
import '../features/orders/components/composite/order_header.dart';
import '../features/orders/components/composite/order_filters_bar.dart';
import '../features/orders/components/composite/dish_grid.dart';
import '../features/orders/components/composite/order_summary_modal.dart';
import '../features/orders/components/ui/search_bar.dart';
import '../features/orders/services/orders_service.dart';
import '../features/tables/services/tables_service.dart';
import '../utils/app_logger.dart';

class NewOrderView extends StatefulWidget {
  NewOrderView({Key? key}) : super(key: key);

  @override
  State<NewOrderView> createState() => _NewOrderViewState();
}

class _NewOrderViewState extends State<NewOrderView> {
  String searchQuery = '';
  // Lista de items completos con variante, cliente, precio
  List<Map<String, dynamic>> _orderItems = [];
  late PageController _pageController;
  Map<String, dynamic>? _table;
  final OrdersService _ordersService = OrdersService();
  final TablesService _tablesService = TablesService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.notifier(dishesControllerProvider).initialize();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && _table == null) {
      _table = args;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Filtra platos por búsqueda
  List<Map<String, dynamic>> _filterBySearch(
    List<Map<String, dynamic>> dishes,
  ) {
    if (searchQuery.isEmpty) return dishes;
    return dishes.where((dish) {
      final name = dish['name']?.toString().toLowerCase() ?? '';
      final description = dish['description']?.toString().toLowerCase() ?? '';
      final query = searchQuery.toLowerCase();
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  // Calcula el total del pedido
  double _calculateTotal() {
    return _orderItems.fold(0.0, (sum, item) {
      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
      final quantity = item['quantity'] ?? 1;
      return sum + (price * quantity);
    });
  }

  // Obtiene mapa de cantidades para DishGrid (por dishId)
  Map<int, int> _getQuantitiesMap() {
    final map = <int, int>{};
    for (final item in _orderItems) {
      final id = int.tryParse(item['dishId']?.toString() ?? '') ?? 0;
      map[id] = (map[id] ?? 0) + ((item['quantity'] as int?) ?? 1);
    }
    return map;
  }

  // Agrega plato sin variantes al pedido
  void _addToOrder(Map<String, dynamic> dish) {
    final price = (dish['price'] as num?)?.toDouble() ?? 0.0;
    final newItem = {
      'dishId': dish['id']?.toString() ?? '',
      'dishName': dish['name'] ?? '',
      'dishImage': dish['imageUrl'] ?? dish['image'],
      'category': dish['category'],
      'description': dish['description'],
      'price': price,
      'variantName': null,
      'customerName': null,
      'quantity': 1,
    };

    setState(() => _orderItems.add(newItem));
    AppLogger.log('Plato añadido: ${dish['name']}', prefix: 'ORDEN:');
  }

  // Actualiza cantidad por dishId (para compatibilidad con DishGrid)
  void _updateQuantityByDishId(String dishId, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _orderItems.removeWhere((item) => item['dishId'] == dishId);
      } else {
        final index = _orderItems.indexWhere(
          (item) => item['dishId'] == dishId,
        );
        if (index != -1) {
          _orderItems[index]['quantity'] = newQuantity;
        }
      }
    });
  }

  // Actualiza cantidad por index (para OrderSummaryModal)
  void _updateQuantityByIndex(int index, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        if (index >= 0 && index < _orderItems.length) {
          _orderItems.removeAt(index);
        }
      } else {
        if (index >= 0 && index < _orderItems.length) {
          _orderItems[index]['quantity'] = newQuantity;
        }
      }
    });
  }

  // Agrega un item (con variante o sin variante) al pedido
  void _addVariantItemToOrder(Map<String, dynamic> orderItem) {
    // Soporta tanto variantPrice (de VariantSelectionSheet) como price (de CustomerNameSheet)
    final price = orderItem['variantPrice'] ?? orderItem['price'] ?? 0.0;

    final newItem = {
      'dishId': orderItem['dishId']?.toString() ?? '',
      'dishName': orderItem['dishName'] ?? '',
      'dishImage': orderItem['dishImage'],
      'category': orderItem['category'],
      'description': orderItem['description'],
      'price': (price as num).toDouble(),
      'variantName': orderItem['variantName'],
      'customerName': orderItem['customerName'],
      'quantity': 1,
    };

    setState(() => _orderItems.add(newItem));

    final variantName = orderItem['variantName']?.toString() ?? '';
    final customerName = orderItem['customerName']?.toString() ?? '';
    final info = [
      if (variantName.isNotEmpty) variantName,
      if (customerName.isNotEmpty) customerName,
    ].join(' - ');

    AppLogger.log(
      'Añadido: ${orderItem['dishName']}${info.isNotEmpty ? " ($info)" : ""}',
      prefix: 'ORDEN:',
    );
  }

  Future<bool> _confirmOrder(String responsibleName, bool specialEvent) async {
    if (_table == null) {
      AppSnackbar.show(
        context: context,
        message: 'Error: No hay mesa seleccionada',
        type: SnackbarType.error,
      );
      return false;
    }

    if (_orderItems.isEmpty) {
      AppSnackbar.show(
        context: context,
        message: 'No hay items en el pedido',
        type: SnackbarType.warning,
      );
      return false;
    }

    try {
      final totalAmount = _calculateTotal();

      final itemsToSave = _orderItems
          .map(
            (item) => {
              'dishId': item['dishId'],
              'name': item['dishName'],
              'category': item['category'],
              'price': item['price'],
              'quantity': item['quantity'],
              'variantName': item['variantName'],
              'customerName': item['customerName'],
            },
          )
          .toList();

      final existingOrder = await _ordersService.getActiveOrderByTable(
        _table!['id'],
      );

      bool success = false;

      if (existingOrder != null) {
        success = await _ordersService.addItemsToOrder(
          existingOrder['id'],
          itemsToSave,
          totalAmount,
        );
      } else {
        final orderData = {
          'tableId': _table!['id'],
          'tableNumber': _table!['number'],
          'staffId': CurrentUserAuth.instance.id,
          'staffName': CurrentUserAuth.instance.name ?? 'Sin nombre',
          'responsibleName': responsibleName.isNotEmpty
              ? responsibleName
              : null,
          'items': itemsToSave,
          'totalAmount': totalAmount,
          'specialEvent': specialEvent,
        };

        final orderId = await _ordersService.createOrder(orderData);
        success = orderId != null;

        if (success) {
          await _tablesService.changeTableStatus(_table!['id'], 'occupied');
        }
      }

      if (success && mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/order-details',
          arguments: _table,
        );
        return true;
      } else {
        throw Exception('No se pudo procesar la orden');
      }
    } catch (e) {
      AppLogger.log('Error procesando orden: $e', prefix: 'ORDEN_ERROR:');
      if (mounted) {
        AppSnackbar.show(
          context: context,
          message: 'Error al procesar la orden',
          type: SnackbarType.error,
        );
      }
      return false;
    }
  }

  void _showOrderSummary() {
    if (_orderItems.isEmpty) return;

    OrderSummaryModal.show(
      context,
      orderItems: _orderItems,
      onUpdateQuantity: (index, qty) => _updateQuantityByIndex(index, qty),
      onConfirm: (responsibleName, specialEvent) async =>
          await _confirmOrder(responsibleName, specialEvent),
      totalAmount: _calculateTotal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppThemes.init(context);
    final table =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Consumer(
      builder: (context, ref) {
        final menuState = ref.watch(dishesControllerProvider);
        final dishesController = ref.notifier(dishesControllerProvider);

        final categoryFilters = <Map<String, dynamic>>[
          {'id': 'all', 'label': 'Todos', 'count': menuState.dishes.length},
          ...menuState.categories.map(
            (cat) => {
              'id': cat,
              'label': cat,
              'count': menuState.dishes
                  .where((d) => d['category'] == cat)
                  .length,
            },
          ),
        ];

        final categoryIds = ['all', ...menuState.categories];
        final totalAmount = _calculateTotal();

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: TransparentAppBar(
            backgroundColor: AppColors.appBarBackground,
          ),
          body: Container(
            decoration: BoxDecoration(color: AppColors.background),
            child: SafeArea(
              child: Column(
                children: [
                  OrderHeader(
                    title: table != null
                        ? 'Mesa ${table['number']}'
                        : 'Nueva Orden',
                    subtitle: 'Selecciona los platos',
                    onBack: () => Navigator.pop(context),
                    actions: [
                      GestureDetector(
                        onTap: _showOrderSummary,
                        child: Container(
                          padding: ResponsiveScaler.padding(
                            EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.card.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(
                              ResponsiveScaler.radius(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, ResponsiveScaler.height(2)),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shopping_basket,
                                size: ResponsiveScaler.icon(20),
                                color: _orderItems.isNotEmpty
                                    ? AppColors.primary
                                    : AppColors.iconMuted,
                              ),
                              SizedBox(width: ResponsiveScaler.width(8)),
                              Text(
                                '${_orderItems.length}',
                                style: GoogleFonts.poppins(
                                  fontSize: ResponsiveScaler.font(16),
                                  fontWeight: FontWeight.bold,
                                  color: _orderItems.isNotEmpty
                                      ? AppColors.primary
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  OrderFiltersBar(
                    selectedFilter: menuState.selectedCategory,
                    onFilterChanged: (category) {
                      dishesController.selectCategory(category);
                      final pageIndex = categoryIds.indexOf(category);
                      if (pageIndex != -1 && _pageController.hasClients) {
                        _pageController.animateToPage(
                          pageIndex,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    orders: [],
                    customFilters: categoryFilters,
                    pageController: _pageController,
                  ),
                  Container(
                    margin: ResponsiveScaler.margin(EdgeInsets.all(20)),
                    child: SearchBar(
                      hintText: 'Buscar platos...',
                      onChanged: (value) => setState(() => searchQuery = value),
                    ),
                  ),
                  Expanded(
                    child: menuState.isLoading
                        ? Center(
                            child: AppLoader(size: ResponsiveScaler.width(40)),
                          )
                        : menuState.dishes.isEmpty
                        ? EmptyState(
                            icon: Icons.restaurant_menu_outlined,
                            title: 'No hay platos',
                            description: 'No hay platos disponibles.',
                          )
                        : PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              final category = categoryIds[index];
                              dishesController.selectCategory(category);
                            },
                            itemCount: categoryIds.length,
                            itemBuilder: (context, pageIndex) {
                              final currentCategory = categoryIds[pageIndex];
                              List<Map<String, dynamic>> pageDishes;

                              if (currentCategory == 'all') {
                                pageDishes = menuState.dishes;
                              } else {
                                pageDishes = menuState.dishes
                                    .where(
                                      (d) => d['category'] == currentCategory,
                                    )
                                    .toList();
                              }

                              pageDishes = _filterBySearch(pageDishes);

                              return DishGrid(
                                dishes: pageDishes,
                                orderQuantities: _getQuantitiesMap(),
                                onAddDish: _addToOrder,
                                onUpdateQuantity: (id, qty) =>
                                    _updateQuantityByDishId(id.toString(), qty),
                                onAddVariantItem: _addVariantItemToOrder,
                                bottomPadding: _orderItems.isNotEmpty
                                    ? 120
                                    : 20,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: _orderItems.isNotEmpty
              ? Padding(
                  padding: ResponsiveScaler.padding(
                    EdgeInsets.only(bottom: 10.0),
                  ),
                  child: FloatingActionButton.extended(
                    onPressed: _showOrderSummary,
                    backgroundColor: AppColors.primary,
                    icon: Icon(
                      Icons.shopping_basket,
                      color: AppColors.iconOnPrimary,
                    ),
                    label: Text(
                      'Ver Pedido (S/ ${totalAmount.toStringAsFixed(2)})',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnPrimary,
                        fontSize: ResponsiveScaler.font(14),
                      ),
                    ),
                  ),
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}

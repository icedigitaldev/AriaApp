import 'package:flutter/material.dart' hide SearchBar;
import 'package:google_fonts/google_fonts.dart';
import '../components/composite/transparent_app_bar.dart';
import '../components/ui/app_snackbar.dart';
import '../design/colors/app_colors.dart';
import '../design/responsive/responsive_scaler.dart';
import '../design/themes/app_themes.dart';
import '../features/orders/components/composite/order_header.dart';
import '../features/orders/components/composite/order_filters_bar.dart';
import '../features/orders/components/composite/dish_grid.dart';
import '../features/orders/components/composite/order_summary_modal.dart';
import '../features/orders/components/ui/search_bar.dart';
import '../utils/app_logger.dart';

class NewOrderView extends StatefulWidget {
  const NewOrderView({Key? key}) : super(key: key);

  @override
  State<NewOrderView> createState() => _NewOrderViewState();
}

class _NewOrderViewState extends State<NewOrderView> {
  String selectedCategory = 'all';
  String searchQuery = '';
  List<Map<String, dynamic>> orderItems = [];
  Map<int, int> orderQuantities = {};
  late PageController _pageController;

  final List<String> categoryIds = ['all', 'ceviches', 'rice', 'chotanos'];

  final List<Map<String, dynamic>> categories = [
    {'id': 'all', 'label': 'Todos', 'count': 5},
    {'id': 'ceviches', 'label': 'Ceviches', 'count': 2},
    {'id': 'rice', 'label': 'Arroces', 'count': 2},
    {'id': 'chotanos', 'label': 'Chotanos', 'count': 1},
  ];

  final List<Map<String, dynamic>> dishes = [
    {
      'id': 1,
      'name': 'Ceviche Clásico',
      'description': 'Pescado fresco marinado en limón con cebolla morada y choclo',
      'category': 'Ceviches',
      'price': 15.99,
      'status': 'available',
      'image': 'https://images.unsplash.com/photo-1535399831218-d5bd36d1a6b3?w=400&h=400&fit=crop',
      'rating': 4.8,
    },
    {
      'id': 2,
      'name': 'Ceviche Mixto',
      'description': 'Combinación de mariscos frescos',
      'category': 'Ceviches',
      'price': 14.99,
      'status': 'unavailable',
      'image': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400&h=400&fit=crop',
      'rating': 4.6,
    },
    {
      'id': 3,
      'name': 'Arroz con Mariscos',
      'description': 'Arroz cremoso con mariscos especiales, langostinos y calamares',
      'category': 'Arroces',
      'price': 16.99,
      'status': 'available',
      'image': 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=400&h=400&fit=crop',
      'rating': 4.9,
    },
    {
      'id': 4,
      'name': 'Chaufa de Mariscos',
      'description': 'Arroz frito al estilo oriental',
      'category': 'Arroces',
      'price': 12.99,
      'status': 'available',
      'image': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&h=400&fit=crop',
      'rating': 4.7,
    },
    {
      'id': 5,
      'name': 'Seco de Cabrito',
      'description': 'Cabrito tierno en chicha de jora con frijoles y yuca dorada',
      'category': 'Platos Chotanos',
      'price': 13.99,
      'status': 'available',
      'image': 'https://images.unsplash.com/photo-1432139555190-58524dae6a55?w=400&h=400&fit=crop',
      'rating': 4.5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> getFilteredDishes(String category) {
    var result = dishes;

    if (category != 'all') {
      final categoryMap = {
        'ceviches': 'Ceviches',
        'rice': 'Arroces',
        'chotanos': 'Platos Chotanos'
      };
      result = result.where((dish) =>
      dish['category'] == categoryMap[category]
      ).toList();
    }

    if (searchQuery.isNotEmpty) {
      result = result.where((dish) {
        final name = dish['name'].toString().toLowerCase();
        final description = dish['description'].toString().toLowerCase();
        final query = searchQuery.toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    }

    return result;
  }

  double get totalAmount {
    return dishes.fold(0, (sum, dish) {
      final quantity = orderQuantities[dish['id']] ?? 0;
      return sum + (dish['price'] * quantity);
    });
  }

  void addToOrder(Map<String, dynamic> dish) {
    setState(() {
      final dishId = dish['id'];
      orderQuantities[dishId] = (orderQuantities[dishId] ?? 0) + 1;
      // Actualizar orderItems
      _updateOrderItems();
    });
    AppLogger.log('Plato añadido: ${dish['name']}', prefix: 'ORDEN:');
  }

  void updateQuantity(int dishId, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        orderQuantities.remove(dishId);
      } else {
        orderQuantities[dishId] = newQuantity;
      }
      // Actualizar orderItems
      _updateOrderItems();
    });
  }

  void _updateOrderItems() {
    orderItems = dishes
        .where((dish) => orderQuantities.containsKey(dish['id']))
        .map((dish) => {
      ...dish,
      'quantity': orderQuantities[dish['id']]!,
    })
        .toList();
  }

  void confirmOrder() async {
    AppLogger.log('Orden confirmada por \$$totalAmount', prefix: 'ORDEN:');
    Navigator.pop(context);
    AppSnackbar.show(
      context: context,
      message: 'Orden enviada correctamente',
      type: SnackbarType.success,
    );
  }

  void _showOrderSummary() {
    if (orderItems.isEmpty) return;

    OrderSummaryModal.show(
      context,
      orderItems: orderItems,
      onUpdateQuantity: updateQuantity,
      onConfirm: confirmOrder,
      totalAmount: totalAmount,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      selectedCategory = categoryIds[index];
    });
    AppLogger.log('Categoría cambiada por deslizamiento: $selectedCategory', prefix: 'ORDEN:');
  }

  void _onCategoryChanged(String category) {
    setState(() {
      selectedCategory = category;
    });
    final pageIndex = categoryIds.indexOf(category);
    if (pageIndex != -1 && _pageController.hasClients) {
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppThemes.init(context);
    ResponsiveSize.init(context);
    final table = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

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
                title: table != null ? 'Mesa ${table['number']}' : 'Nueva Orden',
                subtitle: 'Selecciona los platos',
                onBack: () => Navigator.pop(context),
                actions: [
                  GestureDetector(
                    onTap: _showOrderSummary,
                    child: Container(
                      padding: ResponsiveSize.padding(
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(ResponsiveSize.radius(20)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, ResponsiveSize.height(2)),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_basket,
                            size: ResponsiveSize.icon(20),
                            color: orderItems.isNotEmpty
                                ? AppColors.primary
                                : AppColors.iconMuted,
                          ),
                          SizedBox(width: ResponsiveSize.width(8)),
                          Text(
                            '${orderItems.length}',
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveSize.font(16),
                              fontWeight: FontWeight.bold,
                              color: orderItems.isNotEmpty
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

              // Filtros con componente compartido
              OrderFiltersBar(
                selectedFilter: selectedCategory,
                onFilterChanged: _onCategoryChanged,
                orders: [],
                customFilters: categories,
                pageController: _pageController,
              ),

              // Barra de búsqueda con componente compartido
              Container(
                margin: ResponsiveSize.margin(const EdgeInsets.all(20)),
                child: SearchBar(
                  hintText: 'Buscar platos...',
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
              ),

              // Grid de platos con PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: categoryIds.length,
                  itemBuilder: (context, pageIndex) {
                    final currentCategory = categoryIds[pageIndex];
                    final filteredDishes = getFilteredDishes(currentCategory);

                    return DishGrid(
                      dishes: filteredDishes,
                      orderQuantities: orderQuantities,
                      onAddDish: addToOrder,
                      onUpdateQuantity: updateQuantity,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: orderItems.isNotEmpty
          ? Padding(
        padding: ResponsiveSize.padding(const EdgeInsets.only(bottom: 16.0)),
        child: FloatingActionButton.extended(
          onPressed: _showOrderSummary,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.shopping_basket, color: AppColors.iconOnPrimary),
          label: Text(
            'Ver Pedido (\$${totalAmount.toStringAsFixed(2)})',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
              fontSize: ResponsiveSize.font(14),
            ),
          ),
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
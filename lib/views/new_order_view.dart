import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../components/composite/transparent_app_bar.dart';
import '../utils/logger.dart';

class NewOrderView extends StatefulWidget {
  const NewOrderView({Key? key}) : super(key: key);

  @override
  State<NewOrderView> createState() => _NewOrderViewState();
}

class _NewOrderViewState extends State<NewOrderView> {
  String selectedCategory = 'all';
  String searchQuery = '';
  List<Map<String, dynamic>> orderItems = [];
  bool isLoading = false;

  final List<Map<String, dynamic>> categories = [
    {'id': 'all', 'name': 'Todos', 'count': 5},
    {'id': 'ceviches', 'name': 'Ceviches', 'count': 2},
    {'id': 'rice', 'name': 'Arroces', 'count': 2},
    {'id': 'chotanos', 'name': 'Chotanos', 'count': 1},
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
      'orders': 156,
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
      'orders': 98,
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
      'orders': 234,
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
      'orders': 189,
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
      'orders': 67,
    },
  ];

  List<Map<String, dynamic>> get filteredDishes {
    var result = dishes;

    if (selectedCategory != 'all') {
      final categoryMap = {
        'ceviches': 'Ceviches',
        'rice': 'Arroces',
        'chotanos': 'Platos Chotanos',
      };
      result = result.where((dish) => dish['category'] == categoryMap[selectedCategory]).toList();
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
    return orderItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  void addToOrder(Map<String, dynamic> dish) {
    setState(() {
      final existingIndex = orderItems.indexWhere((item) => item['id'] == dish['id']);
      if (existingIndex != -1) {
        orderItems[existingIndex]['quantity']++;
      } else {
        orderItems.add({
          ...dish,
          'quantity': 1,
        });
      }
    });
    AppLogger.log('Plato añadido: ${dish['name']}', prefix: 'ORDEN:');
  }

  void updateQuantity(int dishId, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        orderItems.removeWhere((item) => item['id'] == dishId);
      } else {
        final index = orderItems.indexWhere((item) => item['id'] == dishId);
        if (index != -1) {
          orderItems[index]['quantity'] = newQuantity;
        }
      }
    });
  }

  void confirmOrder() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });

    AppLogger.log('Orden confirmada por \$$totalAmount', prefix: 'ORDEN:');

    if (mounted) {
      Navigator.pop(context); // Cerrar el bottom sheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Orden enviada correctamente',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context, true); // Cerrar la vista
    }
  }

  void _showOrderSummary() {
    if (orderItems.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Resumen del Pedido',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[900],
                              ),
                            ),
                            Text(
                              '${orderItems.length} items',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: orderItems.length,
                            itemBuilder: (context, index) {
                              final item = orderItems[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: NetworkImage(item['image']),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[900],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${item['price']} x ${item['quantity']}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            updateQuantity(item['id'], item['quantity'] - 1);
                                            setModalState(() {});
                                            if (orderItems.isEmpty) {
                                              Navigator.pop(context);
                                            }
                                          },
                                          icon: const Icon(Icons.remove_circle_outline, size: 24),
                                          color: const Color(0xFF9C27B0),
                                        ),
                                        Container(
                                          width: 40,
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3E5F5),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              item['quantity'].toString(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF9C27B0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            updateQuantity(item['id'], item['quantity'] + 1);
                                            setModalState(() {});
                                          },
                                          icon: const Icon(Icons.add_circle_outline, size: 24),
                                          color: const Color(0xFF9C27B0),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFF3E5F5).withOpacity(0.5),
                                const Color(0xFFFCE4EC).withOpacity(0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                              ),
                              Text(
                                '\$${totalAmount.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..shader = const LinearGradient(
                                      colors: [
                                        Color(0xFF9C27B0),
                                        Color(0xFFE91E63),
                                      ],
                                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 100.0, 70.0)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: isLoading ? null : confirmOrder,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isLoading
                                    ? [Colors.grey[400]!, Colors.grey[400]!]
                                    : [
                                  const Color(0xFF9C27B0),
                                  const Color(0xFFE91E63),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: !isLoading
                                  ? [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                                  : null,
                            ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                                  : Text(
                                'Confirmar Pedido',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modalRoute = ModalRoute.of(context);
    final table = modalRoute?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const TransparentAppBar(
        backgroundColor: Color(0xFFF3E5F5),
        statusBarIconBrightness: Brightness.dark,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3E5F5),
              Color(0xFFFCE4EC),
              Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(table),
              _buildCategorySelector(),
              _buildSearchBar(),
              Expanded(
                child: _buildDishesGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic>? table) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  table != null ? 'Mesa ${table['number']}' : 'Nueva Orden',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [
                          Color(0xFF7B1FA2),
                          Color(0xFFE91E63),
                        ],
                      ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                  ),
                ),
                Text(
                  'Selecciona los platos',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showOrderSummary,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_basket,
                    size: 20,
                    color: orderItems.isNotEmpty ? const Color(0xFF9C27B0) : Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${orderItems.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: orderItems.isNotEmpty ? const Color(0xFF9C27B0) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['id'];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category['id'];
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [
                    Color(0xFF9C27B0),
                    Color(0xFFE91E63),
                  ],
                )
                    : null,
                color: isSelected ? null : Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      category['count'].toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          hintText: 'Buscar platos...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildDishesGrid() {
    return MasonryGridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: filteredDishes.length,
      itemBuilder: (context, index) {
        final dish = filteredDishes[index];
        final orderItem = orderItems.firstWhere(
              (item) => item['id'] == dish['id'],
          orElse: () => {'quantity': 0},
        );

        return _buildDishCard(dish, orderItem['quantity'] ?? 0);
      },
    );
  }

  Widget _buildDishCard(Map<String, dynamic> dish, int quantity) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  image: DecorationImage(
                    image: NetworkImage(dish['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        dish['rating'].toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dish['description'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dish['category'],
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '\$${dish['price']}',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Botones de acción
                if (dish['status'] == 'unavailable')
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'No disponible',
                        style: GoogleFonts.poppins(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else if (quantity == 0)
                  GestureDetector(
                    onTap: () => addToOrder(dish),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF9C27B0),
                            Color(0xFFE91E63),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Agregar',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => updateQuantity(dish['id'], quantity - 1),
                          icon: const Icon(Icons.remove, size: 20),
                          color: const Color(0xFF9C27B0),
                          padding: const EdgeInsets.all(8),
                        ),
                        Text(
                          quantity.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF9C27B0),
                          ),
                        ),
                        IconButton(
                          onPressed: () => updateQuantity(dish['id'], quantity + 1),
                          icon: const Icon(Icons.add, size: 20),
                          color: const Color(0xFF9C27B0),
                          padding: const EdgeInsets.all(8),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
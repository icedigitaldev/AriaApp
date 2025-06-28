import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/composite/transparent_app_bar.dart';
import '../utils/logger.dart';

class KitchenOrdersView extends StatefulWidget {
  const KitchenOrdersView({Key? key}) : super(key: key);

  @override
  State<KitchenOrdersView> createState() => _KitchenOrdersViewState();
}

class _KitchenOrdersViewState extends State<KitchenOrdersView> {
  String selectedFilter = 'pending';

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
      'status': 'ready',
      'items': [
        {'name': 'Ceviche Clásico', 'quantity': 1, 'notes': ''},
        {'name': 'Arroz con Mariscos', 'quantity': 1, 'notes': ''},
      ],
      'orderTime': DateTime.now().subtract(const Duration(minutes: 25)),
    },
  ];

  List<Map<String, dynamic>> get filteredOrders {
    if (selectedFilter == 'all') {
      return orders;
    }
    return orders.where((order) => order['status'] == selectedFilter).toList();
  }

  String _getTimeDifference(DateTime orderTime) {
    final difference = DateTime.now().difference(orderTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else {
      return '${difference.inHours}h ${difference.inMinutes % 60}min';
    }
  }

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(),
              _buildFilterTabs(),
              _buildOrderStats(),
              Expanded(
                child: _buildOrdersList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF9C27B0),
                  Color(0xFFE91E63),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARIA Cocina',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
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
                  'Gestión de pedidos',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              AppLogger.log('Historial de pedidos', prefix: 'COCINA:');
              Navigator.pushNamed(context, '/kitchen-history');
            },
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
              child: const Icon(Icons.history, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'id': 'all', 'label': 'Todos', 'count': orders.length},
      {'id': 'pending', 'label': 'Pendientes', 'count': orders.where((o) => o['status'] == 'pending').length},
      {'id': 'preparing', 'label': 'Preparando', 'count': orders.where((o) => o['status'] == 'preparing').length},
      {'id': 'ready', 'label': 'Listos', 'count': orders.where((o) => o['status'] == 'ready').length},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['id'];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter['id'] as String;
              });
              AppLogger.log('Filtro seleccionado: ${filter['id']}', prefix: 'COCINA:');
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
                    filter['label'] as String,
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
                      filter['count'].toString(),
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

  Widget _buildOrderStats() {
    final pendingCount = orders.where((o) => o['status'] == 'pending').length;
    final preparingCount = orders.where((o) => o['status'] == 'preparing').length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.pending_actions,
            label: 'Pendientes',
            value: pendingCount.toString(),
            color: const Color(0xFFFF9800),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[300],
          ),
          _buildStatItem(
            icon: Icons.soup_kitchen,
            label: 'Preparando',
            value: preparingCount.toString(),
            color: const Color(0xFF2196F3),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[300],
          ),
          _buildStatItem(
            icon: Icons.timer,
            label: 'Tiempo promedio',
            value: '12 min',
            color: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final statusConfig = _getStatusConfig(order['status']);
    final timeDiff = _getTimeDifference(order['orderTime']);

    return GestureDetector(
      onTap: () {
        AppLogger.log('Orden seleccionada: ${order['id']}', prefix: 'COCINA:');
        Navigator.pushNamed(
          context,
          '/kitchen-order-details',
          arguments: order,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: statusConfig['borderColor'],
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusConfig['backgroundColor'].withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusConfig['backgroundColor'],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusConfig['dotColor'],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              statusConfig['text'],
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusConfig['textColor'],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Mesa ${order['tableNumber']}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timeDiff,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: timeDiff.contains('min') && int.parse(timeDiff.split(' ')[0]) > 15
                              ? Colors.red[600]
                              : Colors.grey[700],
                        ),
                      ),
                      Text(
                        order['time'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        order['waiter'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...order['items'].map<Widget>((item) => _buildOrderItem(item)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
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
                if (item['notes'].toString().isNotEmpty)
                  Text(
                    item['notes'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.orange[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'pending':
        return {
          'backgroundColor': const Color(0xFFFFF3E0),
          'borderColor': const Color(0xFFFFB74D),
          'textColor': const Color(0xFFF57C00),
          'dotColor': const Color(0xFFFF9800),
          'text': 'Pendiente',
        };
      case 'preparing':
        return {
          'backgroundColor': const Color(0xFFE3F2FD),
          'borderColor': const Color(0xFF64B5F6),
          'textColor': const Color(0xFF1976D2),
          'dotColor': const Color(0xFF2196F3),
          'text': 'Preparando',
        };
      case 'ready':
        return {
          'backgroundColor': const Color(0xFFE8F5E9),
          'borderColor': const Color(0xFF81C784),
          'textColor': const Color(0xFF388E3C),
          'dotColor': const Color(0xFF4CAF50),
          'text': 'Listo',
        };
      default:
        return {
          'backgroundColor': Colors.grey[100]!,
          'borderColor': Colors.grey[300]!,
          'textColor': Colors.grey[700]!,
          'dotColor': Colors.grey[500]!,
          'text': 'Desconocido',
        };
    }
  }
}
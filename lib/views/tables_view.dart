import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/logger.dart';

class TablesView extends StatefulWidget {
  const TablesView({Key? key}) : super(key: key);

  @override
  State<TablesView> createState() => _TablesViewState();
}

class _TablesViewState extends State<TablesView> {
  final List<Map<String, dynamic>> tables = [
    {'id': 1, 'number': 1, 'capacity': 4, 'status': 'available', 'floor': 1},
    {'id': 2, 'number': 2, 'capacity': 2, 'status': 'occupied', 'floor': 1, 'orderTotal': 45.50},
    {'id': 3, 'number': 3, 'capacity': 6, 'status': 'available', 'floor': 1},
    {'id': 4, 'number': 4, 'capacity': 4, 'status': 'reserved', 'floor': 1},
    {'id': 5, 'number': 5, 'capacity': 2, 'status': 'occupied', 'floor': 1, 'orderTotal': 23.99},
    {'id': 6, 'number': 6, 'capacity': 8, 'status': 'available', 'floor': 2},
    {'id': 7, 'number': 7, 'capacity': 4, 'status': 'occupied', 'floor': 2, 'orderTotal': 67.80},
    {'id': 8, 'number': 8, 'capacity': 4, 'status': 'available', 'floor': 2},
  ];

  int selectedFloor = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3E5F5), // purple-50
              Color(0xFFFCE4EC), // pink-50
              Color(0xFFE3F2FD), // blue-50
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFloorSelector(),
              Expanded(
                child: _buildTablesGrid(),
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
                  Color(0xFF9C27B0), // purple-400
                  Color(0xFFE91E63), // pink-400
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
            child: Center(
              child: Text(
                'A',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARIA Meseros',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [
                          Color(0xFF7B1FA2), // purple-600
                          Color(0xFFE91E63), // pink-600
                        ],
                      ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                  ),
                ),
                Text(
                  'Mesa de control',
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
              AppLogger.log('Abriendo perfil', prefix: 'HEADER:');
            },
            icon: CircleAvatar(
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorSelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildFloorButton(1, 'Piso 1'),
          const SizedBox(width: 12),
          _buildFloorButton(2, 'Piso 2'),
        ],
      ),
    );
  }

  Widget _buildFloorButton(int floor, String label) {
    final isSelected = selectedFloor == floor;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFloor = floor;
          });
          AppLogger.log('Piso seleccionado: $floor', prefix: 'FILTRO:');
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
              colors: [
                Color(0xFF9C27B0), // purple-500
                Color(0xFFE91E63), // pink-500
              ],
            )
                : null,
            color: isSelected ? null : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
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
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTablesGrid() {
    final filteredTables = tables.where((table) => table['floor'] == selectedFloor).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredTables.length,
      itemBuilder: (context, index) {
        final table = filteredTables[index];
        return _buildTableCard(table);
      },
    );
  }

  Widget _buildTableCard(Map<String, dynamic> table) {
    final status = table['status'];
    final statusConfig = _getStatusConfig(status);

    return GestureDetector(
      onTap: () {
        AppLogger.log('Mesa seleccionada: ${table['number']}', prefix: 'MESA:');
        Navigator.pushNamed(
          context,
          status == 'occupied' ? '/order-details' : '/new-order',
          arguments: table,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusConfig['backgroundColor'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              Text(
                'Mesa ${table['number']}',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              if (table['orderTotal'] != null)
                Text(
                  '\$${table['orderTotal'].toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: statusConfig['textColor'],
                  ),
                )
              else
                Text(
                  '${table['capacity']} personas',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'available':
        return {
          'backgroundColor': const Color(0xFFE8F5E9),
          'borderColor': const Color(0xFF81C784),
          'textColor': const Color(0xFF2E7D32),
          'dotColor': const Color(0xFF4CAF50),
          'text': 'Disponible',
        };
      case 'occupied':
        return {
          'backgroundColor': const Color(0xFFFFF3E0),
          'borderColor': const Color(0xFFFFB74D),
          'textColor': const Color(0xFFF57C00),
          'dotColor': const Color(0xFFFF9800),
          'text': 'Ocupada',
        };
      case 'reserved':
        return {
          'backgroundColor': const Color(0xFFE1F5FE),
          'borderColor': const Color(0xFF4FC3F7),
          'textColor': const Color(0xFF0277BD),
          'dotColor': const Color(0xFF03A9F4),
          'text': 'Reservada',
        };
      default:
        return {
          'backgroundColor': Colors.grey[100],
          'borderColor': Colors.grey[300],
          'textColor': Colors.grey[700],
          'dotColor': Colors.grey[500],
          'text': 'Desconocido',
        };
    }
  }
}
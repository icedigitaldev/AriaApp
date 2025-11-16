import 'package:flutter/material.dart';
import '../components/composite/transparent_app_bar.dart';
import '../design/colors/app_colors.dart';
import '../design/responsive/responsive_scaler.dart';
import '../features/tables/components/composite/restaurant_header.dart';
import '../features/tables/components/composite/floor_selector.dart';
import '../features/tables/components/composite/tables_grid.dart';

class TablesView extends StatefulWidget {
  const TablesView({Key? key}) : super(key: key);

  @override
  State<TablesView> createState() => _TablesViewState();
}

class _TablesViewState extends State<TablesView> {
  // Datos de ejemplo - En producción vendrían del controller/service
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
              // Header del restaurante
              RestaurantHeader(
                onProfileTap: () {
                  // Navegar al perfil o mostrar opciones
                },
              ),
              // Selector de pisos
              FloorSelector(
                selectedFloor: selectedFloor,
                onFloorChanged: (floor) {
                  setState(() {
                    selectedFloor = floor;
                  });
                },
              ),
              // Grid de mesas
              Expanded(
                child: TablesGrid(
                  tables: tables,
                  selectedFloor: selectedFloor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
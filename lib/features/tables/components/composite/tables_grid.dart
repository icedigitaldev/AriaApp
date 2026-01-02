import 'package:flutter/material.dart';
import '../../../../components/ui/empty_state.dart';
import '../../../../design/responsive/responsive_scaler.dart';
import '../../../../utils/app_logger.dart';
import '../ui/table_card.dart';

class TablesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> tables;
  final String selectedFloor;
  final Function(Map<String, dynamic>)? onTableTap;
  final Function(String, String)? onStatusChange;

  const TablesGrid({
    Key? key,
    required this.tables,
    required this.selectedFloor,
    this.onTableTap,
    this.onStatusChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Las mesas ya vienen filtradas del controlador
    final displayTables = tables;

    if (displayTables.isEmpty) {
      return const EmptyState(
        icon: Icons.table_restaurant_outlined,
        title: 'No hay mesas',
        description: 'No hay mesas en este piso.',
      );
    }

    return GridView.builder(
      padding: ResponsiveScaler.padding(const EdgeInsets.all(20)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: ResponsiveScaler.width(16),
        mainAxisSpacing: ResponsiveScaler.height(16),
      ),
      itemCount: displayTables.length,
      itemBuilder: (context, index) {
        final table = displayTables[index];
        final bool isLeft = index % 2 == 0;

        return TableCard(
          table: table,
          isLeftColumn: isLeft,
          onTap: () {
            AppLogger.log(
              'Mesa seleccionada: ${table['number']}',
              prefix: 'MESA:',
            );
            if (onTableTap != null) {
              onTableTap!(table);
            } else {
              final status = table['status'];
              Navigator.pushNamed(
                context,
                status == 'occupied' ? '/order-details' : '/new-order',
                arguments: table,
              );
            }
          },
        );
      },
    );
  }
}

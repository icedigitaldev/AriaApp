import 'package:flutter/material.dart';
import '../../../../design/responsive/responsive_scaler.dart';
import '../../../../utils/app_logger.dart';
import '../ui/table_card.dart';

class TablesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> tables;
  final int selectedFloor;

  const TablesGrid({
    Key? key,
    required this.tables,
    required this.selectedFloor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredTables = tables.where((table) => table['floor'] == selectedFloor).toList();

    return GridView.builder(
      padding: ResponsiveSize.padding(const EdgeInsets.all(20)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: ResponsiveSize.width(16),
        mainAxisSpacing: ResponsiveSize.height(16),
      ),
      itemCount: filteredTables.length,
      itemBuilder: (context, index) {
        final table = filteredTables[index];
        final bool isLeft = index % 2 == 0;

        return TableCard(
          table: table,
          isLeftColumn: isLeft,
          onTap: () {
            AppLogger.log('Mesa seleccionada: ${table['number']}', prefix: 'MESA:');
            final status = table['status'];
            Navigator.pushNamed(
              context,
              status == 'occupied' ? '/order-details' : '/new-order',
              arguments: table,
            );
          },
        );
      },
    );
  }
}
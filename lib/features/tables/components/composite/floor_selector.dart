import 'package:flutter/material.dart';
import '../../../../design/responsive/responsive_scaler.dart';
import '../../../../utils/app_logger.dart';
import '../ui/floor_button.dart';

class FloorSelector extends StatelessWidget {
  final String? selectedFloor;
  final Function(String?) onFloorChanged;
  final List<Map<String, String>> availableFloors;

  const FloorSelector({
    Key? key,
    required this.selectedFloor,
    required this.onFloorChanged,
    this.availableFloors = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (availableFloors.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> children = [];

    for (var i = 0; i < availableFloors.length; i++) {
      final floor = availableFloors[i];
      final floorId = floor['id'] ?? '';
      final floorName = floor['name'] ?? floorId;

      children.add(
        FloorButton(
          floorId: floorId,
          label: floorName,
          isSelected: selectedFloor == floorId,
          onTap: () {
            AppLogger.log('Piso seleccionado: $floorName', prefix: 'FILTRO:');
            onFloorChanged(floorId);
          },
        ),
      );

      if (i < availableFloors.length - 1) {
        children.add(SizedBox(width: ResponsiveScaler.width(12)));
      }
    }

    return Container(
      height: ResponsiveScaler.height(50),
      margin: ResponsiveScaler.margin(
        const EdgeInsets.symmetric(horizontal: 20),
      ),
      child: Row(children: children),
    );
  }
}

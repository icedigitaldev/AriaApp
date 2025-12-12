import 'package:flutter/material.dart';
import '../../../../design/responsive/responsive_scaler.dart';
import '../../../../utils/app_logger.dart';
import '../ui/floor_button.dart';

class FloorSelector extends StatelessWidget {
  final int selectedFloor;
  final Function(int) onFloorChanged;
  final List<int> availableFloors;

  const FloorSelector({
    Key? key,
    required this.selectedFloor,
    required this.onFloorChanged,
    this.availableFloors = const [1, 2],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    for (var i = 0; i < availableFloors.length; i++) {
      final floor = availableFloors[i];

      children.add(
        FloorButton(
          floor: floor,
          label: 'Piso $floor',
          isSelected: selectedFloor == floor,
          onTap: () {
            AppLogger.log('Piso seleccionado: $floor', prefix: 'FILTRO:');
            onFloorChanged(floor);
          },
        ),
      );

      if (i < availableFloors.length - 1) {
        children.add(SizedBox(width: ResponsiveScaler.width(12)));
      }
    }

    return Container(
      height: ResponsiveScaler.height(50),
      margin: ResponsiveScaler.margin(const EdgeInsets.symmetric(horizontal: 20)),
      child: Row(children: children),
    );
  }
}

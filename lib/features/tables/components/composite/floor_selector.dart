import 'package:flutter/material.dart';
import '../../../../design/responsive/responsive_scaler.dart';
import '../../../../utils/app_logger.dart';
import '../ui/floor_button.dart';

class FloorSelector extends StatelessWidget {
  final int selectedFloor;
  final Function(int) onFloorChanged;
  final List<Map<String, dynamic>> floors;

  const FloorSelector({
    Key? key,
    required this.selectedFloor,
    required this.onFloorChanged,
    this.floors = const [
      {'floor': 1, 'label': 'Piso 1'},
      {'floor': 2, 'label': 'Piso 2'},
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    for (var i = 0; i < floors.length; i++) {
      final floorData = floors[i];

      children.add(FloorButton(
        floor: floorData['floor'],
        label: floorData['label'],
        isSelected: selectedFloor == floorData['floor'],
        onTap: () {
          AppLogger.log('Piso seleccionado: ${floorData['floor']}', prefix: 'FILTRO:');
          onFloorChanged(floorData['floor']);
        },
      ));

      if (i < floors.length - 1) {
        children.add(SizedBox(width: ResponsiveSize.width(12)));
      }
    }

    return Container(
      height: ResponsiveSize.height(50),
      margin: ResponsiveSize.margin(const EdgeInsets.symmetric(horizontal: 20)),
      child: Row(
        children: children,
      ),
    );
  }
}
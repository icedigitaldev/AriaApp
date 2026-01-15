import 'package:refena_flutter/refena_flutter.dart';

class TablesState {
  final List<Map<String, dynamic>> tables;
  final String? selectedFloor;
  final bool isLoading;
  final String? errorMessage;

  const TablesState({
    this.tables = const [],
    this.selectedFloor,
    this.isLoading = false,
    this.errorMessage,
  });

  // Filtra las mesas por piso seleccionado
  List<Map<String, dynamic>> get filteredTables {
    if (selectedFloor == null) return tables;
    return tables.where((t) => t['floor'] == selectedFloor).toList();
  }

  // Obtiene los pisos disponibles con id y nombre
  List<Map<String, String>> get availableFloors {
    final Map<String, String> floorsMap = {};
    for (final table in tables) {
      final floorId = table['floor']?.toString();
      final floorName = table['floorName']?.toString() ?? floorId;
      if (floorId != null && floorId.isNotEmpty) {
        floorsMap[floorId] = floorName ?? floorId;
      }
    }
    return floorsMap.entries
        .map((e) => {'id': e.key, 'name': e.value})
        .toList();
  }

  // Estadísticas por estado
  int get availableCount =>
      tables.where((t) => t['status'] == 'available').length;
  int get occupiedCount =>
      tables.where((t) => t['status'] == 'occupied').length;
  int get reservedCount =>
      tables.where((t) => t['status'] == 'reserved').length;

  TablesState copyWith({
    List<Map<String, dynamic>>? tables,
    String? selectedFloor,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearFloor = false,
  }) {
    return TablesState(
      tables: tables ?? this.tables,
      selectedFloor: clearFloor ? null : (selectedFloor ?? this.selectedFloor),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// Notifier base con métodos de actualización de estado
class TablesStateNotifier extends Notifier<TablesState> {
  @override
  TablesState init() => const TablesState();

  void setTables(List<Map<String, dynamic>> tables) {
    state = state.copyWith(tables: tables, isLoading: false);
  }

  void setSelectedFloor(String? floor) {
    state = state.copyWith(selectedFloor: floor, clearFloor: floor == null);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error, clearError: error == null);
  }

  void updateTableStatus(String tableId, String status) {
    final updatedTables = state.tables.map((t) {
      if (t['id'] == tableId) {
        return {...t, 'status': status};
      }
      return t;
    }).toList();
    state = state.copyWith(tables: updatedTables);
  }
}

import 'package:refena_flutter/refena_flutter.dart';

class TablesState {
  final List<Map<String, dynamic>> tables;
  final int selectedFloor;
  final bool isLoading;
  final String? errorMessage;

  const TablesState({
    this.tables = const [],
    this.selectedFloor = 1,
    this.isLoading = false,
    this.errorMessage,
  });

  // Convierte el valor de floor a int de forma segura
  static int _parseFloor(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }

  // Filtra las mesas por piso seleccionado
  List<Map<String, dynamic>> get filteredTables {
    return tables
        .where((t) => _parseFloor(t['floor']) == selectedFloor)
        .toList();
  }

  // Obtiene los pisos disponibles
  List<int> get availableFloors {
    final floors = tables.map((t) => _parseFloor(t['floor'])).toSet().toList();
    floors.sort();
    return floors.isEmpty ? [1] : floors;
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
    int? selectedFloor,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TablesState(
      tables: tables ?? this.tables,
      selectedFloor: selectedFloor ?? this.selectedFloor,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TablesStateNotifier extends Notifier<TablesState> {
  @override
  TablesState init() => const TablesState();

  void setTables(List<Map<String, dynamic>> tables) {
    state = state.copyWith(tables: tables, isLoading: false);
  }

  void setSelectedFloor(int floor) {
    state = state.copyWith(selectedFloor: floor);
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

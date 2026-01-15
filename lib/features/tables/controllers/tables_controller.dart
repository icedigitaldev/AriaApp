import 'dart:async';
import 'package:refena_flutter/refena_flutter.dart';
import '../states/tables_state.dart';
import '../services/tables_service.dart';
import '../../../utils/app_logger.dart';

class TablesController extends TablesStateNotifier {
  final TablesService _tablesService = TablesService();
  StreamSubscription? _tablesSubscription;
  bool _initialized = false;

  @override
  TablesState init() {
    return const TablesState();
  }

  // Inicializa el controlador y suscribe a los cambios
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    setLoading(true);

    _tablesSubscription = _tablesService.streamTables().listen(
      (tables) {
        _handleTablesUpdate(tables);
        AppLogger.log('Mesas cargadas: ${tables.length}', prefix: 'TABLES:');
      },
      onError: (error) {
        setError('Error cargando mesas');
        setLoading(false);
        AppLogger.log(
          'Error en stream de mesas: $error',
          prefix: 'TABLES_ERROR:',
        );
      },
    );
  }

  // Procesa la actualización de mesas y selecciona piso inicial si es necesario
  void _handleTablesUpdate(List<Map<String, dynamic>> tables) {
    setTables(tables);

    // Selección automática del primer piso si no hay ninguno seleccionado
    if (state.selectedFloor == null && state.availableFloors.isNotEmpty) {
      final firstFloorId = state.availableFloors.first['id'];
      setSelectedFloor(firstFloorId);
      AppLogger.log(
        'Piso inicial seleccionado: $firstFloorId',
        prefix: 'TABLES:',
      );
    }
  }

  // Cambia el piso seleccionado
  void selectFloor(String? floor) {
    setSelectedFloor(floor);
    AppLogger.log('Piso seleccionado: $floor', prefix: 'TABLES:');
  }

  // Cambia el estado de una mesa
  Future<void> changeStatus(String tableId, String newStatus) async {
    try {
      updateTableStatus(tableId, newStatus);
      await _tablesService.changeTableStatus(tableId, newStatus);
    } catch (e) {
      setError('Error al cambiar estado');
      AppLogger.log('Error cambiando estado: $e', prefix: 'TABLES_ERROR:');
    }
  }

  // Limpia la suscripción
  void cleanup() {
    _tablesSubscription?.cancel();
    _tablesSubscription = null;
    _initialized = false;
  }

  // Reinicializa el controlador (útil para cambio de usuario)
  void reinitialize() {
    cleanup();
    state = const TablesState();
    initialize();
  }
}

// Provider global del controlador de mesas
final tablesControllerProvider =
    NotifierProvider<TablesController, TablesState>(
      (ref) => TablesController(),
    );

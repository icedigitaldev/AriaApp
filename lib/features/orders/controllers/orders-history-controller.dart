import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refena_flutter/refena_flutter.dart';
import '../states/orders-history-state.dart';
import '../services/orders-history-service.dart';
import '../../../utils/app_logger.dart';

class OrdersHistoryController extends OrdersHistoryStateNotifier {
  final OrdersHistoryService _historyService = OrdersHistoryService();
  bool _initialized = false;

  @override
  OrdersHistoryState init() {
    return OrdersHistoryState(selectedDate: DateTime.now());
  }

  // Inicializa el controlador y carga las primeras órdenes
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await loadOrders();
  }

  // Reinicializa para cambios de usuario o refresco forzado
  Future<void> reinitialize() async {
    _initialized = false;
    reset();
    await initialize();
  }

  // Carga las primeras 10 órdenes de la fecha seleccionada
  Future<void> loadOrders() async {
    setLoading(true);
    setError(null);

    try {
      final orders = await _historyService.fetchCompletedOrders(
        date: state.selectedDate,
      );

      // Guarda referencia al último documento para paginación
      if (orders.isNotEmpty) {
        final lastDoc = orders.last['_docSnapshot'] as DocumentSnapshot?;
        setLastDocument(lastDoc);
      }

      // Determina si hay más órdenes disponibles
      setHasMore(orders.length >= OrdersHistoryService.pageSize);
      setOrders(orders);

      AppLogger.log(
        'Historial inicial cargado: ${orders.length} órdenes',
        prefix: 'HISTORY:',
      );
    } catch (e) {
      setError('Error al cargar el historial');
      setLoading(false);
      AppLogger.log('Error en loadOrders: $e', prefix: 'HISTORY_ERROR:');
    }
  }

  // Carga las siguientes 10 órdenes (scroll infinito)
  Future<void> loadMoreOrders() async {
    // Evita cargas duplicadas o innecesarias
    if (state.isLoadingMore || !state.hasMore || state.isLoading) {
      return;
    }

    setLoadingMore(true);

    try {
      final orders = await _historyService.fetchCompletedOrders(
        date: state.selectedDate,
        lastDocument: state.lastDocument,
      );

      if (orders.isNotEmpty) {
        final lastDoc = orders.last['_docSnapshot'] as DocumentSnapshot?;
        setLastDocument(lastDoc);
        appendOrders(orders);
      }

      // Si se obtuvieron menos órdenes que el tamaño de página, no hay más
      setHasMore(orders.length >= OrdersHistoryService.pageSize);
      setLoadingMore(false);

      AppLogger.log(
        'Más órdenes cargadas: ${orders.length} (Total: ${state.orders.length})',
        prefix: 'HISTORY:',
      );
    } catch (e) {
      setLoadingMore(false);
      AppLogger.log('Error en loadMoreOrders: $e', prefix: 'HISTORY_ERROR:');
    }
  }

  // Cambia la fecha seleccionada y recarga las órdenes
  Future<void> changeDate(DateTime newDate) async {
    setSelectedDate(newDate);
    _initialized = false;
    await initialize();

    AppLogger.log(
      'Fecha cambiada: ${newDate.day}/${newDate.month}/${newDate.year}',
      prefix: 'HISTORY:',
    );
  }

  // Calcula tiempo de preparación usando el servicio
  String getPreparationTime(Map<String, dynamic> order) {
    return _historyService.calculatePreparationTime(order);
  }

  // Formatea hora de completado
  String getCompletedTime(Map<String, dynamic> order) {
    return _historyService.formatCompletedTime(order['completedAt']);
  }
}

// Provider global del controlador de historial
final ordersHistoryControllerProvider =
    NotifierProvider<OrdersHistoryController, OrdersHistoryState>(
      (ref) => OrdersHistoryController(),
    );

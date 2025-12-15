import 'dart:async';
import 'package:refena_flutter/refena_flutter.dart';
import '../states/orders-history-state.dart';
import '../services/orders-history-service.dart';
import '../../../utils/app_logger.dart';

class OrdersHistoryController extends OrdersHistoryStateNotifier {
  final OrdersHistoryService _historyService = OrdersHistoryService();
  StreamSubscription<List<Map<String, dynamic>>>? _ordersSubscription;
  bool _initialized = false;

  @override
  OrdersHistoryState init() {
    return OrdersHistoryState(selectedDate: DateTime.now());
  }

  // Inicializa el controlador y suscribe al stream de órdenes
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _subscribeToOrders();
  }

  // Suscribe al stream de órdenes en tiempo real
  void _subscribeToOrders() {
    setLoading(true);
    setError(null);

    // Cancela suscripción anterior si existe
    _ordersSubscription?.cancel();

    // Nueva suscripción al stream
    _ordersSubscription = _historyService
        .streamCompletedOrders(date: state.selectedDate)
        .listen(
          (orders) {
            setOrders(orders);
            setLoading(false);
            AppLogger.log(
              'Stream actualizado: ${orders.length} órdenes',
              prefix: 'HISTORY:',
            );
          },
          onError: (error) {
            setError('Error al cargar el historial');
            setLoading(false);
            AppLogger.log('Error en stream: $error', prefix: 'HISTORY_ERROR:');
          },
        );
  }

  // Reinicializa para cambios de usuario o refresco forzado
  Future<void> reinitialize() async {
    _ordersSubscription?.cancel();
    _initialized = false;
    reset();
    await initialize();
  }

  // Cambia la fecha seleccionada y se resuscribe al stream
  Future<void> changeDate(DateTime newDate) async {
    setSelectedDate(newDate);
    _subscribeToOrders();

    AppLogger.log(
      'Fecha cambiada: ${newDate.day}/${newDate.month}/${newDate.year}',
      prefix: 'HISTORY:',
    );
  }

  // Calcula tiempo de preparación usando el servicio
  String getPreparationTime(Map<String, dynamic> order) {
    return _historyService.calculatePreparationTime(order);
  }

  // Formatea hora de finalización (completedAt o paidAt según el estado)
  String getCompletedTime(Map<String, dynamic> order) {
    final status = order['status']?.toString() ?? 'completed';
    final timestamp = status == 'paid' ? order['paidAt'] : order['completedAt'];
    return _historyService.formatCompletedTime(timestamp);
  }

  // Limpia recursos al destruir
  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}

// Provider global del controlador de historial
final ordersHistoryControllerProvider =
    NotifierProvider<OrdersHistoryController, OrdersHistoryState>(
      (ref) => OrdersHistoryController(),
    );

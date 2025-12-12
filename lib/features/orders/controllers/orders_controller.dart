import 'dart:async';
import 'package:refena_flutter/refena_flutter.dart';
import '../states/orders_state.dart';
import '../services/orders_service.dart';
import '../../../utils/app_logger.dart';

class OrdersController extends OrdersStateNotifier {
  final OrdersService _ordersService = OrdersService();
  StreamSubscription? _ordersSubscription;
  bool _initialized = false;

  @override
  OrdersState init() {
    return const OrdersState();
  }

  // Inicializa el controlador y suscribe a los cambios
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    setLoading(true);

    _ordersSubscription = _ordersService.streamOrders().listen(
      (orders) {
        setOrders(orders);
        AppLogger.log('Órdenes cargadas: ${orders.length}', prefix: 'ORDERS:');
      },
      onError: (error) {
        setError('Error cargando órdenes');
        setLoading(false);
        AppLogger.log(
          'Error en stream de órdenes: $error',
          prefix: 'ORDERS_ERROR:',
        );
      },
    );
  }

  // Cambia el filtro seleccionado
  void selectFilter(String filter) {
    setSelectedFilter(filter);
    AppLogger.log('Filtro seleccionado: $filter', prefix: 'ORDERS:');
  }

  // Cambia el estado de una orden
  Future<void> changeStatus(String orderId, String newStatus) async {
    try {
      updateOrderStatus(orderId, newStatus);
      await _ordersService.changeOrderStatus(orderId, newStatus);
      AppLogger.log(
        'Estado de orden $orderId cambiado a $newStatus',
        prefix: 'ORDERS:',
      );
    } catch (e) {
      setError('Error al cambiar estado');
      AppLogger.log('Error cambiando estado: $e', prefix: 'ORDERS_ERROR:');
    }
  }

  // Marca una orden como en preparación
  Future<void> startPreparing(String orderId) async {
    await changeStatus(orderId, 'preparing');
  }

  // Marca una orden como completada
  Future<void> completeOrder(String orderId) async {
    await changeStatus(orderId, 'completed');
  }

  // Limpia la suscripción
  void cleanup() {
    _ordersSubscription?.cancel();
    _initialized = false;
  }
}

// Provider global del controlador de órdenes
final ordersControllerProvider =
    NotifierProvider<OrdersController, OrdersState>(
      (ref) => OrdersController(),
    );

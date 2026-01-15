import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ice_storage/ice_storage.dart';
import 'package:refena_flutter/refena_flutter.dart';
import '../states/order-details-state.dart';
import '../services/orders_service.dart';
import '../../tables/services/tables_service.dart';
import '../../../auth/current_user.dart';
import '../../../utils/app_logger.dart';

class OrderDetailsController extends OrderDetailsStateNotifier {
  final OrdersService _ordersService = OrdersService();
  final TablesService _tablesService = TablesService();
  StreamSubscription? _orderSubscription;
  bool _initialized = false;

  @override
  OrderDetailsState init() => const OrderDetailsState();

  // Inicializa el controlador con los datos de la mesa
  void initialize(Map<String, dynamic> table) {
    if (_initialized) return;
    _initialized = true;

    setTable(table);
    _subscribeToOrder(table['id']);
  }

  // Reinicializa con nueva mesa
  void reinitialize(Map<String, dynamic> table) {
    cleanup();
    _initialized = false;
    initialize(table);
  }

  // Suscribe a cambios de la orden en tiempo real
  void _subscribeToOrder(String tableId) {
    final gateway = IceStorage.instance.gateway;
    if (gateway == null) {
      setLoading(false);
      return;
    }

    final businessId = CurrentUserAuth.instance.businessId;

    final query = FirebaseFirestore.instance
        .collection('orders')
        .where('businessId', isEqualTo: businessId)
        .where('tableId', isEqualTo: tableId)
        .where('status', whereIn: ['pending', 'preparing', 'completed', 'paid'])
        .orderBy('createdAt', descending: true)
        .limit(1);

    _orderSubscription = gateway
        .streamDocuments(query: query)
        .listen(
          (snapshot) {
            if (snapshot.docs.isNotEmpty) {
              final doc = snapshot.docs.first;
              final data = doc.data();
              data['id'] = doc.id;
              setOrder(data);
              AppLogger.log(
                'Orden actualizada: ${doc.id} - Estado: ${data['status']}',
                prefix: 'ORDER_DETAILS:',
              );
            } else {
              setOrder(null);
            }
          },
          onError: (e) {
            AppLogger.log(
              'Error en stream de orden: $e',
              prefix: 'ORDER_DETAILS_ERROR:',
            );
            setLoading(false);
          },
        );
  }

  // Elimina un item de la orden y retorna true si la orden fue cancelada
  Future<bool> removeItem(int index) async {
    final order = state.order;
    if (order == null) return false;

    final items = List<dynamic>.from(order['items'] ?? []);
    if (index < 0 || index >= items.length) return false;

    final removedItem = items[index];
    final price = (removedItem['price'] as num?)?.toDouble() ?? 0.0;
    final quantity = removedItem['quantity'] ?? 1;
    final amountToSubtract = price * quantity;

    items.removeAt(index);

    final currentTotal = state.totalAmount;
    final newTotal = (currentTotal - amountToSubtract).clamp(
      0.0,
      double.infinity,
    );

    try {
      if (items.isEmpty) {
        // Si no quedan items, cancela orden y libera mesa
        await _ordersService.changeOrderStatus(order['id'], 'cancelled');
        await _tablesService.changeTableStatus(state.table!['id'], 'available');
        AppLogger.log(
          'Orden cancelada por no tener items',
          prefix: 'ORDER_DETAILS:',
        );
        return true;
      } else {
        await _ordersService.updateOrderItems(
          order['id'],
          items.map((e) => Map<String, dynamic>.from(e)).toList(),
        );
        await _updateOrderTotal(order['id'], newTotal);

        updateOrderLocally({'items': items, 'totalAmount': newTotal});
        AppLogger.log('Item eliminado de la orden', prefix: 'ORDER_DETAILS:');
      }
      return false;
    } catch (e) {
      AppLogger.log(
        'Error eliminando item: $e',
        prefix: 'ORDER_DETAILS_ERROR:',
      );
      setError('Error al eliminar item');
      return false;
    }
  }

  // Actualiza el total de la orden
  Future<void> _updateOrderTotal(String orderId, double newTotal) async {
    final gateway = IceStorage.instance.gateway;
    if (gateway == null) return;

    final docRef = FirebaseFirestore.instance.collection('orders').doc(orderId);
    await gateway.updateDocument(
      docRef: docRef,
      data: {'totalAmount': newTotal},
    );
  }

  // Limpia la suscripción
  void cleanup() {
    _orderSubscription?.cancel();
    _orderSubscription = null;
  }
}

// Provider global del controlador
final orderDetailsControllerProvider =
    NotifierProvider<OrderDetailsController, OrderDetailsState>(
      (ref) => OrderDetailsController(),
    );

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ice_storage/ice_storage.dart';
import '../../../auth/current_user.dart';
import '../../../utils/app_logger.dart';
import 'context_service.dart';

class OrdersService {
  // Obtiene el businessId del usuario autenticado
  String? get _businessId => CurrentUserAuth.instance.businessId;

  // Referencia al gateway
  FirestoreGateway? get _gateway => IceStorage.instance.gateway;

  // Stream de órdenes en tiempo real
  Stream<List<Map<String, dynamic>>> streamOrders() {
    final businessId = _businessId;
    final gateway = _gateway;

    if (businessId == null || businessId.isEmpty) {
      AppLogger.log('BusinessId no disponible', prefix: 'ORDERS_ERROR:');
      return Stream.value([]);
    }

    if (gateway == null) {
      AppLogger.log('Gateway no inicializado', prefix: 'ORDERS_ERROR:');
      return Stream.value([]);
    }

    final query = FirebaseFirestore.instance
        .collection('orders')
        .where('businessId', isEqualTo: businessId)
        .orderBy('createdAt', descending: true);

    return gateway.streamDocuments(query: query).map((snapshot) {
      final orders = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      AppLogger.log(
        'Órdenes actualizadas: ${orders.length}',
        prefix: 'ORDERS:',
      );
      return orders;
    });
  }

  // Cambia el estado de una orden
  Future<void> changeOrderStatus(String orderId, String status) async {
    final gateway = _gateway;
    if (gateway == null) {
      AppLogger.log('Gateway no inicializado', prefix: 'ORDERS_ERROR:');
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId);
      await gateway.updateDocument(
        docRef: docRef,
        data: {'status': status, 'updatedAt': FieldValue.serverTimestamp()},
      );

      AppLogger.log('Estado de orden cambiado a $status', prefix: 'ORDERS:');
    } catch (e) {
      AppLogger.log('Error cambiando estado: $e', prefix: 'ORDERS_ERROR:');
      rethrow;
    }
  }

  // Obtiene una orden por ID
  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    final gateway = _gateway;
    if (gateway == null) return null;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId);
      final doc = await gateway.getDocument(docRef: docRef);

      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      AppLogger.log('Error obteniendo orden: $e', prefix: 'ORDERS_ERROR:');
      return null;
    }
  }

  // Crea una nueva orden con número secuencial y datos de contexto
  Future<String?> createOrder(Map<String, dynamic> orderData) async {
    final businessId = _businessId;

    if (businessId == null || businessId.isEmpty) {
      AppLogger.log('BusinessId no disponible', prefix: 'ORDERS_ERROR:');
      return null;
    }

    try {
      // Obtener contexto automático (clima y feriados)
      final contextService = ContextService();
      final context = await contextService.getOrderContext(
        specialEvent: orderData['specialEvent'] ?? false,
      );

      final firestore = FirebaseFirestore.instance;
      final orderDocRef = firestore.collection('orders').doc();
      final counterDocRef = firestore
          .collection('businesses')
          .doc(businessId)
          .collection('counters')
          .doc('data');

      // Transacción atómica para incrementar contador y crear orden
      String? orderId;
      await firestore.runTransaction((transaction) async {
        // Leer contador actual
        final counterSnapshot = await transaction.get(counterDocRef);
        int currentOrderCount = 0;

        if (counterSnapshot.exists) {
          final data = counterSnapshot.data();
          currentOrderCount = (data?['orders'] as int?) ?? 0;
        }

        // Incrementar contador
        final newOrderNumber = currentOrderCount + 1;

        // Actualizar contador
        transaction.set(counterDocRef, {
          'orders': newOrderNumber,
        }, SetOptions(merge: true));

        // Crear orden con datos de contexto para predicción
        transaction.set(orderDocRef, {
          ...orderData,
          'businessId': businessId,
          'orderNumber': newOrderNumber,
          'status': 'pending',
          'holiday': context['holiday'],
          'specialEvent': context['specialEvent'],
          'weather': context['weather'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        orderId = orderDocRef.id;
      });

      AppLogger.log('Orden creada: $orderId', prefix: 'ORDERS:');
      return orderId;
    } catch (e) {
      AppLogger.log('Error creando orden: $e', prefix: 'ORDERS_ERROR:');
      return null;
    }
  }

  // Formatea el número de orden con ceros a la izquierda
  static String formatOrderNumber(int number) {
    return number.toString().padLeft(3, '0');
  }

  // Actualiza los items de una orden
  Future<void> updateOrderItems(
    String orderId,
    List<Map<String, dynamic>> items,
  ) async {
    final gateway = _gateway;
    if (gateway == null) {
      AppLogger.log('Gateway no inicializado', prefix: 'ORDERS_ERROR:');
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId);
      await gateway.updateDocument(
        docRef: docRef,
        data: {'items': items, 'updatedAt': FieldValue.serverTimestamp()},
      );

      AppLogger.log('Items de orden actualizados', prefix: 'ORDERS:');
    } catch (e) {
      AppLogger.log('Error actualizando items: $e', prefix: 'ORDERS_ERROR:');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getActiveOrderByTable(String tableId) async {
    final businessId = _businessId;
    final gateway = _gateway;

    if (businessId == null || gateway == null) return null;

    try {
      final query = FirebaseFirestore.instance
          .collection('orders')
          .where('businessId', isEqualTo: businessId)
          .where('tableId', isEqualTo: tableId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .limit(1);

      final snapshot = await gateway.getDocuments(query: query);

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      AppLogger.log('Error buscando orden activa: $e', prefix: 'ORDERS_ERROR:');
      return null;
    }
  }

  Future<bool> addItemsToOrder(
    String orderId,
    List<Map<String, dynamic>> newItems,
    double additionalAmount,
  ) async {
    final gateway = _gateway;
    if (gateway == null) return false;

    try {
      final order = await getOrder(orderId);
      if (order == null) return false;

      final existingItems = (order['items'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final currentTotal = (order['totalAmount'] as num?)?.toDouble() ?? 0.0;

      existingItems.addAll(newItems);

      final docRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId);

      await gateway.updateDocument(
        docRef: docRef,
        data: {
          'items': existingItems,
          'totalAmount': currentTotal + additionalAmount,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      AppLogger.log('Items agregados a orden existente', prefix: 'ORDERS:');
      return true;
    } catch (e) {
      AppLogger.log('Error agregando items: $e', prefix: 'ORDERS_ERROR:');
      return false;
    }
  }
}

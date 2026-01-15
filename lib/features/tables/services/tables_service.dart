import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ice_storage/ice_storage.dart';
import 'package:rxdart/rxdart.dart';
import '../../../auth/current_user.dart';
import '../../../utils/app_logger.dart';

class TablesService {
  // Obtiene el businessId del usuario autenticado
  String? get _businessId => CurrentUserAuth.instance.businessId;

  // Referencia al gateway
  FirestoreGateway? get _gateway => IceStorage.instance.gateway;

  // Suscripción a mesas con estado de orden en tiempo real
  Stream<List<Map<String, dynamic>>> streamTables() {
    final businessId = _businessId;
    final gateway = _gateway;

    if (businessId == null || businessId.isEmpty) {
      AppLogger.log('BusinessId no disponible', prefix: 'TABLES_ERROR:');
      return Stream.value([]);
    }

    if (gateway == null) {
      AppLogger.log('Gateway no inicializado', prefix: 'TABLES_ERROR:');
      return Stream.value([]);
    }

    final tablesQuery = FirebaseFirestore.instance
        .collection('tables')
        .where('businessId', isEqualTo: businessId);

    final ordersQuery = FirebaseFirestore.instance
        .collection('orders')
        .where('businessId', isEqualTo: businessId)
        .where('status', whereIn: ['pending', 'preparing', 'completed']);

    // Combina ambos streams para obtener mesas con estado de orden
    return Rx.combineLatest2<
      QuerySnapshot<Map<String, dynamic>>,
      QuerySnapshot<Map<String, dynamic>>,
      List<Map<String, dynamic>>
    >(
      gateway.streamDocuments(query: tablesQuery),
      gateway.streamDocuments(query: ordersQuery),
      (tablesSnapshot, ordersSnapshot) {
        // Crea un mapa de tableId a estado de orden
        final ordersByTable = <String, String>{};
        for (final doc in ordersSnapshot.docs) {
          final data = doc.data();
          final tableId = data['tableId'] as String?;
          final status = data['status'] as String?;
          if (tableId != null && status != null) {
            ordersByTable[tableId] = status;
          }
        }

        // Asigna el estado de orden a cada mesa
        final tables = tablesSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          // Agrega el estado de la orden si existe
          if (data['status'] == 'occupied' &&
              ordersByTable.containsKey(doc.id)) {
            data['orderStatus'] = ordersByTable[doc.id];
          }
          return data;
        }).toList();

        AppLogger.log(
          'Mesas actualizadas: ${tables.length}',
          prefix: 'TABLES:',
        );
        return tables;
      },
    );
  }

  // Obtiene las mesas una sola vez
  Future<List<Map<String, dynamic>>> getTables() async {
    final businessId = _businessId;
    final gateway = _gateway;

    if (businessId == null || businessId.isEmpty) {
      AppLogger.log('BusinessId no disponible', prefix: 'TABLES_ERROR:');
      return [];
    }

    if (gateway == null) {
      AppLogger.log('Gateway no inicializado', prefix: 'TABLES_ERROR:');
      return [];
    }

    try {
      final query = FirebaseFirestore.instance
          .collection('tables')
          .where('businessId', isEqualTo: businessId);

      final snapshot = await gateway.getDocuments(query: query);

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      AppLogger.log('Error obteniendo mesas: $e', prefix: 'TABLES_ERROR:');
      return [];
    }
  }

  // Cambia el estado de una mesa
  Future<void> changeTableStatus(String tableId, String status) async {
    final gateway = _gateway;
    if (gateway == null) {
      AppLogger.log('Gateway no inicializado', prefix: 'TABLES_ERROR:');
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance
          .collection('tables')
          .doc(tableId);
      await gateway.updateDocument(
        docRef: docRef,
        data: {'status': status, 'updatedAt': FieldValue.serverTimestamp()},
      );

      AppLogger.log('Estado de mesa cambiado a $status', prefix: 'TABLES:');
    } catch (e) {
      AppLogger.log('Error cambiando estado: $e', prefix: 'TABLES_ERROR:');
      rethrow;
    }
  }
}

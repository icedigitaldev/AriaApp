import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ice_storage/ice_storage.dart';
import '../../../auth/current_user.dart';
import '../../../utils/app_logger.dart';

class TablesService {
  // Obtiene el businessId del usuario autenticado
  String? get _businessId => CurrentUserAuth.instance.businessId;

  // Referencia al gateway
  FirestoreGateway? get _gateway => IceStorage.instance.gateway;

  // Suscripción a mesas en tiempo real
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

    final query = FirebaseFirestore.instance
        .collection('tables')
        .where('businessId', isEqualTo: businessId);

    return gateway.streamDocuments(query: query).map((snapshot) {
      final tables = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      AppLogger.log('Mesas actualizadas: ${tables.length}', prefix: 'TABLES:');
      return tables;
    });
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

  // Convierte el valor de floor a int de forma segura
  int _parseFloor(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }

  // Obtiene los pisos únicos de las mesas
  Future<List<int>> getFloors() async {
    final tables = await getTables();
    final floors = tables.map((t) => _parseFloor(t['floor'])).toSet().toList();
    floors.sort();
    return floors;
  }
}

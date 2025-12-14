import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ice_storage/ice_storage.dart';
import '../../../auth/current_user.dart';
import '../../../utils/app_logger.dart';

class OrdersHistoryService {
  // Cantidad de órdenes por página
  static const int pageSize = 10;

  String? get _businessId => CurrentUserAuth.instance.businessId;
  FirestoreGateway? get _gateway => IceStorage.instance.gateway;

  // Consulta paginada de órdenes completadas por fecha
  Future<List<Map<String, dynamic>>> fetchCompletedOrders({
    required DateTime date,
    DocumentSnapshot? lastDocument,
  }) async {
    final businessId = _businessId;
    final gateway = _gateway;

    if (businessId == null || businessId.isEmpty) {
      AppLogger.log('BusinessId no disponible', prefix: 'HISTORY_ERROR:');
      return [];
    }

    if (gateway == null) {
      AppLogger.log('Gateway no inicializado', prefix: 'HISTORY_ERROR:');
      return [];
    }

    try {
      // Rango de fecha para filtrar órdenes del día seleccionado
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Construcción de la consulta base
      Query query = FirebaseFirestore.instance
          .collection('orders')
          .where('businessId', isEqualTo: businessId)
          .where('status', isEqualTo: 'completed')
          .where(
            'completedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('completedAt', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('completedAt', descending: true)
          .limit(pageSize);

      // Si hay documento previo, continúa desde ahí
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await gateway.getDocuments(
        query: query as Query<Map<String, dynamic>>,
      );

      final orders = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        // Referencia al documento para paginación
        data['_docSnapshot'] = doc;
        return data;
      }).toList();

      AppLogger.log(
        'Historial cargado: ${orders.length} órdenes del ${date.day}/${date.month}/${date.year}',
        prefix: 'HISTORY:',
      );

      return orders;
    } catch (e) {
      AppLogger.log('Error cargando historial: $e', prefix: 'HISTORY_ERROR:');
      return [];
    }
  }

  // Calcula tiempo de preparación de una orden
  String calculatePreparationTime(Map<String, dynamic> order) {
    final createdAt = order['createdAt'];
    final completedAt = order['completedAt'];

    if (createdAt == null || completedAt == null) return '--';

    DateTime created;
    DateTime completed;

    // Conversión de Timestamp de Firebase
    if (createdAt is Timestamp) {
      created = createdAt.toDate();
    } else if (createdAt is DateTime) {
      created = createdAt;
    } else {
      return '--';
    }

    if (completedAt is Timestamp) {
      completed = completedAt.toDate();
    } else if (completedAt is DateTime) {
      completed = completedAt;
    } else {
      return '--';
    }

    final difference = completed.difference(created);

    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    }
    return '${difference.inMinutes} min';
  }

  // Formatea hora de completado
  String formatCompletedTime(dynamic timestamp) {
    if (timestamp == null) return '--';

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return '--';
    }

    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $period';
  }
}

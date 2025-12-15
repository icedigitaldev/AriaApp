import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ice_storage/ice_storage.dart';
import 'package:rxdart/rxdart.dart';
import '../../../auth/current_user.dart';
import '../../../utils/app_logger.dart';

class OrdersHistoryService {
  // Cantidad de órdenes por página
  static const int pageSize = 20;

  String? get _businessId => CurrentUserAuth.instance.businessId;
  FirestoreGateway? get _gateway => IceStorage.instance.gateway;

  // Stream reactivo de órdenes finalizadas (completed y paid) por fecha
  Stream<List<Map<String, dynamic>>> streamCompletedOrders({
    required DateTime date,
  }) {
    final businessId = _businessId;
    final gateway = _gateway;

    if (businessId == null || businessId.isEmpty) {
      AppLogger.log('BusinessId no disponible', prefix: 'HISTORY_ERROR:');
      return Stream.value([]);
    }

    if (gateway == null) {
      AppLogger.log('Gateway no inicializado', prefix: 'HISTORY_ERROR:');
      return Stream.value([]);
    }

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Query para órdenes completed
    final completedQuery = FirebaseFirestore.instance
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

    // Query para órdenes paid
    final paidQuery = FirebaseFirestore.instance
        .collection('orders')
        .where('businessId', isEqualTo: businessId)
        .where('status', isEqualTo: 'paid')
        .where('paidAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('paidAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('paidAt', descending: true)
        .limit(pageSize);

    // Combina ambos streams con rxdart
    final completedStream = gateway.streamDocuments(query: completedQuery);
    final paidStream = gateway.streamDocuments(query: paidQuery);

    return Rx.combineLatest2<
      QuerySnapshot<Map<String, dynamic>>,
      QuerySnapshot<Map<String, dynamic>>,
      List<Map<String, dynamic>>
    >(completedStream, paidStream, (completedSnap, paidSnap) {
      final allOrders = <Map<String, dynamic>>[];

      // Procesa órdenes completed
      for (final doc in completedSnap.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        data['_sortDate'] = data['completedAt'];
        allOrders.add(data);
      }

      // Procesa órdenes paid
      for (final doc in paidSnap.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        data['_sortDate'] = data['paidAt'];
        allOrders.add(data);
      }

      // Ordena por fecha descendente
      allOrders.sort((a, b) {
        final aDate = a['_sortDate'];
        final bDate = b['_sortDate'];
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        DateTime aDateTime;
        DateTime bDateTime;

        if (aDate is Timestamp) {
          aDateTime = aDate.toDate();
        } else {
          aDateTime = aDate as DateTime;
        }

        if (bDate is Timestamp) {
          bDateTime = bDate.toDate();
        } else {
          bDateTime = bDate as DateTime;
        }

        return bDateTime.compareTo(aDateTime);
      });

      AppLogger.log(
        'Historial stream: ${allOrders.length} órdenes del ${date.day}/${date.month}/${date.year}',
        prefix: 'HISTORY:',
      );

      return allOrders;
    });
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

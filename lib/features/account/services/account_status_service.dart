import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/app_logger.dart';

class AccountStatusService {
  static final _firestore = FirebaseFirestore.instance;

  // Escucha en tiempo real el estado del staff
  static Stream<Map<String, dynamic>?> watchStaffStatus(String staffId) {
    if (staffId.isEmpty) {
      AppLogger.log('StaffId vacío para monitorear', prefix: 'ACCOUNT:');
      return Stream.value(null);
    }

    return _firestore.collection('staff').doc(staffId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) {
        AppLogger.log('Staff no encontrado: $staffId', prefix: 'ACCOUNT:');
        return null;
      }

      final data = snapshot.data();
      AppLogger.log(
        'Status actualizado: ${data?['status']}',
        prefix: 'ACCOUNT:',
      );
      return data;
    });
  }

  // Verifica si el staff está activo
  static bool isStaffActive(Map<String, dynamic>? staffData) {
    if (staffData == null) return false;
    final status = staffData['status']?.toString().toLowerCase() ?? 'inactive';
    return status == 'active';
  }
}

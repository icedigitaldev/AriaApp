import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ice_storage/ice_storage.dart';
import '../../../utils/app_logger.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Busca un staff por número de teléfono
  Future<Map<String, dynamic>?> findStaffByPhone(String phone) async {
    try {
      // Normaliza el número de teléfono
      final normalizedPhone = _normalizePhone(phone);

      final querySnapshot = await _firestore
          .collection('staff')
          .where('phone', isEqualTo: normalizedPhone)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        AppLogger.log(
          'Staff no encontrado para: $normalizedPhone',
          prefix: 'AUTH:',
        );
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['docId'] = doc.id;

      AppLogger.log('Staff encontrado: ${data['name']}', prefix: 'AUTH:');
      return data;
    } catch (e) {
      AppLogger.log('Error buscando staff: $e', prefix: 'AUTH_ERROR:');
      return null;
    }
  }

  // Verifica el PIN de acceso
  Future<bool> verifyAccessPin(String docId, String pin) async {
    try {
      final doc = await _firestore.collection('staff').doc(docId).get();

      if (!doc.exists) {
        AppLogger.log('Documento no existe: $docId', prefix: 'AUTH_ERROR:');
        return false;
      }

      final storedPin = doc.data()?['accessPin'] as String?;
      final isValid = storedPin == pin;

      AppLogger.log(
        'PIN verificación - docId: $docId, stored: $storedPin, input: $pin, valid: $isValid',
        prefix: 'AUTH:',
      );

      return isValid;
    } catch (e) {
      AppLogger.log('Error verificando PIN: $e', prefix: 'AUTH_ERROR:');
      return false;
    }
  }

  // Guarda la sesión del usuario autenticado
  Future<void> saveSession(Map<String, dynamic> staffData) async {
    final docId = staffData['docId'] as String;
    final businessId = staffData['currentBusiness'] as String?;

    // Guardamos la sesión usando los datos tal cual vienen de la BD.
    // role: Cargo real (ej: Jefe de Cocina)
    // custom['department']: Departamento (ej: production)
    // Esto asegura que la App use la misma terminología que la base de datos.
    await IceStorage.instance.auth.save(
      uid: docId,
      token: businessId ?? '',
      role:
          staffData['role'] ??
          'Staff', // Rol real (cargo) como rol principal de sesión
      custom: {
        'name': staffData['name'],
        'phone': staffData['phone'],
        'department': staffData['department'] ?? 'service',
        'avatarUrl': staffData['avatarUrl'],
        'imageUrl': staffData['imageUrl'],
        'businessId': businessId,
      },
    );

    AppLogger.log(
      'Sesión guardada para: ${staffData['name']} - rol: ${staffData['role']} - dept: ${staffData['department']}',
      prefix: 'AUTH:',
    );
  }

  // Cierra la sesión del usuario
  Future<void> logout() async {
    await IceStorage.instance.auth.clearAuth();
    AppLogger.log('Sesión cerrada', prefix: 'AUTH:');
  }

  // Verifica si hay una sesión activa
  bool get isAuthenticated => IceStorage.instance.auth.isAuthenticated.value;

  // Obtiene el rol (cargo) del usuario actual
  String? get currentRole => IceStorage.instance.auth.role.value;

  // Obtiene el departamento del usuario actual (Fuente de Verdad para routing)
  String get currentDepartment {
    final custom = currentUserData;
    return custom['department']?.toString() ?? 'service';
  }

  // Obtiene el ID del usuario actual
  String? get currentUserId => IceStorage.instance.auth.uid.value;

  // Obtiene los datos personalizados del usuario
  Map<String, dynamic> get currentUserData =>
      IceStorage.instance.auth.customFields.value;

  // Normaliza el número de teléfono al formato +51XXXXXXXXX
  String _normalizePhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    if (!cleaned.startsWith('+')) {
      if (cleaned.startsWith('51')) {
        cleaned = '+$cleaned';
      } else {
        cleaned = '+51$cleaned';
      }
    }

    return cleaned;
  }
}

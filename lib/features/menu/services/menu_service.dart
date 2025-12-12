import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ice_storage/ice_storage.dart';
import '../../../auth/current_user.dart';
import '../../../utils/app_logger.dart';

class MenuService {
  // Obtiene el businessId del usuario autenticado
  String? get _businessId => CurrentUserAuth.instance.businessId;

  // Referencia al gateway
  FirestoreGateway? get _gateway => IceStorage.instance.gateway;

  // Stream de platillos en tiempo real
  Stream<List<Map<String, dynamic>>> streamDishes() {
    final businessId = _businessId;
    final gateway = _gateway;

    if (businessId == null || businessId.isEmpty) {
      AppLogger.log('BusinessId no disponible', prefix: 'MENU_ERROR:');
      return Stream.value([]);
    }

    if (gateway == null) {
      AppLogger.log('Gateway no inicializado', prefix: 'MENU_ERROR:');
      return Stream.value([]);
    }

    final query = FirebaseFirestore.instance
        .collection('dishes')
        .where('businessId', isEqualTo: businessId)
        .where('status', isEqualTo: 'available');

    return gateway.streamDocuments(query: query).map((snapshot) {
      final dishes = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      AppLogger.log(
        'Platillos actualizados: ${dishes.length}',
        prefix: 'MENU:',
      );
      return dishes;
    });
  }

  // Obtiene platillos por categoría
  Stream<List<Map<String, dynamic>>> streamDishesByCategory(String category) {
    final businessId = _businessId;
    final gateway = _gateway;

    if (businessId == null || businessId.isEmpty) {
      return Stream.value([]);
    }

    if (gateway == null) {
      return Stream.value([]);
    }

    final query = FirebaseFirestore.instance
        .collection('dishes')
        .where('businessId', isEqualTo: businessId)
        .where('category', isEqualTo: category)
        .where('status', isEqualTo: 'available');

    return gateway.streamDocuments(query: query).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Obtiene las categorías únicas de los platillos
  Future<List<String>> getCategories() async {
    final businessId = _businessId;
    final gateway = _gateway;

    if (businessId == null || businessId.isEmpty) {
      return [];
    }

    if (gateway == null) {
      return [];
    }

    try {
      final query = FirebaseFirestore.instance
          .collection('dishes')
          .where('businessId', isEqualTo: businessId);

      final snapshot = await gateway.getDocuments(query: query);

      final categories = snapshot.docs
          .map((doc) => doc.data()['category'] as String?)
          .where((cat) => cat != null)
          .toSet()
          .cast<String>()
          .toList();

      categories.sort();
      return categories;
    } catch (e) {
      AppLogger.log('Error obteniendo categorías: $e', prefix: 'MENU_ERROR:');
      return [];
    }
  }

  // Obtiene un platillo por ID
  Future<Map<String, dynamic>?> getDish(String dishId) async {
    final gateway = _gateway;
    if (gateway == null) return null;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('dishes')
          .doc(dishId);
      final doc = await gateway.getDocument(docRef: docRef);

      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      AppLogger.log('Error obteniendo platillo: $e', prefix: 'MENU_ERROR:');
      return null;
    }
  }
}

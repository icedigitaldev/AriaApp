import 'package:ice_storage/ice_storage.dart';

/// Singleton para acceso centralizado a datos del usuario autenticado
class CurrentUserAuth {
  static final CurrentUserAuth _instance = CurrentUserAuth._();
  static CurrentUserAuth get instance => _instance;
  CurrentUserAuth._();

  // ID del staff (documento en Firestore)
  String? get id => IceStorage.instance.auth.uid.value;

  // Rol del usuario (waiter, kitchen)
  String? get role => IceStorage.instance.auth.role.value;

  // Estado de autenticación
  bool get isAuthenticated => IceStorage.instance.auth.isAuthenticated.value;

  // ID del negocio al que pertenece el staff
  String? get businessId =>
      IceStorage.instance.auth.customFields.value['businessId'];

  // Nombre del usuario
  String? get name => IceStorage.instance.auth.customFields.value['name'];

  // Teléfono del usuario
  String? get phone => IceStorage.instance.auth.customFields.value['phone'];

  // Departamento del usuario
  String? get department =>
      IceStorage.instance.auth.customFields.value['department'];

  // URL del avatar
  String? get avatarUrl =>
      IceStorage.instance.auth.customFields.value['avatarUrl'];

  // Todos los campos personalizados
  Map<String, dynamic> get customFields =>
      IceStorage.instance.auth.customFields.value;
}

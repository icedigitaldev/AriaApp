import 'package:refena_flutter/refena_flutter.dart';
import '../states/auth_state.dart';
import '../services/auth_service.dart';
import '../../../utils/app_logger.dart';

class AuthController extends AuthStateNotifier {
  final AuthService _authService = AuthService();
  bool _initialized = false;

  @override
  AuthState init() {
    if (!_initialized) {
      _initialized = true;
      _checkExistingSession();
    }
    return const AuthState();
  }

  // Verifica si hay sesión existente al iniciar
  void _checkExistingSession() {
    if (_authService.isAuthenticated) {
      AppLogger.log('Sesión existente detectada', prefix: 'AUTH:');
    }
  }

  Future<Map<String, dynamic>?> submitPhoneAndGetStaff(String phone) async {
    if (phone.isEmpty || phone.length < 9) {
      setError('Ingresa un número de teléfono válido');
      return null;
    }

    setLoading(true);
    setError(null);

    final staffData = await _authService.findStaffByPhone(phone);

    if (staffData == null) {
      setLoading(false);
      setError('Número no registrado o cuenta inactiva');
      return null;
    }

    setPendingStaff(staffData);
    setLoading(false);

    AppLogger.log('Staff encontrado: ${staffData['name']}', prefix: 'AUTH:');
    return staffData;
  }

  // Verifica el PIN de acceso
  Future<bool> submitPin(String pin) async {
    AppLogger.log('submitPin llamado con PIN: $pin', prefix: 'AUTH:');

    final pendingStaff = state.pendingStaff;
    AppLogger.log('pendingStaff: $pendingStaff', prefix: 'AUTH:');

    if (pendingStaff == null) {
      AppLogger.log('ERROR: pendingStaff es null', prefix: 'AUTH:');
      setError('Error de sesión, intenta de nuevo');
      return false;
    }

    if (pin.isEmpty || pin.length != 6) {
      AppLogger.log(
        'ERROR: PIN inválido (length: ${pin.length})',
        prefix: 'AUTH:',
      );
      setError('El PIN debe tener 6 dígitos');
      return false;
    }

    setLoading(true);
    setError(null);

    final docId = pendingStaff['docId'] as String;
    AppLogger.log('Verificando PIN para docId: $docId', prefix: 'AUTH:');

    final isValid = await _authService.verifyAccessPin(docId, pin);
    AppLogger.log('Resultado de verificación: $isValid', prefix: 'AUTH:');

    if (!isValid) {
      setLoading(false);
      setError('PIN incorrecto');
      return false;
    }

    // PIN válido, guardar sesión
    await _authService.saveSession(pendingStaff);
    setLoading(false);
    reset();

    AppLogger.log('Autenticación exitosa', prefix: 'AUTH:');
    return true;
  }

  // Vuelve al paso anterior
  void goBack() {
    if (state.currentStep == 'pin') {
      setStep('phone');
      setPendingStaff(null);
    }
  }

  // Cierra la sesión
  Future<void> logout() async {
    await _authService.logout();
    reset();
  }

  // Getters de estado de sesión
  bool get isAuthenticated => _authService.isAuthenticated;
  String? get currentRole => _authService.currentRole;
  String? get currentUserId => _authService.currentUserId;
  Map<String, dynamic> get currentUserData => _authService.currentUserData;
}

// Provider global del controlador
final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);

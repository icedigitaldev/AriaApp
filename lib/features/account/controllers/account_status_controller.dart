import 'dart:async';
import 'package:refena_flutter/refena_flutter.dart';
import '../states/account_status_state.dart';
import '../services/account_status_service.dart';
import '../../../auth/current_user.dart';
import '../../../utils/app_logger.dart';

final accountStatusControllerProvider =
    NotifierProvider<AccountStatusController, AccountStatusState>(
      (ref) => AccountStatusController(),
    );

class AccountStatusController extends Notifier<AccountStatusState> {
  StreamSubscription? _statusSubscription;
  bool _isInitialized = false;

  @override
  AccountStatusState init() => const AccountStatusState();

  // Inicia el monitoreo del status del staff
  void startMonitoring() {
    if (_isInitialized) return;
    _isInitialized = true;

    final staffId = CurrentUserAuth.instance.id;
    if (staffId == null || staffId.isEmpty) {
      AppLogger.log('No hay staffId para monitorear', prefix: 'ACCOUNT:');
      state = state.copyWith(isLoading: false);
      return;
    }

    AppLogger.log(
      'Iniciando monitoreo de cuenta: $staffId',
      prefix: 'ACCOUNT:',
    );

    _statusSubscription = AccountStatusService.watchStaffStatus(staffId).listen(
      (staffData) {
        final isActive = AccountStatusService.isStaffActive(staffData);
        state = state.copyWith(
          isLoading: false,
          isBlocked: !isActive,
          staffData: staffData,
        );

        if (!isActive) {
          AppLogger.log('Cuenta bloqueada detectada', prefix: 'ACCOUNT:');
        }
      },
      onError: (error) {
        AppLogger.log('Error monitoreando cuenta: $error', prefix: 'ACCOUNT:');
        state = state.copyWith(isLoading: false);
      },
    );
  }

  // Detiene el monitoreo
  void stopMonitoring() {
    _statusSubscription?.cancel();
    _statusSubscription = null;
    _isInitialized = false;
    AppLogger.log('Monitoreo de cuenta detenido', prefix: 'ACCOUNT:');
  }

  // Re-inicializa el monitoreo
  void reinitialize() {
    stopMonitoring();
    state = const AccountStatusState();
    startMonitoring();
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}

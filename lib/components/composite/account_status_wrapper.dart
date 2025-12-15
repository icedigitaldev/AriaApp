import 'package:flutter/material.dart';
import 'package:refena_flutter/refena_flutter.dart';
import '../../features/account/controllers/account_status_controller.dart';
import '../../views/account_blocked_view.dart';
import '../ui/app_loader.dart';
import '../../design/colors/app_colors.dart';
import '../../design/responsive/responsive_scaler.dart';

class AccountStatusWrapper extends StatefulWidget {
  final Widget child;

  const AccountStatusWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<AccountStatusWrapper> createState() => _AccountStatusWrapperState();
}

class _AccountStatusWrapperState extends State<AccountStatusWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.ref.notifier(accountStatusControllerProvider).startMonitoring();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref) {
        final accountState = ref.watch(accountStatusControllerProvider);

        // Carga inicial
        if (accountState.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: AppLoader(size: ResponsiveScaler.width(40))),
          );
        }

        // Cuenta bloqueada
        if (accountState.isBlocked) {
          return const AccountBlockedView();
        }

        // Cuenta activa
        return widget.child;
      },
    );
  }
}

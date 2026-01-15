import 'package:flutter/material.dart';
import 'package:ice_storage/ice_storage.dart';
import 'package:refena_flutter/refena_flutter.dart';
import '../controllers/aria_video_controller.dart';
import '../components/composite/account_status_wrapper.dart';

import '../views/phone_auth_view.dart';
import '../views/otp_verification_view.dart';
import '../views/tables_view.dart';
import '../views/new_order_view.dart';
import '../views/order_details_view.dart';
import '../views/kitchen_orders_view.dart';
import '../views/kitchen_order_details_view.dart';
import '../views/orders_history_view.dart';
import '../views/account_blocked_view.dart';
import '../views/profile_view.dart';

class AppRouter {
  // Rutas de autenticación
  static const String phoneAuth = '/phone-auth';
  static const String otpVerification = '/otp-verification';

  // Rutas del mesero
  static const String tables = '/tables';
  static const String newOrder = '/new-order';
  static const String orderDetails = '/order-details';

  // Rutas de cocina
  static const String kitchenOrders = '/kitchen-orders';
  static const String kitchenOrderDetails = '/kitchen-order-details';
  static const String ordersHistory = '/orders-history';

  // Ruta de bloqueo
  static const String accountBlocked = '/account-blocked';

  // Ruta de perfil
  static const String profile = '/profile';

  // Obtiene la ruta inicial según estado de autenticación
  static String getInitialRoute() {
    final isAuthenticated = IceStorage.instance.auth.isAuthenticated.value;

    if (!isAuthenticated) {
      return phoneAuth;
    }

    final custom = IceStorage.instance.auth.customFields.value;
    final department =
        custom['department']?.toString().toLowerCase() ?? 'service';

    if (department == 'production') {
      return kitchenOrders;
    }

    return tables;
  }

  static Map<String, WidgetBuilder> routes = {
    phoneAuth: (context) => PhoneAuthView(),
    otpVerification: (context) => OtpVerificationView(),
    accountBlocked: (context) => AccountBlockedView(),
    // Vistas principales envueltas con monitoreo de status
    tables: (context) => AccountStatusWrapper(child: TablesView()),
    newOrder: (context) => AccountStatusWrapper(child: NewOrderView()),
    orderDetails: (context) => AccountStatusWrapper(child: OrderDetailsView()),
    kitchenOrders: (context) =>
        AccountStatusWrapper(child: KitchenOrdersView()),
    kitchenOrderDetails: (context) =>
        AccountStatusWrapper(child: KitchenOrderDetailsView()),
    ordersHistory: (context) =>
        AccountStatusWrapper(child: OrdersHistoryView()),
    profile: (context) => AccountStatusWrapper(child: ProfileView()),
  };

  // Navega al home y libera el video de Aria
  static void navigateToHome(BuildContext context) {
    // Liberar el video al salir del flujo de autenticación
    context.ref.notifier(ariaVideoControllerProvider).disposeController();

    final custom = IceStorage.instance.auth.customFields.value;
    final department =
        custom['department']?.toString().toLowerCase() ?? 'service';

    final route = department == 'production' ? kitchenOrders : tables;

    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }
}

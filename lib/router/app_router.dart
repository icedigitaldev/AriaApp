import 'package:flutter/material.dart';
import 'package:ice_storage/ice_storage.dart';
import 'package:refena_flutter/refena_flutter.dart';
import '../controllers/aria_video_controller.dart';

import '../views/phone_auth_view.dart';
import '../views/otp_verification_view.dart';
import '../views/tables_view.dart';
import '../views/new_order_view.dart';
import '../views/order_details_view.dart';
import '../views/kitchen_orders_view.dart';
import '../views/kitchen_order_details_view.dart';
import '../views/kitchen_history_view.dart';

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
  static const String kitchenHistory = '/kitchen-history';

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
    phoneAuth: (context) => const PhoneAuthView(),
    otpVerification: (context) => const OtpVerificationView(),
    tables: (context) => const TablesView(),
    newOrder: (context) => const NewOrderView(),
    orderDetails: (context) => const OrderDetailsView(),
    kitchenOrders: (context) => const KitchenOrdersView(),
    kitchenOrderDetails: (context) => const KitchenOrderDetailsView(),
    kitchenHistory: (context) => const KitchenHistoryView(),
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

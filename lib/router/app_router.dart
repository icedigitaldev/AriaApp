import 'package:flutter/material.dart';
import 'package:ice_storage/ice_storage.dart';

// Vistas de autenticación
import '../views/phone_auth_view.dart';
import '../views/otp_verification_view.dart';

// Vistas del mesero
import '../views/tables_view.dart';
import '../views/new_order_view.dart';
import '../views/order_details_view.dart';

// Vistas de cocina
import '../views/kitchen_orders_view.dart';
import '../views/kitchen_order_details_view.dart';
import '../views/kitchen_history_view.dart';

class AppRouter {
  // Rutas de autenticación
  static const String phoneAuth = '/phone-auth';
  static const String otpVerification = '/otp-verification';

  // Rutas del mesero (waiter)
  static const String tables = '/tables';
  static const String newOrder = '/new-order';
  static const String orderDetails = '/order-details';

  // Rutas de cocina (kitchen)
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

    // Redirige según el departamento del usuario
    if (department == 'production') {
      return kitchenOrders;
    }

    // Por defecto, departamento service va a mesas
    return tables;
  }

  static Map<String, WidgetBuilder> routes = {
    // Rutas de autenticación
    phoneAuth: (context) => const PhoneAuthView(),
    otpVerification: (context) => const OtpVerificationView(),

    // Rutas del mesero (waiter)
    tables: (context) => const TablesView(),
    newOrder: (context) => const NewOrderView(),
    orderDetails: (context) => const OrderDetailsView(),

    // Rutas de cocina (kitchen)
    kitchenOrders: (context) => const KitchenOrdersView(),
    kitchenOrderDetails: (context) => const KitchenOrderDetailsView(),
    kitchenHistory: (context) => const KitchenHistoryView(),
  };

  // Navega a la vista principal según el rol
  static void navigateToHome(BuildContext context) {
    final custom = IceStorage.instance.auth.customFields.value;
    final department =
        custom['department']?.toString().toLowerCase() ?? 'service';

    final route = department == 'production' ? kitchenOrders : tables;

    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }
}

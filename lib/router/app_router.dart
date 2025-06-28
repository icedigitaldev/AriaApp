import 'package:flutter/material.dart';
import '../views/otp_verification_view.dart';
import '../views/phone_auth_view.dart';
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
  static const String tables = '/';
  static const String newOrder = '/new-order';
  static const String orderDetails = '/order-details';

  // Rutas de cocina
  static const String kitchenOrders = '/kitchen-orders';
  static const String kitchenOrderDetails = '/kitchen-order-details';
  static const String kitchenHistory = '/kitchen-history';

  // Cambiar esta línea para probar diferentes vistas
  static String getInitialRoute() => phoneAuth; // Cambiar a kitchenOrders para probar cocina

  static Map<String, WidgetBuilder> routes = {

    // Rutas de autenticación
    phoneAuth: (context) => const PhoneAuthView(),
    otpVerification: (context) => const OtpVerificationView(),

    // Rutas del mesero
    tables: (context) => const TablesView(),
    newOrder: (context) => const NewOrderView(),
    orderDetails: (context) => const OrderDetailsView(),

    // Rutas de cocina
    kitchenOrders: (context) => const KitchenOrdersView(),
    kitchenOrderDetails: (context) => const KitchenOrderDetailsView(),
    kitchenHistory: (context) => const KitchenHistoryView(),
  };
}
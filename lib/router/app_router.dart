import 'package:flutter/material.dart';
import '../views/tables_view.dart';
import '../views/new_order_view.dart';
import '../views/order_details_view.dart';

class AppRouter {
  static const String tables = '/';
  static const String newOrder = '/new-order';
  static const String orderDetails = '/order-details';

  static Map<String, WidgetBuilder> routes = {
    tables: (context) => const TablesView(),
    newOrder: (context) => const NewOrderView(),
    orderDetails: (context) => const OrderDetailsView(),
  };
}
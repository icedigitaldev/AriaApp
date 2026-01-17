import 'package:refena_flutter/refena_flutter.dart';

class OrdersState {
  final List<Map<String, dynamic>> orders;
  final String selectedFilter;
  final bool isLoading;
  final String? errorMessage;

  const OrdersState({
    this.orders = const [],
    this.selectedFilter = 'pending',
    this.isLoading = true,
    this.errorMessage,
  });

  // Filtra las órdenes por estado
  List<Map<String, dynamic>> get filteredOrders {
    if (selectedFilter == 'all') return orders;
    return orders.where((o) => o['status'] == selectedFilter).toList();
  }

  // Estadísticas
  int get totalOrders => orders.length;
  int get pendingCount => orders.where((o) => o['status'] == 'pending').length;
  int get preparingCount =>
      orders.where((o) => o['status'] == 'preparing').length;
  int get completedCount =>
      orders.where((o) => o['status'] == 'completed').length;

  OrdersState copyWith({
    List<Map<String, dynamic>>? orders,
    String? selectedFilter,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class OrdersStateNotifier extends Notifier<OrdersState> {
  @override
  OrdersState init() => const OrdersState();

  void setOrders(List<Map<String, dynamic>> orders) {
    state = state.copyWith(orders: orders, isLoading: false);
  }

  void setSelectedFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error, clearError: error == null);
  }

  void updateOrderStatus(String orderId, String status) {
    final updatedOrders = state.orders.map((o) {
      if (o['id'] == orderId) {
        return {...o, 'status': status};
      }
      return o;
    }).toList();
    state = state.copyWith(orders: updatedOrders);
  }
}

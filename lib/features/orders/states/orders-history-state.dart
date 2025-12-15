import 'package:refena_flutter/refena_flutter.dart';

class OrdersHistoryState {
  final List<Map<String, dynamic>> orders;
  final DateTime selectedDate;
  final bool isLoading;
  final String? errorMessage;

  OrdersHistoryState({
    this.orders = const [],
    DateTime? selectedDate,
    this.isLoading = false,
    this.errorMessage,
  }) : selectedDate = selectedDate ?? DateTime.now();

  // Estadísticas del historial cargado
  int get totalOrders => orders.length;

  double get totalAmount {
    double sum = 0;
    for (final order in orders) {
      sum += (order['totalAmount'] as num?)?.toDouble() ?? 0;
    }
    return sum;
  }

  int get totalItems {
    int count = 0;
    for (final order in orders) {
      final items = order['items'] as List?;
      count += items?.length ?? 0;
    }
    return count;
  }

  OrdersHistoryState copyWith({
    List<Map<String, dynamic>>? orders,
    DateTime? selectedDate,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OrdersHistoryState(
      orders: orders ?? this.orders,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// Notifier base para el estado del historial
class OrdersHistoryStateNotifier extends Notifier<OrdersHistoryState> {
  @override
  OrdersHistoryState init() => OrdersHistoryState(selectedDate: DateTime.now());

  void setOrders(List<Map<String, dynamic>> orders) {
    state = state.copyWith(orders: orders, isLoading: false);
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date, orders: [], isLoading: true);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error, clearError: error == null);
  }

  void reset() {
    state = state.copyWith(orders: [], isLoading: false, clearError: true);
  }
}

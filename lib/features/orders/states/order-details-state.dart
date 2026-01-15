import 'package:refena_flutter/refena_flutter.dart';

class OrderDetailsState {
  final Map<String, dynamic>? table;
  final Map<String, dynamic>? order;
  final bool isLoading;
  final String? errorMessage;

  const OrderDetailsState({
    this.table,
    this.order,
    this.isLoading = true,
    this.errorMessage,
  });

  // Verifica si hay orden activa
  bool get hasOrder => order != null;

  // Estado actual de la orden
  String get status => order?['status']?.toString() ?? 'pending';

  // Verifica si la orden está pagada
  bool get isPaid => status == 'paid';

  // Verifica si se pueden eliminar items
  bool get canDeleteItems => status == 'pending';

  // Lista de items de la orden
  List<dynamic> get items => order?['items'] as List<dynamic>? ?? [];

  // Total de la orden
  double get totalAmount => (order?['totalAmount'] as num?)?.toDouble() ?? 0.0;

  // Monto pagado
  double get paidAmount =>
      (order?['paidAmount'] as num?)?.toDouble() ?? totalAmount;

  // Método de pago
  String? get paymentMethod => order?['paymentMethod']?.toString();

  // Nombre del staff asignado
  String get staffName => order?['staffName']?.toString() ?? 'Sin asignar';

  // Número de mesa
  String get tableNumber => table?['number']?.toString() ?? '';

  // Id de la orden
  String? get orderId => order?['id']?.toString();

  // Id de la mesa
  String? get tableId => table?['id']?.toString();

  OrderDetailsState copyWith({
    Map<String, dynamic>? table,
    Map<String, dynamic>? order,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearOrder = false,
  }) {
    return OrderDetailsState(
      table: table ?? this.table,
      order: clearOrder ? null : (order ?? this.order),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class OrderDetailsStateNotifier extends Notifier<OrderDetailsState> {
  @override
  OrderDetailsState init() => const OrderDetailsState();

  void setTable(Map<String, dynamic> table) {
    state = state.copyWith(table: table);
  }

  void setOrder(Map<String, dynamic>? order) {
    state = state.copyWith(
      order: order,
      isLoading: false,
      clearOrder: order == null,
    );
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error, clearError: error == null);
  }

  void updateOrderLocally(Map<String, dynamic> updates) {
    if (state.order == null) return;
    final updatedOrder = {...state.order!, ...updates};
    state = state.copyWith(order: updatedOrder);
  }
}

import 'dart:async';
import 'package:refena_flutter/refena_flutter.dart';
import '../states/dishes_state.dart';
import '../services/dishes_service.dart';
import '../../../utils/app_logger.dart';

class DishesController extends Notifier<DishesState> {
  final DishesService _dishesService = DishesService();
  StreamSubscription? _dishesSubscription;
  bool _initialized = false;

  @override
  DishesState init() => const DishesState();

  // Inicializa y suscribe a los platos
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    state = state.copyWith(isLoading: true);

    _dishesSubscription = _dishesService.streamDishes().listen(
      (dishes) {
        // Extraer categorías únicas de los platos
        final categories = dishes
            .map((d) => d['category'] as String?)
            .where((c) => c != null && c.isNotEmpty)
            .toSet()
            .cast<String>()
            .toList();
        categories.sort();

        state = state.copyWith(
          dishes: dishes,
          categories: categories,
          isLoading: false,
        );

        AppLogger.log(
          'Platillos cargados: ${dishes.length} platos, ${categories.length} categorías',
          prefix: 'DISHES:',
        );
      },
      onError: (error) {
        state = state.copyWith(isLoading: false, error: error.toString());
        AppLogger.log(
          'Error cargando platillos: $error',
          prefix: 'DISHES_ERROR:',
        );
      },
    );
  }

  // Cambia la categoría seleccionada
  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  // Reinicializa (para cambio de usuario)
  void reinitialize() {
    _dishesSubscription?.cancel();
    _initialized = false;
    state = const DishesState();
    initialize();
  }

  @override
  void dispose() {
    _dishesSubscription?.cancel();
    super.dispose();
  }
}

// Provider global del controlador
final dishesControllerProvider =
    NotifierProvider<DishesController, DishesState>(
      (ref) => DishesController(),
    );

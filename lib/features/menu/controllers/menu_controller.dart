import 'dart:async';
import 'package:refena_flutter/refena_flutter.dart';
import '../states/menu_state.dart';
import '../services/menu_service.dart';
import '../../../utils/app_logger.dart';

class MenuController extends Notifier<MenuState> {
  final MenuService _menuService = MenuService();
  StreamSubscription? _dishesSubscription;
  bool _initialized = false;

  @override
  MenuState init() => const MenuState();

  // Inicializa y suscribe a los platos
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    state = state.copyWith(isLoading: true);

    _dishesSubscription = _menuService.streamDishes().listen(
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
          'Menú cargado: ${dishes.length} platos, ${categories.length} categorías',
          prefix: 'MENU:',
        );
      },
      onError: (error) {
        state = state.copyWith(isLoading: false, error: error.toString());
        AppLogger.log('Error cargando menú: $error', prefix: 'MENU_ERROR:');
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
    state = const MenuState();
    initialize();
  }

  @override
  void dispose() {
    _dishesSubscription?.cancel();
    super.dispose();
  }
}

// Provider global del controlador
final menuControllerProvider = NotifierProvider<MenuController, MenuState>(
  (ref) => MenuController(),
);

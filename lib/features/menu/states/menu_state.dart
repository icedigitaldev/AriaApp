/// Estado inmutable del menú
class MenuState {
  final List<Map<String, dynamic>> dishes;
  final List<String> categories;
  final String selectedCategory;
  final bool isLoading;
  final String? error;

  const MenuState({
    this.dishes = const [],
    this.categories = const [],
    this.selectedCategory = 'all',
    this.isLoading = false,
    this.error,
  });

  MenuState copyWith({
    List<Map<String, dynamic>>? dishes,
    List<String>? categories,
    String? selectedCategory,
    bool? isLoading,
    String? error,
  }) {
    return MenuState(
      dishes: dishes ?? this.dishes,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Platos filtrados por categoría seleccionada
  List<Map<String, dynamic>> get filteredDishes {
    if (selectedCategory == 'all') return dishes;
    return dishes.where((d) => d['category'] == selectedCategory).toList();
  }
}

import 'package:flutter/material.dart' hide FilterChip;
import '../../../../design/responsive/responsive_scaler.dart';
import '../ui/filter_chip.dart';

class OrderFiltersBar extends StatefulWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>>? customFilters;
  final PageController? pageController;

  const OrderFiltersBar({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.orders,
    this.customFilters,
    this.pageController,
  }) : super(key: key);

  @override
  State<OrderFiltersBar> createState() => OrderFiltersBarState();
}

class OrderFiltersBarState extends State<OrderFiltersBar> {
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> get _filters {
    if (widget.customFilters != null) return widget.customFilters!;

    return [
      {'id': 'all', 'label': 'Todos', 'count': widget.orders.length},
      {
        'id': 'pending',
        'label': 'Pendientes',
        'count': widget.orders.where((o) => o['status'] == 'pending').length,
      },
      {
        'id': 'preparing',
        'label': 'Preparando',
        'count': widget.orders.where((o) => o['status'] == 'preparing').length,
      },
      {
        'id': 'completed',
        'label': 'Listos',
        'count': widget.orders.where((o) => o['status'] == 'completed').length,
      },
    ];
  }

  @override
  void didUpdateWidget(OrderFiltersBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFilter != widget.selectedFilter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToSelectedFilter();
      });
    }
  }

  void scrollToSelectedFilter() {
    if (!_scrollController.hasClients) return;

    final selectedIndex = _filters.indexWhere(
      (filter) => filter['id'] == widget.selectedFilter,
    );

    if (selectedIndex == -1) return;

    final double chipWidth = ResponsiveScaler.width(120);
    final double targetPosition = selectedIndex * chipWidth;
    final double viewportWidth = _scrollController.position.viewportDimension;
    final double scrollPosition =
        targetPosition - (viewportWidth / 2) + (chipWidth / 2);

    _scrollController.animateTo(
      scrollPosition.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ResponsiveScaler.height(50),
      margin: ResponsiveScaler.margin(
        const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          return FilterChip(
            id: filter['id'],
            label: filter['label'],
            count: filter['count'],
            isSelected: widget.selectedFilter == filter['id'],
            onTap: () {
              widget.onFilterChanged(filter['id']);
              if (widget.pageController != null) {
                widget.pageController!.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          );
        },
      ),
    );
  }
}

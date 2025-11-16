import 'package:flutter/material.dart';
import '../../../../design/colors/app_colors.dart';
import '../../../../design/colors/status_colors.dart';
import '../../../../design/responsive/responsive_scaler.dart';
import '../ui/stat_card.dart';

class OrderStatsContainer extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final bool showPending;
  final bool showPreparing;
  final bool showAverageTime;
  final bool showTotal;
  final String? averageTime;
  final double? totalAmount;

  const OrderStatsContainer({
    Key? key,
    required this.orders,
    this.showPending = true,
    this.showPreparing = false,
    this.showAverageTime = false,
    this.showTotal = false,
    this.averageTime,
    this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = <Widget>[];
    final activeStatsCount = _getActiveStatsCount();

    // Construye las estadísticas activas
    if (showPending) {
      final pendingCount = orders.where((o) => o['status'] == 'pending').length;
      stats.add(
        Expanded(
          child: StatCard(
            icon: Icons.pending_actions,
            label: 'Pendientes',
            value: pendingCount.toString(),
            color: StatusColors.pendingText,
            backgroundColor: StatusColors.pendingBackground,
            compact: activeStatsCount > 3,
            showBackground: false,
          ),
        ),
      );
    }

    if (showPreparing) {
      final preparingCount = orders.where((o) => o['status'] == 'preparing').length;
      stats.add(
        Expanded(
          child: StatCard(
            icon: Icons.soup_kitchen,
            label: 'Preparando',
            value: preparingCount.toString(),
            color: StatusColors.preparingText,
            backgroundColor: StatusColors.preparingBackground,
            compact: activeStatsCount > 3,
            showBackground: false,
          ),
        ),
      );
    }

    if (showAverageTime) {
      stats.add(
        Expanded(
          child: StatCard(
            icon: Icons.timer_outlined,
            label: 'Tiempo promedio',
            value: averageTime ?? '12 min',
            color: AppColors.info,
            backgroundColor: AppColors.info.withOpacity(0.1),
            compact: activeStatsCount > 3,
            showBackground: false,
          ),
        ),
      );
    }

    if (showTotal && totalAmount != null) {
      stats.add(
        Expanded(
          child: StatCard(
            icon: Icons.payments_outlined,
            label: 'Total del día',
            value: '\$${totalAmount!.toStringAsFixed(2)}',
            color: AppColors.success,
            backgroundColor: AppColors.success.withOpacity(0.1),
            compact: activeStatsCount > 3,
            showBackground: false,
          ),
        ),
      );
    }

    if (stats.isEmpty) return const SizedBox.shrink();

    // Agrega separadores entre estadísticas
    final statsWithDividers = <Widget>[];
    for (int i = 0; i < stats.length; i++) {
      statsWithDividers.add(stats[i]);
      if (i < stats.length - 1) {
        statsWithDividers.add(_buildDivider());
      }
    }

    return Container(
      margin: ResponsiveSize.margin(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
      ),
      padding: ResponsiveSize.padding(
        EdgeInsets.symmetric(
          horizontal: 16,
          vertical: activeStatsCount > 3 ? 12 : 16,
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(ResponsiveSize.radius(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPurple,
            blurRadius: 12,
            offset: Offset(0, ResponsiveSize.height(4)),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: statsWithDividers,
        ),
      ),
    );
  }

  // Cuenta las estadísticas activas
  int _getActiveStatsCount() {
    int count = 0;
    if (showPending) count++;
    if (showPreparing) count++;
    if (showAverageTime) count++;
    if (showTotal && totalAmount != null) count++;
    return count;
  }

  // Construye el divider vertical
  Widget _buildDivider() {
    return Container(
      margin: ResponsiveSize.margin(
          const EdgeInsets.symmetric(horizontal: 12)
      ),
      width: 1,
      color: AppColors.textMuted.withOpacity(0.2),
    );
  }
}
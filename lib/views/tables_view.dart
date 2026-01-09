import 'package:flutter/material.dart';
import 'package:refena_flutter/refena_flutter.dart';
import '../components/composite/transparent_app_bar.dart';
import '../components/ui/app_loader.dart';
import '../design/colors/app_colors.dart';
import '../design/responsive/responsive_scaler.dart';
import '../features/tables/components/composite/restaurant_header.dart';
import '../features/tables/components/composite/floor_selector.dart';
import '../features/tables/components/composite/tables_grid.dart';
import '../features/tables/controllers/tables_controller.dart';
import '../auth/current_user.dart';
import '../utils/app_logger.dart';

class TablesView extends StatefulWidget {
  TablesView({Key? key}) : super(key: key);

  @override
  State<TablesView> createState() => _TablesViewState();
}

class _TablesViewState extends State<TablesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.notifier(tablesControllerProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref) {
        final tablesState = ref.watch(tablesControllerProvider);
        final tablesController = ref.notifier(tablesControllerProvider);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: TransparentAppBar(
            backgroundColor: AppColors.appBarBackground,
          ),
          body: Container(
            decoration: BoxDecoration(color: AppColors.background),
            child: SafeArea(
              child: Column(
                children: [
                  RestaurantHeader(
                    onProfileTap: () {
                      // Navegar al perfil o cerrar sesión
                      AppLogger.log('Perfil presionado', prefix: 'MESAS:');
                    },
                    avatarUrl:
                        (CurrentUserAuth.instance.imageUrl != null &&
                            CurrentUserAuth.instance.imageUrl!.isNotEmpty)
                        ? CurrentUserAuth.instance.imageUrl
                        : CurrentUserAuth.instance.avatarUrl,
                    onHistoryTap: () {
                      AppLogger.log('Historial de mesas', prefix: 'MESAS:');
                      Navigator.pushNamed(context, '/orders-history');
                    },
                  ),
                  FloorSelector(
                    selectedFloor: tablesState.selectedFloor,
                    availableFloors: tablesState.availableFloors,
                    onFloorChanged: (floor) {
                      tablesController.selectFloor(floor);
                    },
                  ),
                  Expanded(
                    child: tablesState.isLoading
                        ? Center(
                            child: AppLoader(size: ResponsiveScaler.width(40)),
                          )
                        : TablesGrid(
                            tables: tablesState.filteredTables,
                            selectedFloor: tablesState.selectedFloor ?? '',
                            onTableTap: (table) {
                              final status =
                                  table['status']?.toString() ?? 'available';
                              // Si la mesa está ocupada, ir a ver la orden existente
                              if (status == 'occupied') {
                                Navigator.pushNamed(
                                  context,
                                  '/order-details',
                                  arguments: table,
                                );
                              } else {
                                // Mesa disponible, crear nueva orden
                                Navigator.pushNamed(
                                  context,
                                  '/new-order',
                                  arguments: table,
                                );
                              }
                            },
                            onStatusChange: (tableId, newStatus) {
                              tablesController.changeStatus(tableId, newStatus);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:refena_flutter/refena_flutter.dart';
import '../components/ui/status_app_bar.dart';
import '../components/ui/app_header.dart';
import '../components/ui/app_loader.dart';
import '../components/ui/cached_network_image.dart';
import '../design/colors/app_colors.dart';
import '../design/colors/app_gradients.dart';
import '../design/responsive/responsive_scaler.dart';
import '../features/tables/components/composite/floor_selector.dart';
import '../features/tables/components/composite/tables_grid.dart';
import '../features/tables/controllers/tables_controller.dart';
import '../auth/current_user.dart';

class TablesView extends StatefulWidget {
  const TablesView({Key? key}) : super(key: key);

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

        // Muestra loader mientras carga los datos iniciales
        if (tablesState.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: AppLoader(size: ResponsiveScaler.width(40))),
          );
        }

        // Lógica de selección de imagen
        final String? imageUrl = CurrentUserAuth.instance.imageUrl;
        final String? avatarUrl = CurrentUserAuth.instance.avatarUrl;
        final String? displayImage = (imageUrl != null && imageUrl.isNotEmpty)
            ? imageUrl
            : (avatarUrl != null && avatarUrl.isNotEmpty ? avatarUrl : null);
        final borderRadius = BorderRadius.circular(ResponsiveScaler.radius(16));

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: StatusAppBar(backgroundColor: AppColors.appBarBackground),
          body: Container(
            decoration: BoxDecoration(color: AppColors.background),
            child: SafeArea(
              child: Column(
                children: [
                  AppHeader(
                    title: 'ARIA',
                    subtitle: 'Gestión de mesas',
                    showBackButton: false,
                    leadingIcon: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                      child: Container(
                        width: ResponsiveScaler.width(48),
                        height: ResponsiveScaler.height(48),
                        decoration: BoxDecoration(
                          gradient: (displayImage == null)
                              ? AppGradients.primaryButton
                              : null,
                          color: (displayImage != null) ? AppColors.card : null,
                          borderRadius: borderRadius,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowPurple,
                              blurRadius: 12,
                              offset: Offset(0, ResponsiveScaler.height(4)),
                            ),
                          ],
                        ),
                        child: (displayImage != null)
                            ? CachedNetworkImage(
                                imageUrl: displayImage,
                                width: ResponsiveScaler.width(48),
                                height: ResponsiveScaler.height(48),
                                borderRadius: borderRadius,
                                placeholder: Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                errorWidget: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveScaler.radius(12),
                                  ),
                                  child: Image.asset(
                                    'assets/images/aria-logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveScaler.radius(12),
                                ),
                                child: Image.asset(
                                  'assets/images/aria-logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/orders-history');
                        },
                        icon: Container(
                          padding: ResponsiveScaler.padding(EdgeInsets.all(8)),
                          decoration: BoxDecoration(
                            color: AppColors.card.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(
                              ResponsiveScaler.radius(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 10,
                                offset: Offset(0, ResponsiveScaler.height(4)),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.history,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  FloorSelector(
                    selectedFloor: tablesState.selectedFloor,
                    availableFloors: tablesState.availableFloors,
                    onFloorChanged: (floor) {
                      tablesController.selectFloor(floor);
                    },
                  ),
                  Expanded(
                    child: TablesGrid(
                      tables: tablesState.filteredTables,
                      selectedFloor: tablesState.selectedFloor ?? '',
                      onTableTap: (table) {
                        final status =
                            table['status']?.toString() ?? 'available';
                        if (status == 'occupied') {
                          Navigator.pushNamed(
                            context,
                            '/order-details',
                            arguments: table,
                          );
                        } else {
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

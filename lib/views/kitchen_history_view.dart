import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/composite/transparent_app_bar.dart';
import '../design/colors/app_colors.dart';
import '../design/colors/app_gradients.dart';
import '../design/responsive/responsive_scaler.dart';
import '../design/themes/app_themes.dart';
import '../features/orders/components/composite/order_header.dart';
import '../features/orders/components/composite/date_selector.dart';
import '../features/orders/components/ui/info_chip.dart';

class KitchenHistoryView extends StatefulWidget {
  const KitchenHistoryView({Key? key}) : super(key: key);

  @override
  State<KitchenHistoryView> createState() => _KitchenHistoryViewState();
}

class _KitchenHistoryViewState extends State<KitchenHistoryView> {
  DateTime selectedDate = DateTime.now();

  final List<Map<String, dynamic>> completedOrders = [
    {
      'id': 101,
      'tableNumber': 3,
      'waiter': 'Carlos M.',
      'completedTime': '10:15 AM',
      'preparationTime': '12 min',
      'items': 3,
      'total': 45.50,
    },
    {
      'id': 102,
      'tableNumber': 1,
      'waiter': 'Ana G.',
      'completedTime': '10:25 AM',
      'preparationTime': '8 min',
      'items': 2,
      'total': 32.00,
    },
    {
      'id': 103,
      'tableNumber': 5,
      'waiter': 'Juan P.',
      'completedTime': '10:30 AM',
      'preparationTime': '15 min',
      'items': 4,
      'total': 67.80,
    },
    {
      'id': 104,
      'tableNumber': 2,
      'waiter': 'María L.',
      'completedTime': '10:42 AM',
      'preparationTime': '10 min',
      'items': 2,
      'total': 28.90,
    },
  ];

  @override
  Widget build(BuildContext context) {
    AppThemes.init(context);
    ResponsiveSize.init(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TransparentAppBar(
        backgroundColor: AppColors.appBarBackground,
      ),
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              // Header con componente compartido
              OrderHeader(
                title: 'Historial de Órdenes',
                subtitle: 'Órdenes completadas',
                onBack: () => Navigator.pop(context),
              ),

              // Selector de fecha con componente separado
              Container(
                margin: ResponsiveSize.margin(
                    const EdgeInsets.symmetric(horizontal: 20)
                ),
                child: DateSelector(
                  selectedDate: selectedDate,
                  onDateChanged: (date) => setState(() => selectedDate = date),
                ),
              ),

              // Lista de órdenes
              Expanded(
                child: _buildOrdersList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: ResponsiveSize.padding(
        const EdgeInsets.fromLTRB(20, 20, 20, 20),
      ),
      itemCount: completedOrders.length,
      itemBuilder: (context, index) => _buildOrderCard(completedOrders[index]),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: ResponsiveSize.margin(const EdgeInsets.only(bottom: 16)),
      padding: ResponsiveSize.padding(const EdgeInsets.all(16)),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(ResponsiveSize.radius(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, ResponsiveSize.height(4)),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveSize.width(60),
            height: ResponsiveSize.height(60),
            decoration: BoxDecoration(
              gradient: AppGradients.success,
              borderRadius: BorderRadius.circular(ResponsiveSize.radius(16)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.textOnPrimary,
                  size: ResponsiveSize.icon(24),
                ),
                Text(
                  order['completedTime'],
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveSize.font(10),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textOnPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: ResponsiveSize.width(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Orden #${order['id']}',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveSize.font(16),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '\$${order['total'].toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveSize.font(16),
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveSize.height(4)),
                Row(
                  children: [
                    Icon(
                      Icons.table_bar,
                      size: ResponsiveSize.icon(14),
                      color: AppColors.iconMuted,
                    ),
                    SizedBox(width: ResponsiveSize.width(4)),
                    Text(
                      'Mesa ${order['tableNumber']}',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveSize.font(14),
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(width: ResponsiveSize.width(12)),
                    Icon(
                      Icons.person,
                      size: ResponsiveSize.icon(14),
                      color: AppColors.iconMuted,
                    ),
                    SizedBox(width: ResponsiveSize.width(4)),
                    Text(
                      order['waiter'],
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveSize.font(14),
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveSize.height(8)),
                Row(
                  children: [
                    InfoChip(
                      icon: Icons.timer,
                      text: order['preparationTime'],
                      color: AppColors.info,
                    ),
                    SizedBox(width: ResponsiveSize.width(8)),
                    InfoChip(
                      text: '${order['items']} items',
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
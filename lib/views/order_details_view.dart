import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/composite/transparent_app_bar.dart';
import '../design/colors/app_colors.dart';
import '../design/colors/app_gradients.dart';
import '../design/responsive/responsive_scaler.dart';
import '../design/themes/app_themes.dart';

class OrderDetailsView extends StatefulWidget {
  const OrderDetailsView({Key? key}) : super(key: key);

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  @override
  Widget build(BuildContext context) {
    AppThemes.init(context);
    ResponsiveSize.init(context);
    final table = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TransparentAppBar(
        backgroundColor: AppColors.appBarBackground,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(table),
              Expanded(
                child: Center(
                  child: Text(
                    'Detalles de la orden\nMesa ${table?['number'] ?? ''}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveSize.font(24),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic>? table) {
    return Container(
      padding: ResponsiveSize.padding(const EdgeInsets.all(20)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: ResponsiveSize.padding(const EdgeInsets.all(8)),
              decoration: BoxDecoration(
                color: AppColors.card.withOpacity(0.9),
                borderRadius: BorderRadius.circular(ResponsiveSize.radius(12)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: Offset(0, ResponsiveSize.height(4)),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
          ),
          SizedBox(width: ResponsiveSize.width(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mesa ${table?['number'] ?? ''}',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveSize.font(28),
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = AppGradients.headerText
                          .createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                  ),
                ),
                Text(
                  'Total: \$${table?['orderTotal']?.toStringAsFixed(2) ?? '0.00'}',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveSize.font(14),
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
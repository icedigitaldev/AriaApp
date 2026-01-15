import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../design/colors/app_colors.dart';
import '../../design/colors/app_gradients.dart';
import '../../design/responsive/responsive_scaler.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? titleSuffix;
  final Widget? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool showBackButton;
  final Color? backgroundColor;

  const AppHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.titleSuffix,
    this.leadingIcon,
    this.actions,
    this.onBack,
    this.showBackButton = true,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.transparent,
      padding: ResponsiveScaler.padding(
        // Padding horizontal estándar, vertical reducido para alineación compacta
        const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 8),
      ),
      child: Row(
        children: [
          // Botón de regreso o ícono personalizado
          if (showBackButton && onBack != null)
            IconButton(
              onPressed: onBack,
              icon: Container(
                padding: ResponsiveScaler.padding(const EdgeInsets.all(8)),
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
                child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),
            )
          else if (leadingIcon != null)
            leadingIcon!,

          // Separación entre leading y contenido
          if (showBackButton || leadingIcon != null)
            SizedBox(width: ResponsiveScaler.width(12)),

          // Título y subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveScaler.font(24),
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = AppGradients.headerText.createShader(
                            const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                          ),
                      ),
                    ),
                    if (titleSuffix != null) ...[
                      SizedBox(width: ResponsiveScaler.width(10)),
                      titleSuffix!,
                    ],
                  ],
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveScaler.font(14),
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),

          // Acciones (botones, badges, etc.)
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

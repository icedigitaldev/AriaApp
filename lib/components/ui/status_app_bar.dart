import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design/colors/app_colors.dart';
import '../../design/responsive/responsive_scaler.dart';
import '../../design/themes/app_themes.dart';

class StatusAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color? backgroundColor;
  final Brightness? statusBarIconBrightness;
  final Brightness? statusBarBrightness;
  final VoidCallback? onBack;
  final bool showBackButton;

  const StatusAppBar({
    Key? key,
    this.backgroundColor,
    this.statusBarIconBrightness,
    this.statusBarBrightness,
    this.onBack,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      Size.fromHeight(showBackButton ? ResponsiveScaler.height(56) : 0);

  @override
  Widget build(BuildContext context) {
    AppThemes.init(context);

    final iconBrightness =
        statusBarIconBrightness ??
        (AppThemes.isDarkMode ? Brightness.light : Brightness.dark);

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor ?? Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: showBackButton
          ? SafeArea(
              child: Padding(
                padding: ResponsiveScaler.padding(
                  const EdgeInsets.only(left: 16, top: 8),
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: AppColors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        ResponsiveScaler.radius(14),
                      ),
                      onTap: onBack ?? () => Navigator.pop(context),
                      child: Container(
                        padding: ResponsiveScaler.padding(
                          const EdgeInsets.all(10),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(
                            ResponsiveScaler.radius(14),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 12,
                              offset: Offset(0, ResponsiveScaler.height(4)),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                          size: ResponsiveScaler.icon(22),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: iconBrightness,
        statusBarBrightness:
            statusBarBrightness ??
            (iconBrightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark),
      ),
    );
  }
}

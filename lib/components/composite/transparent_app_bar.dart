import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design/themes/app_themes.dart';

class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color? backgroundColor;
  final Brightness? statusBarIconBrightness;
  final Brightness? statusBarBrightness;

  const TransparentAppBar({
    Key? key,
    this.backgroundColor,
    this.statusBarIconBrightness,
    this.statusBarBrightness,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(0);

  @override
  Widget build(BuildContext context) {
    AppThemes.init(context);

    final iconBrightness = statusBarIconBrightness ??
        (AppThemes.isDarkMode ? Brightness.light : Brightness.dark);

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor ?? Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: iconBrightness,
        statusBarBrightness: statusBarBrightness ??
            (iconBrightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark),
      ),
    );
  }
}
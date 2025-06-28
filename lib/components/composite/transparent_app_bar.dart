import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color? backgroundColor;
  final Brightness statusBarIconBrightness;
  final Brightness? statusBarBrightness;

  const TransparentAppBar({
    Key? key,
    this.backgroundColor,
    this.statusBarIconBrightness = Brightness.dark,
    this.statusBarBrightness,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: backgroundColor ?? Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: statusBarIconBrightness,
        statusBarBrightness: statusBarBrightness ??
            (statusBarIconBrightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark),
      ),
    );
  }
}
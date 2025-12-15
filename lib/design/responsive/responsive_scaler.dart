import 'package:flutter/material.dart';
import '../../utils/app_logger.dart';

class ResponsiveScaler {
  static double _heightFactor = 1.0;
  static const double _refHeight = 914.0;
  static const double _tolerance = 1.5;
  static bool _initialized = false;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.height == 0) return;

    if (_initialized) return;

    final isTablet = size.shortestSide >= 600;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    _heightFactor = _calculateFactor(size.height, isTablet, isIOS);
    _initialized = true;

    AppLogger.log(
      'H: ${size.height.toStringAsFixed(1)} F: $_heightFactor T: $isTablet',
      prefix: 'RESP:',
    );
  }

  static double _calculateFactor(double h, bool isTablet, bool isIOS) {
    // Pantalla de referencia
    if ((h - _refHeight).abs() <= _tolerance) return 1.0;

    // Tablets (iOS y Android)
    if (isTablet) {
      if (h >= 1366) return 1.45;
      if (h >= 1194) return 1.40;
      if (h >= 1024) return 1.35;
      return 1.30;
    }

    // Phones iOS
    if (isIOS) {
      if (h >= 932) return 0.95;
      if (h >= 844) return 0.92;
      if (h >= 812) return 0.88;
      return 0.85;
    }

    // Phones Android
    if (h > _refHeight + _tolerance) return 1.02;
    if (h >= 843) return 0.90;
    if (h >= 817) return 0.88;
    if (h >= 780) return 0.86;
    if (h >= 731) return 0.84;
    return 0.80;
  }

  // Escalado base
  static double height(double v) => v * _heightFactor;
  static double width(double v) => v * _heightFactor;

  // Espaciado
  static EdgeInsets _scale(EdgeInsets e) => EdgeInsets.only(
    left: e.left * _heightFactor,
    top: e.top * _heightFactor,
    right: e.right * _heightFactor,
    bottom: e.bottom * _heightFactor,
  );
  static EdgeInsets padding(EdgeInsets p) => _scale(p);
  static EdgeInsets margin(EdgeInsets m) => _scale(m);

  // Otros
  static Size size(Size s) =>
      Size(s.width * _heightFactor, s.height * _heightFactor);
  static double radius(double r) => r * _heightFactor;
  static double icon(double s) => s * _heightFactor;
  static double font(double s) =>
      s * (_heightFactor < 0.92 ? _heightFactor + 0.05 : _heightFactor);
}

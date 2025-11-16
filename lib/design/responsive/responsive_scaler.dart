import 'package:flutter/material.dart';
import '../../utils/app_logger.dart';

class ResponsiveSize {
  static late double _heightFactor;
  static const double _referenceHeight = 914.0;
  static const double _tolerance = 1.5;

  static void init(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    // Rango de pantalla de referencia
    final double minRef = _referenceHeight - _tolerance;
    final double maxRef = _referenceHeight + _tolerance;

    // Sin escala para pantallas de referencia
    if (screenSize.height >= minRef && screenSize.height <= maxRef) {
      _heightFactor = 1.0;
      AppLogger.log('Ref H: ${screenSize.height.toStringAsFixed(2)}', prefix: 'RESP:');
      return;
    }

    if (isIOS) {
      _initForIOS(screenSize);
    } else {
      _initForAndroid(screenSize);
    }

    AppLogger.log('H: ${screenSize.height.toStringAsFixed(2)} F: $_heightFactor', prefix: 'RESP:');
  }

  static void _initForIOS(Size screenSize) {
    if (screenSize.height >= 932.0) {
      _heightFactor = 0.95;
    } else if (screenSize.height >= 844.0 && screenSize.height < 932.0) {
      _heightFactor = 0.92;
    } else if (screenSize.height >= 812.0 && screenSize.height < 844.0) {
      _heightFactor = 0.88;
    }
  }

  static void _initForAndroid(Size screenSize) {
    // Pantallas más grandes que referencia
    if (screenSize.height > (_referenceHeight + _tolerance)) {
      _heightFactor = 1.02;
    } else if (screenSize.height >= 843.43) {
      _heightFactor = 0.88;
    } else if (screenSize.height >= 817.07) {
      _heightFactor = 0.84;
    } else if (screenSize.height >= 780) {
      _heightFactor = 0.82;
    } else if (screenSize.height >= 731.43) {
      _heightFactor = 0.80;
    } else {
      _heightFactor = 0.80;
    }
  }

  static double height(double value) {
    return value * _heightFactor;
  }

  static double width(double value) {
    return value * _heightFactor;
  }

  static EdgeInsets padding(EdgeInsets padding) {
    return EdgeInsets.only(
      left: width(padding.left),
      top: height(padding.top),
      right: width(padding.right),
      bottom: height(padding.bottom),
    );
  }

  static EdgeInsets margin(EdgeInsets margin) {
    return EdgeInsets.only(
      left: width(margin.left),
      top: height(margin.top),
      right: width(margin.right),
      bottom: height(margin.bottom),
    );
  }

  static Size size(Size size) {
    return Size(width(size.width), height(size.height));
  }

  static double radius(double radius) {
    return height(radius);
  }

  static double font(double fontSize) {
    // Ajuste especial para fuentes
    double factor = _heightFactor == 0.9 ? 0.95 : _heightFactor;
    return fontSize * factor;
  }

  static double icon(double size) {
    return height(size);
  }
}
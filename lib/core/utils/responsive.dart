import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Responsive {
  Responsive._();
  static const double designWidth = 393.0;
  static const double minScaleFactor = 0.85;
  static const double maxScaleFactor = 1.30;
  static double get scaleFactor {
    final context = Get.context;
    if (context == null) return 1.0;
    try {
      final media = MediaQuery.maybeOf(context);
      if (media == null) return 1.0;
      return (media.size.shortestSide / designWidth).clamp(
        minScaleFactor,
        maxScaleFactor,
      );
    } catch (_) {
      return 1.0;
    }
  }

  static double get textScaleFactor {
    final context = Get.context;
    if (context == null) return 1.0;
    try {
      final media = MediaQuery.maybeOf(context);
      if (media == null) return 1.0;
      return media.textScaler.scale(1.0);
    } catch (_) {
      return 1.0;
    }
  }

  static double scale(double value) {
    return value * scaleFactor;
  }

  static double scaleFont(double value) {
    return value * scaleFactor * textScaleFactor;
  }
}

extension ResponsiveNum on num {
  double get width => Responsive.scale(toDouble());

  double get height => Responsive.scale(toDouble());

  double get fontSize => Responsive.scaleFont(toDouble());

  double get radius => Responsive.scale(toDouble());
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  double get shortestSide => MediaQuery.sizeOf(this).shortestSide;
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  double w(double value) =>
      value *
      (shortestSide / Responsive.designWidth).clamp(
        Responsive.minScaleFactor,
        Responsive.maxScaleFactor,
      );
  double h(double value) =>
      value *
      (shortestSide / Responsive.designWidth).clamp(
        Responsive.minScaleFactor,
        Responsive.maxScaleFactor,
      );
  double sp(double value) =>
      value *
      (shortestSide / Responsive.designWidth).clamp(
        Responsive.minScaleFactor,
        Responsive.maxScaleFactor,
      ) *
      MediaQuery.textScalerOf(this).scale(1.0);
  double r(double value) =>
      value *
      (shortestSide / Responsive.designWidth).clamp(
        Responsive.minScaleFactor,
        Responsive.maxScaleFactor,
      );
}

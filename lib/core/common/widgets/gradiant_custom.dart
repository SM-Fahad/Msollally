// ignore_for_file: deprecated_member_use

import 'package:msollaally/core/utils/responsive.dart';
import 'dart:ui';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter/material.dart';
Widget gradientBackground(Widget? child) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SizedBox(
      height: 852.height,
      width: 393.width,
      child: Stack(
        children: [
          Positioned(
            top: -150.height,
            left: 36.width,
            child: buildGlow(
              321.height,
              321.width,
              AppColors.primaryButtonColor,
              120.width,
              120.height,
            ),
          ),

          // Red glow on right, further down
          Positioned(
            bottom: -120.height,
            right: -90.width,
            child: buildGlow(
              350.height,
              350.width,
              AppColors.uiDangerColor,
              140.width,
              140.height,
            ),
          ),

          // Purple glow on left, further down
          Positioned(
            bottom: -150.height,
            left: -90.width,
            child: buildGlow(
              350.height,
              350.width,
              AppColors.mediumPurple8757F3,
              130.width,
              130.height,
            ),
          ),

          if (child != null) child,
        ],
      ),
    ),
  );
}

Widget buildGlow(double h, double w, Color color, double sx, double sy) {
  return ImageFiltered(
    imageFilter: ImageFilter.blur(sigmaX: sx, sigmaY: sy),
    child: Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.5),
            Colors.transparent,
          ],
        ),
      ),
    ),
  );
}

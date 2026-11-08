import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';

TextStyle getTextStyle({
  double fontSize = 14.0,
  FontWeight fontWeight = FontWeight.w400,
  double? height,
  double? letterSpacing,
  Color color = Colors.black,
}) {
  return TextStyle(
    fontFamily: 'Inter',
    fontSize: fontSize.fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    letterSpacing: letterSpacing?.fontSize,
  );
}

TextStyle appTextStyleHeading1({
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.w500,
  Color color = AppColors.black1F1F1F,
  double letterSpacing = -0.5,
}) {
  return TextStyle(
    fontFamily: 'Inter',
    fontSize: fontSize.fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing.fontSize,
  );
}

TextStyle appTextStyleHeading2({
  double fontSize = 14.0,
  FontWeight fontWeight = FontWeight.w400,
  Color color = AppColors.darkSlateGrayAlpha803F3F3F,
  double letterSpacing = -0.5,
}) {
  return TextStyle(
    fontFamily: 'Inter',
    fontSize: fontSize.fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing.fontSize,
  );
}

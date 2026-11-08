import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';

// Shared input decoration used across the app to keep textfields consistent.
InputDecoration standardInputDecoration({
  String? hintText,
  Widget? suffixIcon,
  double borderRadius = 15.0,
}) {
  const enabledColor = AppColors.darkGray9DA4AE;
  const focusedColor = AppColors.primaryButtonColor;
  const fillColor = AppColors.ghostWhiteF9FAFB;

  final enabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(borderRadius),
    borderSide: const BorderSide(color: enabledColor, width: 1),
  );

  final focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(borderRadius),
    borderSide: const BorderSide(color: focusedColor, width: 2),
  );

  return InputDecoration(
    hintText: hintText,
    hintStyle: getTextStyle(
      color: AppColors.secondaryTextColor,
      fontSize: 14
    ),
    filled: true,
    fillColor: fillColor,
    enabledBorder: enabledBorder,
    border: enabledBorder,
    focusedBorder: focusedBorder,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    suffixIcon: suffixIcon,
  );
}

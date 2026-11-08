import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Color? color;
  final double vertical;
  final Color? textColor;
  final double? icon;

  // NEW OPTIONAL PARAMS
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.leading,
    this.icon,
    this.vertical = 12.0,
    this.color = AppColors.primaryButtonColor,
    this.textColor = Colors.white,

    // NEW OPTIONAL PARAMS
    this.fontSize,
    this.fontWeight,
    this.height,
    this.width,
    this.padding,
    this.radius,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    bool isEnabled = onPressed != null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: fullWidth ? (width ?? double.infinity) : width,
        height: height,
        padding:
            padding ??
            EdgeInsets.symmetric(horizontal: 20.width, vertical: vertical.height),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: isEnabled
              ? (color ?? AppColors.primaryButtonColor)
              : (color ?? AppColors.primaryButtonColor).withValues(alpha: .5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 8.radius),
          ),
          shadows: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.blackAlpha0C000000,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, SizedBox(width: 8.width)],
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: fontSize ?? 16.fontSize,
                  fontWeight: fontWeight ?? FontWeight.w600,
                  height: 1.71,
                  letterSpacing: 0.20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomLogoWithTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final double vertical;
  final Color textColor;
  const CustomLogoWithTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.vertical = 12.0,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: vertical),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.textfieldBorderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 12.w),
            Text(
              text,
              style: getTextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.71,
                letterSpacing: 0.20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

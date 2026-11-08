import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class CustomTextFieldButtonStudentAiChat extends StatelessWidget {
  final String hintText;
  final Widget prefix;
  final Widget suffix;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final VoidCallback? onTap;
  final Function(String)? onSubmitted;
  final Gradient? gradient;
  final Color? hintextColor;
  final int? minLines;
  final int? maxLines;

  const CustomTextFieldButtonStudentAiChat({
    super.key,
    required this.hintText,
    required this.controller,
    required this.prefix,
    required this.suffix,
    this.keyboardType = TextInputType.multiline,
    this.onTap,
    this.onSubmitted,
    this.gradient,
    this.hintextColor,
    this.minLines = 1,
    this.maxLines = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.radius),
        gradient:
            gradient ??
            LinearGradient(
              colors: [
                AppColors.violetC686FF,
                AppColors.pinkF5B9EA,
                AppColors.lightSalmonFFBA71,
                AppColors.mediumPurpleAA6EEE,
                AppColors.salmonFF6778,
                AppColors.orchidBC82F3,
                AppColors.cornflowerBlue8D99FF,
              ],
            ),
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: EdgeInsets.symmetric(
          horizontal: 10.width,
          vertical: 4.height,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.radius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: 8.height,
                right: 6.width,
                left: 2.width,
              ),
              child: prefix,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: minLines,
                maxLines: maxLines,
                keyboardType: keyboardType,
                textCapitalization: TextCapitalization.sentences,
                onTap: onTap,
                onSubmitted: onSubmitted,
                style: appTextStyleHeading2(
                  letterSpacing: 0.fontSize,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  hintText: hintText,
                  hintStyle: appTextStyleHeading2(
                    letterSpacing: 0.fontSize,
                    color: hintextColor ?? AppColors.darkSlateGrayAlpha803F3F3F,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10.height,
                    horizontal: 4.width,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: 8.height,
                left: 6.width,
                right: 2.width,
              ),
              child: suffix,
            ),
          ],
        ),
      ),
    );
  }
}

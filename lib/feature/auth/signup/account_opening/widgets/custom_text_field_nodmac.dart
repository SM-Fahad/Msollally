import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/standard_text_field.dart';

class CustomTextFieldNodMac extends StatelessWidget {
  const CustomTextFieldNodMac({
    super.key,
    required this.controller,
    required this.lebelName,
    required this.hinText,
    this.obscureText = false,
    this.suffixIcon,
    this.textFieldHeight,
    this.textFieldColor,
    this.hintColor,
  });

  final TextEditingController controller;
  final String lebelName;
  final String hinText;
  final bool obscureText;
  final Widget? suffixIcon;
  final double? textFieldHeight;
  final Color? textFieldColor;
  final Color? hintColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lebelName,
          style: getTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),

        SizedBox(height: 8.h),

        SizedBox(
          height: textFieldHeight ?? 56.h,
          width: double.infinity,
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: getTextStyle(fontSize: 14),
            decoration:
                standardInputDecoration(
                  hintText: hinText,
                  suffixIcon: suffixIcon,
                  borderRadius: 12.0,
                ).copyWith(
                  hintStyle: TextStyle(
                    color: hintColor ?? AppColors.darkGray9E9E9E,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: textFieldColor,
                ),
          ),
        ),
      ],
    );
  }
}

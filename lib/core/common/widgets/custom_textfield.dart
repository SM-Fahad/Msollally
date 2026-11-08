import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/standard_text_field.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isObscure;
  final Widget? suffixIcon;
  final int maxLines;
  final double? width;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isObscure = false,
    this.suffixIcon,
    this.maxLines = 1,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: TextField(
        maxLines: maxLines,
        controller: controller,
        obscureText: isObscure,
        style: getTextStyle(
          fontSize: 12.fontSize,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        decoration: standardInputDecoration(
          hintText: hintText,
          borderRadius: 12.0,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

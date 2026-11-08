import 'package:flutter/material.dart';
import 'package:msollaally/core/common/widgets/standard_text_field.dart';

class TeacherCustomTextField extends StatelessWidget {
  const TeacherCustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: standardInputDecoration(
        hintText: hintText,
        borderRadius: 12.0,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';

OutlineInputBorder gigFormBorder(Color color) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(12.radius),
  borderSide: BorderSide(color: color),
);

InputDecoration gigFieldDecoration(String hint, {Widget? suffix}) =>
    InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix,
      border: gigFormBorder(Colors.grey.shade300),
      enabledBorder: gigFormBorder(Colors.grey.shade300),
      focusedBorder: gigFormBorder(Colors.blue),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.width, vertical: 14.height),
    );

InputDecoration gigDropdownDecoration() => InputDecoration(
  filled: true,
  fillColor: Colors.white,
  border: gigFormBorder(Colors.grey.shade300),
  enabledBorder: gigFormBorder(Colors.grey.shade300),
  focusedBorder: gigFormBorder(Colors.blue),
  contentPadding: EdgeInsets.symmetric(horizontal: 14.width, vertical: 14.height),
);

Widget gigFieldLabel(String text) => Padding(
  padding: EdgeInsets.only(bottom: 8.height),
  child: Text(
    text,
    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.fontSize),
  ),
);

Widget gigFormSection(List<Widget> children) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ...children,
    SizedBox(height: 20.height),
  ],
);

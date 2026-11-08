import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

Widget buildFullWidthButton(
  String title,
  String subtitle,
  String buttonText, {
  required VoidCallback onTap,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: getTextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: getTextStyle(color: Colors.black54)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 40),
          ),
          child: Text(buttonText),
        ),
      ],
    ),
  );
}

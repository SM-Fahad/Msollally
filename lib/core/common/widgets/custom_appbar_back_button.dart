import 'package:flutter/material.dart';

class CustomAppbarBackButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? textColor;
  final double? fontSize;

  const CustomAppbarBackButton({
    super.key,
    required this.text,
    this.onPressed,
    this.iconColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed ?? () => Navigator.pop(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, color: iconColor ?? Colors.black),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.black,
                fontSize: fontSize ?? 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

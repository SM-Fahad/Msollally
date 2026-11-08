import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';

class CreateJobPickerField extends StatelessWidget {
  final String text;
  final String placeholder;
  final VoidCallback onTap;
  final IconData icon;

  const CreateJobPickerField({
    super.key,
    required this.text,
    required this.placeholder,
    required this.onTap,
    this.icon = Icons.keyboard_arrow_down,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = text.trim().isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.textfieldBorderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? text : placeholder,
                style: TextStyle(
                  color: hasValue
                      ? AppColors.primaryTextColor
                      : AppColors.tertiaryTextColor,
                ),
              ),
            ),
            Icon(icon),
          ],
        ),
      ),
    );
  }
}

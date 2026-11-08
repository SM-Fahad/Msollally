import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class ExportButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const ExportButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 174.5,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.buttonColorOnboarding,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.file_download, // Flutter export-style icon
              size: 18,
              color: Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

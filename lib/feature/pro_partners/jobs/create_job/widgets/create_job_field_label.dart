import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';

class CreateJobFieldLabel extends StatelessWidget {
  final String text;
  final bool isRequired;

  const CreateJobFieldLabel({
    super.key,
    required this.text,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.primaryTextColor,
          ),
          children: isRequired
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ]
              : const [],
        ),
      ),
    );
  }
}

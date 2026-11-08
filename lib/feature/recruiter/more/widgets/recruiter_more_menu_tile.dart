import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';

import 'package:msollaally/core/common/styles/global_text_style.dart';

class RecruiterMoreMenuTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const RecruiterMoreMenuTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryButtonColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

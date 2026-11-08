import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';

class ChatErrorBanner extends StatelessWidget {
  final String message;

  const ChatErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 8.height),
      color: AppColors.uiDangerColor.withValues(alpha: 0.08),
      child: Text(
        message,
        style: getTextStyle(fontSize: 12, color: AppColors.uiDangerColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}

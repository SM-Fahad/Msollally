import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

void showExitConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        "Exit Mock Interview?",
        style: getTextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      content: Text(
        "Are you sure you want to exit? Your progress in this session will be lost.",
        style: getTextStyle(color: AppColors.secondaryTextColor, fontSize: 13, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel", style: getTextStyle(color: AppColors.secondaryTextColor, fontSize: 13)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // dismiss dialog
            Get.back(); // exit screen
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.uiDangerColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 16.width),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.radius)),
          ),
          child: Text("Exit", style: getTextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

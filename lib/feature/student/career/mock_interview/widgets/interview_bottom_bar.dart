import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../controller/mock_interview.dart';
import 'finish_confirmation_dialog.dart';

class InterviewBottomBar extends StatelessWidget {
  final MockController controller;

  const InterviewBottomBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = controller.currentIndex.value;

      return Container(
        padding: EdgeInsets.fromLTRB(20.width, 16.height, 20.width, 36.height),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.sectionBorderColor, width: 1)),
        ),
        child: Row(
          children: [
            // Back Button (only shown if index > 0)
            if (currentIndex > 0) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.previousQuestion(),
                  icon: Icon(Icons.arrow_back, size: 16.radius),
                  label: Text(
                    "Back",
                    style: getTextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.secondaryTextColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondaryTextColor,
                    side: const BorderSide(color: AppColors.sectionBorderColor),
                    padding: EdgeInsets.symmetric(vertical: 12.height),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.radius),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.width),
            ],

            // Next / Finish Button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.isLastQuestion) {
                    showFinishConfirmationDialog(context, controller);
                  } else {
                    controller.nextQuestion();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButtonColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.height),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.radius),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.isLastQuestion ? "Finish" : "Next",
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 6.width),
                    Icon(
                      controller.isLastQuestion ? Icons.check : Icons.arrow_forward,
                      size: 16.radius,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

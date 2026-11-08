import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../controller/mock_interview.dart';

class InterviewProgressHeader extends StatelessWidget {
  final MockController controller;

  const InterviewProgressHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = controller.currentIndex.value;
      final totalQuestions = controller.questions.length;
      final progressPercent = totalQuestions > 0 ? (currentIndex + 1) / totalQuestions : 0.0;

      return Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 14.height),
        child: Row(
          children: [
            Text(
              "${currentIndex + 1} of $totalQuestions",
              style: getTextStyle(
                fontSize: 13,
                color: AppColors.primaryButtonColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 12.width),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.radius),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  backgroundColor: AppColors.sectionBorderColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryButtonColor),
                  minHeight: 8.height,
                ),
              ),
            ),
            SizedBox(width: 16.width),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.width, vertical: 6.height),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.radius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined, size: 16.radius, color: Colors.orange.shade800),
                  SizedBox(width: 4.width),
                  Text(
                    controller.remainingTime.value,
                    style: getTextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

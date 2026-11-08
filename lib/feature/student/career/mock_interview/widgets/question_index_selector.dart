import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../controller/mock_interview.dart';

class QuestionIndexSelector extends StatelessWidget {
  final MockController controller;

  const QuestionIndexSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = controller.currentIndex.value;
      final totalQuestions = controller.questions.length;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.width, 0, 20.width, 16.height),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.sectionBorderColor, width: 1)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(totalQuestions, (index) {
              final isCurrent = currentIndex == index;
              final isAnswered = controller.userAnswers[index] != -1;

              return GestureDetector(
                onTap: () => controller.changeQuestion(index),
                child: Container(
                  margin: EdgeInsets.only(right: 8.width),
                  width: 32.width,
                  height: 32.height,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.primaryButtonColor.withValues(alpha: 0.1)
                        : isAnswered
                            ? AppColors.primaryButtonColor.withValues(alpha: 0.05)
                            : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.primaryButtonColor
                          : isAnswered
                              ? AppColors.primaryButtonColor.withValues(alpha: 0.5)
                              : AppColors.sectionBorderColor,
                      width: isCurrent ? 2.0 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: getTextStyle(
                        fontSize: 12,
                        fontWeight: (isCurrent || isAnswered) ? FontWeight.bold : FontWeight.w500,
                        color: isCurrent
                            ? AppColors.primaryButtonColor
                            : isAnswered
                                ? AppColors.primaryButtonColor
                                : AppColors.secondaryTextColor,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      );
    });
  }
}

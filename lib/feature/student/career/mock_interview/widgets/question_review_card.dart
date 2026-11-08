import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../model/mock_model.dart';

class QuestionReviewCard extends StatelessWidget {
  final MockQuestion question;
  final int index;
  final bool hasAnswer;
  final int userAns;

  const QuestionReviewCard({
    super.key,
    required this.question,
    required this.index,
    required this.hasAnswer,
    required this.userAns,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = userAns == question.correctAnswerIndex;

    return Container(
      margin: EdgeInsets.only(bottom: 16.height),
      padding: EdgeInsets.all(16.width),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.radius),
        border: Border.all(color: AppColors.sectionBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.width, vertical: 4.height),
                decoration: BoxDecoration(
                  color: AppColors.tagBackgroundColor,
                  borderRadius: BorderRadius.circular(6.radius),
                ),
                child: Text(
                  "QUESTION ${index + 1}",
                  style: getTextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tertiaryTextColor,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.width, vertical: 4.height),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? Colors.green.withValues(alpha: 0.08)
                      : userAns == -1
                          ? Colors.grey.withValues(alpha: 0.08)
                          : Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.radius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCorrect
                          ? Icons.check_circle_rounded
                          : userAns == -1
                              ? Icons.help_rounded
                              : Icons.cancel_rounded,
                      size: 14.radius,
                      color: isCorrect
                          ? Colors.green.shade700
                          : userAns == -1
                              ? Colors.grey.shade600
                              : Colors.red.shade700,
                    ),
                    SizedBox(width: 4.width),
                    Text(
                      isCorrect
                          ? "Correct"
                          : userAns == -1
                              ? "Skipped"
                              : "Incorrect",
                      style: getTextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCorrect
                            ? Colors.green.shade700
                            : userAns == -1
                                ? Colors.grey.shade700
                                : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.height),
          Text(
            question.question,
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTextColor,
              height: 1.3,
            ),
          ),
          SizedBox(height: 16.height),
          Column(
            children: List.generate(question.options.length, (optIndex) {
              final optionText = question.options[optIndex];
              final isCorrectOpt = optIndex == question.correctAnswerIndex;
              final isUserSelected = userAns == optIndex;

              Color itemBgColor = Colors.white;
              Color itemBorderColor = AppColors.sectionBorderColor;
              Color textColor = AppColors.primaryTextColor;
              IconData checkIcon = Icons.radio_button_unchecked_rounded;
              Color iconColor = Colors.grey.shade400;

              if (isCorrectOpt) {
                itemBgColor = Colors.green.withValues(alpha: 0.04);
                itemBorderColor = Colors.green.shade400;
                textColor = Colors.green.shade900;
                checkIcon = Icons.check_circle_rounded;
                iconColor = Colors.green.shade600;
              } else if (isUserSelected) {
                itemBgColor = Colors.red.withValues(alpha: 0.04);
                itemBorderColor = Colors.red.shade400;
                textColor = Colors.red.shade900;
                checkIcon = Icons.cancel_rounded;
                iconColor = Colors.red.shade600;
              }

              return Container(
                margin: EdgeInsets.only(bottom: 8.height),
                padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 10.height),
                decoration: BoxDecoration(
                  color: itemBgColor,
                  borderRadius: BorderRadius.circular(10.radius),
                  border: Border.all(color: itemBorderColor, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(checkIcon, color: iconColor, size: 18.radius),
                    SizedBox(width: 10.width),
                    Expanded(
                      child: Text(
                        optionText,
                        style: getTextStyle(
                          fontSize: 13,
                          fontWeight: (isCorrectOpt || isUserSelected)
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: textColor,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          if (question.reason != null && question.reason!.isNotEmpty) ...[
            SizedBox(height: 16.height),
            Container(
              padding: EdgeInsets.all(12.width),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10.radius),
                border: Border.all(color: Colors.blue.shade100, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.blue.shade600, size: 18.radius),
                  SizedBox(width: 8.width),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Explanation",
                          style: getTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        SizedBox(height: 4.height),
                        Text(
                          question.reason!,
                          style: getTextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

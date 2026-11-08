import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../controller/mock_interview.dart';

void showFinishConfirmationDialog(BuildContext context, MockController controller) {
  final unanswered = controller.unansweredCount;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        unanswered > 0 ? "Unanswered Questions" : "Submit Interview Answers",
        style: getTextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      content: Text(
        unanswered > 0
            ? "You have $unanswered unanswered questions. Are you sure you want to finish and submit the interview?"
            : "Are you sure you want to submit your answers and view the results?",
        style: getTextStyle(color: AppColors.secondaryTextColor, fontSize: 13, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "Review",
            style: getTextStyle(color: AppColors.primaryButtonColor, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // dismiss dialog
            controller.finishQuiz(); // submit quiz
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: unanswered > 0 ? AppColors.uiDangerColor : AppColors.primaryButtonColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 16.width),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.radius)),
          ),
          child: Text("Submit", style: getTextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/career/my_career/screen/student_career_screen.dart';
import '../controller/mock_interview.dart';
import '../model/mock_model.dart';
import '../widgets/statistics_summary_card.dart';
import '../widgets/question_review_card.dart';
import '../widgets/statistics_bottom_bar.dart';

class MockStatisticsPage extends StatelessWidget {
  const MockStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MockResult result = Get.arguments as MockResult;

    double scorePercent = result.totalQuestions == 0
        ? 0
        : result.correctAnswers / result.totalQuestions.toDouble();

    int notAnswered =
        result.totalQuestions - (result.correctAnswers + result.wrongAnswers);

    // Clean up controller to free up memory
    if (Get.isRegistered<MockController>()) {
      Get.delete<MockController>();
    }

    return Scaffold(
      backgroundColor: AppColors.panelBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.primaryTextColor, size: 24.radius),
          onPressed: () => Get.offAll(() => StudentCareerScreen()),
        ),
        title: Text(
          "Interview Results",
          style: getTextStyle(
            color: AppColors.primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          StatisticsSummaryCard(
            result: result,
            scorePercent: scorePercent,
            notAnswered: notAnswered,
          ),
          Container(
            width: double.infinity,
            color: AppColors.panelBackgroundColor,
            padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 12.height),
            child: Text(
              "QUESTION REVIEW",
              style: getTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryTextColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 4.height),
              itemCount: result.questions.length,
              itemBuilder: (context, index) {
                final q = result.questions[index];
                final hasAnswer = index < result.userAnswers.length;
                final userAns = hasAnswer ? result.userAnswers[index] : -1;

                return QuestionReviewCard(
                  question: q,
                  index: index,
                  hasAnswer: hasAnswer,
                  userAns: userAns,
                );
              },
            ),
          ),
          StatisticsBottomBar(result: result),
        ],
      ),
    );
  }
}

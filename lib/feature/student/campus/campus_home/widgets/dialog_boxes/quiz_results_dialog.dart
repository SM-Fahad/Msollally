import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/routes/app_route.dart';
import 'controller/dialogbox_controller.dart';
import 'package:get/get.dart';

class QuizResultsDialog extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final int timeLimit;

  const QuizResultsDialog({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeLimit,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DialogboxController>()
        ? Get.find<DialogboxController>()
        : Get.put(DialogboxController());
    final double score = (correctAnswers / totalQuestions) * 100;
    final bool qualified = score >= 70;

    final quizData = QuizData(
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      timeLimit: timeLimit,
      passPercentage: 70,
      answers: [],
      score: score,
      qualified: qualified,
    );
    controller.setQuizData(quizData);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Quiz Results",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(
              "${score.toStringAsFixed(1)}%",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: qualified ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: qualified
                    ? AppColors.honeydewF0FDF4
                    : AppColors.seaShellFFF7ED,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: qualified
                      ? AppColors.gainsboroD1FAE5
                      : AppColors.navajoWhiteFFD6A7,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    qualified ? "Congratulations!" : "Keep Practicing!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: qualified
                          ? AppColors.teal059669
                          : AppColors.orangeRedEA580C,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    qualified
                        ? "You qualified for the finals! Your participation score: ${controller.participationScore.value} points"
                        : "You need 70% to qualify. Review the video and brochure materials and try again next week.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: qualified
                          ? AppColors.teal047857
                          : AppColors.saddleBrown9A3412,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pinkFFC9C9.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.pinkFFC9C9),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                    "Correct Answers:",
                    "$correctAnswers / $totalQuestions",
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    "Pass Mark:",
                    "70% (${(totalQuestions * 0.7).toStringAsFixed(0)}/$totalQuestions)",
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Status:",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: qualified ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          qualified ? "QUALIFIED" : "NOT QUALIFIED",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.offNamed(AppRoute.studentCampus);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black020617,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

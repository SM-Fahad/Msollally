import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../controller/question_bank_controller.dart';
import '../model/question_bank_model.dart';
import '../screen/practice_result_screen.dart';

class PracticeSubmitButton extends StatelessWidget {
  final List<PracticeQuestion> questions;
  final QbankController controller;
  final String qbankItemId;
  final VoidCallback? onRestart;

  const PracticeSubmitButton({
    super.key,
    required this.questions,
    required this.controller,
    required this.qbankItemId,
    this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: Text(
              "End Exam & View Score",
              style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () => _showScore(context),
          ),
        ),
      ),
    );
  }

  Future<void> _showScore(BuildContext context) async {
    // Submit to backend and reveal correct answers
    final response = await controller.submitPractice(qbankItemId);
    
    // If it fails or returns null, we can still show local score or just return.
    if (response == null) return;

    final total = response.summary.totalQuestions > 0
        ? response.summary.totalQuestions
        : controller.practiceQuestions.length;

    int correct = response.summary.correctAnswersCount;
    int incorrect = response.summary.wrongAnswersCount;
    int skipped = response.summary.unattendedCount;

    // Fallback if summary was unpopulated but results exist
    if (correct == 0 && incorrect == 0 && response.results.isNotEmpty) {
      for (final r in response.results) {
        if (!r.isAttended) {
          skipped++;
        } else if (r.isCorrect) {
          correct++;
        } else {
          incorrect++;
        }
      }
    }

    Get.to(() => PracticeResultScreen(
      correct: correct,
      incorrect: incorrect,
      skipped: skipped, 
      total: total,
      onRestart: onRestart,
    ));
  }
}

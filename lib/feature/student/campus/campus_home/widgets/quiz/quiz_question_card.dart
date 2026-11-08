import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';

class QuizQuestionCard extends StatelessWidget {
  const QuizQuestionCard({
    super.key,
    required this.controller,
    required this.showSubmit,
    required this.onNext,
  });

  final StudentCampusController controller;
  final bool showSubmit;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentQuestion = controller.quizCurrentQuestion.value;
      final selectedAnswer = controller.quizSelectedAnswer.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionHeader(currentQuestion),
            const SizedBox(height: 16),
            _buildOptions(selectedAnswer, currentQuestion),
            const SizedBox(height: 16),
            _buildNavigation(currentQuestion),
          ],
        ),
      );
    });
  }

  Widget _buildQuestionHeader(int currentQuestion) {
    final questionText = controller.quizQuestions.isNotEmpty
        ? controller.quizQuestions[currentQuestion].question
        : "No question text loaded.";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: AppColors.darkSlateGray333333,
          radius: 12,
          child: Text(
            "${currentQuestion + 1}",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          questionText,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(String? selectedAnswer, int currentQuestion) {
    if (controller.quizQuestions.isEmpty) return const SizedBox.shrink();
    final q = controller.quizQuestions[currentQuestion];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.whiteSmokeF1F5F9,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (q.optionA.isNotEmpty) ...[
            _buildOption('a', 'a) ${q.optionA}', selectedAnswer),
            const SizedBox(height: 6),
          ],
          if (q.optionB.isNotEmpty) ...[
            _buildOption('b', 'b) ${q.optionB}', selectedAnswer),
            const SizedBox(height: 6),
          ],
          if (q.optionC.isNotEmpty) ...[
            _buildOption('c', 'c) ${q.optionC}', selectedAnswer),
            const SizedBox(height: 6),
          ],
          if (q.optionD.isNotEmpty) ...[
            _buildOption('d', 'd) ${q.optionD}', selectedAnswer),
          ],
        ],
      ),
    );
  }

  Widget _buildOption(String key, String text, String? selectedAnswer) {
    final bool isSelected = selectedAnswer == key;
    return GestureDetector(
      onTap: () => controller.updateQuizAnswer(key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.red : Colors.grey.shade400,
                  width: 1.5,
                ),
                color: Colors.white,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation(int currentQuestion) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: currentQuestion > 0
                ? () => controller.updateQuizQuestion(currentQuestion - 1)
                : null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Previous", style: TextStyle(color: Colors.grey)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: showSubmit
                  ? Colors.green.shade500
                  : AppColors.royalBlue2F69FF,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              showSubmit ? "Submit Quiz" : "Next",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

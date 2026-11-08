import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/question_bank_controller.dart';
import '../model/question_bank_model.dart';
import 'practice_question_card.dart';

class PracticeQuestionList extends StatelessWidget {
  final List<PracticeQuestion> questions;
  final QbankController controller;
  final String qbankItemId;

  const PracticeQuestionList({
    super.key,
    required this.questions,
    required this.controller,
    required this.qbankItemId,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchPracticeQuestions(qbankItemId),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          return Obx(
            () => PracticeQuestionCard(
              question: q,
              questionNumber: index + 1,
              selectedOptionId: controller.selectedOptionIds[q.id],
              isRevealed: controller.revealed[q.id] ?? false,
              onOptionSelected: (optionId) {
                controller.selectOption(q.id, optionId);
              },
              onReveal: () async {
                if (q.hasAnswer) {
                  controller.revealAnswer(q.id);
                } else {
                  await controller.fetchPracticeQuestionById(q.id);
                  controller.revealAnswer(q.id);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:get/get.dart';

import '../controller/quiz_controller.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuizController>();

    return Scaffold(
      appBar: AppBar(title: Text(controller.quizTitle)),
      body: Obx(() {
        final question = controller.currentQuestion;

        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(),
              // Top row: Progress counter + progress bar + timer
              Row(
                children: [
                  SizedBox(height: 100),
                  Text(
                    "${controller.currentIndex.value + 1}/${controller.questions.length}",
                    style: getTextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value:
                          (controller.currentIndex.value + 1) /
                          controller.questions.length,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue,
                      minHeight: 6,
                    ),
                  ),
                  SizedBox(width: 8),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 18, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        controller.remainingTime.value,
                        style: getTextStyle(
                          fontSize: 16,
                          color: Colors.deepOrangeAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Question
              Text(
                "${controller.currentIndex.value + 1}.",
                style: getTextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(question.question, style: getTextStyle(fontSize: 16)),
              SizedBox(height: 20),

              // Options
              ...List.generate(question.options.length, (index) {
                return ListTile(
                  dense: true, // Reduces tile height
                  contentPadding: EdgeInsets.zero, // Removes internal padding
                  title: Text(
                    question.options[index],
                    style: getTextStyle(fontSize: 18),
                  ),
                  leading: Radio<int>(
                    value: index,
                    groupValue: controller.selectedAnswer.value,
                    onChanged: (val) {
                      controller.selectedAnswer.value = val!;
                    },
                  ),
                );
              }),

              // Next / Finish button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: Icon(
                    controller.isLastQuestion
                        ? Icons.check
                        : Icons.arrow_forward,
                    size: 18,
                  ),
                  label: Text(controller.isLastQuestion ? "Finish" : "Next"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    controller.submitAnswer();
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

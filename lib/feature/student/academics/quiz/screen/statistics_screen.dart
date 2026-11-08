import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/academics/quiz/screen/start_quiz_screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../controller/quiz_controller.dart';
import '../model/quiz_model.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final QuizResult result = Get.arguments;

    double scorePercent = result.totalQuestions == 0
        ? 0
        : result.correctAnswers / result.totalQuestions.toDouble();

    int notAnswered =
        result.totalQuestions - (result.correctAnswers + result.wrongAnswers);

    return Scaffold(
      appBar: AppBar(
        title: Text(result.quizTitle),
        actions: [
          TextButton(
            onPressed: () {
              // remove old quiz controller so no leftover state
              if (Get.isRegistered<QuizController>()) {
                Get.delete<QuizController>();
              }

              // Go to start quiz fresh and clear history
              Get.offAll(() => StartQuizScreen());
            },
            child: Text("Retake", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(),
            // Quiz title
            Text(
              "Quiz Result: ${result.quizTitle.replaceFirst('Quiz: ', '')}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),

            // Percent Circle
            Align(
              alignment: Alignment.centerRight,
              child: CircularPercentIndicator(
                radius: 55,
                lineWidth: 20,
                percent: scorePercent.clamp(0.0, 1.0),
                center: Text(
                  "${(scorePercent * 100).toInt()}%",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                progressColor: Colors.purple,
              ),
            ),
            SizedBox(height: 10),

            // Marks row
            Text("Mark: ${result.correctAnswers}/${result.totalQuestions}"),
            Row(
              children: [
                Text(
                  "Correct: ${result.correctAnswers}",
                  style: TextStyle(color: Colors.green),
                ),
                SizedBox(width: 15),
                Text(
                  "Wrong: ${result.wrongAnswers}",
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(width: 15),
                Text(
                  "No Answer: $notAnswered",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            Divider(height: 30),

            // Questions list
            Expanded(
              child: ListView.builder(
                itemCount: result.questions.length,
                itemBuilder: (context, index) {
                  final q = result.questions[index];

                  // Check if user provided an answer
                  final hasAnswer = index < result.userAnswers.length;
                  final userAns = hasAnswer ? result.userAnswers[index] : null;

                  return Card(
                    color: Colors.white70,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question text
                          Text(
                            "${index + 1}.",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          Text(
                            " ${q.question}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 10),

                          // Options
                          Column(
                            children: List.generate(q.options.length, (
                              optIndex,
                            ) {
                              final optionText = q.options[optIndex];

                              // Determine color
                              Color textColor = Colors.black;
                              IconData? icon;
                              if (optIndex == q.correctAnswerIndex) {
                                textColor = Colors.green;
                                icon = Icons.check_circle;
                              } else if (hasAnswer && userAns == optIndex) {
                                textColor = Colors.red;
                                icon = Icons.cancel;
                              } else {
                                textColor = Colors.black87;
                                icon = Icons.radio_button_unchecked;
                              }

                              return ListTile(
                                dense: true,
                                leading: Icon(icon, color: textColor),
                                title: Text(
                                  optionText,
                                  style: TextStyle(color: textColor),
                                ),
                              );
                            }),
                          ),

                          // Solution / Explanation below
                          if (q.explanation.isNotEmpty) ...[
                            SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                "Solution & Explanation:\n${q.explanation}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

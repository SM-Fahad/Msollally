import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/feature/student/academics/preparation/service/prep_ai_service.dart';
import '../controller/quiz_controller.dart';
import '../model/quiz_model.dart';
import 'quiz_screen.dart';
import '../widgets/quiz_dropdown_field.dart';
import '../service/student_quiz_service.dart';

class StartQuizScreen extends StatelessWidget {
  final String? quizTitle;
  final List<QuizQuestion>? generatedQuestions;
  final String? initialQuestionType;
  final int? initialTotalQuestions;

  const StartQuizScreen({
    super.key,
    this.quizTitle,
    this.generatedQuestions,
    this.initialQuestionType,
    this.initialTotalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final totalQuestions = (initialTotalQuestions ?? 10).obs;
    final questionType = (initialQuestionType ?? "both").obs;
    final effectiveTitle = quizTitle?.isNotEmpty == true
        ? quizTitle!
        : "Exam Practice Quiz";

    return Scaffold(
      appBar: AppBar(title: Text(effectiveTitle)),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Ready to Challenge Yourself",
                  style: getTextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Remember, you can’t go back once you start.\nMake sure you are fully prepared.",
                  style: getTextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Question count selection
                Obx(
                  () => QuizDropdownField<int>(
                    label: "Total Questions",
                    value: totalQuestions.value,
                    items: const [5, 10, 15, 20],
                    itemLabel: (v) => "$v Questions",
                    onChanged: (val) {
                      if (val != null) totalQuestions.value = val;
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Question type selection
                Obx(
                  () => QuizDropdownField<String>(
                    label: "Question Type",
                    value: questionType.value,
                    items: const ["mcq", "true_false", "both"],
                    itemLabel: (v) {
                      if (v == "mcq") return "MCQ";
                      if (v == "true_false") return "True/False";
                      return "Both";
                    },
                    onChanged: (val) {
                      if (val != null) questionType.value = val;
                    },
                  ),
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Start Quiz",
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    EasyLoading.show(status: 'Preparing quiz questions...');

                    List<QuizQuestion> questionsToUse = [];

                    // 1. If questions were pre-generated from Prep module/topic
                    if (generatedQuestions != null && generatedQuestions!.isNotEmpty) {
                      questionsToUse = List<QuizQuestion>.from(generatedQuestions!);
                      if (questionsToUse.length > totalQuestions.value) {
                        questionsToUse = questionsToUse.take(totalQuestions.value).toList();
                      }
                    }

                    // 2. Otherwise try fetching from backend service
                    if (questionsToUse.isEmpty) {
                      final service = StudentQuizService();
                      int compId = 2;
                      if (Get.isRegistered<StudentCampusController>()) {
                        final campusCtrl = Get.find<StudentCampusController>();
                        if (campusCtrl.competitionsList.isNotEmpty) {
                          compId = campusCtrl.competitionsList.first.id;
                        }
                      }

                      final rawQuestions = await service.fetchQuizQuestions(
                        competitionId: compId,
                        quizType: questionType.value,
                        weekNumber: 1,
                      );

                      if (rawQuestions.isNotEmpty) {
                        questionsToUse = rawQuestions
                            .map((q) => QuizQuestion.fromModel(q))
                            .take(totalQuestions.value)
                            .toList();
                      }
                    }

                    // 3. Robust fallback to PrepAiService if backend returned empty
                    if (questionsToUse.isEmpty) {
                      questionsToUse = await PrepAiService.generateQuestions(
                        moduleTitle: effectiveTitle.replaceAll(RegExp(r'^Quiz:\s*'), ''),
                        questionType: questionType.value,
                        count: totalQuestions.value,
                      );
                    }

                    EasyLoading.dismiss();

                    if (questionsToUse.isEmpty) {
                      EasyLoading.showError('Could not load questions. Please try again.');
                      return;
                    }

                    // Retrieve user info for submission tracking
                    int myId = 0;
                    if (Get.isRegistered<StudentProfileController>()) {
                      myId = Get.find<StudentProfileController>().userId.value;
                    }

                    if (Get.isRegistered<QuizController>()) {
                      Get.delete<QuizController>();
                    }

                    // Dynamic duration: 90 seconds per question (clamp between 5 and 60 minutes)
                    final calculatedMinutes = ((questionsToUse.length * 90) / 60).ceil().clamp(5, 60);

                    Get.put(
                      QuizController(
                        quizTitle: effectiveTitle,
                        questions: questionsToUse,
                        duration: Duration(minutes: calculatedMinutes),
                        userId: myId,
                        quizType: questionType.value,
                        weekNumber: 1,
                      ),
                    );
                    Get.to(() => const QuizScreen());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

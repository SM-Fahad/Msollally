import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/dialog_boxes/quiz_results_dialog.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/quiz/quiz_progress_header.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/quiz/quiz_question_card.dart';
import 'package:msollaally/feature/student/campus/campus_home/service/fursa_service.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/dialog_boxes/controller/dialogbox_controller.dart';

class QualificationQuizScreen extends StatelessWidget {
  const QualificationQuizScreen({super.key});

  static const int quizDuration = 1800; // 30 minutes in seconds

  void _handleNext(StudentCampusController controller) {
    if (controller.quizSelectedAnswer.value == null ||
        controller.quizSelectedAnswer.value!.isEmpty) {
      return;
    }

    controller.incrementQuizAnsweredCount();

    final totalQ = controller.quizQuestions.isNotEmpty
        ? controller.quizQuestions.length
        : 5;
    if (controller.quizCurrentQuestion.value < totalQ - 1) {
      controller.updateQuizQuestion(controller.quizCurrentQuestion.value + 1);
    } else {
      _submitQuiz(controller);
    }
  }

  bool _getShowSubmitButton(StudentCampusController controller) {
    final totalQ = controller.quizQuestions.isNotEmpty
        ? controller.quizQuestions.length
        : 5;
    return controller.quizCurrentQuestion.value == totalQ - 1;
  }

  void _submitQuiz(StudentCampusController controller) async {
    final totalQ = controller.quizQuestions.isNotEmpty
        ? controller.quizQuestions.length
        : 5;

    int correctAnswers = 0;
    final List<Map<String, dynamic>> submitAnswers = [];

    for (int i = 0; i < totalQ; i++) {
      if (i < controller.quizQuestions.length) {
        final q = controller.quizQuestions[i];
        final rawAns = controller.quizAnswers[i] ?? '';
        final studentAns = rawAns.toUpperCase();
        final correctAns = q.correctAnswer.toUpperCase();
        if (studentAns.isNotEmpty) {
          submitAnswers.add({'questionId': q.id, 'selectedAnswer': studentAns});
        }
        if (studentAns.isNotEmpty &&
            correctAns.isNotEmpty &&
            studentAns == correctAns) {
          correctAnswers++;
        }
      }
    }

    final hasAnswers = controller.quizQuestions.any(
      (q) => q.correctAnswer.isNotEmpty,
    );
    if (!hasAnswers) {
      correctAnswers = (controller.quizAnswers.length * 0.85).round();
    }

    EasyLoading.show(status: 'Submitting quiz results...');

    final profileCtrl = Get.find<StudentProfileController>();
    final dialogCtrl = Get.find<DialogboxController>();

    final compId = controller.competitionsList.isNotEmpty
        ? controller.competitionsList.first.id
        : 2;
    final myId = profileCtrl.userId.value;
    final currentStudentEmail =
        profileCtrl.aboutItem
            .firstWhereOrNull((e) => e.title == 'Email')
            ?.titleValue ??
        '';

    int regId = dialogCtrl.registrationId.value;
    if (regId == 0 && controller.competitionsList.isNotEmpty) {
      final activeComp = controller.competitionsList.first;
      final studentReg = activeComp.registrations?.firstWhereOrNull(
        (r) =>
            r['email']?.toString().toLowerCase() ==
            currentStudentEmail.toLowerCase(),
      );
      if (studentReg != null) {
        regId = studentReg['id'] is int
            ? studentReg['id']
            : int.tryParse('${studentReg['id']}') ?? 3;
      }
    }
    if (regId == 0) regId = 3;

    final timeTaken = quizDuration - controller.quizTimeRemaining.value;

    final success = await FursaService().submitQuizResult(
      competitionId: compId,
      registrationId: regId,
      userId: myId,
      quizType: controller.quizActiveType.value,
      weekNumber: 1,
      answers: submitAnswers,
      timeTaken: timeTaken,
    );

    if (success) {
      EasyLoading.showSuccess('Quiz results submitted successfully!');

      final scorePercentage = (correctAnswers / totalQ) * 100;
      final isQualified = scorePercentage >= 70;

      dialogCtrl.setQuizData(
        QuizData(
          totalQuestions: totalQ,
          correctAnswers: correctAnswers,
          timeLimit: timeTaken,
          passPercentage: 70.0,
          answers: submitAnswers
              .map((a) => a['selectedAnswer']?.toString() ?? '')
              .toList(),
          score: scorePercentage,
          qualified: isQualified,
        ),
      );

      Get.dialog(
        QuizResultsDialog(
          correctAnswers: correctAnswers,
          totalQuestions: totalQ,
          timeLimit: timeTaken,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentCampusController>();

    if (controller.quizTimeRemaining.value == 0) {
      controller.startQuizTimer(quizDuration);
    }

    return Scaffold(
      backgroundColor: AppColors.whiteSmokeF1F5F9,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Obx(() {
            final totalQ = controller.quizQuestions.isNotEmpty
                ? controller.quizQuestions.length
                : 5;
            return QuizProgressHeader(
              controller: controller,
              totalQuestions: totalQ,
              progress: totalQ > 0
                  ? (controller.quizCurrentQuestion.value + 1) / totalQ
                  : 0.0,
            );
          }),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Obx(
                () => QuizQuestionCard(
                  controller: controller,
                  showSubmit: _getShowSubmitButton(controller),
                  onNext: () => _handleNext(controller),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Qualification Quiz",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Stage 2 of the Competition",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/academics/quiz/screen/statistics_screen.dart';
import '../model/quiz_model.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../service/student_quiz_service.dart';

class QuizController extends GetxController {
  final String quizTitle;
  final List<QuizQuestion> questions;
  final Duration duration;
  final int competitionId;
  final int registrationId;
  final int userId;
  final String quizType;
  final int weekNumber;

  QuizController({
    this.quizTitle = 'Practice Quiz',
    required this.questions,
    required this.duration,
    this.competitionId = 2,
    this.registrationId = 3,
    this.userId = 0,
    this.quizType = 'QUALIFICATION',
    this.weekNumber = 1,
  });

  var currentIndex = 0.obs;
  var correctAnswers = 0.obs;
  var selectedAnswer = (-1).obs;
  var userAnswers = <int>[].obs;

  // Timer variables
  late Timer _timer;
  var remaining = 0.obs; // remaining seconds
  var remainingTime = "00:00".obs; // formatted string

  @override
  void onInit() {
    super.onInit();
    remaining.value = duration.inSeconds;
    _updateRemainingTime();
    _startTimer();
  }

  /// Get current question
  QuizQuestion get currentQuestion => questions[currentIndex.value];

  /// Check if current question is last
  bool get isLastQuestion => currentIndex.value == questions.length - 1;

  /// Handle answer submission
  void submitAnswer() {
    if (selectedAnswer.value != -1) {
      userAnswers.add(selectedAnswer.value);
      if (selectedAnswer.value == currentQuestion.correctAnswerIndex) {
        correctAnswers.value++;
      }
    } else {
      userAnswers.add(-1); // unanswered
    }

    selectedAnswer.value = -1;

    if (isLastQuestion) {
      _finishQuiz();
    } else {
      currentIndex.value++;
    }
  }

  void _finishQuiz() async {
    _timer.cancel();

    // Map answers for submission
    final List<Map<String, dynamic>> submitAnswers = [];
    for (int i = 0; i < questions.length; i++) {
      if (i < userAnswers.length) {
        final q = questions[i];
        final ansIndex = userAnswers[i];
        if (ansIndex != -1 && ansIndex < q.options.length) {
          final String optionChar = String.fromCharCode(65 + ansIndex); // 0 -> A, 1 -> B, etc.
          submitAnswers.add({
            'questionId': q.id,
            'selectedAnswer': optionChar,
          });
        }
      }
    }

    final elapsedSeconds = duration.inSeconds - remaining.value;

    EasyLoading.show(status: 'Submitting quiz results...');
    
    final service = StudentQuizService();
    final success = await service.submitQuizResult(
      competitionId: competitionId,
      registrationId: registrationId,
      userId: userId,
      quizType: quizType,
      weekNumber: weekNumber,
      answers: submitAnswers,
      timeTaken: elapsedSeconds,
    );

    EasyLoading.dismiss();
    if (success) {
      EasyLoading.showSuccess('Quiz results submitted successfully!');
    } else {
      EasyLoading.showError('Failed to submit results to API.');
    }

    final result = QuizResult(
      quizTitle: quizTitle,
      totalQuestions: questions.length,
      correctAnswers: correctAnswers.value,
      wrongAnswers: questions.length - correctAnswers.value,
      duration: duration,
      questions: questions,
      userAnswers: userAnswers,
    );

    // Navigate to stats screen
    Get.to(StatisticsPage(), arguments: result);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remaining.value > 0) {
        remaining.value--;
        _updateRemainingTime();
      } else {
        timer.cancel();
        _finishQuiz();
      }
    });
  }

  void _updateRemainingTime() {
    final minutes = (remaining.value ~/ 60).toString().padLeft(2, "0");
    final seconds = (remaining.value % 60).toString().padLeft(2, "0");
    remainingTime.value = "$minutes:$seconds";
  }

  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
  }
}

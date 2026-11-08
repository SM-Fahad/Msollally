import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger_barta/logger_barta.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import '../model/mock_model.dart';
import '../screen/statistics_mock_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MockController extends GetxController {
  final String topicId;
  final Duration duration;
  final String categoryTitle;

  MockController({
    required this.topicId,
    required this.duration,
    this.categoryTitle = "Mock Interview",
  });

  var questions = <MockQuestion>[].obs;
  var isLoading = true.obs;
  var isSubmitting = false.obs;
  var currentIndex = 0.obs;
  var selectedAnswer = (-1).obs;
  var userAnswers = <int>[].obs;

  // Timer variables
  Timer? _timer;
  var remaining = 0.obs; // remaining seconds
  var remainingTime = "00:00".obs; // formatted string

  @override
  void onInit() {
    super.onInit();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    isLoading.value = true;
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse(Urls.getInterviewTopic(topicId));
      final response = await http.get(
        url,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        BartaLog.network(
          endpoint: Urls.getInterviewTopic(topicId),
          responseBody: response.body,
        );
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> questionsData = data['questions'] ?? [];

        final List<MockQuestion> parsedQuestions = questionsData.map((q) {
          final List<String> opts =
              (q['options'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          return MockQuestion(
            id: q['id']?.toString() ?? '',
            question: q['questionText']?.toString() ?? '',
            options: opts,
          );
        }).toList();

        questions.assignAll(parsedQuestions);
      }
    } catch (e) {
      BartaLog.error('fetchQuestions error', error: e);
    } finally {
      // Pre-fill answers with -1 representing unanswered
      userAnswers.assignAll(List.filled(questions.length, -1));
      remaining.value = duration.inSeconds;
      _updateRemainingTime();

      if (questions.isNotEmpty) {
        _startTimer();
      }
      isLoading.value = false;
    }
  }

  /// Get current question
  MockQuestion get currentQuestion => questions[currentIndex.value];

  /// Check if current question is last
  bool get isLastQuestion => currentIndex.value == questions.length - 1;

  /// Get total unanswered count
  int get unansweredCount => userAnswers.where((val) => val == -1).length;

  /// Select option for current question
  void selectOption(int optIndex) {
    selectedAnswer.value = optIndex;
    userAnswers[currentIndex.value] = optIndex;
  }

  /// Change current question index and reload saved answer
  void changeQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      currentIndex.value = index;
      selectedAnswer.value = userAnswers[index];
    }
  }

  /// Navigate to previous question
  void previousQuestion() {
    if (currentIndex.value > 0) {
      changeQuestion(currentIndex.value - 1);
    }
  }

  /// Navigate to next question
  void nextQuestion() {
    if (!isLastQuestion) {
      changeQuestion(currentIndex.value + 1);
    }
  }

  /// Finish interview and compute scores
  Future<void> finishQuiz() async {
    _timer?.cancel();

    if (questions.isEmpty) {
      Get.back();
      return;
    }

    isSubmitting.value = true;

    // Show a loading dialog during submission
    EasyLoading.show(status: 'Submitting...');

    try {
      final List<Map<String, dynamic>> answersPayload = [];
      for (int i = 0; i < questions.length; i++) {
        if (userAnswers[i] != -1) {
          answersPayload.add({
            "questionId": questions[i].id,
            "selectedOption": userAnswers[i],
          });
        }
      }

      final payload = {"answers": answersPayload};

      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse(Urls.submitInterviewTopic(topicId));
      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      BartaLog.network(
        endpoint: Urls.submitInterviewTopic(topicId),
        requestBody: payload,
        responseBody: response.body,
      );

      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        final Map<String, dynamic> data = jsonDecode(response.body);
        final message = data['message']?.toString() ?? "Interview submitted successfully!";

        EasyLoading.showSuccess(message);
        
        // Parse the correct answers from the response
        final List<dynamic> resultAnswers = data['answers'] ?? [];
        for (var ans in resultAnswers) {
          final String qId = ans['questionId']?.toString() ?? '';
          final int correctOpt = ans['question']?['correctOption'] ?? -1;
          final String? reason = ans['question']?['reason']?.toString();
          
          final int qIndex = questions.indexWhere((q) => q.id == qId);
          if (qIndex != -1) {
            final oldQ = questions[qIndex];
            questions[qIndex] = MockQuestion(
              id: oldQ.id,
              question: oldQ.question,
              options: oldQ.options,
              correctAnswerIndex: correctOpt,
              reason: reason,
            );
          }
        }
        
        int correct = data['score'] ?? 0;
        int answeredCount = userAnswers.where((ans) => ans != -1).length;
        int wrong = answeredCount - correct;
        
        final result = MockResult(
          totalQuestions: data['totalQuestions'] ?? questions.length,
          correctAnswers: correct,
          wrongAnswers: wrong,
          duration: duration,
          questions: questions,
          userAnswers: userAnswers,
          topicId: topicId,
          categoryTitle: categoryTitle,
        );
        
        isSubmitting.value = false;
        Get.off(() => const MockStatisticsPage(), arguments: result);
        
      } else {
        final Map<String, dynamic>? data = jsonDecode(response.body);
        final message = data?['message']?.toString() ?? "Failed to submit.";
        EasyLoading.showError(message);
        isSubmitting.value = false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      BartaLog.error('submitQuiz error', error: e);
      EasyLoading.showError("An error occurred while submitting.");
      isSubmitting.value = false;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remaining.value > 0) {
        remaining.value--;
        _updateRemainingTime();
      } else {
        timer.cancel();
        finishQuiz(); // auto-submit on timeout
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
    _timer?.cancel();
    super.onClose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../model/question_bank_model.dart';
import '../service/question_bank_service.dart';

class QbankController extends GetxController {
  var questionBanks = <QuestionBankItem>[].obs;
  var filteredQuestionBanks = <QuestionBankItem>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var itemDetails = Rxn<QuestionBankItem>();
  var isDetailsLoading = false.obs;
  var detailsErrorMessage = ''.obs;

  var practiceQuestions = <PracticeQuestion>[].obs;
  var isPracticeLoading = false.obs;
  var practiceErrorMessage = ''.obs;

  var selectedOptionIds = <String, String?>{}.obs;
  var revealed = <String, bool>{}.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchQuestionBanks();
    debounce(
      searchQuery,
      (_) => _applySearch(),
      time: const Duration(milliseconds: 300),
    );
  }

  // ── API ─────────────────────────────────────────────────────────────────────
  Future<void> fetchQuestionBanks() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await QuestionBankService.getQuestionBanks();
      questionBanks.assignAll(data);
      filteredQuestionBanks.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('Error fetching question bank: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchQuestionBankById(String id) async {
    try {
      isDetailsLoading.value = true;
      detailsErrorMessage.value = '';
      itemDetails.value = null;

      final data = await QuestionBankService.getQuestionBankById(id);
      itemDetails.value = data;
    } catch (e) {
      detailsErrorMessage.value = e.toString();
      debugPrint('Error fetching question bank details ($id): $e');
    } finally {
      isDetailsLoading.value = false;
    }
  }

  Future<void> fetchPracticeQuestions(String qbankId) async {
    try {
      isPracticeLoading.value = true;
      practiceErrorMessage.value = '';
      practiceQuestions.clear();
      resetPractice();

      final data = await QuestionBankService.getPracticeQuestions(qbankId);
      practiceQuestions.assignAll(data);
    } catch (e) {
      practiceErrorMessage.value = e.toString();
      debugPrint('Error fetching practice questions ($qbankId): $e');
    } finally {
      isPracticeLoading.value = false;
    }
  }

  void selectOption(String questionId, String optionId) {
    selectedOptionIds[questionId] = optionId;
  }

  void revealAnswer(String questionId) {
    revealed[questionId] = true;
  }

  void resetPractice() {
    selectedOptionIds.clear();
    revealed.clear();
  }

  void restartPractice() {
    selectedOptionIds.clear();
    revealed.clear();
    practiceQuestions.shuffle();
    practiceQuestions.refresh();
  }

  Future<void> fetchPracticeQuestionById(String questionId) async {
    try {
      final updated = await QuestionBankService.getPracticeQuestionById(
        questionId,
      );
      final idx = practiceQuestions.indexWhere((q) => q.id == questionId);
      if (idx != -1) {
        practiceQuestions[idx] = updated;
        practiceQuestions.refresh();
      }
    } catch (e) {
      debugPrint('Error fetching practice question ($questionId): $e');
    }
  }

  Future<PracticeSubmissionResponse?> submitPractice(String qbankId) async {
    if (selectedOptionIds.isEmpty) {
      EasyLoading.showError('Please answer at least one question.');
      return null;
    }

    try {
      EasyLoading.show(status: 'Submitting...');
      final answers = selectedOptionIds.entries
          .where((e) => e.value != null)
          .map((e) => {
                "questionId": e.key,
                "selectedOptionId": e.value!,
              })
          .toList();

      final response = await QuestionBankService.submitPracticeQuestions(
        qbankId,
        answers,
      );

      // Update practice questions with correct answers from result
      for (var result in response.results) {
        final idx = practiceQuestions.indexWhere((q) => q.id == result.questionId);
        if (idx != -1) {
          final old = practiceQuestions[idx];
          // Since models are final, create a new one with correctOptionId
          final updated = PracticeQuestion(
            id: old.id,
            questionText: old.questionText,
            imageUrl: old.imageUrl,
            explanation: old.explanation,
            order: old.order,
            options: old.options.map((opt) {
               return PracticeOption(
                 id: opt.id,
                 text: opt.text,
                 order: opt.order,
                 isCorrect: opt.id == result.correctOptionId,
               );
            }).toList(),
            correctOptionId: result.correctOptionId,
          );
          practiceQuestions[idx] = updated;
          revealed[result.questionId] = true;
        }
      }
      practiceQuestions.refresh();
      
      EasyLoading.dismiss();
      return response;
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(e.toString());
      debugPrint('Error submitting practice questions: $e');
      return null;
    }
  }

  void _applySearch() {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      filteredQuestionBanks.assignAll(questionBanks);
      return;
    }
    filteredQuestionBanks.assignAll(
      questionBanks.where((item) {
        return item.subjectName.toLowerCase().contains(query) ||
            item.semester.toLowerCase().contains(query) ||
            item.universityName.toLowerCase().contains(query) ||
            item.programName.toLowerCase().contains(query) ||
            item.departmentName.toLowerCase().contains(query) ||
            item.examType.toLowerCase().contains(query);
      }).toList(),
    );
  }
}

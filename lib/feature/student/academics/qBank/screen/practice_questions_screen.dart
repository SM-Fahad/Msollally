import 'dart:async';
import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../controller/question_bank_controller.dart';
import '../model/question_bank_model.dart';
import 'practice_result_screen.dart';
import '../widgets/practice_progress_bar.dart';
import '../widgets/practice_question_list.dart';
import '../widgets/practice_error_view.dart';
import '../widgets/practice_submit_button.dart';

class PracticeQuestionsScreen extends StatefulWidget {
  final QuestionBankItem qbankItem;

  const PracticeQuestionsScreen({super.key, required this.qbankItem});

  @override
  State<PracticeQuestionsScreen> createState() => _PracticeQuestionsScreenState();
}

class _PracticeQuestionsScreenState extends State<PracticeQuestionsScreen> {
  late final QbankController controller;
  Timer? _timer;
  int _secondsRemaining = 1200; // 20 minutes countdown
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<QbankController>();
    // Always fetch fresh questions and reset state when entering the practice screen
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchPracticeQuestions(widget.qbankItem.id);
      final qCount = controller.practiceQuestions.length;
      final allocatedSeconds = qCount > 0 ? (qCount * 90) : 600;
      if (mounted) {
        setState(() {
          _secondsRemaining = allocatedSeconds;
        });
      }
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        _timer?.cancel();
        _onTimeExpired();
      }
    });
  }

  void _restartPractice() {
    _timer?.cancel();
    final qCount = controller.practiceQuestions.length;
    final allocatedSeconds = qCount > 0 ? (qCount * 90) : 600;
    setState(() {
      _secondsRemaining = allocatedSeconds;
      _isSubmitted = false;
    });
    controller.restartPractice();
    _startTimer();
    final min = (allocatedSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (allocatedSeconds % 60).toString().padLeft(2, '0');
    Get.snackbar(
      "Practice Restarted",
      "Timer reset to $min:$sec ($qCount questions).",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.indigo.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showRestartDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Restart Practice?"),
        content: const Text(
          "This will reset your 20-minute timer, clear all selections, and reshuffle the questions.",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Get.back();
              _restartPractice();
            },
            child: const Text("Restart"),
          ),
        ],
      ),
    );
  }

  Future<void> _onTimeExpired() async {
    if (!mounted || _isSubmitted) return;
    _isSubmitted = true;
    Get.snackbar(
      "Time's Up!",
      "The 20-minute practice time has expired. Submitting your answers...",
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
    await _submitExam();
  }

  Future<void> _submitExam() async {
    _timer?.cancel();
    final response = await controller.submitPractice(widget.qbankItem.id);
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
      onRestart: _restartPractice,
    ));
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildTimerBadge() {
    final isUnderTwoMinutes = _secondsRemaining <= 120;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isUnderTwoMinutes ? Colors.red.shade50 : Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnderTwoMinutes ? Colors.red.shade400 : Colors.indigo.shade200,
          width: isUnderTwoMinutes ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUnderTwoMinutes ? Icons.warning_amber_rounded : Icons.timer_outlined,
            size: 16,
            color: isUnderTwoMinutes ? Colors.red.shade700 : Colors.indigo.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            _formattedTime,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: isUnderTwoMinutes ? Colors.red.shade700 : Colors.indigo.shade700,
            ),
          ),
        ],
      ),
    );
  }

  int _getAnsweredCount() =>
      controller.selectedOptionIds.values.where((v) => v != null).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.aliceBlueF4F6FB,
      appBar: AppBar(
        title: Text(
          widget.qbankItem.subjectName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
        actions: [
          Center(child: _buildTimerBadge()),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Restart Practice",
            onPressed: _showRestartDialog,
          ),
          Obx(() {
            final total = controller.practiceQuestions.length;
            if (total == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  "${_getAnsweredCount()}/$total",
                  style: getTextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isPracticeLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.practiceErrorMessage.value.isNotEmpty &&
            controller.practiceQuestions.isEmpty) {
          return PracticeErrorView(
            message: controller.practiceErrorMessage.value,
            onRetry: () => controller.fetchPracticeQuestions(widget.qbankItem.id),
          );
        }

        if (controller.practiceQuestions.isEmpty) {
          return Center(
            child: Text(
              "No practice questions available.",
              style: getTextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        final questions = controller.practiceQuestions;
        final answered = _getAnsweredCount();

        return Column(
          children: [
            PracticeProgressBar(answered: answered, total: questions.length),
            Expanded(
              child: PracticeQuestionList(
                questions: questions,
                controller: controller,
                qbankItemId: widget.qbankItem.id,
              ),
            ),
            PracticeSubmitButton(
              qbankItemId: widget.qbankItem.id,
              questions: questions,
              controller: controller,
              onRestart: _restartPractice,
            ),
          ],
        );
      }),
    );
  }
}

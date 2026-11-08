import 'package:flutter/material.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';

class FinalQuizDialog extends StatelessWidget {
  const FinalQuizDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentCampusController>();
    final comp = controller.competitionsList.isNotEmpty
        ? controller.competitionsList.first
        : null;

    final questionsCount = comp?.finalQuizQuestionsCount ?? 50;
    final timeLimit = comp?.finalQuizTimeLimit ?? 45;
    final topLimit = comp?.qualificationTopLimit ?? 1000;
    final prizesList = comp?.prizes ?? [];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 650),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInfoBox(
                      questionsCount,
                      timeLimit,
                      topLimit,
                      prizesList.length,
                    ),
                    const SizedBox(height: 20),
                    _buildPrizeStructure(prizesList),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildFooterButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.emoji_events_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Final Quiz",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Final Stage of the Competition",
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildInfoBox(
    int questions,
    int timeLimit,
    int topLimit,
    int prizeCount,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.stars_outlined,
                color: Color(0xFFD97706),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                "Finals Information",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoItem(
            Icons.help_outline,
            "Questions",
            "$questions Comprehensive",
          ),
          _infoItem(Icons.timer_outlined, "Time Limit", "$timeLimit minutes"),
          _infoItem(Icons.speed_outlined, "Scoring", "Accuracy + Speed"),
          _infoItem(
            Icons.groups_outlined,
            "Participants",
            "Top $topLimit qualifiers",
          ),
          _infoItem(
            Icons.card_giftcard_outlined,
            "Prizes",
            prizeCount > 0
                ? "Top $prizeCount win cash & gifts"
                : "Exciting prizes to win!",
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFB45309)),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Color(0xFF78350F)),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeStructure(List<dynamic> prizesList) {
    if (prizesList.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Prize Structure",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          ...prizesList.asMap().entries.map((entry) {
            final index = entry.key;
            final prizeData = entry.value;
            String emoji = "🏅";
            if (index == 0) emoji = "🥇";
            if (index == 1) emoji = "🥈";
            if (index == 2) emoji = "🥉";

            final title = prizeData['title'] ?? 'Prize';
            final amount = prizeData['amount'] ?? '';

            return _prizeRow(emoji, title, amount);
          }),
        ],
      ),
    );
  }

  Widget _prizeRow(String emoji, String rank, String prize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rank,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            prize,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              EasyLoading.show(status: 'Loading questions...');
              try {
                final controller = Get.find<StudentCampusController>();
                final compId = controller.competitionsList.isNotEmpty
                    ? controller.competitionsList.first.id
                    : 2;
                await controller.loadQuizQuestions(
                  competitionId: compId,
                  quizType: 'WEEKLY_FINAL',
                  weekNumber: 1,
                );
                EasyLoading.dismiss();
                if (controller.quizQuestions.isEmpty) {
                  EasyLoading.showError(
                    'No questions available for this competition yet.',
                  );
                  return;
                }
                Get.back();
                Get.toNamed(AppRoute.qualificationQuizScreen);
              } catch (e) {
                EasyLoading.dismiss();
                EasyLoading.showError('Failed to load quiz questions');
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFFD97706),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Begin Final",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

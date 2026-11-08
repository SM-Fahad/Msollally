import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';

class QuizProgressHeader extends StatelessWidget {
  const QuizProgressHeader({
    super.key,
    required this.controller,
    required this.totalQuestions,
    required this.progress,
  });

  final StudentCampusController controller;
  final int totalQuestions;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentQuestion = controller.quizCurrentQuestion.value;
      final timeRemaining = controller.quizTimeRemaining.value;
      final answeredCount = controller.quizAnsweredCount.value;

      return Container(
        width: double.infinity,
        color: AppColors.seaShellFFF7ED,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statusChip("Q ${currentQuestion + 1}/$totalQuestions"),
                Row(
                  children: [
                    _liveChip(),
                    const SizedBox(width: 8),
                    _timerChip(controller.formatTime(timeRemaining)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey.shade300,
                color: AppColors.royalBlue2F69FF,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$answeredCount answered",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  "${totalQuestions - answeredCount} remaining",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _statusChip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    ),
  );

  void _openCamera() async {
    final picker = ImagePicker();
    await picker.pickVideo(source: ImageSource.camera);
  }

  Widget _liveChip() => GestureDetector(
    onTap: _openCamera,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.videocam, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            "Live",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _timerChip(String time) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.royalBlue2F69FF,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
        const SizedBox(width: 4),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class PracticeResultScreen extends StatelessWidget {
  final int correct;
  final int incorrect;
  final int skipped;
  final int total;
  final VoidCallback? onRestart;

  const PracticeResultScreen({
    super.key,
    required this.correct,
    required this.incorrect,
    required this.skipped,
    required this.total,
    this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total == 0 ? 0 : ((correct / total) * 100).round();
    
    return Scaffold(
      backgroundColor: AppColors.aliceBlueF4F6FB,
      appBar: AppBar(
        title: const Text("Exam Result"),
        centerTitle: true,
        automaticallyImplyLeading: false, // Force them to use actions
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkSlateBlue3F51B5.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ]
                ),
                child: Column(
                  children: [
                    Text(
                      "$percentage%",
                      style: getTextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: percentage >= 50 ? Colors.green : Colors.redAccent,
                      ),
                    ),
                    Text(
                      "Score",
                      style: getTextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Marks Attained & Rating Rate Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      "Marks Attained: $correct / $total",
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(5, (index) {
                          final starThreshold = (index + 1) * 20;
                          final isFilled = percentage >= starThreshold;
                          final isHalf = !isFilled && percentage >= (starThreshold - 10);
                          return Icon(
                            isFilled
                                ? Icons.star_rounded
                                : (isHalf ? Icons.star_half_rounded : Icons.star_outline_rounded),
                            color: Colors.amber,
                            size: 22,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          percentage >= 85
                              ? "Grade A+ (Excellent)"
                              : percentage >= 70
                                  ? "Grade A (Great)"
                                  : percentage >= 50
                                      ? "Grade B (Pass)"
                                      : "Needs Review",
                          style: getTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: percentage >= 50 ? Colors.green.shade700 : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                percentage >= 80 
                  ? "Excellent Work!" 
                  : percentage >= 50 
                    ? "Good Job!" 
                    : "Keep Practicing!",
                style: getTextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You have completed the practice exam.",
                style: getTextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                child: Column(
                  children: [
                    _buildStatRow("Correct Answers", correct, Colors.green),
                    const Divider(height: 24),
                    _buildStatRow("Incorrect Answers", incorrect, Colors.redAccent),
                    const Divider(height: 24),
                    _buildStatRow("Skipped / Unattended", skipped, Colors.orange),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(
                    "Restart Practice",
                    style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Get.back(); // Pop result screen back to practice screen
                    if (onRestart != null) {
                      onRestart!();
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkSlateBlue3F51B5,
                    side: const BorderSide(color: AppColors.darkSlateBlue3F51B5, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Pop only the result screen to review answers on the practice screen
                    Get.back();
                  },
                  child: Text(
                    "Review Answers",
                    style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    // Close results and go back to QBank detail
                    Get.back(); // Pop result screen
                    Get.back(); // Pop practice questions screen
                  },
                  child: Text(
                    "Back to Question Bank",
                    style: getTextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12),
            Text(
              label,
              style: getTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Text(
          value.toString(),
          style: getTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

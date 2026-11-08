import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../controller/my_career_controller.dart';

/// Circular progress card showing career preparation percentage.
class CareerPrepCard extends StatelessWidget {
  final CareerController controller;

  const CareerPrepCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Circular progress indicator
            SizedBox(
              width: 70,
              height: 70,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: controller.progress.value / 100,
                    strokeWidth: 20,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple,
                    ),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  Center(
                    child: Text(
                      '${controller.progress.value}%',
                      style: getTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Career Prep',
                    style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Text(
                    'You are ${controller.progress.value}% prepared for your job search!',
                    style: getTextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on your profile completeness and interview practice.',
                    style: getTextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/furza_zone/student_quiz_competition/controller/student_quiz_competition_controller.dart';

class DetailsTab extends StatelessWidget {
  const DetailsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentQuizCompetitionController>();
    return Obx(() {
      final comp = controller.competition.value;
      return Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (comp?.promoImageLink != null &&
                  comp!.promoImageLink!.isNotEmpty)
                Image.network(
                  comp.promoImageLink!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 24),
              if (comp?.competitionGuidelines != null) ...[
                Text(
                  "Guidelines",
                  style: getTextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  comp!.competitionGuidelines!,
                  style: getTextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (comp?.requirements != null &&
                  comp!.requirements!.isNotEmpty) ...[
                Text(
                  "Requirements",
                  style: getTextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...comp.requirements!.map(
                  (req) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "• Eligibility: ${req['eligibility'] ?? ''}",
                        style: getTextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (req['prerequisites'] != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            "Prerequisites: ${(req['prerequisites'] as List).join(', ')}",
                            style: getTextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (comp?.promoVideoLink != null ||
                  comp?.partnerInfoFileLink != null ||
                  comp?.knowledgeBaseFileLink != null) ...[
                Text(
                  "Resources",
                  style: getTextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (comp?.promoVideoLink != null)
                  _buildResourceLink(
                    "Promo Video",
                    Icons.video_library_outlined,
                  ),
                if (comp?.partnerInfoFileLink != null)
                  _buildResourceLink("Partner Info", Icons.info_outline),
                if (comp?.knowledgeBaseFileLink != null)
                  _buildResourceLink(
                    "Knowledge Base",
                    Icons.menu_book_outlined,
                  ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildResourceLink(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryButtonColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: getTextStyle(fontSize: 14, color: AppColors.primaryButtonColor),
          ),
        ],
      ),
    );
  }
}

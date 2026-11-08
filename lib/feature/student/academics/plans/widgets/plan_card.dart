import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:get/get.dart';
import '../screen/plan_details_screen.dart';

class PlanCard extends StatelessWidget {
  final dynamic plan;

  const PlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final rawProgress = plan.raw['progress'] ?? 0;
    final progress = (rawProgress is num) ? rawProgress.toInt() : 0;
    final status = plan.status.isNotEmpty ? plan.status : "In Progress";

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: plan.hasDetailId
          ? () => Get.to(() => StudentPlanDetailsScreen(
                planId: plan.id,
                initialPlan: plan,
              ))
          : null,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.title,
              style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text(
              status,
              style: getTextStyle(fontSize: 12, color: AppColors.royalBlue3B82F6),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey.shade100,
                    color: AppColors.royalBlue3B82F6,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "$progress%",
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.royalBlue3B82F6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

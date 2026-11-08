import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:get/get.dart';
import '../controller/student_plans_controller.dart';
import '../widgets/plan_header_card.dart';
import '../widgets/plan_task_card.dart';
import '../widgets/plans_state_message.dart';

import '../model/student_plan_model.dart';

class StudentPlanDetailsScreen extends StatelessWidget {
  final String planId;
  final StudentPlanModel? initialPlan;

  const StudentPlanDetailsScreen({
    super.key,
    required this.planId,
    this.initialPlan,
  });

  @override
  Widget build(BuildContext context) {
    final String tag = 'plan-details-$planId';
    final controller = Get.isRegistered<StudentPlanDetailsController>(tag: tag)
        ? Get.find<StudentPlanDetailsController>(tag: tag)
        : Get.put(
            StudentPlanDetailsController(
              planId: planId,
              initialPlan: initialPlan,
            ),
            tag: tag,
          );

    return Scaffold(
      appBar: AppBar(title: Text('Plan Details')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return PlansStateMessage(
            message: controller.errorMessage.value,
            actionLabel: 'Retry',
            onPressed: controller.fetchPlanDetails,
          );
        }
        final plan = controller.plan.value;
        if (plan == null) {
          return PlansStateMessage(
            message: 'Plan details are not available.',
            actionLabel: 'Retry',
            onPressed: controller.fetchPlanDetails,
          );
        }

        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            PlanHeaderCard(plan: plan),
            SizedBox(height: 20),
            if (plan.tasks.isEmpty)
              _buildEmptyDescription(plan.description)
            else ...[
              Text(
                'Plan Items',
                style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              ...plan.tasks.map((task) => PlanTaskCard(task: task)),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildEmptyDescription(String desc) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          Text(
            desc.isEmpty ? 'No description available.' : desc,
            style: getTextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

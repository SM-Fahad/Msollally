import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/academics/create_plan/screen/create_plan.dart';
import '../controller/student_plans_controller.dart';
import '../widgets/plan_card.dart';
import '../widgets/plans_state_message.dart';

class StudentPlanScreen extends StatelessWidget {
  const StudentPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<StudentPlansController>()
        ? Get.find<StudentPlansController>()
        : Get.put(StudentPlansController());

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return PlansStateMessage(
                  message: controller.errorMessage.value,
                  actionLabel: 'Retry',
                  onPressed: controller.fetchPlans,
                );
              }
              if (controller.plans.isEmpty) {
                return PlansStateMessage(
                  message: 'No plans found yet.',
                  actionLabel: 'Refresh',
                  onPressed: controller.fetchPlans,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchPlans,
                child: ListView.separated(
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: controller.plans.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      PlanCard(plan: controller.plans[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/icons/ai_icon2.png',
              height: 44,
              width: 44,
              color: Colors.deepPurpleAccent,
            ),
            SizedBox(width: 8),
            Text(
              'AI Study Planner',
              style: getTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => Get.to(() => CreatePlanScreen()),
          icon: Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          label: Text(
            "Create Plan",
            style: getTextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mediumPurple8B5CF6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }
}

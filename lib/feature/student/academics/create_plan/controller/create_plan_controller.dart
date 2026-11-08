import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/academics/create_plan/screen/plan_details.dart';
import '../../../../../core/services/share_preferrance_helper.dart';
import '../service/create_plan_service.dart';

class CreatePlanController extends GetxController {
  final planTypeController = TextEditingController();
  final subjectController = TextEditingController();
  final deadlineController = TextEditingController();
  final instructionsController = TextEditingController();

  final difficulty = 3.obs;

  final CreatePlanService _service = CreatePlanService();

  Future<void> createPlan() async {
    final userId = await SharedPreferenceHelper().getUserId();

    final data = {
      "user_id": userId ?? "unknown",
      "subject": subjectController.text.trim(),
      "module": subjectController.text.trim(),
      "plan_type": planTypeController.text.trim(),
      "deadline": deadlineController.text.trim().isEmpty
          ? DateTime.now().toIso8601String()
          : deadlineController.text.trim(),
      "difficulty": difficulty.value,
      "instructions": instructionsController.text.trim(),
    };

    final success = await _service.createAiPlan(data);
    if (success) {
      final sub = subjectController.text.trim().isNotEmpty
          ? subjectController.text.trim()
          : "Custom Plan";
      Get.off(() => PlanScreen(subject: sub, courseName: sub));
    }
  }

  @override
  void onClose() {
    planTypeController.dispose();
    subjectController.dispose();
    deadlineController.dispose();
    instructionsController.dispose();
    super.onClose();
  }
}

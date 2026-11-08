import 'package:get/get.dart';

import '../model/student_plan_model.dart';
import '../service/student_plan_service.dart';

class StudentPlansController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final plans = <StudentPlanModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  Future<void> fetchPlans({String? id}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      plans.value = await StudentPlanService.getAllPlans(id: id);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}

class StudentPlanDetailsController extends GetxController {
  StudentPlanDetailsController({required this.planId, this.initialPlan});

  final String planId;
  final StudentPlanModel? initialPlan;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final plan = Rxn<StudentPlanDetailsModel>();

  @override
  void onInit() {
    super.onInit();
    if (initialPlan != null) {
      plan.value = StudentPlanDetailsModel.fromMap(initialPlan!.raw);
    } else if (Get.isRegistered<StudentPlansController>()) {
      final listCtrl = Get.find<StudentPlansController>();
      final match = listCtrl.plans.firstWhereOrNull((p) => p.id == planId);
      if (match != null) {
        plan.value = StudentPlanDetailsModel.fromMap(match.raw);
      }
    }
    fetchPlanDetails();
  }

  Future<void> fetchPlanDetails() async {
    try {
      if (plan.value == null) {
        isLoading.value = true;
      }
      errorMessage.value = '';
      plan.value = await StudentPlanService.getPlanById(planId);
    } catch (e) {
      if (plan.value == null) {
        errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      isLoading.value = false;
    }
  }
}

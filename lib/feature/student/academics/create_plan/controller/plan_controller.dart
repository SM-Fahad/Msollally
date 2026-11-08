import 'package:get/get.dart';
import '../model/plan_model.dart';

class PlanController extends GetxController {
  var plans = <PlanModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPlans();
  }

  void loadPlans() {
    plans.value = [];
  }

  void updateDate(int index, String newDate) {
    plans[index] = PlanModel(
      date: newDate,
      time: plans[index].time,
      task: plans[index].task,
    );
  }

  void updateTime(int index, String newTime) {
    plans[index] = PlanModel(
      date: plans[index].date,
      time: newTime,
      task: plans[index].task,
    );
  }
}

class PlanSessionController extends GetxController {
  var sessions = <PlanSession>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSessions();
  }

  void loadSessions() {
    sessions.value = [];
  }

  void markCompleted(int index) {
    sessions[index] = PlanSession(
      date: sessions[index].date,
      time: sessions[index].time,
      title: sessions[index].title,
      task: sessions[index].task,
      status: "completed",
      progress: 100,
      timer: "00:00",
    );
  }
}

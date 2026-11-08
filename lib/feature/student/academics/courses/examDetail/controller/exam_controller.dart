// exam_controller.dart
import 'package:get/get.dart';

import '../../module/model/module_model.dart';

class ExamController extends GetxController {
  var exams = <ExamModel>[].obs;

  String daysRemaining(ExamModel exam) {
    final remaining = exam.examDate.difference(DateTime.now()).inDays;
    return "$remaining days remaining";
  }
}

import 'package:get/get.dart';

class TodaysQuickPicksModel {
  final String title;
  final RxBool isChecked;
  final int? taskId;

  TodaysQuickPicksModel({
    required this.title,
    bool initialChecked = false,
    this.taskId,
  }) : isChecked = RxBool(initialChecked);
}

import 'package:flutter/widgets.dart';
import 'package:msollaally/core/const/appcolors.dart';

class ScheduleActivityModel {
  final String title;
  final int students;
  final String nextClass;
  final String nextExam;
  final Color color;

  ScheduleActivityModel({
    required this.title,
    required this.students,
    required this.nextClass,
    required this.nextExam,
    this.color = AppColors.ghostWhiteF5F5FF,
  });
}

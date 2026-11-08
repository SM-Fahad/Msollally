import 'dart:ui';

class UpcommingReminderModel {
  final String title;
  final String icon;
  final int day;
  final Color containercolor;
  final Color containerBorderborderColor;

  UpcommingReminderModel({
    required this.icon,
    required this.title,
    required this.day,
    required this.containercolor,
    required this.containerBorderborderColor,
  });
}

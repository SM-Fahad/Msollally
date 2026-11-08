import 'package:flutter/widgets.dart';

class StudentEmergencyItemTabModel {
  final String title;
  final Icon icon;
  final VoidCallback onTap;
  final Color color;
  StudentEmergencyItemTabModel({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.color,
  });
}

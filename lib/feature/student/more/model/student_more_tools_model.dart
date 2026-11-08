import 'package:flutter/material.dart';

class StudentMoreToolsModel {
  final Widget icon;
  final String title;
  final VoidCallback ontap;

  StudentMoreToolsModel({
    required this.icon,
    required this.title,
    required this.ontap,
  });
}

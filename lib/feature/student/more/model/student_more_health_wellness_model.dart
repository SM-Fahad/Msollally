//student more health and wellness model

import 'package:flutter/material.dart';

class StudentMoreHealthWellnessModel {
  final String title;
  final String subTitle;
  final String buttonText;
  final Color bgColor;
  final Color borderColor;
  final VoidCallback ontap;

  StudentMoreHealthWellnessModel({
    required this.title,
    required this.subTitle,
    required this.buttonText,
    required this.bgColor,
    required this.borderColor,
    required this.ontap,
  });
}

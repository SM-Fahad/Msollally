import 'package:flutter/material.dart';

class StudentPublicProfileAboutModel {
  final String title;
  final String titleValue;
  final VoidCallback? ontap;
  StudentPublicProfileAboutModel({
    required this.title,
    required this.titleValue,
    this.ontap,
  });
}

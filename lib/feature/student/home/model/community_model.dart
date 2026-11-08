import 'package:flutter/material.dart';

class CommunityModel {
  final String icon;
  final String text;
  final int days;
  final VoidCallback ontap;

  CommunityModel({
    required this.ontap,
    required this.icon,
    required this.text,
    required this.days,
  });
}

import 'package:flutter/material.dart';

class ForYouModel {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  ForYouModel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

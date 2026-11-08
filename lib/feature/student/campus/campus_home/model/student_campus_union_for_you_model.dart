import 'package:flutter/animation.dart';

class StudentCampusUnionForYouModel {
  final String imageUrl;
  final String name;
  final String subName;
  final int member;
  final VoidCallback? ontap;

  StudentCampusUnionForYouModel({
    this.ontap,
    required this.imageUrl,
    required this.name,
    required this.subName,
    required this.member,
  });
}

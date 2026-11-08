import 'package:flutter/material.dart';

class CompetitionOverviewItem {
  final String title;
  final String icon;
  final String value;
  final Color color;

  CompetitionOverviewItem({
    required this.title,
    required this.icon,
    required this.value,
    required this.color,
  });
}

// Prize winner model
class PrizeWinner {
  final String rank;
  final String userName;
  final String points;
  final String price;
  final String imagePath;
  final Color gradientStartColor;
  final Color gradientEndColor;
  final Color avatarBackgroundColor;
  final Color borderColor;

  PrizeWinner({
    required this.rank,
    required this.userName,
    required this.points,
    required this.price,
    required this.imagePath,
    required this.gradientStartColor,
    required this.gradientEndColor,
    required this.avatarBackgroundColor,
    required this.borderColor,
  });
}

// University performance model
class UniversityPerformance {
  final String indexText;
  final String title;
  final String subtitle;
  final String badgeText;

  UniversityPerformance({
    required this.indexText,
    required this.title,
    required this.subtitle,
    required this.badgeText,
  });
}

// Student info model
class StudentInfo {
  final String studentName;
  final String studentId;
  final int position;
  final String university;
  final String year;
  final String program;
  final String email;
  final String phone;
  final String region;
  final String district;
  final String ward;
  final String street;
  final String bankAccount;
  final String currency;
  final String registeredDate;

  StudentInfo({
    required this.studentName,
    required this.studentId,
    required this.position,
    required this.university,
    required this.year,
    required this.program,
    required this.email,
    required this.phone,
    required this.region,
    required this.district,
    required this.ward,
    required this.street,
    required this.bankAccount,
    required this.currency,
    required this.registeredDate,
  });
}

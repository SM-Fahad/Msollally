import 'package:flutter/material.dart';

class QuickToolItem {
  final String title;
  final String iconPath;
  final Color iconColor;
  final VoidCallback onTap;

  QuickToolItem({
    required this.title,
    required this.iconPath,
    required this.iconColor,
    required this.onTap,
  });
}

class SummaryCardData {
  final String title;
  final String subtitle;
  final String iconPath;
  final Color iconColor;

  SummaryCardData({
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.iconColor,
  });
}

class ApplicantData {
  final int applicationId;
  final String name;
  final String appliedTo;
  final String date;
  final String avatarUrl;
  final String resumeUrl;
  final Color nameColor;
  final Color backgroundColor;
  final Color borderColor;

  ApplicantData({
    required this.applicationId,
    required this.name,
    required this.appliedTo,
    required this.date,
    required this.avatarUrl,
    required this.resumeUrl,
    required this.nameColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}

class JobData {
  final int? id;
  final String title;
  final String status;
  final String level;
  final String experience;
  final String deadline;
  final String postDate;
  final String imageUrl;

  JobData({
    required this.id,
    required this.title,
    required this.status,
    required this.level,
    required this.experience,
    required this.deadline,
    required this.postDate,
    required this.imageUrl,
  });

  /// Factory constructor to convert from JobModel
  factory JobData.fromJobModel(dynamic jobModel) {
    return JobData(
      id: jobModel.id is int
          ? jobModel.id as int
          : int.tryParse(jobModel.id?.toString() ?? ''),
      title: jobModel.title ?? '',
      status: jobModel.status ?? '',
      level: jobModel.experienceLevel ?? '',
      experience:
          '${jobModel.minimumExperience ?? 0}-${jobModel.maximumExperience ?? 0} Years',
      deadline: jobModel.applicationDeadline ?? '',
      postDate: jobModel.publishedAt ?? jobModel.createdAt ?? '',
      imageUrl: jobModel.companyLogo ?? '',
    );
  }
}

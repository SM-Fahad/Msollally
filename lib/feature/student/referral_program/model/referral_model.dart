import 'package:flutter/material.dart';

class ReferralModel {
  final int referralCount;
  final double earnedAmount;
  final String currentStatus;
  final int currentTierReferrals;
  final int nextTierReferrals;
  final List<MilestoneModel> milestones;
  final String referralCode;
  final String referalLink;

  ReferralModel({
    required this.referralCount,
    required this.earnedAmount,
    required this.currentStatus,
    required this.currentTierReferrals,
    required this.nextTierReferrals,
    required this.milestones,
    required this.referralCode,
    required this.referalLink,
  });

  double get progressPercentage => nextTierReferrals == 0 ? 1.0 : currentTierReferrals / nextTierReferrals;
}

class MilestoneModel {
  final String title;
  final int requiredReferrals;
  final String description;
  final MilestoneStatus status;
  final IconData icon;
  final Color color;
  final String levelKey;

  MilestoneModel({
    required this.title,
    required this.requiredReferrals,
    required this.description,
    required this.status,
    required this.icon,
    required this.color,
    required this.levelKey,
  });

  MilestoneModel copyWith({
    String? title,
    int? requiredReferrals,
    String? description,
    MilestoneStatus? status,
    IconData? icon,
    Color? color,
    String? levelKey,
  }) {
    return MilestoneModel(
      title: title ?? this.title,
      requiredReferrals: requiredReferrals ?? this.requiredReferrals,
      description: description ?? this.description,
      status: status ?? this.status,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      levelKey: levelKey ?? this.levelKey,
    );
  }
}

enum MilestoneStatus { unlocked, pending, approved, locked }

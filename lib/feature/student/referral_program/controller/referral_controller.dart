import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/referral_program/model/referral_model.dart';
import 'package:msollaally/feature/student/referral_program/service/referral_service.dart';
import 'package:share_plus/share_plus.dart';

class ReferralController extends GetxController {
  final isLoading = true.obs;
  final _referralData = Rxn<ReferralModel>();
  ReferralModel? get referralData => _referralData.value;

  @override
  void onInit() {
    super.onInit();
    fetchReferralData();
  }

  Future<void> fetchReferralData() async {
    try {
      isLoading.value = true;
      final authMeFuture = ReferralService.getUserAuthMe();
      final statsFuture = ReferralService.getUserStats();
      final roleFuture = ReferralService.getReferRole();

      final results = await Future.wait([authMeFuture, statsFuture, roleFuture]);
      final authMe = results[0];
      final stats = results[1];
      final role = results[2];

      // Parse AuthMe
      final referCode = authMe['refer_code']?.toString() ?? '';
      var referLink = authMe['referal_link']?.toString() ?? '';
      if (referLink.contains('undefined/')) {
        referLink = referLink.replaceAll('undefined/', 'https://nodmac.com/');
      }
      var statusLevel = authMe['profile']?['referal_status_level']?.toString() ?? 'standard';
      if (statusLevel.isEmpty) statusLevel = 'standard';

      // Parse Stats
      final totalReferral = (stats['totalReferral'] as num?)?.toInt() ?? 0;
      final totalEarning = (stats['totalEarning']?['totalEarning'] as num?)?.toDouble() ?? 0.0;

      // Parse Role Data
      final roleData = role['data'] ?? {};
      final ambassadorReq = (roleData['ambassador'] as num?)?.toInt() ?? 50;
      final eliteReq = (roleData['elite'] as num?)?.toInt() ?? 20;

      // Prepare Milestones
      List<MilestoneModel> milestones = [];
      
      // Elite Milestone
      MilestoneStatus eliteStatus = MilestoneStatus.locked;
      if (statusLevel.toLowerCase() == 'elite') {
         eliteStatus = MilestoneStatus.approved;
      } else if (totalReferral >= eliteReq) {
         eliteStatus = MilestoneStatus.unlocked;
      }
      
      milestones.add(MilestoneModel(
        title: 'Elite Member ($eliteReq Referrals)',
        requiredReferrals: eliteReq,
        description: 'Get Premium Subscription FREE For 1 Year.',
        status: eliteStatus,
        icon: Icons.emoji_events,
        color: Colors.amber,
        levelKey: 'elite',
      ));

      // Ambassador Milestone
      MilestoneStatus ambassadorStatus = MilestoneStatus.locked;
      if (statusLevel.toLowerCase() == 'ambassador') {
         ambassadorStatus = MilestoneStatus.approved;
      } else if (totalReferral >= ambassadorReq) {
         ambassadorStatus = MilestoneStatus.unlocked;
      }

      milestones.add(MilestoneModel(
        title: 'Campus Ambassador ($ambassadorReq Referrals)',
        requiredReferrals: ambassadorReq,
        description: roleData['commissionStructure']?.toString() ?? 'Earn money + commission from referred students.',
        status: ambassadorStatus,
        icon: Icons.school,
        color: Colors.purple,
        levelKey: 'ambassador',
      ));

      // Sort milestones by requirement
      milestones.sort((a, b) => a.requiredReferrals.compareTo(b.requiredReferrals));

      // Calculate next tier
      int nextTierReq = milestones.isNotEmpty ? milestones.last.requiredReferrals : 0;
      for (var milestone in milestones) {
        if (totalReferral < milestone.requiredReferrals) {
           nextTierReq = milestone.requiredReferrals;
           break;
        }
      }

      final displayStatus = statusLevel[0].toUpperCase() + statusLevel.substring(1).toLowerCase() + ' Member';

      _referralData.value = ReferralModel(
        referralCount: totalReferral,
        earnedAmount: totalEarning,
        currentStatus: displayStatus,
        currentTierReferrals: totalReferral,
        nextTierReferrals: nextTierReq,
        referralCode: referCode,
        referalLink: referLink,
        milestones: milestones,
      );
    } catch (e) {
      EasyLoading.showError('Failed to load referral data');
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyForLevel(String requestedLevel) async {
    try {
      EasyLoading.show(status: 'Applying...');
      final response = await ReferralService.applyForLevel(requestedLevel);
      await EasyLoading.dismiss();
      final msg = response['message']?.toString() ?? 'Application submitted successfully';
      Get.defaultDialog(
        title: 'Success',
        middleText: msg,
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back();
          fetchReferralData();
        }
      );
    } catch (e) {
      await EasyLoading.dismiss();
      Get.defaultDialog(
        title: 'Notice',
        middleText: e.toString().replaceFirst('Exception: ', ''),
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        buttonColor: Colors.red,
        onConfirm: () => Get.back(),
      );
    }
  }

  void copyReferralCode() {
    EasyLoading.showToast(
      '📋  Referral code copied',
      duration: const Duration(seconds: 2),
      toastPosition: EasyLoadingToastPosition.bottom,
    );
  }

  void inviteFriends() {
    final link = _referralData.value?.referalLink ?? 'https://nodmac.com';
    Share.share("Download the app and use my referral code: $link", subject: "Invite Friends");
  }
}

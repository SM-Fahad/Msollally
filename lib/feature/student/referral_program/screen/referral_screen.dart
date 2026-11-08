import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_appbar_back_button.dart';
import 'package:msollaally/feature/student/referral_program/controller/referral_controller.dart';
import 'package:msollaally/feature/student/referral_program/model/referral_model.dart';
import 'package:msollaally/feature/student/referral_program/widgets/current_status_widgets.dart';
import 'package:msollaally/feature/student/referral_program/widgets/milestone_card_widget.dart';
import 'package:msollaally/feature/student/referral_program/widgets/referral_code_widget.dart';
import 'package:msollaally/feature/student/referral_program/widgets/referral_status_card_widget.dart';
import 'package:msollaally/feature/student/referral_program/widgets/referral_payout_dialog.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReferralController());
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: CustomAppbarBackButton(
            text: "Referral Program",
            onPressed: () => Navigator.pop(context),
            iconColor: Colors.black,
            textColor: Colors.black,
            fontSize: 16,
          ),
          leadingWidth: 200,
        ),
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.referralData == null) {
            return Center(
              child: ElevatedButton(
                onPressed: controller.fetchReferralData,
                child: const Text('Retry'),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsRow(context, controller),
                const SizedBox(height: 16),
                CurrentStatusCard(
                  status: controller.referralData!.currentStatus,
                  currentReferrals: controller.referralData!.currentTierReferrals,
                  nextTierReferrals: controller.referralData!.nextTierReferrals,
                  progressPercentage: controller.referralData!.progressPercentage,
                ),
                const SizedBox(height: 24),
                _buildMilestonesSection(controller),
                const SizedBox(height: 24),
                ReferralCodeCard(
                  referralCode: controller.referralData!.referralCode,
                  referralLink: controller.referralData!.referalLink,
                  onCopy: controller.copyReferralCode,
                ),
                const SizedBox(height: 16),
                _buildInviteButton(controller),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, ReferralController controller) {
    final balance = controller.referralData!.earnedAmount;
    final canPayout = balance >= 10000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ReferralStatsCard(
              count: controller.referralData!.referralCount,
              label: 'TOTAL INVITED',
              backgroundColor: Colors.blue[50]!,
              textColor: Colors.blue,
            ),
            const SizedBox(width: 12),
            ReferralStatsCard(
              valueText: '${balance.toStringAsFixed(0)} TZS',
              label: 'WALLET BALANCE',
              backgroundColor: Colors.green[50]!,
              textColor: Colors.green,
            ),
          ],
        ),
        if (canPayout) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
              label: const Text(
                'Request Payout (>= 10,000 TZS)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              onPressed: () => showReferralPayoutSheet(
                context,
                balance,
                controller.fetchReferralData,
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Minimum balance for payout is 10,000 TZS (${(10000 - balance).clamp(0, 10000).toStringAsFixed(0)} TZS remaining)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMilestonesSection(ReferralController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Milestones',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              for (
                int i = 0;
                i < controller.referralData!.milestones.length;
                i++
              ) ...[
                MilestoneCard(
                  milestone: controller.referralData!.milestones[i],
                  onApply: controller.referralData!.milestones[i].status == MilestoneStatus.unlocked
                      ? () => controller.applyForLevel(controller.referralData!.milestones[i].levelKey)
                      : null,
                  isFirst: i == 0,
                  isLast: i == controller.referralData!.milestones.length - 1,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInviteButton(ReferralController controller) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: controller.inviteFriends,
      icon: const Icon(Icons.share),
      label: const Text('Invite Friends'),
    );
  }
}

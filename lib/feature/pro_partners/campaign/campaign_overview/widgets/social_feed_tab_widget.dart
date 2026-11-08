import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/campaign_social_feed_controller.dart';
import 'post_card_widget.dart';

class SocialFeedTabWidget extends StatelessWidget {
  final int campaignId;

  const SocialFeedTabWidget({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    final tag = 'campaign-feed-$campaignId';
    final controller = Get.put(
      CampaignSocialFeedController(campaignId: campaignId),
      tag: tag,
    );

    return Obx(() {
      if (controller.isInitialLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.campaign.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.refreshFeed,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 120.h),
              Center(
                child: Text(
                  'No campaign data found',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshFeed,
        child: ListView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 28.h),
          children: [
            PostCardWidget(tag: tag),
            if (controller.isLoadingMore.value)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      );
    });
  }
}

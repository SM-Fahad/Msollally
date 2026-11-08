import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/more/controller/pro_partners_more_controller.dart';

import '../../../widgets/default_pro_partners_app_bar.dart';
import '../controller/all_campaigns_controller.dart';
import '../../create_campaign/screen/create_campaign_screen.dart';
import '../widgets/campaign_card_widget.dart';

class ProPartnersAllCampaignsScreen extends StatelessWidget {
  ProPartnersAllCampaignsScreen({super.key});

  final ProPartnersMoreController moreController = Get.put(
    ProPartnersMoreController(),
  );

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProPartnersAllCampaignsController());
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Obx(
          () => DefaultProPartnersAppBar(
            title: 'Campaigns',
            profileImageUrl: moreController.profileImageUrl,
            notificationCount: 9,
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campaigns',
                        style: TextStyle(
                          color: AppColors.black09090B,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Manage your advertising campaigns',
                        style: TextStyle(
                          color: AppColors.tertiaryTextColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Get.to<bool>(
                      () => const CreateCampaignScreen(),
                    );
                    if (result == true) {
                      await controller.fetchCampaigns(isRefresh: true);
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Campaign',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButtonColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Obx(() {
                if (controller.isInitialLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.campaigns.isEmpty) {
                  return const Center(child: Text('No campaigns found'));
                }
                return RefreshIndicator(
                  onRefresh: () => controller.fetchCampaigns(isRefresh: true),
                  child: ListView.separated(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount:
                        controller.campaigns.length +
                        (controller.isLoadingMore.value ? 1 : 0),
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      if (index >= controller.campaigns.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return ProPartnersCampaignCardWidget(
                        campaign: controller.campaigns[index],
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

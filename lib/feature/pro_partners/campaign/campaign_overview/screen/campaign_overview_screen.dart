import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import '../../create_campaign/screen/create_campaign_screen.dart';

import '../controller/campaign_notice_controller.dart';
import '../controller/campaign_stats_controller.dart';
import '../widgets/stats_tab_widget.dart';
import '../widgets/social_feed_tab_widget.dart';
import '../widgets/notices_tab_widget.dart';

class CampaignOverviewScreen extends StatelessWidget {
  final String title;
  final int campaignId;

  const CampaignOverviewScreen({
    super.key,
    required this.title,
    required this.campaignId,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(
      CampaignStatsController(campaignId: campaignId),
      tag: 'campaign-stats-$campaignId',
    );
    Get.put(
      CampaignNoticeController(campaignId: campaignId),
      tag: 'campaign-notices-$campaignId',
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.primaryTextColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppColors.primaryTextColor),
              onSelected: (value) async {
                if (value == 'edit') {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => CreateCampaignScreen(campaignId: campaignId),
                    ),
                  );
                  if (result == true) {
                    if (Get.isRegistered<CampaignStatsController>(tag: 'campaign-stats-$campaignId')) {
                      Get.find<CampaignStatsController>(tag: 'campaign-stats-$campaignId').fetchStats();
                    }
                  }
                } else if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogCtx) => Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Delete Campaign',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Are you sure you want to delete this campaign? This action cannot be undone.',
                              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.of(dialogCtx).pop(false),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.of(dialogCtx).pop(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      EasyLoading.show(status: 'Deleting campaign...');
                      final prefs = SharedPreferenceHelper();
                      final token = await prefs.getAccessToken();
                      final networkCaller = NetworkCaller();
                      var res = await networkCaller.deleteRequest(
                        Urls.deleteCampaign('$campaignId'),
                        token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
                      );
                      if (!res.isSuccess && res.statusCode == 404) {
                        res = await networkCaller.deleteRequest(
                          '${Urls.baseUrl}/campaigns/$campaignId',
                          token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
                        );
                      }
                      EasyLoading.dismiss();
                      if (res.isSuccess) {
                        EasyLoading.showSuccess('Campaign deleted successfully');
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      } else {
                        EasyLoading.showError(res.errorMessage);
                      }
                    } catch (e) {
                      EasyLoading.dismiss();
                      EasyLoading.showError(e.toString());
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18.sp, color: AppColors.black09090B),
                      SizedBox(width: 8.w),
                      Text('Edit Campaign', style: TextStyle(fontSize: 13.sp)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18.sp, color: Colors.red),
                      SizedBox(width: 8.w),
                      Text('Delete Campaign', style: TextStyle(fontSize: 13.sp, color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            TabBar(
              indicatorColor: AppColors.primaryButtonColor,
              labelColor: AppColors.primaryButtonColor,
              unselectedLabelColor: AppColors.appBarTitleColor.withValues(alpha: 0.5),
              tabs: [
                Tab(text: 'Stats'),
                Tab(text: 'Social Feed'),
                Tab(text: 'Notices'),
              ],
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: TabBarView(
                children: [
                  StatsTabWidget(campaignId: campaignId),
                  SocialFeedTabWidget(campaignId: campaignId),
                  NoticesTabWidget(campaignId: campaignId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

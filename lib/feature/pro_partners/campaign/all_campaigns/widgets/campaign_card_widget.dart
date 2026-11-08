import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';

import '../../campaign_overview/screen/campaign_overview_screen.dart';
import '../controller/all_campaigns_controller.dart';
import '../model/campaign_model.dart';
import 'campaign_media_preview_widget.dart';

class ProPartnersCampaignCardWidget extends StatelessWidget {
  final CampaignModel campaign;

  const ProPartnersCampaignCardWidget({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProPartnersAllCampaignsController>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.sectionBorderColor),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CampaignOverviewScreen(
                    title: campaign.title,
                    campaignId: campaign.id,
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  CampaignMediaPreviewWidget(
                    url: campaign.imageOrVideoLink,
                    size: 54,
                    borderRadius: 10,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.appBarTitleColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: _statusBg(campaign.status),
                                borderRadius: BorderRadius.circular(50.r),
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                campaign.status,
                                style: TextStyle(
                                  color: _statusColor(campaign.status),
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Opacity(
                                opacity: 0.5,
                                child: Text(
                                  '${campaign.clicks} Clicks • TZS ${campaign.spent.toStringAsFixed(0)} spent',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.appBarTitleColor,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (campaign.companyLogo.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: Image.network(
                            campaign.companyLogo,
                            width: 28.w,
                            height: 28.w,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.business,
                              size: 24.sp,
                              color: AppColors.primaryButtonColor,
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.business,
                          size: 24.sp,
                          color: AppColors.primaryButtonColor,
                        ),
                      SizedBox(height: 4.h),
                      Text(
                        campaign.companyName.isNotEmpty
                            ? campaign.companyName
                            : 'Partner',
                        style: TextStyle(
                          color: AppColors.black09090B,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 20.sp,
                      color: AppColors.appBarTitleColor.withValues(alpha: 0.6),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        controller.goToUpdateCampaign(campaign);
                      } else if (value == 'delete') {
                        controller.confirmAndDeleteCampaign(context, campaign);
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
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Edit Campaign',
                    onPressed: () => controller.goToUpdateCampaign(campaign),
                    color: AppColors.whiteSmokeF4F4F5,
                    textColor: AppColors.black09090B,
                    height: 36.h,
                    radius: 8.r,
                    vertical: 0,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomButton(
                    text: campaign.status.toLowerCase() == 'active'
                        ? 'Pause Campaign'
                        : 'Activate Campaign',
                    onPressed: () => controller.updateCampaignStatus(campaign),
                    color: AppColors.primaryButtonColor,
                    textColor: Colors.white,
                    height: 36.h,
                    radius: 8.r,
                    vertical: 0,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.checkBoxActiveColor;
      case 'paused':
        return AppColors.orangeF59E0B;
      default:
        return AppColors.appBarTitleColor.withValues(alpha: 0.5);
    }
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.createTaskButtonColorHomePage;
      case 'paused':
        return AppColors.seaShellFFF7ED;
      default:
        return Colors.black.withValues(alpha: 0.04);
    }
  }
}

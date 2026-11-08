import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import '../../../../../core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import '../controller/student_campus_campaign_controller.dart';
import '../widgets/student_campaign_card.dart';

class StudentCampusCampaignScreen extends StatelessWidget {
  const StudentCampusCampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentCampusCampaignController());

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 12.height),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with search icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Campaign',
                style: appTextStyleHeading1(
                  fontSize: 20.fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black09090B,
                ),
              ),
              Obx(
                () => IconButton(
                  onPressed: controller.toggleSearch,
                  icon: Icon(
                    controller.isSearchOpen.value
                        ? Icons.close_rounded
                        : Icons.search_rounded,
                    color: AppColors.black09090B,
                    size: 24.fontSize,
                  ),
                  tooltip: controller.isSearchOpen.value
                      ? 'Close Search'
                      : 'Search Campaigns',
                  splashRadius: 20.radius,
                ),
              ),
            ],
          ),

          // Search input field
          Obx(() {
            if (!controller.isSearchOpen.value &&
                controller.searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(top: 10.height, bottom: 4.height),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12.radius),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: controller.searchController,
                  focusNode: controller.searchFocusNode,
                  onChanged: controller.onSearchChanged,
                  style: getTextStyle(
                    fontSize: 14.fontSize,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search campaigns...',
                    hintStyle: getTextStyle(
                      fontSize: 14.fontSize,
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.grey.shade600,
                      size: 20.fontSize,
                    ),
                    suffixIcon: controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: Colors.grey.shade600,
                              size: 18.fontSize,
                            ),
                            onPressed: controller.clearSearch,
                            splashRadius: 16.radius,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.width,
                      vertical: 12.height,
                    ),
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: 16.height),

          // Campaigns List
          Obx(() {
            if (controller.isLoading.value) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.height),
                child: ShimmerLoading.list(
                  itemCount: 3,
                  height: 120.height,
                  borderRadius: 16.radius,
                ),
              );
            }

            if (controller.campaigns.isEmpty) {
              if (controller.searchQuery.value.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 36.height),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48.fontSize,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 12.height),
                        Text(
                          'No campaigns found for "${controller.searchQuery.value}"',
                          style: getTextStyle(
                            fontSize: 15.fontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.height),
                        TextButton(
                          onPressed: controller.clearSearch,
                          child: const Text('Clear Search'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const Center(child: Text('No campaigns found.'));
            }

            return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount:
                  controller.campaigns.length +
                  (controller.isLoadMore.value ? 1 : 0),
              separatorBuilder: (_, __) => SizedBox(height: 12.height),
              itemBuilder: (context, index) {
                if (index == controller.campaigns.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.height),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                return StudentCampaignCard(
                  campaign: controller.campaigns[index],
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

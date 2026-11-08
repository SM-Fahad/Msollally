import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/device/device_utility.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';
import '../controller/student_emergency_contact_controller.dart';
import '../widgets/student_emergency_tab.dart';

class StudentEmergencyContact extends StatelessWidget {
  const StudentEmergencyContact({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(StudentEmergencyContactController());
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(
              leadingIcon: const Icon(Icons.arrow_back),
              onLeadingTap: () {
                Get.back();
              },
              title: "Emergency Support",
            ),

            studentEmergencyTab(controller),
            SizedBox(height: 8.height),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0.width),
              child: Text(
                "Help & Rescue Resources",
                style: appTextStyleHeading1(
                  fontSize: 12.fontSize,
                  letterSpacing: 0.fontSize,
                ),
              ),
            ),

            SizedBox(height: 12.height),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return ShimmerLoading.list(
                    itemCount: 3,
                    height: 160.height,
                    padding: 20.width,
                  );
                }

                if (controller.error.value.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.width),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 48.radius),
                          SizedBox(height: 16.height),
                          Text(
                            controller.error.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14.fontSize, color: Colors.grey.shade700),
                          ),
                          SizedBox(height: 16.height),
                          ElevatedButton.icon(
                            onPressed: () {
                              controller.fetchResourcesForTab(controller.selectedTab.value);
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.resourcesList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey.shade400, size: 48.radius),
                        SizedBox(height: 16.height),
                        Text(
                          "No resources found for this category.",
                          style: TextStyle(fontSize: 14.fontSize, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 10.height),
                  itemCount: controller.resourcesList.length,
                  itemBuilder: (context, index) {
                    final resource = controller.resourcesList[index];
                    final hasImageUrl = resource.imageUrl != null && resource.imageUrl!.isNotEmpty;
                    final hasVideoUrl = resource.videoUrl != null && resource.videoUrl!.isNotEmpty;

                    return Card(
                      margin: EdgeInsets.only(bottom: 16.height),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.radius),
                      ),
                      shadowColor: Colors.black12,
                      child: InkWell(
                        onTap: () {
                          if (hasVideoUrl) {
                            AppDeviceUtility.launchUrl(resource.videoUrl!);
                          }
                        },
                        borderRadius: BorderRadius.circular(12.radius),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasImageUrl)
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(12.radius)),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      resource.imageUrl!,
                                      height: 180.height,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 180.height,
                                          color: Colors.grey.shade100,
                                          child: Center(
                                            child: Icon(Icons.broken_image, size: 48.radius, color: Colors.grey.shade400),
                                          ),
                                        );
                                      },
                                    ),
                                    if (hasVideoUrl)
                                      Positioned.fill(
                                        child: Container(
                                          color: Colors.black26,
                                          child: Center(
                                            child: Container(
                                              padding: EdgeInsets.all(12.radius),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white, width: 2),
                                              ),
                                              child: Icon(
                                                Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: 32.radius,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            else if (hasVideoUrl) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(12.radius)),
                                child: Container(
                                  height: 180.height,
                                  color: Colors.black87,
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.all(12.radius),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 32.radius,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            Padding(
                              padding: EdgeInsets.all(16.width),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.width, vertical: 4.height),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryButtonColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20.radius),
                                    ),
                                    child: Text(
                                      resource.category.toUpperCase(),
                                      style: TextStyle(
                                        color: AppColors.primaryButtonColor,
                                        fontSize: 10.fontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.height),
                                  Text(
                                    resource.resourceName,
                                    style: appTextStyleHeading1(
                                      fontSize: 16.fontSize,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  if (resource.summary.isNotEmpty) ...[
                                    SizedBox(height: 6.height),
                                    Text(
                                      resource.summary,
                                      style: appTextStyleHeading2(
                                        fontSize: 13.fontSize,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                  if (resource.description.isNotEmpty) ...[
                                    SizedBox(height: 8.height),
                                    Text(
                                      resource.description,
                                      style: TextStyle(
                                        fontSize: 12.fontSize,
                                        color: Colors.grey.shade600,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                  if (hasVideoUrl) ...[
                                    SizedBox(height: 12.height),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        AppDeviceUtility.launchUrl(resource.videoUrl!);
                                      },
                                      icon: Icon(Icons.video_library, size: 16.radius),
                                      label: Text(
                                        "Watch Resource Video",
                                        style: TextStyle(fontSize: 12.fontSize),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primaryButtonColor,
                                        side: const BorderSide(color: AppColors.primaryButtonColor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.radius),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

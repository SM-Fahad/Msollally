import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';
import '../../../../core/const/icons_path.dart' show IconsPath;
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/student_profile_controller.dart';
import '../widgets/student_profile_about_item.dart';
import '../widgets/student_profile_cover_and_profile_pic.dart';
import '../widgets/student_profile_post_item.dart';
import '../widgets/student_profile_friends_item.dart';
import '../widgets/student_profile_gigs_items.dart';
import '../widgets/student_profile_shimmer.dart';
import '../widgets/student_profile_header.dart';
import '../widgets/student_profile_tabs.dart';

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentProfileController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leadingIcon: SvgPicture.asset(
                IconsPath.arrowLeftIcon,
                height: 24.height,
                width: 24.width,
              ),
              onLeadingTap: () => Get.back(),
              title: 'Profile',
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingProfile.value) {
                  return StudentProfileShimmer();
                }
                return RefreshIndicator(
                  onRefresh: controller.refreshAll,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StudentProfileCoverAndProfilePic(),
                        SizedBox(height: 32.height),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.width),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StudentProfileHeader(controller: controller),
                              SizedBox(height: 16.height),
                              StudentProfileTabs(controller: controller),
                            ],
                          ),
                        ),
                        Container(
                          height: 1,
                          width: double.infinity,
                          color: AppColors.textfieldBorderColor,
                        ),
                        SizedBox(height: 13.height),
                        Obx(() => _buildTabContent(controller)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(StudentProfileController controller) {
    switch (controller.selectedTab.value) {
      case 0:
        return StudentProfileAboutItem(controller: controller);
      case 1:
        return StudentProfilePostsItem(controller: controller);
      case 2:
        return StudentProfileFriendsItems(controller: controller);
      case 3:
        return StudentProfileGigsItems(controller: controller);
      default:
        return StudentProfileAboutItem(controller: controller);
    }
  }
}

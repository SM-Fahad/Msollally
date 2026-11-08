import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/campus/campus_student_public_profile/widgets/student_public_profile_gigs_items.dart';
import 'package:msollaally/feature/student/campus/chat/service/chat_badge_service.dart';
import 'package:msollaally/feature/student/campus/chat/screen/chat_screen.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';

import '../../../../../core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/routes/app_route.dart';
import '../controller/student_campus_student_public_profile_controller.dart';
import '../widgets/student_public_profile_about_item.dart';
import '../widgets/student_public_profile_cover_and_profile_pic.dart';
import '../widgets/student_public_profile_friends_item.dart';
import '../widgets/student_public_profile_post_item.dart';

class StudentCampusStudentPublicProfilePage extends StatelessWidget {
  const StudentCampusStudentPublicProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    StudentPublicProfileController controller = Get.put(
      StudentPublicProfileController(),
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(
                leadingIcon: SvgPicture.asset(
                  IconsPath.arrowLeftIcon,
                  height: 24.height,
                  width: 24.width,
                ),
                onLeadingTap: () {
                  Get.back();
                },
                title: "Profile",
              ),
              StudentPublicProfileCoverAndProfilePic(),

              SizedBox(height: 32.height),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.width),
                child: Obx(() {
                  if (controller.isLoadingProfile.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.profileName.value.isEmpty
                            ? "Unknown"
                            : controller.profileName.value,
                        style: appTextStyleHeading1(
                          fontSize: 20.fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10.height),

                      Row(
                        children: [
                          Text(
                            controller.friendsCount.value.toString(),
                            style: appTextStyleHeading1(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0.fontSize,
                            ),
                          ),
                          Text(
                            " Friends",
                            style: appTextStyleHeading2(letterSpacing: 0.0.fontSize),
                          ),
                        ],
                      ),

                      if (controller.profileBio.value.isNotEmpty) ...[
                        SizedBox(height: 8.height),
                        Text(
                          controller.profileBio.value,
                          style: appTextStyleHeading2(letterSpacing: 0.fontSize),
                        ),
                      ],

                      SizedBox(height: 16.height),

                      // Tabs Row
                      Padding(
                        padding: EdgeInsets.only(right: 16.width),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(() {
                              return Row(
                                children: List.generate(
                                  controller.tabs.length,
                                  (index) {
                                    bool isSelected =
                                        controller.selectedTab.value == index;
                                    return GestureDetector(
                                      onTap: () =>
                                          controller.selectedTab.value = index,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 10.width),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              controller.tabs[index],
                                              style: appTextStyleHeading1(
                                                color: isSelected
                                                    ? Colors.blue
                                                    : AppColors.appBarTitleColor.withValues(alpha: .50),
                                              ),
                                            ),
                                            SizedBox(height: 8.height),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.blue
                                                    : Colors.transparent,
                                              ),
                                              height: 3.height,
                                              width: 65.width,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),

                            // Message icon with reactive badge
                            InkWell(
                              onTap: () {
                                if (controller.userId.value > 0) {
                                  if (UserRoleService.isTeacher) {
                                    Get.toNamed(
                                      AppRoute.teacherChatScreen,
                                      arguments: {
                                        'reciverId': controller.userId.value.toString(),
                                        'receiverId': controller.userId.value,
                                        'receiverIds': [controller.userId.value],
                                        'name': controller.profileName.value,
                                        'chatName': controller.profileName.value,
                                        'isGroup': false,
                                      },
                                    );
                                  } else {
                                    Get.to(
                                      () => CampusChatScreen(),
                                      arguments: {
                                        'receiverId': controller.userId.value,
                                        'name': controller.profileName.value,
                                        'isGroup': false,
                                      },
                                    );
                                  }
                                }
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  SvgPicture.asset(
                                    IconsPath.messageIcon,
                                    height: 28.height,
                                    width: 28.width,
                                  ),
                                  Obx(() {
                                    final count =
                                        ChatBadgeService.unreadCount.value;
                                    if (count == 0) {
                                      return const SizedBox.shrink();
                                    }
                                    return Positioned(
                                      right: -15.width,
                                      bottom: 20,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.width,
                                          vertical: 2.height,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10.radius,
                                          ),
                                          color: AppColors.uiDangerColor,
                                        ),
                                        constraints: BoxConstraints(
                                          minWidth: 20.width,
                                          minHeight: 15.height,
                                        ),
                                        child: Center(
                                          child: Text(
                                            count > 99 ? '99+' : '$count',
                                            style: appTextStyleHeading1(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10.fontSize,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
              // const Divider(),
              Container(
                height: 1,
                width: double.infinity,
                color: AppColors.textfieldBorderColor,
              ),
              SizedBox(height: 13.height),

              // Tab Content
              Obx(() {
                if (controller.selectedTab.value == 0) {
                  return StudentPublicProfileAboutItem(controller: controller);
                } else if (controller.selectedTab.value == 1) {
                  return StudentPublicProfilePostsItem();
                } else if (controller.selectedTab.value == 2) {
                  return StudentPublicProfileFriendsItems(
                    controller: controller,
                  );
                } else {
                  return StudentPublicProfileGigsItems();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}

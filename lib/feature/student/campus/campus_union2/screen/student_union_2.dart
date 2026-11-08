import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/feature/student/campus/campus_union/controller/campus_union_controller.dart';
import 'package:msollaally/feature/student/campus/campus_union/widgets/custom_post_content.dart';
import 'package:msollaally/feature/student/campus/campus_home/custom_wall_text_field.dart';
import 'package:msollaally/feature/student/campus/create_event/screen/create_event.dart';
import 'package:msollaally/feature/student/campus/create_notice/screen/notice_screen.dart';
import 'package:msollaally/feature/student/campus/create_poll/screen/poll_screen.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';

class StudentUnion2 extends StatelessWidget {
  const StudentUnion2({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(CampusUnionController());
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomAppBar(
                leadingIcon: Icon(Icons.arrow_back),
                onLeadingTap: () {
                  Get.back();
                },
                title: "",
                actionWidget: Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 7.width),
                    Icon(Icons.more_vert),
                  ],
                ),
              ),
              Image.asset(ImagesPath.chessClubImage),

              Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 20.width,
                  vertical: 10.height,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Chess Club",
                      style: appTextStyleHeading1(
                        fontSize: 20.fontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5.fontSize,
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.public, size: 13.fontSize, color: Colors.grey),
                        SizedBox(width: 5.width),
                        Text(
                          "Public union • 120 members",
                          style: appTextStyleHeading1(
                            fontSize: 15.fontSize,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.height),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            color: AppColors.appBarTitleColor.withValues(alpha: .36),
                            vertical: 8.height,
                            text: "Joined",
                            onPressed: () {},
                          ),
                        ),

                        SizedBox(width: 10.width),

                        Expanded(
                          child: CustomButton(
                            vertical: 8.height,
                            text: "Invite",
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.height),
              CustomWallTextField(
                profileImage: ImagesPath.profilePNG,
                controller: controller.wallTextController,
              ),

              SizedBox(height: 10.height),

              Container(
                padding: EdgeInsets.symmetric(vertical: 8.height, horizontal: 20.width),

                decoration: BoxDecoration(color: Colors.grey.shade200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.height,
                        horizontal: 12.width,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.black000000.withValues(alpha: .12),
                        ),
                        borderRadius: BorderRadius.circular(50.radius),
                        color: AppColors.black000000.withValues(alpha: .04),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event,
                            color: AppColors.appBarTitleColor.withValues(alpha: .7),
                          ),
                          SizedBox(width: 5.width),
                          InkWell(
                            onTap: () {
                              Get.to(CreateEventStudentScreen());
                            },
                            child: Text(
                              "Event",
                              style: appTextStyleHeading1(
                                fontSize: 12.fontSize,
                                letterSpacing: 0.fontSize,
                                color: AppColors.appBarTitleColor.withValues(alpha: .7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.height,
                        horizontal: 12.width,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.black000000.withValues(alpha: .12),
                        ),

                        borderRadius: BorderRadius.circular(50.radius),
                        color: AppColors.black000000.withValues(alpha: .04),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.poll,
                            color: AppColors.appBarTitleColor.withValues(alpha: .7),
                          ),
                          SizedBox(width: 5.width),
                          InkWell(
                            onTap: () {
                              Get.to(CreatePollPage());
                            },
                            child: Text(
                              "poll",
                              style: appTextStyleHeading1(
                                fontSize: 12.fontSize,
                                letterSpacing: 0.fontSize,
                                color: AppColors.appBarTitleColor.withValues(alpha: .7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.height,
                        horizontal: 12.width,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.black000000.withValues(alpha: .12),
                        ),

                        borderRadius: BorderRadius.circular(50.radius),
                        color: AppColors.black000000.withValues(alpha: .04),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.announcement,
                            color: AppColors.appBarTitleColor.withValues(alpha: .7),
                          ),
                          SizedBox(width: 5.width),
                          InkWell(
                            onTap: () {
                              Get.to(CreateNoticeScreen());
                            },
                            child: Text(
                              "Announcement",
                              style: appTextStyleHeading1(
                                fontSize: 12.fontSize,
                                letterSpacing: 0.fontSize,
                                color: AppColors.appBarTitleColor.withValues(alpha: .7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Divider(color: Colors.grey.shade100, thickness: 15),
              Obx(() {
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: controller.posts.length,
                  itemBuilder: (_, index) {
                    final post = controller.posts[index];
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.width,
                            vertical: 10.height,
                          ),
                          child: PostContent(
                            post: post,
                            onLike: () => controller.toggleLike(post),
                            onComment: () =>
                                debugPrint("Comment tapped on ${post.id}"),
                            onShare: () =>
                                debugPrint("Share tapped on ${post.id}"),
                            onEdit: (content) =>
                                controller.updatePost(post.id, content),
                            onDelete: () => controller.deletePost(post.id),
                          ),
                        ),

                        Divider(color: Colors.grey.shade200, thickness: 15),
                      ],
                    );
                  },
                );
              }),
              SizedBox(height: 20.height),

              SizedBox(height: 35.height),
            ],
          ),
        ),
      ),
    );
  }
}

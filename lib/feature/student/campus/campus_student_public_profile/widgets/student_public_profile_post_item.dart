import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart'
    show appTextStyleHeading2, appTextStyleHeading1;

import '../../../../../core/const/icons_path.dart';
import '../../../../../core/common/widgets/fullscreen_image_view.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/comment_bottom_sheet.dart';
import '../controller/student_campus_student_public_profile_controller.dart';
import 'package:get/get.dart';

class StudentPublicProfilePostsItem extends StatelessWidget {
  const StudentPublicProfilePostsItem({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentPublicProfileController>();

    return Obx(() {
      if (controller.posts.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.height),
            child: Text(
              "No posts found",
              style: appTextStyleHeading2(fontSize: 16.fontSize),
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.posts.length,
        itemBuilder: (context, index) {
          final post = controller.posts[index];
          final authorName = post.author.username.isNotEmpty
              ? post.author.username
              : 'Unknown';
          final authorPic = post.author.profilePicture;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 10.height),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (authorPic != null &&
                                  authorPic.startsWith('http')) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => FullscreenImageView(
                                      imageUrl: authorPic,
                                      isNetworkImage: true,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100.radius),
                              child:
                                  (authorPic != null &&
                                      authorPic.startsWith('http'))
                                  ? Image.network(
                                      authorPic,
                                      fit: BoxFit.cover,
                                      height: 40.height,
                                      width: 40.width,
                                      errorBuilder: (_, __, ___) =>
                                          _defaultAvatar(),
                                    )
                                  : _defaultAvatar(),
                            ),
                          ),
                          SizedBox(width: 12.width),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        authorName,
                                        style: appTextStyleHeading1(
                                          fontSize: 16.fontSize,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  post.createdAt.toLocal().toString().split(
                                    ' ',
                                  )[0],
                                  style: appTextStyleHeading2(fontSize: 12.fontSize),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.more_vert, size: 24),
                  ],
                ),
                SizedBox(height: 12.height),

                if (post.content.isNotEmpty)
                  Text(
                    post.content,
                    style: appTextStyleHeading1(
                      fontWeight: FontWeight.w400,
                      color: AppColors.appBarTitleColor,
                    ),
                  ),

                if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty) ...[
                  SizedBox(height: 12.height),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => FullscreenImageView(
                            imageUrl: post.mediaUrl!,
                            isNetworkImage: true,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.radius),
                      child: Image.network(
                        post.mediaUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 12.height),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.likeCount.toString(),
                          style: appTextStyleHeading2(fontSize: 12.fontSize),
                        ),
                        Text(
                          " likes",
                          style: appTextStyleHeading2(fontSize: 12.fontSize),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          post.commentCount.toString(),
                          style: appTextStyleHeading2(fontSize: 12.fontSize),
                        ),
                        Text(
                          " Comments",
                          style: appTextStyleHeading2(fontSize: 12.fontSize),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 18.height),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => controller.toggleLike(post),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.height, horizontal: 4.width),
                        child: Row(
                          children: [
                            Image.asset(
                              IconsPath.reactIcon,
                              height: 20.height,
                              width: 20.width,
                              color: post.isLiked ? Colors.blue : AppColors.appBarTitleColor,
                            ),
                            SizedBox(width: 6.width),
                            Text(
                              "Like",
                              style: appTextStyleHeading2(
                                color: post.isLiked
                                    ? Colors.blue
                                    : AppColors.appBarTitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => showCommentSheet(context, post.id),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.height, horizontal: 4.width),
                        child: Row(
                          children: [
                            Image.asset(
                              IconsPath.commentIcon,
                              height: 20.height,
                              width: 20.width,
                            ),
                            SizedBox(width: 6.width),
                            Text(
                              "Comment",
                              style: appTextStyleHeading2(color: AppColors.appBarTitleColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => controller.sharePost(post),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.height, horizontal: 4.width),
                        child: Row(
                          children: [
                            Image.asset(
                              IconsPath.shareIcon,
                              height: 20.height,
                              width: 20.width,
                            ),
                            SizedBox(width: 6.width),
                            Text(
                              "Share",
                              style: appTextStyleHeading2(color: AppColors.appBarTitleColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.height),
                const Divider(),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _defaultAvatar() {
    return Container(
      height: 40.height,
      width: 40.width,
      color: Colors.grey[200],
      child: const Icon(Icons.person, color: Colors.grey),
    );
  }
}

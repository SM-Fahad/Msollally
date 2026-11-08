import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/comment_bottom_sheet.dart';
import 'package:msollaally/feature/student/campus/campus_home/screen/student_edit_post_screen.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';
import 'package:msollaally/feature/student/profile/model/student_profile_post_model.dart';
import 'package:msollaally/routes/app_route.dart';
import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/const/icons_path.dart';
import '../../../../core/const/images_path.dart';
import '../../../../core/common/widgets/post_action_button.dart';
import '../../../../core/common/widgets/fullscreen_image_view.dart';

class StudentProfilePostCard extends StatelessWidget {
  final StudentProfilePostModel post;
  final StudentProfileController controller;

  const StudentProfilePostCard({
    super.key,
    required this.post,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        SizedBox(height: 12.height),
        if (post.content.isNotEmpty)
          Text(
            post.content,
            style: appTextStyleHeading1(
              fontWeight: FontWeight.w400,
              color: AppColors.appBarTitleColor,
            ),
          ),
        if (post.imageUrl != null &&
            post.imageUrl!.isNotEmpty &&
            !post.imageUrl!.contains('example.com')) ...[
          SizedBox(height: 12.height),
          GestureDetector(
            onTap: () {
              Get.to(
                () => FullscreenImageView(
                  imageUrl: post.imageUrl!,
                  isNetworkImage: true,
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.radius),
              child: Image.network(
                post.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
        SizedBox(height: 12.height),
        _buildStats(),
        SizedBox(height: 18.height),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PostActionButton(
              iconPath: IconsPath.reactIcon,
              label: "Like",
              isActive: post.isLiked,
              onTap: () => controller.toggleLike(post),
            ),
            PostActionButton(
              iconPath: IconsPath.commentIcon,
              label: "Comment",
              onTap: () => showCommentSheet(context, post.id),
            ),
            const PostActionButton(
              iconPath: IconsPath.shareIcon,
              label: "Share",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => Get.toNamed(AppRoute.studentProfilePage),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (post.authorAvatarUrl?.isNotEmpty == true) {
                    Get.to(
                      () => FullscreenImageView(
                        imageUrl: post.authorAvatarUrl!,
                        isNetworkImage: true,
                      ),
                    );
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.radius),
                  child: (post.authorAvatarUrl?.isNotEmpty == true)
                      ? Image.network(
                          post.authorAvatarUrl!,
                          fit: BoxFit.cover,
                          height: 52.height,
                          width: 52.width,
                          errorBuilder: (_, __, ___) => Image.asset(
                            ImagesPath.profilePNG,
                            fit: BoxFit.cover,
                            height: 52.height,
                            width: 52.width,
                          ),
                        )
                      : Image.asset(
                          ImagesPath.profilePNG,
                          fit: BoxFit.cover,
                          height: 52.height,
                          width: 52.width,
                        ),
                ),
              ),
              SizedBox(width: 12.width),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.authorName.isNotEmpty ? post.authorName : 'Unknown',
                    style: appTextStyleHeading1(
                      fontSize: 20.fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    post.createdAt ?? 'Just now',
                    style: appTextStyleHeading2(fontSize: 15.fontSize),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildPopupMenu(context),
      ],
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        final campusController = Get.find<StudentCampusController>();
        if (value == 'edit') {
          _showEditDialog(context, campusController);
        } else if (value == 'delete') {
          _showDeleteConfirmDialog(campusController);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: const Icon(Icons.more_vert, size: 24),
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${post.likeCount} likes",
          style: appTextStyleHeading2(fontSize: 12.fontSize),
        ),
        Row(
          children: [
            Text(
              "${post.commentCount} Comments",
              style: appTextStyleHeading2(fontSize: 12.fontSize),
            ),
            SizedBox(width: 12.width),
            Text(
              "${post.shareCount} Shares",
              style: appTextStyleHeading2(fontSize: 12.fontSize),
            ),
          ],
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog(StudentCampusController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deletePost(post.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    StudentCampusController controller,
  ) {
    Get.to(() => StudentEditPostScreen(
      postId: post.id,
      initialContent: post.content,
      initialMediaUrl: post.imageUrl,
      authorName: post.authorName,
      authorAvatarUrl: post.authorAvatarUrl,
    ));
  }
}

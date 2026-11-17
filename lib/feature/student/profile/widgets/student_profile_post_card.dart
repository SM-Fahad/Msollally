import 'package:flutter/material.dart';
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
        if (post.moderationStatus != 'APPROVED') ...[
          SizedBox(height: 8.height),
          _buildModerationBanner(),
        ],
        SizedBox(height: 12.height),
        if (post.content.isNotEmpty)
          Text(
            post.content,
            style: appTextStyleHeading1(
              fontWeight: FontWeight.w400,
              color: AppColors.appBarTitleColor,
            ),
          ),
        if (post.effectiveMediaUrls.isNotEmpty) ...[
          SizedBox(height: 12.height),
          _buildMediaGallery(post.effectiveMediaUrls),
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

  Widget _buildModerationBanner() {
    final isRejected =
        post.moderationStatus == 'REJECTED' ||
        post.moderationStatus == 'FLAGGED';
    final color = isRejected ? Colors.red.shade700 : Colors.orange.shade800;
    final bgColor = isRejected ? Colors.red.shade50 : Colors.orange.shade50;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.width, vertical: 6.height),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.radius),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 16.fontSize, color: color),
          SizedBox(width: 6.width),
          Expanded(
            child: Text(
              post.moderationReason != null && post.moderationReason!.isNotEmpty
                  ? '${post.moderationStatus}: ${post.moderationReason}'
                  : 'Moderation status: ${post.moderationStatus}',
              style: TextStyle(
                fontSize: 12.fontSize,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGallery(List<String> urls) {
    if (urls.length == 1) {
      final url = urls.first;
      return GestureDetector(
        onTap: () {
          Get.to(
            () => FullscreenImageView(imageUrl: url, isNetworkImage: true),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.radius),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.width),
        itemBuilder: (_, idx) {
          final url = urls[idx];
          return GestureDetector(
            onTap: () {
              Get.to(
                () => FullscreenImageView(imageUrl: url, isNetworkImage: true),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.radius),
              child: Image.network(
                url,
                width: 240.width,
                height: 220.height,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    StudentCampusController controller,
  ) {
    Get.to(
      () => StudentEditPostScreen(
        postId: post.id,
        initialContent: post.content,
        initialMediaUrl: post.imageUrl,
        initialMediaUrls: post.effectiveMediaUrls,
        initialIsAnnouncement: post.isAnnouncement,
        authorName: post.authorName,
        authorAvatarUrl: post.authorAvatarUrl,
      ),
    );
  }
}

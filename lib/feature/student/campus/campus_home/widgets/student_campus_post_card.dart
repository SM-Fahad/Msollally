import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/post_model.dart';
import 'package:msollaally/routes/app_route.dart';
import '../../../../../core/common/styles/global_text_style.dart';
import '../../../../../core/const/icons_path.dart';
import '../../../../../core/common/widgets/post_action_button.dart';
import '../../../../../core/common/widgets/fullscreen_image_view.dart';
import 'package:msollaally/core/utils/time_formatter.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/wall/wall_video_player.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/comment_bottom_sheet.dart';
import 'package:msollaally/feature/student/campus/campus_home/screen/student_edit_post_screen.dart';

class StudentCampusPostCard extends StatelessWidget {
  final PostModel post;
  final StudentCampusController controller;

  const StudentCampusPostCard({
    super.key,
    required this.post,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(thickness: 10, color: Colors.grey.shade100),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.width,
            vertical: 16.height,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 12.height),
              _ExpandablePostText(
                text: post.content,
                style: appTextStyleHeading1(
                  fontWeight: FontWeight.w400,
                  color: AppColors.appBarTitleColor,
                ),
              ),
              if (post.mediaUrl != null &&
                  post.mediaUrl!.isNotEmpty &&
                  !post.mediaUrl!.contains('example.com')) ...[
                SizedBox(height: 10.height),
                if (_isVideo(post.mediaUrl!))
                  WallVideoPlayer(videoUrl: post.mediaUrl!)
                else
                  GestureDetector(
                    onTap: () {
                      Get.to(
                        () => FullscreenImageView(
                          imageUrl: post.mediaUrl!,
                          isNetworkImage: true,
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.radius),
                      child: Image.network(
                        post.mediaUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(),
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
                  PostActionButton(
                    iconPath: IconsPath.shareIcon,
                    label: "Share",
                    onTap: () => controller.sharePost(post),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            if (Get.isRegistered<StudentProfileController>()) {
              final profileController = Get.find<StudentProfileController>();
              final myId = profileController.userId.value;
              if (post.author.id == myId) {
                Get.toNamed(AppRoute.studentProfilePage);
              } else {
                Get.toNamed(
                  AppRoute.studentCampusPublicProfile,
                  arguments: post.author.id,
                );
              }
            }
          },
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (post.author.profilePicture?.isNotEmpty == true) {
                    Get.to(
                      () => FullscreenImageView(
                        imageUrl: post.author.profilePicture!,
                        isNetworkImage: true,
                      ),
                    );
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.radius),
                  child: (post.author.profilePicture?.isNotEmpty == true)
                      ? Image.network(
                          post.author.profilePicture!,
                          fit: BoxFit.cover,
                          height: 52.height,
                          width: 52.width,
                          errorBuilder: (_, __, ___) => _buildProfileFallback(),
                        )
                      : _buildProfileFallback(),
                ),
              ),
              SizedBox(width: 12.width),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        post.author.fullName,
                        style: appTextStyleHeading1(
                          fontSize: 16.fontSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5.fontSize,
                        ),
                      ),
                      SizedBox(width: 4.width),
                      Text(
                        "@${post.author.username}",
                        style: appTextStyleHeading2(
                          fontSize: 13.fontSize,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.height),
                  Row(
                    children: [
                      Text(
                        post.author.role,
                        style: appTextStyleHeading2(
                          fontSize: 13.fontSize,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        " • ${TimeFormatter.timeAgo(post.createdAt)}",
                        style: appTextStyleHeading2(
                          fontSize: 13.fontSize,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (post.postableType == 'Union')
                        Container(
                          margin: EdgeInsets.only(left: 8.width),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.width,
                            vertical: 2.height,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(4.radius),
                            border: Border.all(color: Colors.blueAccent),
                          ),
                          child: Text(
                            "Union",
                            style: appTextStyleHeading2(
                              fontSize: 10.fontSize,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                    ],
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

  Widget _buildProfileFallback() {
    return Container(
      height: 52.height,
      width: 52.width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, color: Colors.grey.shade400, size: 32),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return Obx(() {
      if (!Get.isRegistered<StudentProfileController>()) {
        return const SizedBox();
      }
      final profileController = Get.find<StudentProfileController>();
      if (post.author.id != profileController.userId.value) {
        return const SizedBox();
      }

      return PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _showEditDialog(context);
          } else if (value == 'delete') {
            _showDeleteConfirmDialog();
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
    });
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
            // SizedBox(width: 12.width),
            // Text(
            //   "0 Shares",
            //   style: appTextStyleHeading2(fontSize: 12.fontSize),
            // ),
          ],
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog() {
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

  void _showEditDialog(BuildContext context) {
    Get.to(
      () => StudentEditPostScreen(
        postId: post.id,
        initialContent: post.content,
        initialMediaUrl: post.mediaUrl,
        authorName: post.author.fullName.isNotEmpty
            ? post.author.fullName
            : post.author.username,
        authorAvatarUrl: post.author.profilePicture,
      ),
    );
  }

  bool _isVideo(String url) {
    final clean = url.split('?').first.toLowerCase();
    return clean.endsWith('.mp4') ||
        clean.endsWith('.mov') ||
        clean.endsWith('.m4v') ||
        clean.endsWith('.webm') ||
        clean.endsWith('.avi') ||
        clean.endsWith('.mkv');
  }
}

class _ExpandablePostText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _ExpandablePostText({required this.text, required this.style});

  @override
  State<_ExpandablePostText> createState() => _ExpandablePostTextState();
}

class _ExpandablePostTextState extends State<_ExpandablePostText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: widget.style);
        final tp = TextPainter(
          text: span,
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final bool isOverflowing = tp.didExceedMaxLines;

        if (!isOverflowing) {
          return Text(widget.text, style: widget.style);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                widget.text,
                maxLines: _isExpanded ? null : 1,
                overflow: _isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: widget.style,
              ),
            ),
            SizedBox(height: 4.height),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.height),
                child: Text(
                  _isExpanded ? 'Show less' : 'Show more',
                  style: getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryButtonColor,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
